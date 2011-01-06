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
	
	import flash.display.BitmapData;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import managers.EventManager;
	import managers.FocusPanelManager;
	
	import messaging.ChannelJavascriptBridge;
	import messaging.events.ChannelAttackEvent;
	
	import models.map.TowerSaintMarker;
	
	import mx.controls.Alert;
	import mx.controls.List;
	import mx.core.BitmapAsset;

	[Bindbale]
	[RemoteClass(alias="models.Tower")]
	public class Tower  implements SuperObject 
	{
		
		// Stats
		public var Experience:Number;
		public var Speed:Number;
		public var Power:Number;
		public var Armor:Number;
		public var Range:Number;
		public var Accuracy:Number;
		public var HitPoints:Number;
		public var isIsolated:Boolean;
		public var isCapital:Boolean;
		public var hasRuler:Boolean;
		public var Level:Number;
		
		// The user associated with the tower.
		public var user:User;
		
		// Mining capabilities.
		public var manaProduction:Number;
		public var stoneProduction:Number;
		public var woodProduction:Number;
		
		// Location
		public var latIndex:int;
		public var lonIndex:int;
		public var latitude:Number;
		public var longitude:Number;
		
		// State variables
		private var isModified:Boolean;
		private var hasFocus:Boolean;											/* True if the current object has user focus */
		
		// Keep a reference to the marker
		private var towerMarker:TowerSaintMarker;								/* The marker to be drawn on the map */
		private var focusPolygon:Polygon;										/* The polygon used to show focus */
		private var boundaryPolygon:Polygon;									/* The polygon associated with the boundary */
		private var tMEventManager:EventManager;								/* Manages events of the tower view */
		
		// Item Renderer interface (HUserObjectRenderer)
		public const alias:String = "Tower";									/* The name of the tower */
		public var icon:BitmapAsset;											/* The icon associated with the current tower */
		
		public function Tower()
		{
			super();
		}
		
		// Factory functions for differenct cases
		public static function createCapitalAtPosition(loc:LatLng, u:User):Tower {
			var t:Tower = new Tower();
			t.Experience = 0;
			t.Speed = 1;
			t.Power = 1;
			t.Armor = 1;
			t.Range = 1;
			t.Accuracy = .5;
			t.HitPoints = 100;
			t.isIsolated = false;
			t.isCapital = true;
			t.hasRuler = true;
			t.user = u;
			t.manaProduction = 50 + Math.floor( Math.random() * 50);
			t.stoneProduction = 50 + Math.floor( Math.random() * 50);
			t.woodProduction = 50 + Math.floor( Math.random() * 50);
			t.Level = 0;
			t.latitude = loc.lat();
			t.longitude = loc.lng();
			return t;
		}

		// Update the position of the tower
		public function updatePosition(loc:LatLng): void{
			this.latitude = loc.lat();
			this.longitude = loc.lng();
		}
		
		// IExternalizable interface		
		public function writeExternal(output:IDataOutput) : void {
			output.writeInt(this.Experience);
			output.writeInt(this.Speed);
			output.writeInt(this.Power);
			output.writeInt(this.Armor);
			output.writeInt(this.Range);
			output.writeFloat(this.Accuracy);
			output.writeInt(this.HitPoints);
			output.writeBoolean(this.isIsolated);
			output.writeBoolean(this.isCapital);
			output.writeBoolean(this.hasRuler);
			output.writeObject(this.user);
			output.writeInt(this.manaProduction);
			output.writeInt(this.stoneProduction);
			output.writeInt(this.woodProduction);
			output.writeInt(this.Level);
			output.writeInt(this.latIndex);
			output.writeInt(this.lonIndex);
			output.writeFloat(this.latitude);
			output.writeFloat(this.longitude);
		}
		public function readExternal(input:IDataInput) : void {
			this.Experience = input.readInt();
			this.Speed = input.readInt();
			this.Power = input.readInt();
			this.Armor = input.readInt();
			this.Range = input.readInt();
			this.Accuracy = input.readFloat();
			this.HitPoints = input.readInt();
			this.isIsolated = input.readBoolean();
			this.isCapital = input.readBoolean();
			this.hasRuler = input.readBoolean();
			this.user = input.readObject();
			this.manaProduction = input.readInt();
			this.stoneProduction = input.readInt();
			this.woodProduction = input.readInt();
			this.Level = input.readInt();
			this.latIndex = input.readInt();
			this.lonIndex = input.readInt();
			this.latitude = input.readFloat();
			this.longitude = input.readFloat();
		}
		
		public function draw(drag:Boolean, map:Map, _photo:PhotoAssets, fpm:FocusPanelManager, withBoundary:Boolean) : void {
			// Add a test ground overlay
			var towerIcon:BitmapAsset = _getImage(_photo);
			
			// Extract the position associated with remoteObject(Tower)			
			var gposition:LatLng = new LatLng(latitude, longitude);
			
			// Create test overlays
			var markerOptions : MarkerOptions = new MarkerOptions();
			markerOptions.icon = towerIcon;
			markerOptions.iconAlignment = MarkerOptions.ALIGN_BOTTOM | MarkerOptions.ALIGN_HORIZONTAL_CENTER;
			markerOptions.hasShadow = true;
			markerOptions.clickable = true;
			markerOptions.radius = 5;
			markerOptions.draggable = drag;
			
			// Create the marker
			towerMarker = new TowerSaintMarker(this, gposition, markerOptions, map);
			
			// Create an event manager associated with the marker
			this.tMEventManager = new EventManager(towerMarker)
			
			this.tMEventManager.addEventListener(MapMouseEvent.CLICK, fpm.onMarkerClick);
			if(drag){
				// Add events associated with the dragging of the marker on the screen
				this.tMEventManager.addEventListener(MapMouseEvent.DRAG_START, this.onTowerDragStart);
				this.tMEventManager.addEventListener(MapMouseEvent.DRAG_END, this.onTowerDragEnd);
			}
			
			// Add the marker to the map
			map.addOverlay(towerMarker);
			
			// Copy over the icon data
			icon = new BitmapAsset(towerIcon.bitmapData.clone());
			
			// Potentially add a boundary
			if(withBoundary){
				this.generateBoundaryPolygon(map);
			}
			var e:ChannelAttackEvent;
			var r:ChannelJavascriptBridge;
		}
		
		// Generate the boundary around the objects
		private function generateBoundaryPolygon(m:Map) : void {
			// Get the position of the marker
			var pos:LatLng = this.towerMarker.getLatLng();
			
			// Get the influence
			var influence:Number = this.getMaxInfluence();
			
			// Get the width of the image
			var options:MarkerOptions = towerMarker.getOptions();
			var icon:BitmapAsset = options.icon as BitmapAsset;
			var data:BitmapData = icon.bitmapData;
			var width:Number = data.width;
			
			// Get the game constants
			var aspectRatio:Number = GameConstants.getAspectRatio(m);
			var lonOffset:Number = influence  * GameConstants.getLatOffsetFromMarkerPixelWidth(width, m);
			var latOffset:Number =  lonOffset * aspectRatio;
			
			// Get the points associated with the boundary
			var points:Array = this.generateSquarePolygonPoints(pos, latOffset, lonOffset);
			
			// Create a polygon for an empire boundary
			var boundaryColor:Number = 0xffffff;
			var polygon:Polygon = new Polygon(points, 
				new  PolygonOptions({ 
					strokeStyle: new StrokeStyle({
						color: boundaryColor,
						thickness: 5,
						alpha: 1.0}), 
					fillStyle: new FillStyle({
						color: boundaryColor,
						alpha: 0.5})
				}));
			
			// Add the boundary object
			// Keep a reference to the focus polygon.
			this.boundaryPolygon = polygon;
			
			// Add the polygon to the map
			m.addOverlay(this.boundaryPolygon);
		}
		
		// Events associated with the dragging of a marker
		protected function onTowerDragStart(event:MapMouseEvent) : void {
			var m:Map = towerMarker.getMap();
			m.removeOverlay(this.focusPolygon);
		}
		protected function onTowerDragEnd(event:MapMouseEvent) : void {
			createFocusPolygonAtPosition(true);
		}
		
		// Erase the marker
		public function eraseFromMap(map:Map) : void {
			if(towerMarker != null){
				map.removeOverlay(towerMarker);
			}
		}
		
		public function setFocusOnObject(error:Boolean) : void{
			// Remove the polygon
			if(focusPolygon != null){
				var m:Map = towerMarker.getMap();
				m.removeOverlay(this.focusPolygon);
			}
			
			// Set the focus
			createFocusPolygonAtPosition(error);
			hasFocus = true;
		}
		
		public function removeFocusOnObject() : void {
			// Change focus state
			hasFocus = false;
			
			// Remove from the map
			var m:Map = towerMarker.getMap();
			if(m != null){
				m.removeOverlay(this.focusPolygon);
			}
		}
		
		private function createFocusPolygonAtPosition(color:Boolean):void {
			// The position on the map, and the map
			var pos:LatLng = towerMarker.getLatLng();
			var m:Map = towerMarker.getMap();
			
			// Get the color
			var pColor:Number;
			if(color){
				pColor = 0xFF0000;
			}else{
				pColor = 0x00FF00;
			}
			
			// Get the width of the image
			var options:MarkerOptions = towerMarker.getOptions();
			var icon:BitmapAsset = options.icon as BitmapAsset;
			var data:BitmapData = icon.bitmapData;
			var width:Number = data.width;
			
			// Get the game constants
			var aspectRatio:Number = GameConstants.getAspectRatio(m);
			var latOffset:Number = aspectRatio * GameConstants.getLatOffsetFromMarkerPixelWidth(width, m);
			var lonOffset:Number = latOffset;
			
			// Create the polygon
			var points:Array = this.generateSquarePolygonPoints(pos, latOffset, lonOffset);
			var polygon:Polygon = new Polygon(points, 
				new  PolygonOptions({ 
					strokeStyle: new StrokeStyle({
						color: pColor,
						thickness: 5,
						alpha: 0.7}), 
					fillStyle: new FillStyle({
						color: pColor,
						alpha: 0.0})
				}));
			
			// Keep a reference to the focus polygon.
			this.focusPolygon = polygon;
			
			// Add the polygon to the map
			m.addOverlay(this.focusPolygon);
			
		}
		
		private function generateSquarePolygonPoints(pos:LatLng, latOffset:Number, lonOffset:Number):Array {
			var lat:Number = pos.lat(); 
			var lon:Number = pos.lng();
			var firstPoint:LatLng = new LatLng(lat - latOffset, lon - lonOffset);
			return [firstPoint, 
				    new LatLng(lat - latOffset, lon + lonOffset), 
				    new LatLng(lat + latOffset, lon + lonOffset),
			     	new LatLng(lat + latOffset, lon - lonOffset), 
			    	firstPoint];
		}
		
		public function getMarker():TowerSaintMarker {
			return towerMarker;
		}
		
		public function getMarkerEventManager():EventManager {
			return tMEventManager;
		}
		
		private function _getImage(_photo:PhotoAssets):BitmapAsset {
			var towerIcon:BitmapAsset;
			switch(Level){
				// Tower image
				case 0:
					towerIcon =  new _photo.TowerLevel0() as BitmapAsset;
					break;
				// Fort image
				case 1:
					towerIcon = new _photo.TowerLevel1() as BitmapAsset;
					break;
				// Castle image
				case 2:
					towerIcon = new _photo.TowerLevel2() as BitmapAsset;
					break;
				// TowerSaint image
				case 3:
					towerIcon = new _photo.TowerSaint() as BitmapAsset;
					break;
				default:
					towerIcon =  new _photo.TowerLevel0() as BitmapAsset;
					break;
			}
			return towerIcon
		}
		
		public function getImage(photo:PhotoAssets):BitmapAsset {
			return this._getImage(photo);
		}
		
		private function onMarkerClick(event:MapMouseEvent) : void {
			
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
			if(this.isCapital){
				s+="Capital\n";
			}
			s+="Experience\t" + Experience.toString() + "\n";
			s+="Speed\t\t" + Speed.toString() + "\n";
			s+="Power\t\t" + Power.toString() + "\n";
			s+="Armor\t\t" + Armor.toString() + "\n";
			s+="Range\t\t" + Range.toString() + "\n";
			s+="Accuracy\t" + Accuracy.toPrecision(2) + "\n";
			s+="HitPoints\t" + HitPoints.toString() + "\n";
			s+="Level\t\t" + Level.toString() + "\n";
			s+="ManaProduction\t" + manaProduction.toString() + "\n";
			s+="StoneProduction\t" + stoneProduction.toString() + "\n";
			s+="WoodProduction\t" + woodProduction.toString() + "\n";
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
			switch(this.Level){
				case 0:
					return 5.;
				case 1:
					return 10.;
				case 2:
					return 20.;
				case 3:
					return 40.;
				default:
					return 5.;
			}
		}
		public function getPosition(b:LatLngBounds):LatLng{
			return new LatLng(this.latitude, this.longitude);
		}
	}
}