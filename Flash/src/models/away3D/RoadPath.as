package models.away3D
{
	import assets.PhotoAssets;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	import away3d.extrusions.PathExtrusion;
	import away3d.materials.BitmapMaskMaterial;
	import away3d.materials.BitmapMaterial;
	
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	
	import flash.display.Bitmap;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import models.constants.GameConstants;
	import models.interfaces.FilteredObject;
	
	import mx.controls.Alert;

	/* 
	Road path uses away3D to draw a path on google maps. 
	*/
	public class RoadPath extends PathExtrusion implements FilteredObject
	{
		private const numberOfPointsPerL:Number = 10000;				// The number of points lat
		private const profileWidth:Number = 10;							// The width of the road
		private var startPosition:LatLng;								// The starting position of the path
		private var endPosition:LatLng;									// The end position of the path
		private var _map:Map;											// The map variable.
		private var _bitmap:Bitmap;										// Bitmap associated with the picture
		private var _scene:Scene3D;										// The scene which draws the child.
		private var _view:View3D;										// The view.
		private var firstDraw:Boolean;									// True after the child is added to the scene
		private var startPoint:Point;									// The start point of the path
		private var endPoint:Point;										// The end point of the path
		private var focusFilters:Array;									// Focus filters 
		public function RoadPath()
		{
			// Set the state
			this._bitmap = null;
			
			// Flags control the extrusion.
			this.firstDraw = true;
			this.bothsides = true;
			this.subdivision = 2;
			super();
		}
		
		
		// The filter interface
		private function createFilters():void {
			// Make sure that the objects can show the filter
			this.ownCanvas = true;
			
			// First object
			this.focusFilters = new Array();
			var gF:GlowFilter = new GlowFilter(0x4169e1,0,6.0,6.0,2,BitmapFilterQuality.MEDIUM,false, false);
			focusFilters.push(gF);
			
			// Set the filter of the path extrusion
			this.filters = [this.focusFilters[0]];
		}
		
		// The Filtered Object interface
		public function updateFilter(i:Number):void{

			for(var k:int = 0; k < focusFilters.length; k++){
				var gf:GlowFilter = focusFilters[k] as GlowFilter;
				gf.alpha = i;
			}
		}
		public function changeFilterState(b:Boolean):void {
			for(var k:int = 0; k < focusFilters.length; k++){
				var gf:GlowFilter = focusFilters[k] as GlowFilter;
				if(b){
					gf.alpha = 1;
				}else{
					gf.alpha = 0;
				}
			}
		}
		
		// Set the map variable
		public function set map(_m:Map):void {
			_map = _m;
		}
		public function set scene(_s:Scene3D):void {
			_scene = _s;
		}
		public function set view(_v:View3D):void {
			_view = _v;
		}
		
		// Update the path of points
		public function updatePath(bS:Number, l:LatLng, photo:PhotoAssets):void {
			if(bS == 0){
				startPosition = l;
			}else{
				
				endPosition = l;
				drawRandomPathBetweenPositions(photo);
				if(this.firstDraw){
					this.firstDraw = false;
					this._scene.addChild(this);
					this.createFilters();

				}
			}
		}
		
		// draw the random path between the positions
		private function drawRandomPathBetweenPositions(photo:PhotoAssets):void {
			// Save the start, and end point
			this.startPoint = GameConstants.fromMapToAway3D(this.startPosition, this._map);
			this.endPoint = GameConstants.fromMapToAway3D(this.endPosition, this._map);
			
			// Get the distance and angle
			var distance:Number = startPosition.distanceFrom(this.endPosition);
			var angle:Number = startPosition.angleFrom(this.endPosition);
			
			// Convert the positions to away3D coordinates
			var depth:Number = 0.1;							// How deepd would we like the path to be.
			var a:Array = GameConstants.transfromMapLineTo3DCoordinatesWithDepth(startPosition, endPosition,
				_map, depth, _view,_scene);
			var sP:Point = startPoint;
			var eP:Point =  endPoint;
			
			// Calculate the number of points
			// TODO: Make paths curved.
			var startVector:Vector3D = new Vector3D(sP.x, sP.y, depth);
			var controlVector:Vector3D = new Vector3D((sP.x + eP.x) / 2., (sP.y + eP.y) / 2, depth);
			var endVector:Vector3D = new Vector3D(eP.x, eP.y, depth);
			var pC:PathCommand;
			if(eP.x < sP.x){
				pC = new PathCommand(PathCommand.CURVE, startVector, controlVector, endVector);
			}else{
				pC = new PathCommand(PathCommand.CURVE, endVector, controlVector, startVector);
			}
			var pathPoint:Vector.<PathCommand> = new Vector.<PathCommand>();
			pathPoint.push(pC);

			this.path = new Path();
			this.path.aSegments = pathPoint;			// Save the list of information
			
			// Create the profile to extrude, and set it equal to the proper value
			var profileWidth:Number = 10;
			var pF:Array = new Array();
			var pv:Vector3D = new Vector3D(0., 10., 0.);
			var pv2:Vector3D = new Vector3D(0., -10, 0.);
			pF.push(pv);pF.push(pv2);
			this.profile = pF;
			
			// Create the material with the appropriate bitmap
			if(this._bitmap == null){
				this._bitmap = new photo.Dirt();
				var bm:BitmapMaterial = new BitmapMaterial(this._bitmap.bitmapData);
				bm.alpha = .5;
				this.material = bm;
			}
		}
		
		public function onPath(p:LatLng):Boolean {
			// Convert the latlng to a away3d position
			var testPoint:Point = GameConstants.fromMapToAway3D(p, this._map);
			var distance:Number = _distanceBetweeenPointAndLine(this.startPoint, this.endPoint, testPoint);
			return distance < 2. * this.profileWidth;
		}
		
		public function getClosestPointToObject(l:LatLng):LatLng{
			// Transform the latlng into points.
			var p:Point = GameConstants.fromMapToAway3D(l, this._map);
			
			// Convert into vectors
			var eV:Vector3D = new Vector3D(startPoint.x, startPoint.y, 0.);
			var sV:Vector3D = new Vector3D(endPoint.x, endPoint.y, 0.);
			var pV:Vector3D = new Vector3D(p.x, p.y, 0.);
			
			// Calculate the nearest point on the line between sV, eV to pV
			var A:Vector3D = pV.subtract(sV);
			var B:Vector3D = eV.subtract(sV);
			
			var cosTheta:Number = A.dotProduct(B) / (A.length * B.length);
			var pLength:Number = A.length * cosTheta;
			var scale:Number = pLength / B.length;
			B.scaleBy(scale);
			var nl:Vector3D = sV.add(B);

			// Convert into a point, and then to latlng ... may need work
			var nlP:Point = new Point(nl.x, nl.y);
			var rLL:LatLng = GameConstants.fromAway3DtoMap(nlP, this._map);
			
			return rLL;
			
		}
		
		// Return the distance between a point and a line
		private function _distanceBetweeenPointAndLine(startPoint:Point, endPoint:Point, spacePoint:Point):Number{
			var numerator:Number = Math.abs((endPoint.x - startPoint.x) * (startPoint.y - spacePoint.y) -  
						                    (startPoint.x - spacePoint.x) * (endPoint.y - startPoint.y));
			var denominator:Number = Math.sqrt(Math.pow(endPoint.x - startPoint.x, 2) +
										Math.pow(endPoint.y - startPoint.y, 2));
			return numerator / denominator;
		}
	}
}