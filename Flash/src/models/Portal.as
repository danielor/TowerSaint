package models
{
	import assets.PhotoAssets;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.core.BitmapAsset;

	[Bindable]
	[RemoteClass(alias="models.Portal")]
	public class Portal implements SuperObject
	{
		// Information
		public var hitPoints:Number;
		public var level:Number;
		
		// Who owns it?
		public var user:User;
		
		// Locations- The location object has been decomposed to 
		
		// The Start location.
		public var startLocationLatitude:Number;
		public var startLocationLongitude:Number;
		public var startLocationLatitudeIndex:Number;
		public var startLocationLongitudeIndex:Number;
		
		// The End location
		public var endLocationLatitude:Number;
		public var endLocationLongitude:Number;
		public var endLocationLatitudeIndex:Number;
		public var endLocationLongitudeIndex:Number;
		
		//public var startLocation:Location;
		//public var endLocation:Location;
		
		public function Portal()
		{
			super();
		}
		

		
		public function draw(drag:Boolean, map:Map, photo:PhotoAssets) : void {
			// Extract the position associated with remoteObject(Tower)			
			var firstPosition:LatLng = new LatLng(endLocationLatitude, endLocationLongitude);
			var secondPosition:LatLng = new LatLng(startLocationLatitude, startLocationLongitude);

			// Create both portals
			var bounds:LatLngBounds = map.getLatLngBounds();
			if(bounds.containsLatLng(firstPosition)){
				_drawPortal(firstPosition, photo, map, drag);
			}
			if(bounds.containsLatLng(secondPosition)){
				_drawPortal(secondPosition, photo, map, drag);
			}
		}
		
		private function _drawPortal(pos:LatLng, photo:PhotoAssets, map:Map, drag:Boolean) : void {
			// The portal icon
			var portalIcon:BitmapAsset = new photo.ThePortal() as BitmapAsset;
			
			// Create test overlays
			var markerOptions : MarkerOptions = new MarkerOptions();
			markerOptions.icon = portalIcon;
			markerOptions.iconAlignment = MarkerOptions.ALIGN_HORIZONTAL_CENTER | MarkerOptions.ALIGN_BOTTOM;
			markerOptions.hasShadow = false;
			markerOptions.radius = 5;
			markerOptions.draggable = drag;
			
			// Create the marker
			var marker: Marker = new Marker(pos, markerOptions);				
			map.addOverlay(marker);
			
		}
		
		public function display():TextFlow {
			var textFlow:TextFlow = new TextFlow();
			return textFlow;
		}
		
		public function setPosition(pos:LatLng) : void {
			startLocationLatitude = pos.lat();
			startLocationLongitude = pos.lng();
		}
	}
}