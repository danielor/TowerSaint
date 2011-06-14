package models.states.events
{
	import flash.events.Event;
	
	import models.states.GameState;
	
	import mx.collections.ArrayCollection;
	
	public class BuildStateEvent extends Event implements StateEvent
	{
		// The Information assoicated with the event
		private var previousState:GameState;					/* The previous state associated with the event */
		private var _listOfQueueObjects:ArrayCollection;		/* A list of objects we would like to send to the build state */
		private var _type:String;								/* The type associated with the event */
		
		// The constants associated with the event
		public static var BUILD_COMPLETE:String = "BuildComplete";
		public static var BUILD_START:String = "BuildStart";
		public static var BUILD_INIT:String = "BuildInit";
		public static var BUILD_CANCEL:String = "BuildCancel";
		
		public function BuildStateEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this._type = type;
			super(type, bubbles, cancelable);	
		}
		
		override public function clone():Event {
			return new BuildStateEvent(this._type);
		}
		
		// Create a property interface to inform the user the build state of the appropriate 
		// functionality.
		public function set listOfQueueObjects(arr:ArrayCollection) : void {
			this._listOfQueueObjects = arr;
		}
		public function get listOfQueueObjecs():ArrayCollection {
			return this._listOfQueueObjects;
		}
		override public function get type():String {
			return this._type;
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