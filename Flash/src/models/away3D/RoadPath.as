package models.away3D
{
	import assets.PhotoAssets;
	
	import away3d.containers.Scene3D;
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	import away3d.extrusions.PathExtrusion;
	import away3d.materials.BitmapMaskMaterial;
	import away3d.materials.BitmapMaterial;
	
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import models.constants.GameConstants;

	/* 
	Road path uses away3D to draw a path on google maps. 
	*/
	public class RoadPath extends PathExtrusion
	{
		private const numberOfPointsPerL:Number = 10000;				// The number of points lat
		private var startPosition:LatLng;								// The starting position of the path
		private var endPosition:LatLng;									// The end position of the path
		private var _map:Map;											// The map variable.
		private var _bitmap:Bitmap;										// Bitmap associated with the picture
		public function RoadPath()
		{
			this._bitmap = null;
			super();
		}
		
		// Set the map variable
		public function set map(_m:Map):void {
			_map = _m;
		}
		
		// Update the path of points
		public function updatePath(bS:Number, l:LatLng, photo:PhotoAssets):void {
			if(bS == 0){
				startPosition = l;
			}else{
				endPosition = l;
				drawRandomPathBetweenPositions(photo);
			}
		}
		
		// draw the random path between the positions
		private function drawRandomPathBetweenPositions(photo:PhotoAssets):void {
			// Get the distance and angle
			var distance:Number = startPosition.distanceFrom(this.endPosition);
			var angle:Number = startPosition.angleFrom(this.endPosition);
			
			// Convert the positions to away3D coordinates
			var startPoint:Point = GameConstants.fromMapToAway3D(startPosition, this._map);
			var endPoint:Point = GameConstants.fromMapToAway3D(endPosition, this._map);
			var dP:Point = new Point(endPoint.x - startPoint.x,
									endPoint.y - startPoint.y);
			// Calculate the number of points
			// TODO: Make paths curved.
			var numberOfPoints:Number = distance  * this.numberOfPointsPerL;
			
			// Create a path
			var pathPoint:Array = new Array();		
			var scale:Number = Math.sqrt(dP.x * dP.x + dP.y * dP.y) / numberOfPoints;
			for(var i:int = 0; i < numberOfPoints; i++){
				var v:Vector3D = new Vector3D(startPoint.x + dP.x * scale, endPoint.y + dP.y * scale, -.01);
				pathPoint.push(v);
			}
			var path:Path = new Path(pathPoint);
			
			// Create the profile to extrude, and set it equal to the proper value
			var profileWidth:Number = 10;
			var pF:Array = new Array();
			var pv:Vector3D = new Vector3D(profileWidth * Math.acos(angle), profileWidth * Math.asin(angle), 0.);
			var pv2:Vector3D = new Vector3D(profileWidth * Math.acos(angle), profileWidth * Math.asin(angle), 0.);
			pv2.negate();
			pF.push(pv);pF.push(pv2);
			this.profile = pF;
			
			// Create the material with the appropriate bitmap
			if(this._bitmap == null){
				this._bitmap = new photo.cannonMaterial();
				var bm:BitmapMaterial = new BitmapMaterial(this._bitmap.bitmapData);
				this.material = bm;
			}
			
			// Set the path variable
			this.path = path;
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