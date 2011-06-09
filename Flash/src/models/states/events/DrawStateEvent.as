package models.states.events
{
	import flash.events.Event;
	
	import models.states.GameState;
	
	public class DrawStateEvent extends Event implements StateEvent
	{
		public static var DRAW_STATE:String = "DrawState";
		private var previousState:GameState;						/* The previous game state */

		public function DrawStateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new DrawStateEvent(DRAW_STATE);
		}
		
		// StateEvent interface
		public function attachPreviousState(g:GameState):void {
			this.previousState = g;
		}
		public function getPreviousState():GameState {
			return this.previousState;
		}
	}
}