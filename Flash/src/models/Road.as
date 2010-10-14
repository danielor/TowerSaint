package models
{
	[Bindable]
	[RemoteClass(alias="models.Road")]
	public class Road
	{
		// Information
		public var hitPoints:Number;
		public var level:Number;
		
		// Who owns it?
		public var user:User;
		
		// Location 
		public var latIndex:int;
		public var lonIndex:int;
		public var latitude:Number;
		public var longitude:Number;
	
		
		public function Road()
		{
			super();
		}
	}
}