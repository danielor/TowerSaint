package models
{
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
	}
}