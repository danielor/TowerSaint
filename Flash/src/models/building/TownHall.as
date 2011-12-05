package models.building
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	
	import models.away3D.buildings.TownHall3D;
	
	[Bindable]
	[RemoteClass(alias="models.TownHall")]
	public class TownHall extends BaseBuilding
	{
		
		public var latitude:Number;				// The latitude of the barracks
		public var longitude:Number;			// The longitude of the barracks
		public function TownHall()
		{
			this.model = new TownHall3D(.1);
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