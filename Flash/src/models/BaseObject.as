package models
{
	import assets.ColladaAssetLoader;
	import assets.PhotoAssets;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
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
	
	import models.away3D.RoadPath;
	import models.away3D.Tower3D;
	import models.constants.GameConstants;
	import models.interfaces.BoundarySuperObject;
	import models.interfaces.FilteredObject;
	import models.interfaces.SuperObject;
	import models.map.TowerSaintMarker;
	
	import mx.controls.Alert;
	import mx.controls.List;
	import mx.core.BitmapAsset;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	public class BaseObject implements SuperObject, IEventDispatcher
	{
		// State information representative of all objects
		private var isModified:Boolean;
		private var hasFocus:Boolean;													/* True if the current object has user focus */
		protected var isInitialized:Boolean;											/* Flag true if initialized */
		private var _atValidLocation:Boolean;											/* Flag true if a valid location is used */
		private var _isDragging:Boolean;												/* Flag true if the tower is being dragged */
		private var _isDrawn:Boolean;													/* Flag for when the tower is drawn */
		private var currentPoint:Point;													/* The current position of the 3d model in AWAY3D coordinates */
		public static const AT_VALID_LOCATION_CHANGE:String = "AtValidLocation";		/* Event string associated with the object */
		public static const ON_DRAG_START:String = "OnDragStart";						/* Event string for the tower dragging */
		public static const ON_DRAG_END:String = "OnDragEnd";							/* Event string for the tower dragging */
		protected var marker:TowerSaintMarker;											/* The marker to be drawn on the map */
		private var focusPolygon:Polygon;												/* The polygon used to show focus */
		private var boundaryPolygon:Polygon;											/* The polygon associated with the boundary */
		private var markerEventManager:EventManager;									/* Manages events of the tower view */
		private var modelEventManager:EventManager;										/* The event manager associated with the 3d model */
		private var modelBounds:LatLngBounds;											/* Get the bounds of the object */
		protected var model:Mesh;															/* The 3D model of the object */
		private var modelDispatcher:EventDispatcher;									/* The event dispatcher sends events */
		public var icon:BitmapAsset;													/* The icon associated with the current tower */

		
		public function BaseObject()
		{
			this._atValidLocation = true;
			this.hasFocus = false;
			this._isDragging = false;
			this._isDrawn = false;
			this.isInitialized = false;
			this.modelDispatcher = new EventDispatcher(this);
		}
		
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
		
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
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
		
		public function removeAllEvents():void{
			if(this.modelDispatcher != null){
				this.modelEventManager.RemoveEvents();
			}
		}
		public function removeEvent(s:String, f:Function):void {
			if(this.modelDispatcher != null){
				this.modelDispatcher.removeEventListener(s, f);
			}
		}
		
		public function get3DObject():Mesh {
			return this.model;
		}
		
		public function isDynamicBuild():Boolean{
			return false;
		}
		
		public function getNumberOfBuildStages():Number{
			return 1;
		}
		
		public function drawStage(bS:Number, l:LatLng, p:PhotoAssets):void {
			
		}
		
		public function draw(drag:Boolean, map:Map, photo:PhotoAssets, fpm:GameFocusManager, withBoundary:Boolean, scene:Scene3D, view:View3D):void
		{
			Alert.show("Begin Build");
			var i:Number = 1.9;
			
			if(!this.isDynamicBuild()){
				var bitmapData:BitmapData = new BitmapData(this.model.objectWidth /i, this.model.objectHeight / i, true, 0x00FFFFFF);
				var asset:BitmapAsset = new BitmapAsset(bitmapData);
				
				// Extract the position associated with remoteObject(Tower)		
				var b:LatLngBounds = map.getLatLngBounds();
				var gposition:LatLng = this.getPosition(b);
				
				// Create test overlays
				var markerOptions : MarkerOptions = new MarkerOptions();
				markerOptions.icon = asset;
				markerOptions.iconAlignment = MarkerOptions.ALIGN_BOTTOM | MarkerOptions.ALIGN_HORIZONTAL_CENTER;
				markerOptions.hasShadow = true;
				markerOptions.clickable = true;
				markerOptions.radius = 5;
				markerOptions.draggable = drag;
				
				// Create the marker
				marker = new TowerSaintMarker(this, gposition, markerOptions, map, view);
			
				// Add the marker to the map
				map.addOverlay(this.marker);
				
				// Create the bounds around the point
				this.createBoundsAroundPoint(gposition, map, view);
				this.generateBoundaryPolygon(map);
				
				this.markerEventManager = new EventManager(this.marker);
				this.markerEventManager.addEventListener(MapMouseEvent.CLICK, onMarkerClick);
				if(drag){
					// Add events associated with the dragging of the marker on the screen
					this.markerEventManager.addEventListener(MapMouseEvent.DRAG_START, this.onDragStart);
					this.markerEventManager.addEventListener(MapMouseEvent.DRAG_END, this.onDragEnd);
				}
				
			}
			
			// Copy over the icon data
			icon = getImage(photo);

			
			// Change the state of the program
			this._isDrawn = true;
			// Map the position to the map
			if(!this.isDynamicBuild()){
				currentPoint = GameConstants.fromMapToAway3D(gposition, map);
				this.model.x = currentPoint.x;
				this.model.y = currentPoint.y;
				this.model.z = 0.;
				this.model.ownCanvas = true;
		
				// Add the container to the scene
				scene.addChild(this.model);
			}else{
				// Dynamic build objects (i.e The ones that change with user input)
				// are null upon intial drawing. The intial drawing sets up the 
				// handlers for objects. Away3D does not play nice(buildPrimitive)
				// with empty paths, so this is needed
				// TODO: Other dynamic builds???
				if(this.model is RoadPath){
					var rp:RoadPath = this.model as RoadPath;
					rp.map = map;
					rp.scene = scene;
					rp.view = view;
					if(this.isIncompleteState()){
						this.drawAllStages(photo);
					}
				}
			}	

		}
		
		private function onMarkerClick(event:MapMouseEvent) : void {
			
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
			modelBounds = new LatLngBounds(sw, ne);
		}
		

		public function display():TextFlow
		{
			return null;
		}
		
		// Hide the 3d model
		public function hide():void
		{
			var p:Point = GameConstants.hideAWAY3DCoordinate();
			this.model.x = p.x;
			this.model.y = p.y;
		}
		// View the 3d model
		public function view():void
		{
			Alert.show("View");
			this.model.x = this.currentPoint.x;
			this.model.y = this.currentPoint.y;
		}
		
		public function isDrawn():Boolean
		{
			return this._isDrawn;
		}
		
		public function hasInit():Boolean
		{
			Alert.show(this.isInitialized.toString());
			return this.isInitialized;
		}
		
		public function setValid(valid:Boolean, intern:Boolean):void
		{
			if(intern){
				this._atValidLocation = valid;
			}else{
				this.atValidLocation = valid;
			}
		}
		
		public function set atValidLocation(iVL:Boolean) : void {
			// Create a proprety change event
			if(this._atValidLocation != iVL){
				// Change the property before sending out the event
				this._atValidLocation = iVL;
				
				// Send out a property change event
				var event:PropertyChangeEvent = new PropertyChangeEvent(BaseObject.AT_VALID_LOCATION_CHANGE, false, false,
					PropertyChangeEventKind.UPDATE, 'atValidLocation', this._atValidLocation, iVL, this);
				this.dispatchEvent(event);
			}
			
		}
		
		
		public function statelessEqual(s:SuperObject):Boolean
		{
			if(this.isObject(s)){
				var m:Map = marker.getMap();
				var b:LatLngBounds = m.getLatLngBounds();
				var pos:LatLng = s.getPosition(b);
				var ipos:LatLng = this.getPosition(b);
				return pos.equals(ipos);
			}else{
				return false;
			}
		}
		
		public function isReady():Boolean
		{
			return !this._isDragging;
		}
		
		public function get atValidLocation() : Boolean {
			return this._atValidLocation;
		}
		
		public function isAtValidLocation():Boolean
		{
			return this._atValidLocation;
		}
		
		public function getBounds():LatLngBounds
		{
			return this.modelBounds;
		}
		
		public function initialize(u:User):void
		{
		}
		
		public function eraseFromMap(map:Map, s:Scene3D):void
		{
			Alert.show("Erasing" + this.getNameString());
			if(this.marker != null){
				map.removeOverlay(this.marker);
			}
			if(this.model != null){
				s.removeChild(this.model);
			}
			if(this.boundaryPolygon != null){
				map.removeOverlay(this.boundaryPolygon);
			}
		}
		
		public function setFocusOnObject(error:Boolean):void
		{
			// Remove the polygon
			if(focusPolygon != null){
				var m:Map = this.marker.getMap();
				m.removeOverlay(this.focusPolygon);
			}
			
			// Set the focus
			createFocusPolygonAtPosition(error);
			hasFocus = true;
		}
		
		private function createFocusPolygonAtPosition(color:Boolean):void {
			// The position on the map, and the map
			var pos:LatLng = this.marker.getLatLng();
			var m:Map = this.marker.getMap();
			
			// Get the color
			var pColor:Number;
			if(color){
				pColor = 0xFF0000;
			}else{
				pColor = 0x00FF00;
			}
			
			// Get the width of the image
			var options:MarkerOptions = this.marker.getOptions();
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
		
		public function setPosition(pos:LatLng):void
		{
		}
		
		public function getPosition(b:LatLngBounds):LatLng
		{
			return null;
		}
		
		public function setIsModified(t:Boolean):void
		{
			this.isModified = t;
		}
		
		public function getIsModified():Boolean
		{
			return this.isModified;
		}
		
		public function isEqual(s:SuperObject):Boolean
		{
			return false;
		}
		
		public function updateBuildState(i:Number):void
		{
			
			if(this.model is FilteredObject){
				var f:FilteredObject = this.model as FilteredObject;
				f.updateFilter(i);
			}
			
		}
		
		public function updatePosition(loc:LatLng):void {

		}
		
		public function getImage(photo:PhotoAssets):BitmapAsset
		{
			return null;
		}
		
		public function isVisible(map:Map):Boolean
		{
			var b:LatLngBounds = map.getLatLngBounds();
			var l:LatLng = this.getPosition(b);
			return b.containsLatLng(l);
		}
		
		public function isIncompleteState():Boolean
		{
			return false;
		}
		
		public function getFoundingDate():Date
		{
			return null;
		}
		
		// Upon update of the particles. This will shift the 3D model and the empire
		// boundary on the map
		public function redrawModelInShiftedFrame():void {
			var m:Map = this.marker.getMap();
			var b:LatLngBounds = m.getLatLngBounds();
			var l:LatLng = this.getPosition(b);

			var e:MapMouseEvent = new MapMouseEvent(MapMouseEvent.DRAG_START, this, l);
			this.onDragStart(e);
			this.onDragEnd(e);
		}
		
		// Events associated with the dragging of a marker
		public function onDragStart(event:MapMouseEvent) : void {
			var m:Map = this.marker.getMap();
			if(this.focusPolygon != null){
				m.removeOverlay(this.focusPolygon);
			}
			this._isDragging = true;
			
			// Dispatch that we have begun dragging the tower
			var e:PropertyChangeEvent = new PropertyChangeEvent(BaseObject.ON_DRAG_START, false, false, 
				PropertyChangeEventKind.UPDATE, 'onDragStart', this._isDragging, true, this);
			this.dispatchEvent(e);
		}
		public function onDragEnd(event:MapMouseEvent) : void {
			//createFocusPolygonAtPosition(true);
			var l:LatLng = event.latLng;
	
			// Update the position
			var m:Map = this.marker.getMap();
			var v:View3D = this.marker.getView();
			currentPoint = GameConstants.fromMapToAway3D(l, m);
			this.model.x = currentPoint.x;
			this.model.y = currentPoint.y;
			Alert.show(currentPoint.x.toString() + ":" + currentPoint.y.toString());
			
			// Set the flag
			this._isDragging = false;
			
			// Update the position and redraw the boundary
			this.setPosition(l);
			this.generateBoundaryPolygon(m);
			
			// Update the bounds of the object
			this.createBoundsAroundPoint(l, m, v);
			
			// Dispatch that we have begun dragging the tower
			var e:PropertyChangeEvent = new PropertyChangeEvent(BaseObject.ON_DRAG_END, false, false, 
				PropertyChangeEventKind.UPDATE, 'onDragEnd', this._isDragging, true, this);
			this.dispatchEvent(e);
			
		}
		
		
		// Generate the boundary around the objects
		private function generateBoundaryPolygon(m:Map) : void {
			// Get the position of the marker
			var b:LatLngBounds = m.getLatLngBounds();
			var pos:LatLng = this.getPosition(b);
			
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

		}
		
		
		public function setUser(u:User):void
		{
		}
		
		public function getMaxInfluence():Number
		{
			return 0;
		}
		
		public function getBoundaryPolygon():Polygon
		{
			return this.boundaryPolygon;
		}
		
		public function isObject(s:SuperObject):Boolean {
			return false
		}
		
		public function getNameString():String
		{
			return null;
		}
		
		public function getProduction():Production
		{
			return null;
		}
		
		public function hasBoundary():Boolean
		{
			return false;
		}
		
		public function drawAllStages(p:PhotoAssets):void {
			
		}
		
		public function isOverLappingBoundsOfObject(pos:LatLng, map:Map, photo:PhotoAssets):Boolean
		{
			var iPos:LatLng = this.marker.getLatLng();
			var bounds:LatLngBounds = GameConstants.getBaseLatticeBounds(iPos, map, photo);
			return bounds.containsLatLng(pos)
		}		
		
		public function getMarker():TowerSaintMarker{
			return this.marker;
		}

	}
}