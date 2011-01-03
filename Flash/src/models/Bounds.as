package models
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;

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
		
		public function writeExternal(output:IDataOutput) : void {
			output.writeObject(this.southwestLocation);
			output.writeObject(this.northeastLocation);
		}
		public function readExternal(input:IDataInput) : void {
			this.southwestLocation = input.readObject();
			this.northeastLocation = input.readObject();
		}

		
		/*
			Extract the information from the LatLngBounds object
		*/
		public function fromGoogleBounds(bounds:LatLngBounds) : void{
			this.northeastLocation = Location.googleToAMFLocation(bounds.getNorthEast());
			this.southwestLocation = Location.googleToAMFLocation(bounds.getSouthWest());
		}
		
	}
}