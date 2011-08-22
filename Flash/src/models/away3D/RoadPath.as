package models.away3D
{
	import away3d.containers.Scene3D;
	import away3d.core.geom.Path;
	import away3d.extrusions.PathExtrusion;


	/* 
	Road path uses away3D to draw a path on google maps. 
	*/
	public class RoadPath extends PathExtrusion
	{
		private var scene:Scene3D;								/* The scene where the road path will be draw */
		public function RoadPath()
		{
			
		}
	}
}