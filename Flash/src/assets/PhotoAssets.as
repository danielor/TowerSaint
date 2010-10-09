package assets
{
	public class PhotoAssets
	{
		// Images for the four levels of tower
		[Embed(source="assets/pictures/Tower_Level0.png")]
		[Bindable] public var TowerLevel0 : Class;
		[Embed(source="assets/pictures/Tower_Level1.png")]
		[Bindbale] public var TowerLevel1 : Class;
		[Embed(source="assets/pictures/Tower_Level2.png")]
		[Bindbale] public var TowerLevel2 : Class;
		[Embed(source="assets/pictures/TowerSaint.png")]
		[Bindable] public var TowerSaint : Class;
		
		[Embed(source="assets/pictures/Cannon_Material.png")]
		[Bindable] public var cannonMaterial : Class;
		
		public function PhotoAssets()
		{
			
		}
	}
}