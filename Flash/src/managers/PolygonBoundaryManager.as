package managers
{
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.overlays.Polygon;
	import com.google.maps.overlays.PolygonOptions;
	import com.google.maps.styles.FillStyle;
	import com.google.maps.styles.StrokeStyle;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import models.SuperObject;
	import models.User;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.controls.Alert;
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
		
		public function PolygonBoundaryManager(m:Map, arr:ArrayCollection, u:User)
		{
			this.map = m;
			this.listOfGameObjects = arr;
			this.user = u;
			
			// Disjoint polygons
			this.disjointPolygons = new Dictionary();
			this.firstDraw = true;								/* Set the state variable */
		
		}
		
		/* Initialize and draw the boundary */
		public function initDraw() : void {
			// Draw the current empire boundary
			var arrayOfPolygons:ArrayCollection =  fromLatLngToPoint(this.listOfGameObjects);
			
			_draw(arrayOfPolygons);
		}
		
		/* 
		Draw the Polygon
		*/
		private function _draw(arrayOfPolygons:ArrayCollection) : void {
			for(var o:Object in this.disjointPolygons){
				var poly:Poly = this.disjointPolygons[o] as Poly;
				_drawPoly(poly);
			}
			this.currentPolygons = arrayOfPolygons;
		}
		
		/* 
		Change an array collection of latlng to points
		*/
		private function fromLatLngToPoint(arr:ArrayCollection) : ArrayCollection {
			// Draw the current empire boundary
			var arrayOfPolygons:ArrayCollection =  new ArrayCollection();
			
			// Grab the game objects and draw them
			for(var i:int = 0;  i < this.listOfGameObjects.length; i++){
				var s:SuperObject = this.listOfGameObjects[i] as SuperObject;
				var p:Polygon = s.getBoundaryPolygon();
				if(p != null){
					if(p.getPolylineCount() != 0){
						// Create a new array
						var poly:Poly = new PolyDefault();
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
			this._decomposeIntoDisjointPolygons(this.currentPolygons);
			this._draw(this.currentPolygons);
		}
		
		/*
		Remove and draw, removes a superobject from the boundary,
		an updates the boundary
		*/
		public function updateAndDraw(s:SuperObject) : void {
			var arr:ArrayCollection = this.fromLatLngToPoint(new ArrayCollection([s]));
			var poly:Poly = arr[0] as Poly;
		
		}
		
		// TODO: Could be more clever??!? Not performance hungry code.... Finish
		private function _removePolygon(poly:Poly) : void {
			this.currentPolygons;
		}
				
		// TODO: This algorithm may need sprucing up, and performance tuning
		private function _decomposeIntoDisjointPolygons(arrayOfPolygons:ArrayCollection) : void{
		
			// Grab the polygon
			var numberOfPoly:int = 0;
			var noPolygon:Boolean = true;
			
			if(this.firstDraw){
				disjointPolygons[numberOfPoly] = arrayOfPolygons.getItemAt(0);
				arrayOfPolygons.removeItemAt(0);
				this.firstDraw = false;
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
						var p:Poly = arrayOfPolygons[i] as Poly;
						
						var foundPolygonSet:Boolean = false;
						for(var obj:Object in disjointPolygons){
							var key:int = obj as int;
							var compositePolygon:Poly = disjointPolygons[key] as Poly;
							
							// Intersect the polygon 
							var iPoly:Poly = compositePolygon.intersection(p);
							if(!iPoly.isEmpty()){
								notFound = false;
								foundPolygonSet = true;
								disjointPolygons[key] = compositePolygon.union(p);
								continue;
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
		
		private function _drawPoly(poly:Poly) : void {
			var arr:Array = poly.getPoints();
			
			// An array of lat lng points for a boundary
			var arrayOfLatLng:Array = new Array();
			
			for(var m:int = 0; m < arr.length; m++){
				var tempP:Point = arr[m] as Point;
				var tPos:LatLng = new LatLng(tempP.x, tempP.y);
				arrayOfLatLng.push(tPos);
			}
			
			// Create and draw the polygon.
			var boundaryColor:Number = 0xffffff;
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
		}
	}
}