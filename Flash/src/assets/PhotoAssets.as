package assets
{
	import flash.display.Bitmap;
	
	import models.Portal;

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
		
		// Images for the different types of roadss
		[Embed(source="assets/pictures/EastRoad.png")]
		[Bindbale] public var EastRoad : Class;
		[Embed(source="assets/pictures/EastWestRoad.png")]
		[Bindable] public var EastWestRoad:Class;
		[Embed(source="assets/pictures/NorthEastRoad.png")]
		[Bindable] public var NorthEastRoad : Class;
		[Embed(source="assets/pictures/NorthEastWestRoad.png")]
		[Bindable] public var NorthEastWestRoad : Class;
		[Embed(source="assets/pictures/NorthRoad.png")]
		[Bindable] public var NorthRoad:Class;
		[Embed(source="assets/pictures/NorthSouthEastRoad.png")]
		[Bindable] public var NorthSouthEastRoad:Class;
		[Embed(source="assets/pictures/NorthSouthEastWestRoad.png")]
		[Bindable] public var NorthSouthEastWestRoad:Class;
		[Embed(source="assets/pictures/NorthSouthRoad.png")]
		[Bindable] public var NorthSouthRoad:Class;
		[Embed(source="assets/pictures/NorthSouthWestRoad.png")]
		[Bindable] public var NorthSouthWestRoad:Class;
		[Embed(source="assets/pictures/NorthWestRoad.png")]
		[Bindable] public var NorthWestRoad:Class;
		[Embed(source="assets/pictures/SouthEastRoad.png")]
		[Bindable] public var SouthEastRoad:Class;
		[Embed(source="assets/pictures/SouthEastWestRoad.png")]
		[Bindable] public var SouthEastWestRoad:Class;
		[Embed(source="assets/pictures/SouthRoad.png")]
		[Bindable] public var SouthRoad:Class;
		[Embed(source="assets/pictures/SouthWestRoad.png")]
		[Bindable] public var SouthWestRoad:Class;
		[Embed(source="assets/pictures/WestRoad.png")]
		[Bindable] public var WestRoad:Class;
		
		// The portal
		[Embed(source="assets/pictures/Portal.png")]
		[Bindbale] public var ThePortal:Class;
		[Embed(source="assets/pictures/PortalMouse.png")]
		[Bindable] public var ThePortalMouse:Class;
		
		// The cannonball texture
		[Embed(source="assets/pictures/Cannon_Material.png")]
		[Bindable] public var cannonMaterial : Class;
		
		public function PhotoAssets()
		{
			
		}
		

	}
}