package models
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;

	[Bindbale]
	[RemoteObject(alias = "models.Bounds")]
	public class Bounds
	{
		// Class for the bounds of the current map
		public var southwestLocation:Location;
		public var northeastLocation:Location;
		public function Bounds()
		{
			super();
		}
		
		/*
			Extract the information from the LatLngBounds object
		*/
		public function fromGoogleBounds(bounds:LatLngBounds) : void{
			this.northeastLocation = googleToAMFLocation(bounds.getNorthEast());
			this.southwestLocation = googleToAMFLocation(bounds.getSouthWest());
		}
		
		/*
			The internal conversion function
		*/
		private function googleToAMFLocation(loc:LatLng):Location {
			var myLoc:Location = new Location();
			
			// The lattice values
			var latOffset:Number = .001;
			var lonOffset:Number = .001;
			
			// Set the latitude/longitude
			myLoc.latitude = loc.lat();
			myLoc.longitude = loc.lng();
			myLoc.latIndex = int(myLoc.latitude / latOffset);
			myLoc.lonIndex = int(myLoc.longitude / lonOffset);
			
			// Set the latitude/longitude index
			return myLoc;
		}
	}
}