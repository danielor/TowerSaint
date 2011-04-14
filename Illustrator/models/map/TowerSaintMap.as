package models.map
{
	import com.google.maps.Map;
	
	import managers.FocusPanelManager;

	public class TowerSaintMap extends Map
	{
		public var focusPanelManager:FocusPanelManager;
		public function TowerSaintMap(fPM:FocusPanelManager)
		{
			this.focusPanelManager = fPM;	
		}
		
	}
}