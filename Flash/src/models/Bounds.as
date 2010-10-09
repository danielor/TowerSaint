package models
{
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
	}
}