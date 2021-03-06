package models.states.events
{
	import flash.events.Event;
	
	import models.states.GameState;
	
	// Update state event send an event to change into the update state
	public class UpdateStateEvent extends Event implements StateEvent
	{
		public static const UPDATE_STATE:String = "UpdateBuild";
		private var previousState:GameState;						/* The previous game state */
		private var chainedEvent:StateEvent;						/* An non standard next state */
		public function UpdateStateEvent()
		{
			super(UPDATE_STATE);
		}
		
		override public function clone():Event {
			return new UpdateStateEvent();
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
		
		public function  getChainedEvent():StateEvent {
			return this.chainedEvent;
		}
		public function setChainedEvent(s:StateEvent):void{
			this.chainedEvent = s;
		}
	}
}