package models
{
	[Bindable]
	[RemoteClass(alias='models.User')]
	public class User
	{
		// The User information
		public var FacebookID:Number;
		public var Experience:Number;
		public var Empire:String;
		public var isEmperor:Boolean;
		
		// Complete mining information
		public var completeManaProduction : Number;
		public var completeStoneProduction : Number;
		public var completeWoodProduction : Number;
		
		public function User()
		{
			super();	
		}
	}
}