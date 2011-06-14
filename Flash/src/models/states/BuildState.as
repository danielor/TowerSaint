package models.states
{
	import com.google.maps.Map;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Application;
	
	public class BuildState implements GameState
	{
		private const viewString:String = "inApp";						/* The view associated with the state */
		private var isInState:Boolean;									/* Flag determines the state */
		private var app:Application;									/* The application associated with the game */
		private var _listOfQueueObjects:ArrayCollection;				/* The queue objects to be added/removed */
		private var _buildStateEventType:String;						/* The event type that created the event */
		private var map:Map;											/* The map where the game runs */
		public function BuildState(a:Application, m:Map)
		{
			this.app = a;
			this.map = m;
			this.isInState = false;
		}
		
		// Event objects that need to be set
		public function set listOfQueueObjects(arr:ArrayCollection) : void {
			this._listOfQueueObjects = arr;
		}
		public function set buildStateEventType(type:String) : void {
			this._buildStateEventType = type;
		}
		
		// GameState interface
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
		public function getStateString():String {
			return "build";
		}
		
		public function enterState():void
		{
			this.isInState = true;
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
			return false;
		}
		
		public function getViewString():String
		{
			return null;
		}
		
		public function getNextState():GameState
		{
			return null;
		}
	}
}