package models.states
{
	
	public class BuildState implements GameState
	{
		public function BuildState()
		{
		}
		
		public function isChatActive():Boolean
		{
			return false;
		}
		
		public function isMapActive():Boolean
		{
			return false;
		}
		
		public function isFocusActive():Boolean
		{
			return false;
		}
		
		public function isGameActive():Boolean
		{
			return false;
		}
		public function getStateString():String {
			return "build";
		}
		
		public function enterState():void
		{
		}
		
		public function exitState():void
		{
		}
		
		public function isActiveState():Boolean
		{
			return false;
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