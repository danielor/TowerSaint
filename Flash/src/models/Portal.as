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
	[RemoteClass(alias="models.Portal")]
	public class Portal  implements SuperObject
	{
		// Information
		public var hitPoints:int;
		public var level:int;
		public var isComplete:Boolean;
		
		// Who owns it?
		public var user:User;
		
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
		public var foundingDate:Date;											/* The date the tower was begun */
	
		// State variable
		private var isModified:Boolean;
		private var hasFocus:Boolean;											/* True if the current object has user focus */
		private var portalMarker:TowerSaintMarker;								/* The marker to be drawn on the map */
		private var focusPolygon:Polygon;	
		
		// Event variables
		private var modelDispatcher:EventDispatcher;							/* Dispatch events associated with roads */
		private var modelEventManager:EventManager;								/* The event manager associated with the object */
		
		public function Portal()
		{
			super();
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
			p.isComplete = buildObject.iscomplete;
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
		
		// Function is true if initialized
		public function hasInit():Boolean{
			return true;
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
		
		public function getNameString():String {
			return "Portal";
		}
		
		public function redrawModelInShiftedFrame():void {
			
		}
		
		public function getProduction():Production {
			return new Production(0., 0., 0.);
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
		
		public function draw(drag:Boolean, map:Map, photo:PhotoAssets, fpm:GameFocusManager, withBoundary:Boolean,  scence:Scene3D, view:View3D) : void {
			// Extract the position associated with remoteObject(Tower)			
			var firstPosition:LatLng = new LatLng(endLocationLatitude, endLocationLongitude);
			var secondPosition:LatLng = new LatLng(startLocationLatitude, startLocationLongitude);

			// Create both portals
			var bounds:LatLngBounds = map.getLatLngBounds();
			if(bounds.containsLatLng(firstPosition)){
				_drawPortal(firstPosition, photo, map, drag, fpm, view);
			}
			if(bounds.containsLatLng(secondPosition)){
				_drawPortal(secondPosition, photo, map, drag, fpm, view);
			}
		}
		
		public function getBounds():LatLngBounds{
			return new LatLngBounds(new LatLng(0, 0), new LatLng(0, 0));
		}
		
		public function isAtValidLocation():Boolean {
			return true;
		}
		
		public function setValid(valid:Boolean, intern:Boolean):void {
			
		}
		
		private function _drawPortal(pos:LatLng, photo:PhotoAssets, map:Map, drag:Boolean, fpm:GameFocusManager, view:View3D) : void {
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
			portalMarker = new TowerSaintMarker(this, pos, markerOptions, map, view);
			portalMarker.addEventListener(MapMouseEvent.CLICK, fpm.onMarkerClick);
			map.addOverlay(portalMarker);
			
		}
		
		// Erase the marker
		public function eraseFromMap(map:Map, s:Scene3D) : void {
			map.removeOverlay(portalMarker);
		}
		
		public function setFocusOnObject(error:Boolean) : void{
			createFocusPolygonAtPosition(error);
			hasFocus = true;
		}
		public function isReady():Boolean{
			return true;
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
		
		// Compare two operators
		public function isEqual(s:SuperObject) : Boolean {
			if(s is Portal){
				// Convert to the portal interface
				var p:Portal = s as Portal;
				
				// Create the positions
				var thisStart:LatLng = new LatLng(this.startLocationLatitude, this.startLocationLongitude);
				var thisEnd:LatLng = new LatLng(this.endLocationLatitude, this.endLocationLongitude);
				var cStart:LatLng = new LatLng(p.startLocationLatitude, p.startLocationLongitude);
				var cEnd:LatLng = new LatLng(p.endLocationLatitude, p.endLocationLongitude);
				if(thisStart.equals(cStart) && thisEnd.equals(cEnd) && this.hitPoints == p.hitPoints && 
					this.level == level && this.user.isEqual(p.user)){
					return true;
				}else{
					return false;
				}
			}else{
				return false;
			}
		}
		
		// Update the state.
		public function updateBuildState(i:Number) : void {
			if(portalMarker != null){
				var m:MarkerOptions = portalMarker.getOptions();
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