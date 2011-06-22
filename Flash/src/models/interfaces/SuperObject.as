package models.interfaces
{
	import assets.PhotoAssets;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.overlays.Polygon;
	
	import flash.events.IEventDispatcher;
	
	import flashx.textLayout.elements.TextFlow;
	
	import managers.GameFocusManager;
	
	import models.Bounds;
	
	import mx.core.BitmapAsset;
	import models.Production;
	import models.User;

	public interface SuperObject extends TowerSaintDispatcher
	{
		// Draw the object on the map
		function draw(drag:Boolean, map:Map, photo:PhotoAssets, fpm:GameFocusManager, withBoundary:Boolean, scence:Scene3D, view:View3D) : void;
		//function initializeIcon(photo:PhotoAssets):void;
		
		// Display information associated with object in text
		function display() : TextFlow;
		function hide():void;											/* Hide the 3d model */
		function view():void;											/* Redisplay the 3d model */
		function isDrawn():Boolean;										/* Flag for whether the object is drawn */
		
		// Flag deterimens whether is the object is valid(not dragged, at a valid location)
		function isReady() : Boolean;
		function isAtValidLocation() : Boolean;							/* Returns true if the object does not intersect with any other empires */
		function getBounds():LatLngBounds;								/* Get the bounds of the object on the map */
		
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
		
		// Comparision operators between different super objects
		function isEqual(s:SuperObject):Boolean;
		
		// While building a superobject, this function will change the appearacnce of the
		// object, and/or change the state of the object
		function updateBuildState(i:Number) : void;
		
		// Get the image representation
		function getImage(photo:PhotoAssets):BitmapAsset;
		
		// Returns true if the object is current visible on the map
		function isVisible(map:Map):Boolean;
		
		// Build State interface
		function isIncompleteState():Boolean;				/* Has the objects finished building */
		function getFoundingDate():Date;					/* Return the date the object was built */
		function setUser(u:User):void;						/* Set the user of the object equal to something */				
		
		
		// Boundary interface
		function getMaxInfluence():Number;					/* Get the number of tower units in pixels */
		function getBoundaryPolygon():Polygon;				/* Return the polygon associate with the bounds of influence */
		
		// Get the string associated with object
		function getNameString():String;
		
		// Returns the production of resources associated with o
		function getProduction():Production; 				
		
		// Boundary interface
		function hasBoundary():Boolean;												/* Object for which this is true should implement the boundary super object interface */
		function isOverLappingBoundsOfObject(pos:LatLng, map:Map, photo:PhotoAssets) : Boolean;		/* Check if the position is overlapping the image */
	}
}