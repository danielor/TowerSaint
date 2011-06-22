package models.interfaces
{
	import com.google.maps.LatLng;
	import com.google.maps.Map;

	public interface BoundarySuperObject extends SuperObject
	{
		// Interface functions for objects which have a boundary of influence
		// in the towersaint game.
		function isInsideBoundary(pos:LatLng, m:Map):Boolean;
		
	}
}