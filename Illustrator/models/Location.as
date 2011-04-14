package models
{
	import com.google.maps.LatLng;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;

	[Bindable]
	[RemoteClass("alias=models.Location")]
	public class Location 
	{
		public var latIndex:int;
		public var lonIndex:int;
		public var latitude:Number;
		public var longitude:Number;
		
		public function Location()
		{
			super();
		}
		
		
		public static function googleToAMFLocation(loc:LatLng) : Location {
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
		
		public function writeExternal(output:IDataOutput) : void {
			output.writeInt(this.latIndex);
			output.writeInt(this.lonIndex);
			output.writeFloat(this.latitude);
			output.writeFloat(this.longitude);
		}
		
		public function readExternal(input:IDataInput) : void {
			this.latIndex = input.readInt();
			this.lonIndex = input.readInt();
			this.latitude = input.readFloat();
			this.longitude = input.readFloat();
		}
	}
}