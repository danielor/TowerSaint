package models.interfaces
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	
	import models.User;

	public interface UserObject
	{
		function initialize(u:User, obj:ObjectModifier) : void;		// Initialize a user object
		function getNameString():String;							// Return the name of the object
		function getPosition(b:LatLngBounds):LatLng;				// Get the position of the object
		function setPosition(pos:LatLng) : void;					// Set the position of the object on the map
	}
}