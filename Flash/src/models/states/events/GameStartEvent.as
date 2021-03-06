package models.states.events
{
	import flash.events.Event;
	
	import models.states.GameState;
	
	public class GameStartEvent extends Event implements StateEvent
	{
		public static var GAME_START:String = "GameStart";
		private var previousState:GameState;
		private var chainedEvent:StateEvent;						/* An non standard next state */

		public function GameStartEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new GameStartEvent(GAME_START);
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