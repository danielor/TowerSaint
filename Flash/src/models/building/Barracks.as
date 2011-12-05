package models.building
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	
	import models.away3D.buildings.Barracks3D;

	[Bindable]
	[RemoteClass(alias="models.Barracks")]
	public class Barracks extends BaseBuilding
	{
		public var latitude:Number;				// The latitude of the barracks
		public var longitude:Number;			// The longitude of the barracks
		public function Barracks()
		{
			// Create the 3d model
			this.model = new Barracks3D(.1);
		}
		
		override public function setPosition(pos:LatLng) : void {
			this.latitude = pos.lat();
			this.longitude = pos.lng();
		}
		
		override public function getPosition(b:LatLngBounds):LatLng {
			return new LatLng(this.latitude, this.longitude);
		}
	}
}