package models.map
{
	import com.google.maps.LatLng;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	
	import models.SuperObject;
	
	// An extension of the marker to keep a reference to the SuperObject
	public class TowerSaintMarker extends Marker
	{
		// The model of the object associated with marker
		public var model:SuperObject;
		public function TowerSaintMarker(m:SuperObject, pos:LatLng, mOpt:MarkerOptions)
		{
			// The model
			this.model = m;
			
			// Setup the marker class
			super(pos, mOpt);
		}
	}
}