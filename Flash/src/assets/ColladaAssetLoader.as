package assets
{
	import away3d.containers.ObjectContainer3D;
	import away3d.loaders.Collada;
	import away3d.loaders.Loader3D;

	public class ColladaAssetLoader
	{
		[Embed(source="assets/collada/tower.dae", mimeType="application/octet-stream")]
		public static const TowerLevel0:Class;
		public function ColladaAssetLoader()
		{
			
		}
		
		
	}
}