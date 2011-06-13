package models.states
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapMoveEvent;
	
	import managers.EventManager;
	import managers.GameFocusManager;
	import managers.GameManager;
	import managers.UserObjectManager;
	
	import models.states.events.UpdateStateEvent;
	
	import mx.controls.Alert;
	
	import spark.components.Application;

	// The background state runs when no other states are running
	public class BackgroundState implements GameState
	{
		private var mapEventManager:EventManager;						/* The map event manager */
		private var map:Map;											/* The google map */
		private var isInState:Boolean;									/* Boolean variable which denotes the state */
		private var initialMapDragMouse:LatLng; 						/* Initial drag position */				
		private var app:Application;									/* The application running the current state */
		private var gameFocus:GameFocusManager								/* The focus manager */
		private const viewString:String = "inApp";						/* The view state */
		public function BackgroundState(m:Map, a:Application, gF:GameFocusManager)
		{
			// Initialize
			this.map = m;
			this.app = a;
			this.gameFocus= gF;
			
			// Set the state
			this.isInState = false;
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
			this.mapEventManager = new EventManager(this.map);	
			this.mapEventManager.addEventListener(MapMouseEvent.DRAG_START, onMapDragStart);
			this.mapEventManager.addEventListener(MapMouseEvent.DRAG_END, onMapDragEnd);
			this.mapEventManager.addEventListener(MapMouseEvent.MOUSE_DOWN, this.gameFocus.onMouseClick);			
			this.isInState = true;
		}
		
		public function exitState():void
		{
			this.mapEventManager.RemoveEvents();			/* Remove all map events in state */
			this.isInState = false;
		}
		
		private function onMapDragStart(event:MapMouseEvent) : void {
			initialMapDragMouse = event.latLng;
		}
		
		private function onMapDragEnd(event:MapMouseEvent) : void {
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
			
			// Change to the update state
			var updateStateEvent:UpdateStateEvent = new UpdateStateEvent();
			updateStateEvent.attachPreviousState(this);
			this.app.dispatchEvent(updateStateEvent);
			
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