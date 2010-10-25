package managers
{
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import managers.states.TowerSaintServiceState;
	
	public class UserObjectManager
	{
		// The map
		public var map:Map;
		
		// State variables
		public var serverState:TowerSaintServiceState;
		
		/*
			Constructor - Takes in the map(view), and state constants
		*/
		public function UserObjectManager(m:Map, sS:TowerSaintServiceState)
		{
			this.map = m;
			this.serverState = sS;
		}
		
		/* 
			Function asynchoously gets all objects within visible bounds of the map.
			The objects recived are drawn on the map
		*/
		public function getAllObjectsWithinBounds(bounds:LatLngBounds) : void {
			var a:Array = this.serverState.getAllConstants();
			for(var s:String in a){
				getObjectWithinBound(s);
			}
		}
		
		private function getObjectWithinBound(serviceString:String) : void {
			
		}
	}
}