package models.states
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import models.interfaces.SuperObject;
	import models.states.events.MoveStateEvent;

	public class MoveState implements GameState
	{
		private var isInState:Boolean;						/*Boolean flag if it is in state */
		private const viewString:String = "inApp";			/*The view associated with the state */ 
		private const stateString:String = "move";			/*State's string name */
		private var _moveStateEventType:String;				/* The move state associated with a model */
		private var _moveObject:SuperObject;				/* The object we will move */
		private var _originalLocation:LatLng;				/* The original location of the object */
		private var _map:Map;								/* A reference to the map where the game runs */
		
		public function MoveState(m:Map)
		{
			this.isInState = false;
			this._map = m;
			this.moveStateEventType = MoveStateEvent.MOVE_START;
		}
		
		public function isChatActive():Boolean
		{
			return true;
		}
		
		// Set functions control the state
		public function set moveStateEventType(s:String):void {
			this._moveStateEventType = s;
		}
		public function set moveObject(s:SuperObject):void {
			this._moveObject = s;	
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
			if(this._moveStateEventType == MoveStateEvent.MOVE_START){
				this._moveStart();
			}else if(this._moveStateEventType == MoveStateEvent.MOVE_STEP){
				// TODO: do something...
			}else if(this._moveStateEventType == MoveStateEvent.MOVE_END){
				this._moveEnd();	
			}
		}
		
		// Internal function actually perform the substate tasks
		private function _moveStart():void {
			// Save the original location so that the panel can pop back if it needs to.
			var b:LatLngBounds = this._map.getLatLngBounds();
			this._originalLocation = this._moveObject.getPosition(b);
			
			// Attach
			
		}
		private function _moveEnd():void {
			
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
			return this.viewString;
		}
		
		public function getStateString():String
		{
			return this.stateString;
		}
		
		public function getNextState():GameState
		{
			return null;
		}
	}
}