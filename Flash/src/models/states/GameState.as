package models.states
{
	// Game states define a well-defined logical points(events characterstic to the state) in the game.
	// The game states define a finite state machine of user interactions with the game.
	public interface GameState
	{
		function isChatActive():Boolean;				/* In this state. Can we chat? */
		function isMapActive():Boolean;					/* In this state. Is the map active? */
		function isFocusActive():Boolean;				/* In this state. Can we focus on objects? */
		function isGameActive():Boolean;				/* In this state. Are we in the game? */
		function enterState():void;						/* Enter this state */
		function exitState():void;						/* Exit the state */
		function isActiveState():Boolean;				/* True if we are in this state */
		function hasView():Boolean;						/* True if it changes the view of the game */
		function getViewString():String;				/* Get the view string associated with the state */
		function getStateString():String;				/* Get a string representation of the state */
		
		// NOTE: This functionr returns null when no game state is defined.
		function getNextState():GameState;				/* Get the next state... ideal for chained states*/
	}
}