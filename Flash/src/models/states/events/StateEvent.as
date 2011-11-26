package models.states.events
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import models.states.GameState;

	// Interface for state events
	public interface StateEvent 
	{
		function attachPreviousState(g:GameState):void;
		function getPreviousState():GameState;
		function getChainedEvent():StateEvent;			// Get the next event, if not default
		function setChainedEvent(s:StateEvent):void;	// Set a nonstandard event.
		function realizeAsEvent():Event;				// Return self as event
	}
}