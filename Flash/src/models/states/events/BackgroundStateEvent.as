package models.states.events
{
	import flash.events.Event;
	
	import models.states.GameState;
	
	public class BackgroundStateEvent extends Event implements StateEvent
	{
		public static var BACKGROUND_STATE:String = "BackgroundState";			/* Event string */
		private var previousState:GameState;									/* The previous state */
		public function BackgroundStateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new BackgroundStateEvent(BACKGROUND_STATE);
		}
		
		// StateEvent interface
		public function attachPreviousState(g:GameState):void {
			this.previousState = g;
		}
		public function getPreviousState():GameState {
			return this.previousState;
		}
		
		public function realizeAsEvent():Event{
			return this;
		}
	}
}