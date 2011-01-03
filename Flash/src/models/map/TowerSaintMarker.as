package models.map
{
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	
	import models.SuperObject;
	
	// An extension of the marker to keep a reference to the SuperObject
	public class TowerSaintMarker extends Marker
	{
		// The model of the object associated with marker
		private var model:SuperObject;
		private var map:Map;
		public function TowerSaintMarker(m:SuperObject, pos:LatLng, mOpt:MarkerOptions, map:Map)
		{
			// The model
			this.model = m;
			this.map = map;
			
			// Setup the marker class
			super(pos, mOpt);
		}
		
		public function getMap():Map{
			return map;
		}
		
		public function getModel():SuperObject{
			return model;
		}
	}
}