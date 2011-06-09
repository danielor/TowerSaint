package models.states.events
{
	import models.states.GameState;

	// Interface for state events
	public interface StateEvent
	{
		function attachPreviousState(g:GameState):void;
		function getPreviousState():GameState;
	}
}