package models
{
	// A simple structure which contains all of the possible production elements
	// of the game
	public class Production
	{
		public var woodProduction:Number;
		public var stoneProduction:Number;
		public var manaProduction:Number;
		public function Production(wP:Number, sP:Number, mP:Number)
		{
			this.woodProduction = wP;
			this.stoneProduction = sP;
			this.manaProduction = mP;
		}
	}
}