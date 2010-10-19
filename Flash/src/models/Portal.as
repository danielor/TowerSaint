package models
{
	import flashx.textLayout.elements.TextFlow;

	[Bindable]
	[RemoteClass(alias="models.Portal")]
	public class Portal
	{
		// Information
		public var hitPoints:Number;
		public var level:Number;
		
		// Who owns it?
		public var user:User;
		
		// Locations- The location object has been decomposed to 
		
		// The Start location.
		public var startLocationLatitude:Number;
		public var startLocationLongitude:Number;
		public var startLocationLatitudeIndex:Number;
		public var startLocationLongitudeIndex:Number;
		
		// The End location
		public var endLocationLatitude:Number;
		public var endLocationLongitude:Number;
		public var endLocationLatitudeIndex:Number;
		public var endLocationLongitudeIndex:Number;
		
		//public var startLocation:Location;
		//public var endLocation:Location;
		
		public function Portal()
		{
			super();
		}
		
		public function toTextFlow():TextFlow {
			var textFlow:TextFlow = new TextFlow();
			return textFlow;
		}
	}
}