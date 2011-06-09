package models.away3D
{
	import away3d.containers.Scene3D;
	
	import models.Road;

	/* 
	Road path uses away3D to draw a path on google maps. 
	*/
	public class RoadPath
	{
		private var scene:Scene3D;				/* The scene to draw the path */
		private var road:Road;					/* The road associated with the path */
		
		public function RoadPath(r:Road, s:Scene3D, withLinks:Boolean = false)
		{
			
		}
	}
}