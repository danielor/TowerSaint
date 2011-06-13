package models.constants
{
	import assets.PhotoAssets;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	
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