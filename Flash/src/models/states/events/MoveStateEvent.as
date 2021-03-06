package models.states.events
{
	import com.google.maps.LatLng;
	
	import flash.events.Event;
	
	import models.interfaces.BuildingObject;
	import models.interfaces.UserObject;
	import models.states.GameState;
	
	public class MoveStateEvent extends Event implements StateEvent
	{
		private var previousState:GameState;							/* The previous state */
		private var _moveObject:UserObject;								/* The object being moved */
		private var _targetLocation:LatLng;								/* The location to end up in */
		private var chainedEvent:StateEvent;						    /* An non standard next state */
		public static const MOVE_START:String = "MoveStateStart";		/* The move state starts */
		public static const MOVE_STEP:String = "MoveStateStep";			/* Itermediate drag movements in the state */
		public static const MOVE_END:String = "MoveStateEnd"; 			/* The end of the movement */
		
		public function MoveStateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set moveObject(s:UserObject):void {
			this._moveObject = s;	
		}
		public function get moveObject():UserObject {
			return this._moveObject;	
		}
		public function set targetLocation(l:LatLng):void {
			this._targetLocation = l;
		}
		public function get targetLocation():LatLng {
			return this._targetLocation;
		}
		
		override public function clone():Event {
			var e:MoveStateEvent = new MoveStateEvent(this.type, this.bubbles, this.cancelable);
			e.attachPreviousState(e.getPreviousState());
			return e;
		}
		
		public function attachPreviousState(g:GameState):void
		{
			this.previousState = g;
		}
		
		public function getPreviousState():GameState
		{
			return this.previousState;
		}
		
		public function realizeAsEvent():Event{
			return this;
		}
		
		public function  getChainedEvent():StateEvent {
			return this.chainedEvent;
		}
		public function setChainedEvent(s:StateEvent):void{
			this.chainedEvent = s;
		}
	}
}