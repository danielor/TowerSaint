package models.map
{
	import com.google.maps.Map;
	
	import managers.GameFocusManager;

	public class TowerSaintMap extends Map
	{
		public var focusPanelManager:GameFocusManager;
		public function TowerSaintMap(fPM:GameFocusManager)
		{
			this.focusPanelManager = fPM;	
		}
		
	}
}