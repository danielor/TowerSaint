package models
{
	import assets.PhotoAssets;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	
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
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import managers.EventManager;
	import managers.GameFocusManager;
	
	import models.constants.GameConstants;
	import models.interfaces.SuperObject;
	import models.map.TowerSaintMarker;
	
	import mx.core.BitmapAsset;

	[Bindable]
	[RemoteClass(alias="models.Road")]
	public class Road  implements SuperObject, IEventDispatcher
	{
		// Information
		public var hitPoints:Number;
		public var level:Number;
		public var isComplete:Boolean;
		public var foundingDate:Date;											/* The date the tower was begun */
		
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
		
		// Dispatcher of events
		private var modelDispatcher:EventDispatcher;							/* Dispatch events associated with roads */
		private var modelEventManager:EventManager;								/* The event manager associated with the object */
		
		public function Road()
		{
			super();
			this.modelDispatcher = new EventDispatcher(this);
		}
		
		/* The dispatcher interface */
		public function dispatchEvent(evt:Event):Boolean{
			return modelDispatcher.dispatchEvent(evt);
		}
		
		public function hasEventListener(type:String):Boolean{
			return modelDispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			modelDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean {
			return modelDispatcher.willTrigger(type);
		}
		/* Override the event listener to use the marker event manager where appropriate. If not away3D's base class is a displayObject */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			if(this.modelEventManager == null){
				this.modelDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}else{
				var mouseEventArray:Array = [MapMouseEvent.CLICK, MapMouseEvent.DOUBLE_CLICK, MapMouseEvent.DRAG_END, MapMouseEvent.DRAG_START, 
				MapMouseEvent.DRAG_STEP, MapMouseEvent.MOUSE_DOWN, MapMouseEvent.MOUSE_MOVE, MapMouseEvent.MOUSE_UP, MapMouseEvent.ROLL_OUT,
				MapMouseEvent.ROLL_OVER];
				if(mouseEventArray.indexOf(type) >= 0 ){
					this.modelEventManager.addEventListener(type,listener, useCapture, priority, useWeakReference);
				}else{
					this.modelDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
				}
			}
		}
		/* Override towersaitndispatcher fuctions */
		public function removeAllEvents():void{
			if(this.modelEventManager != null){
				this.modelEventManager.RemoveEvents();
			}
		}
		public function removeEvent(s:String, f:Function):void {
			if(this.modelEventManager != null){
				this.modelEventManager.removeEventListener(s, f);
			}
		}
		
		// Returns a stateful equal
		public function statelessEqual(s:SuperObject):Boolean {
			return true;
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
		
		public function setValid(valid:Boolean, intern:Boolean):void {
			
		}
		
		public function initialize(u:User) : void {
			this.user = user;
			this.hitPoints = 50;
			this.level = 0;
		}
		
		public function getNameString():String {
			return "Road";
		}
		
		public function getProduction():Production {
			return new Production(0., 0., 0.);
		}
		
		public function redrawModelInShiftedFrame():void {
			
		}
		
		
		// Hide the 3d model
		public function hide():void {
			// TODO
		}
		// View the 3D model
		public function view():void {
			// TODO
		}
		// Return the drawing state
		public function isDrawn():Boolean{
			// TODO
			return false;
		}
		
		public static function createUserRoadFromJSON(buildObject:Object, u:User):Road {
			var r:Road = new Road();
			r.hitPoints = buildObject.hitpoints;
			r.level = buildObject.level;
			r.latitude = buildObject.latitude;
			r.longitude = buildObject.longitude;
			r.isComplete = buildObject.iscomplete;
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
		public function draw(drag:Boolean, map:Map, photo:PhotoAssets, fpm:GameFocusManager, withBoundary:Boolean, scence:Scene3D, view:View3D) : void{
			
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
			roadMarker = new TowerSaintMarker(this, gposition, markerOptions, map, view);
			roadMarker.addEventListener(MapMouseEvent.CLICK, fpm.onMarkerClick);
			map.addOverlay(roadMarker);
			
			// Create an event manager
			this.modelEventManager = new EventManager(roadMarker);
		}
		
		// Function is true if initialized
		public function hasInit():Boolean{
			return true;
		}
		
		public function isReady():Boolean{
			return true;
		}
		
		public function isAtValidLocation():Boolean {
			return false;
		}
		
		// Erase the marker
		public function eraseFromMap(map:Map, s:Scene3D) : void {
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

		public function updateBuildState(i:Number) : void {
			if(roadMarker != null){
				var m:MarkerOptions = roadMarker.getOptions();
				var bitmap:BitmapAsset = m.icon as BitmapAsset;
				var data:BitmapData = bitmap.bitmapData;
				
				// Check if we can make the image transparent
				if(data.transparent){
					data.lock();
					for(var h:int = 0; h < data.height; h++){
						for(var w:int = 0; w < data.width; w++){
							var oldColor:uint = data.getPixel32(h, w);
							var color:uint = (0xFF000000 * (i)) | (0x00FFFFFF & oldColor);
							data.setPixel32(h, w, color);
						}
					}
					data.unlock();
				}
			}
		}
		public function isIncompleteState():Boolean{
			return this.isComplete;
		}
		
		public function getFoundingDate():Date{
			return this.foundingDate;
		}
		
		public function setUser(u:User):void {
			this.user = u;
		}
		
		public function getBoundaryPolygon():Polygon {
			return new Polygon([]);
		}
		
		public function isEqual(s:SuperObject) : Boolean {
			if(s is Road){
				var r:Road = s as Road;
				var pos:LatLng = new LatLng(this.latitude, this.longitude);
				var cpos:LatLng = new LatLng(this.latitude, this.longitude);
				if(pos.equals(cpos) && this.hitPoints == r.hitPoints  && this.level == r.level && 
					this.user.isEqual(r.user)){
					return true;
				}else{
					return false;
				}
			}else{
				return false;
			}
			
		}
			
		public function getBounds():LatLngBounds{
			return new LatLngBounds(new LatLng(0, 0), new LatLng(0, 0));
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
