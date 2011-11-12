package models.states
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapMoveEvent;
	
	import managers.EventManager;
	import managers.GameFocusManager;
	import managers.GameManager;
	import managers.UserObjectManager;
	
	import models.interfaces.SuperObject;
	import models.interfaces.UserObject;
	import models.states.events.GameStartEvent;
	import models.states.events.MoveStateEvent;
	import models.states.events.UpdateStateEvent;
	
	import mx.controls.Alert;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	import spark.components.Application;

	// The background state runs when no other states are running
	public class BackgroundState implements GameState
	{
		private var mapEventManager:EventManager;						/* The map event manager */
		private var map:Map;											/* The google map */
		private var isInState:Boolean;									/* Boolean variable which denotes the state */
		private var initialMapDragMouse:LatLng; 						/* Initial drag position */				
		private var app:Application;									/* The application running the current state */
		private var gameFocus:GameFocusManager							/* The focus manager */
		private var buildState:BuildState;								/* The build state is needed for deferred events */
		private var isClicked:Boolean;									/* True if the operation is clicked */
		private var gameManager:GameManager;							/* The game manager running the state */
		private const viewString:String = "inApp";						/* The view state */
		
		// Constants associate a certain type of mouse activity with a certain state.
		private var _mouseState:String;
		public static const MOUSE_BUILD:String = "MouseBuild";
		public static const MOUSE_FOCUS:String = "MouseFocus";
		public static const MOUSE_ATTACK:String = "MouseAttack";
		public static const MOUSE_MOVE:String = "MouseMove";
		
		// Map state constants
		private var _mapReady:Boolean;
		public static const MAP_READY:String = "MapMoveOver";
		
		public function BackgroundState(m:Map, a:Application, gF:GameFocusManager, bS:BuildState,
								gm:GameManager)
		{
			// Initialize
			this.map = m;
			this.app = a;
			this.gameFocus= gF;
			this.buildState = bS;
			this.gameManager = gm;
			
			// Set the state
			this.isInState = false;
			this._mouseState = BackgroundState.MOUSE_FOCUS;
			this.isClicked = false;
			
			// Setup the events associated with the mouse deferred events
			this.app.addEventListener(BackgroundState.MOUSE_BUILD, onMouseState);
			this.app.addEventListener(BackgroundState.MOUSE_FOCUS, onMouseState);
			this.app.addEventListener(BackgroundState.MOUSE_ATTACK, onMouseState);
			this.app.addEventListener(BackgroundState.MOUSE_MOVE, onMouseState);
		}
		
		public function  onMouseState(e:PropertyChangeEvent):void{
			this._mouseState = e.newValue as String;
		}
		
		public function isChatActive():Boolean
		{
			return true;
		}
		
		public function isMapActive():Boolean
		{
			return true;
		}
		
		public function isFocusActive():Boolean
		{
			return true;
		}
		public function getStateString():String {
			return "background";
		}
		
		public function isGameActive():Boolean
		{
			return true;
		}
		
		public function enterState():void
		{
			if(!this.gameManager.isGameActive()){
				var e:GameStartEvent = new GameStartEvent(GameStartEvent.GAME_START);
				e.attachPreviousState(this);
				this.app.dispatchEvent(e);
				return;
			}
			
			this.mapEventManager = new EventManager(this.map);	
			this.mapEventManager.addEventListener(MapMouseEvent.DRAG_START, onMapDragStart);
			this.mapEventManager.addEventListener(MapMouseEvent.DRAG_END, onMapDragEnd);
			this.mapEventManager.addEventListener(MapMouseEvent.MOUSE_DOWN, onMapMouseDown); 
			this.mapEventManager.addEventListener(MapMouseEvent.MOUSE_UP, onMapMouseUp);
			this.mapEventManager.addEventListener(MapMouseEvent.ROLL_OVER, onMapRollOver);
			this.mapEventManager.addEventListener(MapMouseEvent.ROLL_OUT, onMapRollOut);
			this.mapEventManager.addEventListener(MapMouseEvent.MOUSE_MOVE, onMapMouseMove);
			this.mapEventManager.addEventListener(MapMoveEvent.MOVE_END, onMapMoveEnd);
			this.mapEventManager.addEventListener(MapMoveEvent.MOVE_START, onMapMoveStart);
			this.isInState = true;
		}
		
		public function exitState():void
		{
			this.mapEventManager.RemoveEvents();			/* Remove all map events in state */
			this.isInState = false;
		}
		
		private function onMapMouseUp(event:MapMouseEvent):void {
			this.isClicked = false;
			if(this._mouseState == BackgroundState.MOUSE_MOVE){
				var e:MoveStateEvent = new MoveStateEvent(MoveStateEvent.MOVE_END);
				e.attachPreviousState(this);
				this.app.dispatchEvent(e);
				this._mouseState = BackgroundState.MOUSE_FOCUS;
			}
		}
		
		private function onMapMoveEnd(event:MapMoveEvent):void {
			this._mapReady = true;
			var e:PropertyChangeEvent = new PropertyChangeEvent(BackgroundState.MAP_READY, false, false,
				PropertyChangeEventKind.UPDATE, 'mapReady', this._mapReady, this._mapReady, this);
			this.app.dispatchEvent(e);
			
			// Change to the update state
			var updateStateEvent:UpdateStateEvent = new UpdateStateEvent();
			updateStateEvent.attachPreviousState(this);
			this.app.dispatchEvent(updateStateEvent);
		}
		
		private function onMapMoveStart(event:MapMoveEvent):void {
			this._mapReady = false;
			var e:PropertyChangeEvent = new PropertyChangeEvent(BackgroundState.MAP_READY, false, false,
				PropertyChangeEventKind.UPDATE, 'mapReady', this._mapReady, this._mapReady, this);
			this.app.dispatchEvent(e);
		}
		
		private function onMapMouseDown(event:MapMouseEvent):void {
			this.isClicked = true;
			if(this._mouseState == BackgroundState.MOUSE_FOCUS){
				this.gameFocus.setFocusFromMapEvent(event);

				// Get the focus object
				var focusObject:UserObject = this.gameFocus.focusObject;
				if(focusObject != null){
					// Set the internal state
					this._mouseState = BackgroundState.MOUSE_MOVE;
					
					// Send out a move event
					var e:MoveStateEvent = new MoveStateEvent(MoveStateEvent.MOVE_START);
					e.attachPreviousState(this);
					e.moveObject = focusObject;
					this.app.dispatchEvent(e);
				}
				
			}else if(this._mouseState == BackgroundState.MOUSE_BUILD){
				// Call the build state hook and return to the previous state
				this.buildState.onMapMouseClick(event);
				//this._mouseState = BackgroundState.MOUSE_FOCUS;
			}
		}
		
		private function onMapMouseMove(event:MapMouseEvent):void {
			if(this._mouseState == BackgroundState.MOUSE_BUILD){
				this.buildState.onMapMouseMove(event);
			}
		}
		
		private function onMapRollOver(event:MapMouseEvent):void{
			if(this._mouseState == BackgroundState.MOUSE_BUILD){
				this.buildState.onMapRollOver(event);
			}
		}
		
		private function onMapRollOut(event:MapMouseEvent):void {
			if(this._mouseState == BackgroundState.MOUSE_BUILD){
				this.buildState.onMapRollOut(event);
			}
		}
		
		private function onMapDragStart(event:MapMouseEvent) : void {
			if(this._mouseState == BackgroundState.MOUSE_FOCUS){
				initialMapDragMouse = event.latLng;
			}
		}
		
		private function onMapDragEnd(event:MapMouseEvent) : void {
			if(this._mouseState == BackgroundState.MOUSE_FOCUS){
				var finalDragPosition:LatLng = event.latLng;
				
				// The center of the map, and bounds
				var centerOfMap:LatLng = this.map.getCenter();
				var bounds:LatLngBounds = this.map.getLatLngBounds();
				var mapDimension:LatLng = new LatLng(bounds.getNorth() - bounds.getSouth(), bounds.getWest() - bounds.getEast());
				
				
				// The net distance
				var netDragLongitude:Number = finalDragPosition.lng() - initialMapDragMouse.lng();
				var netDragLatitude:Number = finalDragPosition.lat() - initialMapDragMouse.lat();
				
				// The new center position
				var newCenterLatitude:Number;
				var newCenterLongitude:Number;
				
				if(Math.abs(netDragLongitude) > Math.abs(netDragLatitude)) {
					if(netDragLongitude > 0.0){
						newCenterLatitude = centerOfMap.lat();
						newCenterLongitude = centerOfMap.lng() +  mapDimension.lng();
					}else{
						newCenterLatitude = centerOfMap.lat();
						newCenterLongitude = centerOfMap.lng() - mapDimension.lng();	
					}
				}else{
					if(netDragLatitude > 0.0){
						newCenterLatitude = centerOfMap.lat() + mapDimension.lat();
						newCenterLongitude = centerOfMap.lng();
					}else{
						newCenterLatitude = centerOfMap.lat() - mapDimension.lat();
						newCenterLongitude = centerOfMap.lng();
					}
				}
				
				// Create the new position, and pan to the new position
				centerOfMap = new LatLng(newCenterLatitude, newCenterLongitude);
				this.map.panTo(centerOfMap);
				

			}
		}
		
	
		
		public function isActiveState():Boolean
		{
			return this.isInState;
		}
		
		public function hasView():Boolean
		{
			return false;
		}
		
		public function getViewString():String
		{
			return this.viewString;
		}
		
		public function getNextState():GameState
		{
			return null;
		}
	}
}