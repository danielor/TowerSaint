package models
{
	import assets.ColladaAssetLoader;
	import assets.PhotoAssets;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.events.MouseEvent3D;
	import away3d.loaders.Collada;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.interfaces.IProjection;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.overlays.Polygon;
	import com.google.maps.overlays.PolygonOptions;
	import com.google.maps.styles.FillStyle;
	import com.google.maps.styles.StrokeStyle;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import managers.EventManager;
	import managers.GameFocusManager;
	
	import messaging.ChannelJavascriptBridge;
	import messaging.events.ChannelAttackEvent;
	
	import models.away3D.Tower3D;
	import models.constants.GameConstants;
	import models.map.TowerSaintMarker;
	
	import mx.controls.Alert;
	import mx.controls.List;
	import mx.core.BitmapAsset;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;

	[Bindbale]
	[RemoteClass(alias="models.Tower")]
	public class Tower implements BoundarySuperObject, IEventDispatcher
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
		public var isComplete:Boolean;
		public var hasRuler:Boolean;
		public var Level:Number;
		public var foundingDate:Date;											/* The date the tower was begun */
		
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
		private var hasFocus:Boolean;													/* True if the current object has user focus */
		private var _atValidLocation:Boolean;											/* Flag true if a valid location is used */
		private var _isDragging:Boolean;												/* Flag true if the tower is being dragged */
		private var _isDrawn:Boolean;													/* Flag for when the tower is drawn */
		private var currentPoint:Point;													/* The current position of the 3d model in AWAY3D coordinates */
		public static const AT_VALID_LOCATION_CHANGE:String = "AtValidLocation";		/* Event string associated with the object */
		public static const ON_DRAG_START:String = "OnDragStart";						/* Event string for the tower dragging */
		public static const ON_DRAG_END:String = "OnDragEnd";							/* Event string for the tower dragging */
		
		// Keep a reference to the marker
		private var towerMarker:TowerSaintMarker;										/* The marker to be drawn on the map */
		private var focusPolygon:Polygon;												/* The polygon used to show focus */
		private var boundaryPolygon:Polygon;											/* The polygon associated with the boundary */
		private var tMEventManager:EventManager;										/* Manages events of the tower view */
		private var towerBounds:LatLngBounds;											/* Get the bounds of the 
		
		// Item Renderer interface (HUserObjectRenderer)
		public const alias:String = "Tower";											/* The name of the tower */
		public var icon:BitmapAsset;													/* The icon associated with the current tower */
		private var model:Tower3D;														/* The 3D representation */
		private var modelDispatcher:EventDispatcher;									/* The event dispatcher sends events */
		
		public function Tower()
		{
			
			// Set the initial state of the tower
			this._atValidLocation = true;		
			this.hasFocus = false;
			this._isDragging = false;
			this._isDrawn = false;
			this.modelDispatcher = new EventDispatcher(this);					/* Create the event dispatcher */
			this.model = new Tower3D(.1);										/* Create the view */
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
		
		public static function createUserTowerFromJSON(buildObject:Object, u:User) : Tower {
			var t:Tower = new Tower();
			t.Experience = buildObject.experience;
			t.Speed = buildObject.speed;
			t.Power = buildObject.power;
			t.Armor = buildObject.armor;
			t.Range = buildObject.range;
			t.Accuracy = buildObject.accuracy;
			t.HitPoints = buildObject.hitpoints;
			t.isIsolated = buildObject.isisolated;
			t.isCapital = buildObject.iscapital;
			t.hasRuler = buildObject.hasRuler;
			t.user = u;
			t.manaProduction = buildObject.manaproduction;
			t.stoneProduction = buildObject.stoneproduction;
			t.woodProduction = buildObject.woodproduction;
			t.Level = buildObject.level;
			t.latitude = buildObject.latitude;
			t.longitude = buildObject.longitude;
			return t;
		}
		
		// Valid Location is a flag used when the 
		public function set atValidLocation(iVL:Boolean) : void {
			// Create a proprety change event
			if(this._atValidLocation != iVL){
				// Change the property before sending out the event
				this._atValidLocation = iVL;
				
				// Send out a property change event
				var event:PropertyChangeEvent = new PropertyChangeEvent(Tower.AT_VALID_LOCATION_CHANGE, false, false, 
					PropertyChangeEventKind.UPDATE, 'atValidLocation', this._atValidLocation, iVL, this);
				this.dispatchEvent(event);
			}
			
		}
		public function get atValidLocation() : Boolean {
			return this._atValidLocation;
		}
		
		
		public static function createTowerFromJSON(buildObject:Object):Tower{
			var t:Tower = new Tower();
			t.Level = buildObject.level;
			t.latitude = buildObject.latitude;
			t.longitude = buildObject.longitude;
			t.user = User.createUserFromJSON(buildObject.user);
			return t;
		}
		
		public function initialize(u:User): void {
			this.Experience = 0;
			this.Speed = 1;
			this.Power = 1;
			this.Armor = 1;
			this.Range = 1;
			this.Accuracy = .5;
			this.HitPoints = 100;
			this.isIsolated = false;
			this.isCapital = false;
			this.hasRuler = true;
			//this.user = u;
			this.manaProduction = 50 + Math.floor( Math.random() * 50);
			this.stoneProduction = 50 + Math.floor( Math.random() * 50);
			this.woodProduction = 50 + Math.floor( Math.random() * 50);
			this.Level = 0;

		}

		// Update the position of the tower
		public function updatePosition(loc:LatLng): void{
			this.latitude = loc.lat();
			this.longitude = loc.lng();
		
			if(this.towerMarker != null){
				this.towerMarker.setLatLng(loc); 
			}
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
			output.writeInt(this.manaProduction);
			output.writeInt(this.stoneProduction);
			output.writeInt(this.woodProduction);
			output.writeInt(this.Level);
			output.writeInt(this.latIndex);
			output.writeInt(this.lonIndex);
			output.writeFloat(this.latitude);
			output.writeFloat(this.longitude);
			output.writeObject(this.foundingDate);
			
			
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
			this.foundingDate = input.readObject();
		}
		
		public function toString() : String {
			var s:String = "";
			s = s + this.Experience.toString() + ":";
			s = s + this.Speed.toString() + ":";
			s = s + this.Power.toString() + ":";
			s = s + this.Armor.toString() + ":";
			s = s + this.Range.toString() + ":";
			s = s + this.HitPoints.toString() + ":";
			s = s + this.isIsolated.toString() + ":";
			s = s + this.isCapital.toString() + ":";
			s = s + this.hasRuler.toString() + "\n";
			s = s + this.manaProduction.toString() + ":";
			s = s + this.stoneProduction.toString() + ":";
			s = s + this.woodProduction.toString() + ":";
			s = s + this.Level.toString() + ":";
			s = s + this.latIndex.toString() + ":";
			s = s + this.lonIndex.toString() + ":";
			s = s + this.latitude.toString() + ":";
			s = s + this.longitude.toString() + ":";
			return s;
		}
		
		/* Override the event listener to use the marker event manager where appropriate. If not away3D's base class is a displayObject */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			if(this.tMEventManager == null){
				this.modelDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}else{
				var mouseEventArray:Array = [MapMouseEvent.CLICK, MapMouseEvent.DOUBLE_CLICK, MapMouseEvent.DRAG_END, MapMouseEvent.DRAG_START, 
				MapMouseEvent.DRAG_STEP, MapMouseEvent.MOUSE_DOWN, MapMouseEvent.MOUSE_MOVE, MapMouseEvent.MOUSE_UP, MapMouseEvent.ROLL_OUT,
				MapMouseEvent.ROLL_OVER];
				if(mouseEventArray.indexOf(type) >= 0 ){
					this.tMEventManager.addEventListener(type,listener, useCapture, priority, useWeakReference);
				}else{
					this.modelDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
				}
			}
		}
		
		
		
		public function draw(drag:Boolean, map:Map, _photo:PhotoAssets, fpm:GameFocusManager, withBoundary:Boolean, scene:Scene3D, view:View3D) : void {
			
			// TODO: Make this more robust
			// Create a bounding box. 2~ is an estimation of a bounding box
			var bitmapData:BitmapData = new BitmapData(this.model.objectWidth / 2., this.model.objectHeight / 2., true, 0x00FFFFFF);
			var asset:BitmapAsset = new BitmapAsset(bitmapData);
			
			// Extract the position associated with remoteObject(Tower)			
			var gposition:LatLng = new LatLng(latitude, longitude);
			
			// Create test overlays
			var markerOptions : MarkerOptions = new MarkerOptions();
			markerOptions.icon = asset;
			markerOptions.iconAlignment = MarkerOptions.ALIGN_BOTTOM | MarkerOptions.ALIGN_HORIZONTAL_CENTER;
			markerOptions.hasShadow = true;
			markerOptions.clickable = true;
			markerOptions.radius = 5;
			markerOptions.draggable = drag;
			
			// Create the marker
			towerMarker = new TowerSaintMarker(this, gposition, markerOptions, map, view);

			
			// Create an event manager associated with the marker
			this.tMEventManager = new EventManager(towerMarker);
			this.tMEventManager.addEventListener(MapMouseEvent.CLICK, onMarkerClick);
			if(drag){
				// Add events associated with the dragging of the marker on the screen
				this.tMEventManager.addEventListener(MapMouseEvent.DRAG_START, this.onTowerDragStart);
				this.tMEventManager.addEventListener(MapMouseEvent.DRAG_END, this.onTowerDragEnd);
			}
			
			// Add the marker to the map
			map.addOverlay(towerMarker);
			
			// Copy over the icon data
			icon = _getImage(_photo);
			
			// Potentially add a boundary
			if(withBoundary){
				this.generateBoundaryPolygon(map);
			}
		
			// Change the state of the program
			this._isDrawn = true;
			
			// Map the position to the map
			var position:LatLng = new LatLng(this.latitude, this.longitude);
			currentPoint = GameConstants.fromMapToAway3D(position, map);
			this.model.x = currentPoint.x;
			this.model.y = currentPoint.y;
			this.model.z = 0.;
			this.model.ownCanvas = true;
			
			// Add the container to the scene
			scene.addChild(this.model);
			
			// Create the bounds around the point
			this.createBoundsAroundPoint(gposition, map, view);
		}
		
		private function createBoundsAroundPoint(gposition:LatLng, map:Map, view:View3D):void {
			// Find the bouds of the object
			var bounds:LatLngBounds = map.getLatLngBounds();
			var width:Number = Math.abs(this.model.minX - this.model.maxX);
			var height:Number = Math.abs(this.model.minY - this.model.maxY);
			var widthFraction:Number = width / view.width;
			var heightFraction:Number = height / view.height;
			var latFraction:Number = heightFraction * Math.abs(bounds.getNorth() - bounds.getSouth());
			var lonFraction:Number = widthFraction * Math.abs(bounds.getEast() - bounds.getWest());
			var sw:LatLng = new LatLng(gposition.lat() - latFraction / 2., gposition.lng() - lonFraction/2.);
			var ne:LatLng = new LatLng(gposition.lat() + latFraction / 2., gposition.lng() + lonFraction/2.);
			towerBounds = new LatLngBounds(sw, ne);
		}
		
		private function onMouseDown(e:MouseEvent3D):void {
			Alert.show(e.sceneX + ":" + e.sceneY + ":" + e.sceneZ);
		}
		private function onMouseUp(e:MouseEvent3D):void {
			
		}	
	
		public function getBounds():LatLngBounds{
			return this.towerBounds;
		}
		
		public function getNameString():String {
			return "Tower";
		}
		
		public function isAtValidLocation():Boolean {
			return this._atValidLocation;
		}
		
		
		// Generate the boundary around the objects
		private function generateBoundaryPolygon(m:Map) : void {
			// Get the position of the marker
			var pos:LatLng = new LatLng(this.latitude, this.longitude);
			
			// Get the influence
			var influence:Number = this.getMaxInfluence();
			
			// Get the width of the image
			var width:Number = Math.abs(this.model.minX - this.model.maxX);
			
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
			
			// Let the PolygonEmpireBoudnary handle the drawing of the boundary
			// Add the polygon to the map
			//m.addOverlay(this.boundaryPolygon);
		}
		
		public function getBoundaryPolygon():Polygon {
			return this.boundaryPolygon;
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
		
		// Events associated with the dragging of a marker
		public function onTowerDragStart(event:MapMouseEvent) : void {
			var m:Map = towerMarker.getMap();
			m.removeOverlay(this.focusPolygon);
			this._isDragging = true;

			// Dispatch that we have begun dragging the tower
			var e:PropertyChangeEvent = new PropertyChangeEvent(Tower.ON_DRAG_START, false, false, 
				PropertyChangeEventKind.UPDATE, 'onDragStart', this._isDragging, true, this);
			this.dispatchEvent(e);
		}
		public function onTowerDragEnd(event:MapMouseEvent) : void {
			//createFocusPolygonAtPosition(true);
			var l:LatLng = event.latLng;

			// Update the position
			var m:Map = this.towerMarker.getMap();
			var v:View3D = this.towerMarker.getView();
			currentPoint = GameConstants.fromMapToAway3D(l, m);
			this.model.x = currentPoint.x;
			this.model.y = currentPoint.y;
			
			// Set the flag
			this._isDragging = false;
			
			// Update the position and redraw the boundary
			this.latitude = l.lat();
			this.longitude = l.lng();
			this.generateBoundaryPolygon(m);
			
			// Update the bounds of the object
			this.createBoundsAroundPoint(l, m, v);
			
			// Dispatch that we have begun dragging the tower
			var e:PropertyChangeEvent = new PropertyChangeEvent(Tower.ON_DRAG_END, false, false, 
				PropertyChangeEventKind.UPDATE, 'onDragEnd', this._isDragging, true, this);
			this.dispatchEvent(e);
			
		}
		public function isReady():Boolean{
			return !this._isDragging;
		}
		
		// Erase the marker
		public function eraseFromMap(map:Map) : void {
			if(towerMarker != null){
				map.removeOverlay(towerMarker);
			}
			
			if(this.boundaryPolygon != null){
				map.removeOverlay(this.boundaryPolygon);
			}
		}
		
		// Hide the 3d model
		public function hide():void {
			var p:Point = GameConstants.hideAWAY3DCoordinate();
			this.model.x = p.x;
			this.model.y = p.y;
		}
		// View the 3D model
		public function view():void {
			this.model.x = this.currentPoint.x;
			this.model.y = this.currentPoint.y;
		}
		// Flag for the 3D model
		public function isDrawn():Boolean{
			return this._isDrawn;
		}
		public function updateBuildState(i:Number) : void {
			if(this.towerMarker != null){
				var m:MarkerOptions = this.towerMarker.getOptions();
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
		
		// Check if the tower is equal to another object
		public function isEqual(s:SuperObject) : Boolean {
			if(s is Tower){
				var t:Tower = s as Tower;
				var pos:LatLng = new LatLng(this.latitude, this.longitude);
				var tpos:LatLng = new LatLng(t.latitude, t.longitude);
				if(pos.equals(tpos) && this.Experience == t.Experience && this.Speed == t.Speed && this.Power == t.Power &&
					this.Armor == t.Armor && this.Range == t.Range && this.Accuracy == t.Accuracy && 
					this.HitPoints == t.HitPoints && this.isIsolated == t.isIsolated && this.isCapital == t.isCapital &&
					this.hasRuler == t.hasRuler && this.user.isEqual(t.user) && this.Level == t.Level &&
					this.manaProduction == t.manaProduction && this.stoneProduction == t.stoneProduction &&
					this.woodProduction == t.woodProduction){
					return true;
				}else{
					return false;
				}
			}else{
				return false;
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
		
		public function getProduction():Production {
			return new Production(this.woodProduction, this.stoneProduction, this.manaProduction);
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
		
		/* Extract the 3D model that corresponds to the level of the model */
		private function _get3DModel(_collada:ColladaAssetLoader):Class {
			var newClass:Class;
			switch(this.Level){
				case 0:
					newClass = ColladaAssetLoader.TowerLevel0;
					break;
				case 1:
					newClass =  ColladaAssetLoader.TowerLevel0;
					break;
				case 2:
					newClass = ColladaAssetLoader.TowerLevel0;
					break;
				case 3:
					newClass =  ColladaAssetLoader.TowerLevel0;
					break;
				default:
					break;
			}
			return newClass;
		}
		
		public function getImage(photo:PhotoAssets):BitmapAsset {
			return this._getImage(photo);
		}
		
		private function onMarkerClick(event:MapMouseEvent) : void {
			
		}
		
		public function hasBoundary():Boolean {
			return true;
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
		
		// The Boundary interface
		private function getBoundsForScope( m:Map, influence:Number):LatLngBounds {
			// Get the position of the marker
			var pos:LatLng = this.towerMarker.getLatLng();
			
			// Get the width of the image
			var options:MarkerOptions = towerMarker.getOptions();
			var icon:BitmapAsset = options.icon as BitmapAsset;
			var data:BitmapData = icon.bitmapData;
			var width:Number = data.width;
			
			// Get the game constants
			var aspectRatio:Number = GameConstants.getAspectRatio(m);
			var lonOffset:Number = influence  * GameConstants.getLatOffsetFromMarkerPixelWidth(width, m);
			var latOffset:Number =  lonOffset * aspectRatio;
			
			// Create the bounds
			var southWest:LatLng = new LatLng(pos.lat() - latOffset, pos.lng() - lonOffset);
			var northEast:LatLng = new LatLng(pos.lat() + latOffset, pos.lng() + lonOffset);
			return new LatLngBounds(southWest, northEast);
		}
		
		public function isInsideBoundary(pos:LatLng, m:Map):Boolean {
			// Get the influence
			var influence:Number = this.getMaxInfluence();
	
			var bounds:LatLngBounds = getBoundsForScope( m, influence);
			return bounds.containsLatLng(pos);
		
		}
		
		public function isOverLappingBoundsOfObject(pos:LatLng, m:Map, photo:PhotoAssets) : Boolean {
			var iPos:LatLng = this.towerMarker.getLatLng();
			var bounds:LatLngBounds = GameConstants.getBaseLatticeBounds(iPos, m, photo);
			return bounds.containsLatLng(pos);
		}
	}
}