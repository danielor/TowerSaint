package models.interfaces
{
	import flash.events.IEventDispatcher;
	
	public interface TowerSaintDispatcher extends IEventDispatcher
	{
		function removeAllEvents():void;					/* Remove all events from the objects */
		function removeEvent(s:String, f:Function):void;	/* Remove a certain function from an event */
	}
}