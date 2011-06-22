package models.states.events
{
	import flash.events.Event;
	
	import models.interfaces.SuperObject;
	import models.states.GameState;
	
	public class MoveStateEvent extends Event implements StateEvent
	{
		private var previousState:GameState;							/* The previous state */
		private var _moveObject:SuperObject;							/* The object being moved */
		public static const MOVE_START:String = "MoveStateStart";		/* The move state starts */
		public static const MOVE_STEP:String = "MoveStateStep";			/* Itermediate drag movements in the state */
		public static const MOVE_END:String = "MoveStateEnd"; 			/* The end of the movement */
		
		public function MoveStateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set moveObject(s:SuperObject):void {
			this._moveObject = s;	
		}
		public function get moveObject():SuperObject {
			return this._moveObject;	
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
	}
}