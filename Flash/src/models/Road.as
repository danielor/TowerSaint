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
	
	import models.map.TowerSaintMarker;
	
	import mx.core.BitmapAsset;

	[Bindable]
	[RemoteClass(alias="models.Road")]
	public class Road  implements SuperObject
	{
		// Information
		public var hitPoints:Number;
		public var level:Number;
		
		// Who owns it?
		public var user:User;
		
		// Location 
		public var latIndex:int;
		public var lonIndex:int;
		public var latitude:Number;
		public var longitude:Number;
		
		// State variables
		private var isModified:Boolean;
		private var hasFocus:Boolean;											/* True if the current object has user focus */
		private var roadMarker:TowerSaintMarker;								/* The marker to be drawn on the map */
		private var focusPolygon:Polygon;	
		private var roadIcon:BitmapAsset;										/* The bitmap associated with the object */
		
		public function Road()
		{
			super();
		}
		
		// IExternalizable interface		
		public function writeExternal(output:IDataOutput) : void {
			output.writeInt(this.hitPoints);
			output.writeInt(this.level);
			output.writeObject(this.user);
			output.writeInt(this.lonIndex);
			output.writeInt(this.latIndex);
			output.writeFloat(this.latitude);
			output.writeFloat(this.longitude);
		}
		public function readExternal(input:IDataInput) : void {
			this.hitPoints = input.readInt();
			this.level = input.readInt();
			this.user = input.readObject();
			this.lonIndex = input.readInt();
			this.latIndex = input.readInt();
			this.latitude = input.readFloat();
			this.longitude = input.readFloat();
		}
		
		public static function createUserRoadFromJSON(buildObject:Object, u:User):Road {
			var r:Road = new Road();
			r.hitPoints = buildObject.hitpoints;
			r.level = buildObject.level;
			r.latitude = buildObject.latitude;
			r.longitude = buildObject.longitude;
			return r;
		}
		
		public static function createRoadFromJSON(buildObject:Object):Road{
			var r:Road = new Road();
			r.level = buildObject.level;
			r.latitude = buildObject.latitude;
			r.longitude = buildObject.longitude;
			r.user = User.createUserFromJSON(buildObject.user);
			return r;
		}
		
		public function draw(drag:Boolean, map:Map, photo:PhotoAssets, fpm:FocusPanelManager, withBoundary:Boolean) : void{
			
			// Add a ground overlay
			roadIcon = getRoadFromNeighbors(photo);
			
			// Extract the position associated with remoteObject(Tower)			
			var gposition:LatLng = new LatLng(latitude, longitude);
			
			// Create test overlays
			var markerOptions : MarkerOptions = new MarkerOptions();
			markerOptions.icon = roadIcon;
			markerOptions.iconAlignment = MarkerOptions.ALIGN_HORIZONTAL_CENTER | MarkerOptions.ALIGN_BOTTOM;
			markerOptions.hasShadow = false;
			markerOptions.radius = 5;
			markerOptions.draggable = drag;
			
			// Create the marker
			roadMarker = new TowerSaintMarker(this, gposition, markerOptions, map);
			roadMarker.addEventListener(MapMouseEvent.CLICK, fpm.onMarkerClick);
			map.addOverlay(roadMarker);
		}
		
		// Erase the marker
		public function eraseFromMap(map:Map) : void {
			map.removeOverlay(roadMarker);
		}
		
		public function setFocusOnObject(error:Boolean) : void{
			createFocusPolygonAtPosition(error);
			hasFocus = true;
		}
		
		private function createFocusPolygonAtPosition(color:Boolean):void {
			// The position on the map, and the map
			var pos:LatLng = roadMarker.getLatLng();
			var m:Map = roadMarker.getMap();
			
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

		

		
		public function getRoadFromNeighbors(_photo:PhotoAssets):BitmapAsset {
			
			// TODO: This value needs to be calculated properly so that depending on the
			// neighbor list different bitmaps are used.
			var neighborType:Number = 0;
			// North - (0, 1)
			// East - (0, 2)
			// South - (0, 4)
			// West - (0, 8)
			switch(neighborType){
				case 0:
					return new _photo.EastRoad() as BitmapAsset;
				case 1:
					return new _photo.NorthRoad() as BitmapAsset;
				case 2:
					return new _photo.EastRoad() as BitmapAsset;
				case 3:
					return new _photo.NorthEastRoad() as BitmapAsset;
				case 4:
					return new _photo.SouthRoad() as BitmapAsset;
				case 5:
					return new _photo.NorthSouthRoad() as BitmapAsset;
				case 6:
					return new _photo.SouthEastRoad() as BitmapAsset;
				case 7:
					return new _photo.NorthSouthEastRoad() as BitmapAsset;
				case 8:
					return new _photo.WestRoad() as BitmapAsset;
				case 9:
					return new _photo.NorthWestRoad() as BitmapAsset;
				case 10:
					return new _photo.EastWestRoad() as BitmapAsset;
				case 11:
					return new _photo.NorthEastWestRoad() as BitmapAsset;
				case 12:
					return new _photo.SouthWestRoad() as BitmapAsset;
				case 13:
					return new _photo.NorthSouthWestRoad() as BitmapAsset;
				case 14:
					return new _photo.SouthEastWestRoad() as BitmapAsset;
				case 15:
					return new _photo.NorthSouthEastWestRoad() as BitmapAsset;
				default:
					return new _photo.EastRoad() as BitmapAsset;
			}
		}
		
		public function getImage(photo:PhotoAssets):BitmapAsset {
			return getRoadFromNeighbors(photo);			
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
		
		public function isVisible(map:Map):Boolean {
			// Get the location
			var loc:LatLng = new LatLng(this.latitude, this.longitude);
			var b:LatLngBounds = map.getLatLngBounds();
			
			return b.containsLatLng(loc);
		}
		
		public function getString():String {
			var s:String = "";
			s+="HitPoints\t" + hitPoints.toString() + "\n";
			s+="Level\t\t" + level.toString() + "\n";
			s+="Latitude\t\t" + latitude.toPrecision(5) + "\n";
			s+="Lognitude\t" + longitude.toPrecision(5) + "\n";
			return s;
		}
		
		public function setPosition(pos:LatLng) : void {
			latitude = pos.lat();
			longitude = pos.lng();
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
			return new LatLng(this.latitude, this.longitude);
		}
		
		// Update the position of the tower
		public function updatePosition(loc:LatLng): void{
			this.latitude = loc.lat();
			this.longitude = loc.lng();
		}		
		
		public function isOverLappingBoundsOfObject(pos:LatLng, m:Map, photo:PhotoAssets) : Boolean {
			var iPos:LatLng = this.roadMarker.getLatLng();
			var bounds:LatLngBounds = GameConstants.getBaseLatticeBounds(iPos, m, photo);
			return bounds.containsLatLng(pos);
		}
	}
}
