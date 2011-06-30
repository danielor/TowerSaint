package models.states
{
	import managers.GameManager;
	
	import models.states.events.BackgroundStateEvent;
	import models.states.events.UpdateStateEvent;
	
	import spark.components.Application;

	public class GameStartState implements GameState
	{
		public var isInState:Boolean;								/* True if the function is in the state */
		public var gameManager:GameManager;							/* The game manager */
		public var app:Application;									/* The application that runs the game */
		private const viewString:String = 'inApp';					/* The view associated with the state */

		public function GameStartState(gm:GameManager, a:Application)
		{
			this.gameManager = gm;
			this.app = a;
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
		
		public function isGameActive():Boolean
		{
			return true;
		}
		
		public function enterState():void
		{
			this.isInState = true;
			this.gameManager.initGame();
			
			// Send the update state
			var e:BackgroundStateEvent = new BackgroundStateEvent(BackgroundStateEvent.BACKGROUND_STATE);
			e.attachPreviousState(this);
			this.app.dispatchEvent(e);
		}
		
		public function exitState():void
		{
			this.isInState = false;
		}
		
		public function isActiveState():Boolean
		{
			return this.isInState;
		}
		
		public function hasView():Boolean
		{
			return true;
		}
		
		public function getViewString():String
		{
			return this.viewString;
		}
		
		public function getStateString():String
		{
			return "gamestart";
		}
		
		public function getNextState():GameState
		{
			return null;
		}
	}
}