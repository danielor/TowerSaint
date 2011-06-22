package models.map
{
	import away3d.containers.View3D;
	
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	
	import models.interfaces.SuperObject;
	
	import spark.effects.Scale3D;
	
	// An extension of the marker to keep a reference to the SuperObject
	public class TowerSaintMarker extends Marker
	{
		// The model of the object associated with marker
		private var model:SuperObject;
		private var map:Map;
		private var view:View3D;
		public function TowerSaintMarker(m:SuperObject, pos:LatLng, mOpt:MarkerOptions, map:Map, view:View3D)
		{
			// The model
			this.model = m;
			this.map = map;
			this.view = view;
			
			// Setup the marker class
			super(pos, mOpt);
		}
		
		public function getMap():Map{
			return map;
		}
		
		public function getModel():SuperObject{
			return model;
		}
		
		public function getView():View3D {
			return view;
		}
	}
}