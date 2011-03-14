package models
{
	import assets.PhotoAssets;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.overlays.Polygon;
	import com.google.maps.overlays.PolygonOptions;
	import com.google.maps.styles.FillStyle;
	import com.google.maps.styles.StrokeStyle;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import managers.FocusPanelManager;
	
	import models.constants.GameConstants;
	import models.map.TowerSaintMarker;
	
	import mx.core.BitmapAsset;

	[Bindable]
	[RemoteClass(alias="models.Portal")]
	public class Portal  implements SuperObject
	{
		// Information
		public var hitPoints:int;
		public var level:int;
		
		// Who owns it?
		public var user:User;
		
		// Locations- The location object has been decomposed to 
		
		// The Start location.
		public var startLocationLatitude:Number;
		public var startLocationLongitude:Number;
		public var startLocationLatitudeIndex:int;
		public var startLocationLongitudeIndex:int;
		
		// The End location
		public var endLocationLatitude:Number;
		public var endLocationLongitude:Number;
		public var endLocationLatitudeIndex:int;
		public var endLocationLongitudeIndex:int;
	
		
		// State variables
		private var isModified:Boolean;
		private var hasFocus:Boolean;											/* True if the current object has user focus */
		private var portalMarker:TowerSaintMarker;								/* The marker to be drawn on the map */
		private var focusPolygon:Polygon;	
		
		public function Portal()
		{
			super();
		}
		
		// IExternalizable interface		
		public function writeExternal(output:IDataOutput) : void {
			output.writeInt(this.hitPoints);
			output.writeInt(this.level);
			output.writeObject(this.user);
			output.writeFloat(this.startLocationLatitude);
			output.writeFloat(this.startLocationLongitude);
			output.writeInt(this.startLocationLatitudeIndex);
			output.writeInt(this.startLocationLongitudeIndex);
			output.writeFloat(this.endLocationLatitude);
			output.writeFloat(this.endLocationLongitude);
			output.writeInt(this.endLocationLatitudeIndex);
			output.writeInt(this.endLocationLongitudeIndex);
		}
		public function readExternal(input:IDataInput) : void {
			this.hitPoints = input.readInt();
			this.level = input.readInt();
			this.user = input.readObject();
			this.startLocationLatitude = input.readFloat();
			this.startLocationLongitude = input.readFloat();
			this.startLocationLatitudeIndex = input.readInt();
			this.startLocationLongitudeIndex = input.readInt();
			this.endLocationLatitude = input.readFloat();
			this.endLocationLongitude = input.readFloat();
			this.endLocationLatitudeIndex = input.readInt();
			this.endLocationLongitudeIndex = input.readInt();
		}
		
		public function initialize(u:User):void {
			this.user = u;
			this.hitPoints = 10;
			this.level = 0;
		}

		public static function createUserPortalFromJSON(buildObject:Object, u:User) : Portal {
			var p:Portal = new Portal();
			p.hitPoints = buildObject.hitpoints;
			p.level = buildObject.level;
			p.user = u;
			p.startLocationLatitude = buildObject.startlocationlatitude;
			p.startLocationLongitude = buildObject.startlocationlongitude;
			p.endLocationLatitude = buildObject.endlocationlatitude;
			p.endLocationLongitude = buildObject.endlocationlongitude;
			return p;
		}
		
		public static function createPortalFromJSON(buildObject:Object) : Portal {
			var p:Portal = new Portal();
			p.hitPoints = buildObject.hitpoints;
			p.endLocationLatitude = buildObject.endLocationLatitude;
			p.endLocationLongitude = buildObject.endLocationLongitude;
			p.startLocationLatitude = buildObject.startLocationLatitude;
			p.startLocationLongitude = buildObject.startLocationLongitude;
			p.user = User.createUserFromJSON(buildObject.user);
			return p;
		}
		
		public function getNameString():String {
			return "Portal";
		}
		
		public function getProduction():Production {
			return new Production(0., 0., 0.);
		}
		
		public function draw(drag:Boolean, map:Map, photo:PhotoAssets, fpm:FocusPanelManager, withBoundary:Boolean) : void {
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
			portalMarker = new TowerSaintMarker(this, pos, markerOptions, map);
			portalMarker.addEventListener(MapMouseEvent.CLICK, fpm.onMarkerClick);
			map.addOverlay(portalMarker);
			
		}
		
		// Erase the marker
		public function eraseFromMap(map:Map) : void {
			map.removeOverlay(portalMarker);
		}
		
		public function setFocusOnObject(error:Boolean) : void{
			createFocusPolygonAtPosition(error);
			hasFocus = true;
		}
		
		private function createFocusPolygonAtPosition(color:Boolean):void {
			// The position on the map, and the map
			var pos:LatLng = portalMarker.getLatLng();
			var m:Map = portalMarker.getMap();
			
			// Get the color
			var pColor:Number;
			if(color){
				pColor = 0xFF0000;
			}else{
				pColor = 0x0000FF;
			}
			
			// Get the game constants
			var latOffset:Number = GameConstants.getLatOffset();
			var lonOffset:Number = GameConstants.getLonOffset();
			
			// Create the polygon
			var lat:Number = pos.lat();
			var lon:Number = pos.lng();
			var polygon:Polygon = new Polygon([
				new LatLng(lat - latOffset, lon - lonOffset),
				new LatLng(lat - latOffset, lon + lonOffset),
				new LatLng(lat + latOffset, lon + lonOffset),
				new LatLng(lat + latOffset, lon - lonOffset),
				new LatLng(lat - lonOffset, lon - lonOffset)
			], 
				new  PolygonOptions({ 
					strokeStyle: new StrokeStyle({
						color: 0x0000ff,
						thickness: 10,
						alpha: 0.7}), 
					fillStyle: new FillStyle({
						color: 0x0000ff,
						alpha: 0.7})
				}));
			
			// Keep a reference to the focus polygon.
			this.focusPolygon = polygon;
			
			// Add the polygon to the map
			m.addOverlay(this.focusPolygon);
			
		}
		
		// Update the position of the tower
		public function updatePosition(loc:LatLng): void{
			this.startLocationLatitude = loc.lat();
			this.startLocationLongitude = loc.lng();
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
		
		public function hasBoundary():Boolean {
			return false;
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
		
		public function isOverLappingBoundsOfObject(pos:LatLng, m:Map, photo:PhotoAssets) : Boolean {
			var iPos:LatLng = this.portalMarker.getLatLng();
			var bounds:LatLngBounds = GameConstants.getBaseLatticeBounds(iPos, m, photo);
			return bounds.containsLatLng(pos);
		}
	}
}