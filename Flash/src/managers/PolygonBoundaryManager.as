package managers
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.overlays.Polygon;
	import com.google.maps.overlays.PolygonOptions;
	import com.google.maps.styles.FillStyle;
	import com.google.maps.styles.StrokeStyle;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import models.SuperObject;
	import models.Tower;
	import models.User;
	import models.map.TowerSaintPolygon;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	import mx.utils.ObjectUtil;
	
	import pl.bmnet.gpcas.geometry.Poly;
	import pl.bmnet.gpcas.geometry.PolyDefault;

	public class PolygonBoundaryManager
	{
		private var map:Map;								/* The map associated with the game */
		private var listOfGameObjects:ArrayCollection;		/* A list of game objects in the current view */
		private var user:User;								/* The user associated with this boundary */
		private var disjointPolygons:Dictionary;			/* A dictionary which holds a collection of disjoint polygons */
		private var firstDraw:Boolean;						/* First time the boundary is drawn */
		private var currentPolygons:ArrayCollection;		/* The current list of polygons */
		private var drawnPolygons:ArrayCollection; 			/* A list of drawn polygons */
		
		public function PolygonBoundaryManager(m:Map, arr:ArrayCollection, u:User)
		{
			this.map = m;
			this.listOfGameObjects = arr;
			this.user = u;
			
			// Disjoint polygons
			this.disjointPolygons = new Dictionary();
			this.firstDraw = true;								/* Set the state variable */
			this.drawnPolygons = new ArrayCollection();			/* A set of drawn polygons */
		}
		
		/* Initialize and draw the boundary */
		public function initDraw() : void {
			// Draw the current empire boundary
			var arrayOfPolygons:ArrayCollection =  fromLatLngToPoint(this.listOfGameObjects);
			_decomposeIntoDisjointPolygons(arrayOfPolygons);
			_draw(arrayOfPolygons);
			
		}
		
		/* 
		When the valid location changes(when an object is moving), the boundary changes
		*/
		private function onTowerValidLocationChange(e:PropertyChangeEvent):void {
			this.initDraw();
		}
		private function onTowerDragStart(e:PropertyChangeEvent):void {
			this.removeAndDraw(e.source as SuperObject);
		}
		private function onTowerDragEnd(e:PropertyChangeEvent):void {
			this.addAndDraw(e.source as SuperObject);
		}
		/* 
		Draw the Polygon
		*/
		private function _draw(arrayOfPolygons:ArrayCollection) : void {
			
			// Remove all of the polygons
			for(var i:int = 0; i < this.drawnPolygons.length; i++){
				var pol:Polygon = this.drawnPolygons[i] as Polygon;
				this.map.removeOverlay(pol);
			}
			this.drawnPolygons.removeAll();
			
		
			// Draw the dijsoint polygons
			for(var o:Object in this.disjointPolygons){
				var poly:TowerSaintPolygon = this.disjointPolygons[o] as TowerSaintPolygon;
				var tPolygon:Polygon = _drawPoly(poly);
				this.drawnPolygons.addItem(tPolygon);
			}
			this.currentPolygons = arrayOfPolygons;
		//	Alert.show("Length:" + this.drawnPolygons.length.toString());
		}
		
		/* 
		Change an array collection of latlng to points
		*/
		private function fromLatLngToPoint(arr:ArrayCollection) : ArrayCollection {
			// Draw the current empire boundary
			var arrayOfPolygons:ArrayCollection =  new ArrayCollection();
			
			// Grab the game objects and draw them
			for(var i:int = 0;  i < arr.length; i++){
				var s:SuperObject = arr[i] as SuperObject;
				if(s.isReady()){
					var p:Polygon = s.getBoundaryPolygon();
					if(p != null){
						if(p.getPolylineCount() != 0){
							// Create a new array
							var poly:Poly = new TowerSaintPolygon(s.isAtValidLocation());
							for(var l:int = 0; l < p.getPolylineCount(); l++){
								for(var j:int = 0; j < p.getVertexCount(l); j++){
									var pos:LatLng = p.getVertex(l, j);
									poly.addPointXY(pos.lat(), pos.lng());
								}
							}
							if(!poly.isEmpty()){
								arrayOfPolygons.addItem(poly);
							}
						}
					}
				}
			}
			
			return arrayOfPolygons;
		}
		
		
		
		/* 
		Add and draw, and adds a new superobject to the boundary,
		and draws it
		*/
		public function addAndDraw(s:SuperObject) : void {
			var arr:ArrayCollection = this.fromLatLngToPoint(new ArrayCollection([s]));
						
			// Add to the array
			this.currentPolygons.addAll(arr);
			this._decomposeIntoDisjointPolygons(arr);
			this._draw(this.currentPolygons);
		}
		
		/* 
		When the valid location property is changed. This function is called. The function will
		redraw the polygons showing a merged boundary(this.isValidLocation == true), or 
		
		/* 
		When the list of user models change.The functions addAndDraw, and removeAndDraw no longer
		need to be called directly because any change in the listOfModels ArrrayCollection will
		cause an event that will end up here.
		TODO: Add move, and change plugins
		*/
		public function onCollectionChange(e:CollectionEvent):void {
			var obj:SuperObject = e.items[e.location] as SuperObject;
			if(e.kind == CollectionEventKind.ADD || e.kind == CollectionEventKind.REPLACE){
				this.addAndDraw(obj);
			}else if(e.kind == CollectionEventKind.REMOVE){
				this.removeAndDraw(obj);
			}
			
			if(obj.hasBoundary()){
				// Tie in some events
				if(obj is Tower){
					var t:Tower = obj as Tower;
					t.addEventListener(Tower.AT_VALID_LOCATION_CHANGE, onTowerValidLocationChange);
					t.addEventListener(Tower.ON_DRAG_START, onTowerDragStart);
					t.addEventListener(Tower.ON_DRAG_END, onTowerDragEnd);
				}
			}
		}
		
		/* 
		Check if the latlng is iniside a visible polygon
		*/
		public function isInsidePolygon(pos:LatLng) : Boolean {
			for(var i:int = 0; i < this.listOfGameObjects.length; i++){
				var s:SuperObject = this.listOfGameObjects[i] as SuperObject;
				var p:Polygon = s.getBoundaryPolygon();
				
				var bounds:LatLngBounds = p.getLatLngBounds();
				if(bounds.containsLatLng(pos)){
					return true;
				}
			}
			return false;
			/*
			for(var i:int = 0; i < this.drawnPolygons.length; i++){
				var poly:Polygon = this.drawnPolygons[i] as Polygon;
				
				// Since the boundary is a square the check is trivial
				var bounds:LatLngBounds = poly.getLatLngBounds();
				if(bounds.containsLatLng(pos)){
					return true;
				}
			}
			return false;
			*/
		}
		/*
		Remove and draw, removes a superobject from the boundary,
		an updates the boundary
		*/
		public function removeAndDraw(s:SuperObject) : void {
			
			// Clear the current dictionary
			for(var obj:Object in this.disjointPolygons){
				delete this.disjointPolygons[obj];
			} 
			
			initDraw();
		}
		
				
		// TODO: This algorithm may need sprucing up, and performance tuning
		private function _decomposeIntoDisjointPolygons(arrayOfPolygons:ArrayCollection) : void{
		
			// Grab the polygon
			var numberOfPoly:int = 0;
			var noPolygon:Boolean = true;

			if(arrayOfPolygons.length == 0){
				return;
			}
			
			if(this.firstDraw){
				disjointPolygons[numberOfPoly] = arrayOfPolygons.getItemAt(0);
				arrayOfPolygons.removeItemAt(0);
				this.firstDraw = false;
				noPolygon = false;
			}else{
				noPolygon = false;
			}
			
			while(arrayOfPolygons.length != 0){
				if(noPolygon){
					// Pop off the top object
					numberOfPoly++;
					disjointPolygons[numberOfPoly] = arrayOfPolygons.getItemAt(0);
					arrayOfPolygons.removeItemAt(0);
					
					// Set the polygon
					noPolygon = false;
				}else{
					var notFound:Boolean = true;
					for(var i:int = 0; i < arrayOfPolygons.length; i++){
						var p:TowerSaintPolygon = arrayOfPolygons[i] as TowerSaintPolygon;
						
						var foundPolygonSet:Boolean = false;
						for(var obj:Object in disjointPolygons){
							var key:int = obj as int;
							var compositePolygon:TowerSaintPolygon = disjointPolygons[key] as TowerSaintPolygon;
							
							// Intersect the polygon 
							if(p.isValid() == compositePolygon.isValid()){
								var iPoly:Poly = compositePolygon.intersection(p);
								if(!iPoly.isEmpty()){
									notFound = false;
									foundPolygonSet = true;
									disjointPolygons[key] = TowerSaintPolygon.createTSPolygonFromPoly(compositePolygon.union(p), p.isValid());
									continue;
								}
							}
						}
						
						if(foundPolygonSet){
							// Remove the item
							arrayOfPolygons.removeItemAt(i);
							i--;
						}
					}
					noPolygon = notFound;
				}
			}
	
		}
		
		private function _drawPoly(poly:TowerSaintPolygon) : Polygon {
			var arr:Array = poly.getPoints();
			
			// An array of lat lng points for a boundary
			var arrayOfLatLng:Array = new Array();
			
			for(var m:int = 0; m < arr.length; m++){
				var tempP:Point = arr[m] as Point;
				var tPos:LatLng = new LatLng(tempP.x, tempP.y);
				arrayOfLatLng.push(tPos);
			}
			
			// Create and draw the polygon.
			var boundaryColor:Number;
			if(poly.isValid()){
				boundaryColor = 0xffffff;
			}else{
				boundaryColor = 0xffff0000;
			}
			var polygon:Polygon = new Polygon(arrayOfLatLng, 
				new  PolygonOptions({ 
					strokeStyle: new StrokeStyle({
						color: boundaryColor,
						thickness: 5,
						alpha: 1.0}), 
					fillStyle: new FillStyle({
						color: boundaryColor,
						alpha: 0.5})
				}));
			this.map.addOverlay(polygon);
			return polygon;
		}
	}
}