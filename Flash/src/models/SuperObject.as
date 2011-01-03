package models
{
	import assets.PhotoAssets;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import flashx.textLayout.elements.TextFlow;
	
	import managers.FocusPanelManager;
	
	import models.Bounds;
	
	import mx.core.BitmapAsset;

	public interface SuperObject
	{
		// Draw the object on the map
		function draw(drag:Boolean, map:Map, photo:PhotoAssets, fpm:FocusPanelManager, withBoundary:Boolean) : void;
		
		// Display information associated with object in text
		function display() : TextFlow;
		
		// Remove the marker from the map
		function eraseFromMap(map:Map) : void;
		
		// Set focus on the object
		function setFocusOnObject(error:Boolean) : void;
		
		// Set the position of the object on the map
		function setPosition(pos:LatLng) : void;
		
		// Get the position of the object
		function getPosition(b:LatLngBounds):LatLng;
		
		// Interface to the isModified flag, which is true when an object has been create.
		function setIsModified(t:Boolean) : void;
		function getIsModified():Boolean;
		
		// Get the image representation
		function getImage(photo:PhotoAssets):BitmapAsset;
		
		// Returns true if the object is current visible on the map
		function isVisible(map:Map):Boolean;
		
		// Get the influence
		function getMaxInfluence():Number;
	}
}