package models.map
{
	import com.google.maps.Map;
	import com.google.maps.overlays.Polygon;
	
	import models.SuperObject;
	import models.User;
	
	import mx.collections.ArrayCollection;

	public class PolygonEmpireBoundary
	{
		var map:Map;								/* The map associated with the game */
		var listOfGameObjects:ArrayCollection;		/* A list of game objects in the current view */
		var user:User;								/* The user associated with this boundary */
		
		public function PolygonEmpireBoundary(m:Map, arr:ArrayCollection, u:User)
		{
			this.map = m;
			this.listOfGameObjects = arr;
			this.user = u;
		}
		
		public function draw() : void {
			// Draw the current empire boundary
			for(var i:int = 0;  i < this.listOfGameObjects.length; i++){
				var s:SuperObject = this.listOfGameObjects[i] as BuildingObject;
				
			}
		}
	}
}