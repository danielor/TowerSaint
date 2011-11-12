package models.interfaces
{
	import assets.PhotoAssets;
	
	import away3d.core.base.Mesh;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	
	import flashx.textLayout.elements.TextFlow;
	
	import models.User;
	
	import mx.core.BitmapAsset;

	public interface UserObject
	{
		function initialize(u:User, obj:ObjectModifier) : void;		// Initialize a user object
		function getNameString():String;							// Return the name of the object
		function getPosition(b:LatLngBounds):LatLng;				// Get the position of the object
		function setPosition(pos:LatLng) : void;					// Set the position of the object on the map
		function display() : TextFlow;								// Convert the object into a rich text string
		function getImage(photo:PhotoAssets):BitmapAsset;			// Get the image repreresentation
		function get3DObject():Mesh;								// Return the 3d object associated with the container
	}	
}