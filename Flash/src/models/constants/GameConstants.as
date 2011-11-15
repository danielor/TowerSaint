package models.constants
{
	import assets.PhotoAssets;
	
	import away3d.cameras.Camera3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import mx.controls.Alert;
	import mx.core.BitmapAsset;

	public class GameConstants
	{
		// Class contains map game constants needed to run the game
		public function GameConstants()
		{
				
		}
		
		public static function getLatOffset():Number{
			return .001;
		}
		
		public static function getLonOffset():Number{
			return .001;
		}
		
		// Convert a lat lng to away3D coordinate. The away3D view is assumed to be inside the
		// the map so that the points need to be rescaled.
		public static function fromMapToAway3D(pos:LatLng, map:Map):Point {
			// Calculate the transformation
			var p:Point = map.fromLatLngToViewport(pos);
			var bounds:LatLngBounds = map.getLatLngBounds();
			var southeast:LatLng = bounds.getSouthEast();
			var northwest:LatLng = bounds.getNorthWest();
			var southEastPoint:Point = map.fromLatLngToViewport(southeast);
			var northWestPoint:Point = map.fromLatLngToViewport(northwest);
			var xFraction:Number = Math.abs(p.x - southEastPoint.x)/Math.abs(southEastPoint.x - northWestPoint.x);
			var yFraction:Number = Math.abs(p.y - southEastPoint.y)/Math.abs(southEastPoint.y - northWestPoint.y);
			var totalWidth:Number = 2. * (map.width + map.y);
			var totalHeight:Number = -2. * (map.height + map.y);
		
			// Create the point
			return new Point(Math.abs(totalWidth *(1 - xFraction)), totalHeight * (1 - yFraction));
		}
		
		// Convert  distance and speed into an amount of time
		public static function convertSpeedIntoTime(s:Number, distance:Number):Number{
			return 5 * distance / s;
		}
		
		// Convert a lat lng to away3d coordinates. The difference betwen the previous 
		// the simple version above is that this function calculates the depth, and rescales
		// the position
		public static function transfromMapLineTo3DCoordinatesWithDepth(startPos:LatLng, endPos:LatLng, map:Map, depth:Number,
																		view:View3D, scene:Scene3D):Array{
			var a:Array = new Array();
			
			
			// Get points at zero depth
			var startPoint:Point = GameConstants.fromMapToAway3D(startPos, map);
			var endPoint:Point = GameConstants.fromMapToAway3D(endPos, map);
			
			
			// TODO: Good god I hate this haaaaaaack!
			// TODO: Fix this complete hack. Cannot seem to get
			// the proper transform
			var constant:Number = 930;
			var sconstant:Number = 2.;
			var totalWidth:Number = 2. * (map.width + map.y);
			var totalHeight:Number = -2. * (map.height + map.y);
			var shift:Point = new Point(constant/ depth  *totalWidth / 2, constant/ depth * totalHeight / 2);
			
			// Get the distance betwen the points
			var diff:Point = endPoint.subtract(startPoint);
			diff.x = diff.x * sconstant * (constant / depth);
			diff.y = diff.y * sconstant * (constant / depth);
			/*
			// Convert to vector3D
			var startVec:Vector3D = new Vector3D(startPoint.x, endPoint.x, 0);
			var endVec:Vector3D = new Vector3D(endPoint.x, endPoint.y, 0.);
			var dStartVec:Vector3D = new Vector3D(startPoint.x, endPoint.y, depth);
			var dEndVec:Vector3D = new Vector3D(endPoint.x, endPoint.y, depth);
			
			// Get the camera
			var c:Camera3D = view.camera;
			var m:Matrix3D = c.transform;
			
			// Transform to local vector
			var sVecLoc:Vector3D = m.transformVector(startVec);
			var eVecLoc:Vector3D = m.transformVector(endVec);
			var dSVecLoc:Vector3D = m.transformVector(dStartVec);
			var dEVecLoc:Vector3D = m.transformVector(dEndVec);

			
			// Find the rescaling that occurs
			var xDiff:Number = sVecLoc.x - dSVecLoc.x;
			var yDiff:Number = sVecLoc.y - dSVecLoc.y;
			var rescaling:Number = Math.abs((dSVecLoc.x - dEVecLoc.x) / (sVecLoc.x - eVecLoc.x));
			Alert.show(xDiff.toString()+ ":" + yDiff.toString() + ":" + rescaling.toString() + ":" + sVecLoc.toString() + ":" + 
						dSVecLoc.toString() + ":" + m.determinant.toString());
 			// Create the new points
			//var nStartPoint:Point = new Point(startPoint.x + xDiff, startPoint.y + yDiff);
			//var nEndPoint:Point = new Point(startPoint.x + rescaling * (startPoint.x + endPoint.x),
			//								startPoint.y + rescaling * (startPoint.y + endPoint.y));
			*/
			var nStartPoint:Point = new Point(startPoint.x + shift.x, startPoint.y + shift.y);
			var nEndPoint:Point = new Point(startPoint.x + diff.x + shift.x, 
											startPoint.y + diff.y +  shift.y);
			// Push the array.
			a.push(nStartPoint);
			a.push(nEndPoint);
			return a;
		}
		
		// Convert a away3D coordinate to lat lng
		public static function fromAway3DtoMap(p:Point, map:Map):LatLng {
			var bounds:LatLngBounds = map.getLatLngBounds();
			var southeast:LatLng = bounds.getSouthEast();
			var northwest:LatLng = bounds.getNorthWest();
			var totalWidth:Number = 2. * (map.width + map.y);
			var totalHeight:Number = -2. * (map.height + map.y);
			var xFraction:Number = p.x / totalWidth;
			var yFraction:Number = p.y / totalHeight;
			return new LatLng(northwest.lat() - yFraction * (Math.abs(bounds.getNorth() - bounds.getSouth())),
							 northwest.lng() - xFraction * (Math.abs(bounds.getEast() - bounds.getWest())));
		}
		
		// Proximity distance
		public static function proximityDistance():Number{
			return 50;
		}
		
		// TODO: A more robust mechanism is needed to hide objects on the map.
		// A point far off the viewport, where objects that are rendered can remain.
		public static function hideAWAY3DCoordinate():Point {
			return new Point(-5000., 5000.);
		}
		
		public static function getAspectRatio(map:Map) : Number {
			// Get the latitude/longitude
			var bounds:LatLngBounds = map.getLatLngBounds();
			var ne:LatLng = bounds.getNorthEast();
			var sw:LatLng = bounds.getSouthWest();
			var lat:Number = Math.abs(ne.lat() - sw.lat());
			var lng:Number = Math.abs(ne.lng() - sw.lng());
			return lat/lng;
		}
		
		public static function getLatOffsetFromMarkerPixelWidth(width:Number, map:Map) : Number{
			// Get the map information
			var bounds:LatLngBounds = map.getLatLngBounds();
			var ne:LatLng = bounds.getNorthEast()
			var sw:LatLng = bounds.getSouthWest()
			var zoom:Number = map.getZoom();
				
			// Get the distance
			var pixelNE:Point = map.getProjection().fromLatLngToPixel(ne, zoom);
			var pixelSW:Point = map.getProjection().fromLatLngToPixel(sw, zoom);
			
			// Get the fraction of the width
			var fracWidth:Number = width / Math.abs(pixelNE.x - pixelSW.x);
			
			// Find the equlivalent in longitude
			var diff:Number = fracWidth * (Math.abs(ne.lng() - sw.lng()));
			return diff / 4.;
		}
		
		// Returns the level of a user from the experience
		public static function getUserLevelFromExperience(Experience:Number) : Number{
			var baseExp:Number = 1000;
			return int(Experience / baseExp);

		}
		
		// Create the basic lattice bounds
		public static function getBaseLatticeBounds(pos:LatLng, m:Map, p:PhotoAssets) :LatLngBounds {
			var tower:BitmapAsset = new p.TowerLevel0() as BitmapAsset;
			var data:BitmapData = tower.bitmapData;
			var width:Number = data.width;
			
			// Get the game constants
			var aspectRatio:Number = GameConstants.getAspectRatio(m);
			var lonOffset:Number =  GameConstants.getLatOffsetFromMarkerPixelWidth(width, m);
			var latOffset:Number =  lonOffset * aspectRatio;
			
			// Create the bounds
			var southWest:LatLng = new LatLng(pos.lat() - latOffset, pos.lng() - lonOffset);
			var northEast:LatLng = new LatLng(pos.lat() + latOffset, pos.lng() + lonOffset);
			return new LatLngBounds(southWest, northEast);
		}
	}
}