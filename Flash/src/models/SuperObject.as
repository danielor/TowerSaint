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
		//function initializeIcon(photo:PhotoAssets):void;
		
		// Display information associated with object in text
		function display() : TextFlow;
		
		// Initialize the information for a new build object
		function initialize(u:User) : void;
		
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
		
		// Get the string associated with object
		function getNameString():String;
		
		// Returns the production of resources associated with o
		function getProduction():Production; 				
		
		// Boundary interface
		function hasBoundary():Boolean;												/* Object for which this is true should implement the boundary super object interface */
		function isOverLappingBoundsOfObject(pos:LatLng, map:Map, photo:PhotoAssets) : Boolean;		/* Check if the position is overlapping the image */
	}
}