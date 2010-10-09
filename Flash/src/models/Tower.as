package models
{
	[Bindbale]
	[RemoteClass(alias="models.Tower")]
	public class Tower
	{
		
		// Stats
		public var Experience:Number;
		public var Speed:Number;
		public var Power:Number;
		public var Armor:Number;
		public var Range:Number;
		public var Accuracy:Number;
		public var HitPoints:Number;
		public var isIsolated:Boolean;
		public var isCapital:Boolean;
		public var hasRuler:Boolean;
		public var Level:Number;
		
		// The user associated with the tower.
		public var user:User;
		
		// Mining capabilities.
		public var manaProduction:Number;
		public var stoneProduction:Number;
		public var woodProduction:Number;
		
		// Location
		public var latIndex:int;
		public var lonIndex:int;
		public var latitude:Number;
		public var longitude:Number;
		
		public function Tower()
		{
			super();
		}
	}
}