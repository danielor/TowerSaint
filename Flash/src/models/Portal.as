package models
{
	import assets.PhotoAssets;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
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
		
		// State variables
		private var isModified:Boolean;
		
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
			marker.addEventListener(MapMouseEvent.CLICK, onMarkerClick);
			map.addOverlay(marker);
			
		}
		
		private function onMarkerClick(event:MapMouseEvent) : void {
			var tF:TextFlow = this.display();
			
		}
		
		public function display():TextFlow {
			var textFlow:TextFlow = new TextFlow();
			
			// Setup the stuff
			var pGraph:ParagraphElement = new ParagraphElement();
		
			// Add the span
			var iSpan:SpanElement = new SpanElement();
			iSpan.text = "portal";
		
			// The span element
			pGraph.addChild(iSpan);
			textFlow.addChild(pGraph);
			
			return textFlow;
		}
		
		public function setPosition(pos:LatLng) : void {
			startLocationLatitude = pos.lat();
			startLocationLongitude = pos.lng();
		}
		
		// Interface to the isModified flag, which is true when an object has been create.
		public function setIsModified(t:Boolean) : void {
			this.isModified = t;
		}
		public function getIsModified():Boolean {
			return this.isModified;
		}
	}
}