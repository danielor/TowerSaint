package models
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import flash.geom.Point;
	
	import mx.controls.Alert;

	public class GameConstants
	{
		// Class contains all of the game constants needed to run the game
		public function GameConstants()
		{
				
		}
		
		public static function getLatOffset():Number{
			return .001;
		}
		
		public static function getLonOffset():Number{
			return .001;
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
	}
}