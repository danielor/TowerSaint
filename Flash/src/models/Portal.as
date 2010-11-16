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
	
	import managers.FocusPanelManager;
	
	import models.map.TowerSaintMarker;
	
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
		

		
		public function draw(drag:Boolean, map:Map, photo:PhotoAssets, fpm:FocusPanelManager) : void {
			// Extract the position associated with remoteObject(Tower)			
			var firstPosition:LatLng = new LatLng(endLocationLatitude, endLocationLongitude);
			var secondPosition:LatLng = new LatLng(startLocationLatitude, startLocationLongitude);

			// Create both portals
			var bounds:LatLngBounds = map.getLatLngBounds();
			if(bounds.containsLatLng(firstPosition)){
				_drawPortal(firstPosition, photo, map, drag, fpm);
			}
			if(bounds.containsLatLng(secondPosition)){
				_drawPortal(secondPosition, photo, map, drag, fpm);
			}
		}
		
		private function _drawPortal(pos:LatLng, photo:PhotoAssets, map:Map, drag:Boolean, fpm:FocusPanelManager) : void {
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
			var marker:TowerSaintMarker = new TowerSaintMarker(this, pos, markerOptions);
			marker.addEventListener(MapMouseEvent.CLICK, fpm.onMarkerClick);
			map.addOverlay(marker);
			
		}
		
		/* Get the image of the bitmap asset */
		public function getImage(photo:PhotoAssets):BitmapAsset {
			return new photo.ThePortal() as BitmapAsset;
		}

		/* Return the textflow representation of the model */
		public function display():TextFlow {
			var textFlow:TextFlow = new TextFlow();
			
			// Setup the stuff
			var pGraph:ParagraphElement = new ParagraphElement();
		
			// Add the span
			var iSpan:SpanElement = new SpanElement();
			iSpan.text = getString();
		
			// The span element
			pGraph.addChild(iSpan);
			textFlow.addChild(pGraph);
			
			return textFlow;
		}
		
		public function getString() : String {
			var s:String = "";
			s += "HitPoints\t" + hitPoints.toString() + "\n";
			s += "Level\t\t" + level.toString() + "\n";
			s += "StartLatitude\t" + startLocationLatitude.toPrecision(5) + "\n";
			s += "StartLongitude\t" + startLocationLongitude.toPrecision(5) + "\n";
			s += "EndLatitude\t" + endLocationLatitude.toPrecision(5) + "\n";
			s += "EndLongitude\t" + endLocationLongitude.toPrecision(5) + "\n";
			return s;
		}
		
		public function setPosition(pos:LatLng) : void {
			startLocationLatitude = pos.lat();
			startLocationLongitude = pos.lng();
		}
		
		public function isVisible(map:Map):Boolean {
			// Create the two positions
			var eLoc:LatLng = new LatLng(this.endLocationLatitude, this.endLocationLongitude);
			var sLoc:LatLng = new LatLng(this.startLocationLatitude, this.endLocationLatitude);
			
			// Check if either are within the bounds
			var lB:LatLngBounds = map.getLatLngBounds();
			return (lB.containsLatLng(eLoc) || lB.containsLatLng(sLoc));
		}
		
		// Interface to the isModified flag, which is true when an object has been create.
		public function setIsModified(t:Boolean) : void {
			this.isModified = t;
		}
		public function getIsModified():Boolean {
			return this.isModified;
		}
		
		public function getMaxInfluence():Number {
			switch(this.level){
				case 1:
					return 1.;
				case 2:
					return 2.;
				case 3:
					return 5.;
				case 4:
					return 10.;
				default:
					return 1.;
			}
		}
		public function getPosition(b:LatLngBounds):LatLng{
			var sL:LatLng = new LatLng(this.startLocationLatitude, this.startLocationLongitude);
			var eL:LatLng = new LatLng(this.endLocationLatitude, this.endLocationLongitude);
			if(b.containsLatLng(sL)){
				return sL;
			}else{
				return eL;
			}
		}
	}
}