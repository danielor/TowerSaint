package character.intefaces
{
	import assets.PhotoAssets;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import managers.EventManager;
	import managers.GameManager;
	
	import models.interfaces.UserObject;
	import models.states.GameState;
	import models.states.events.StateEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	
	import spark.components.Application;
	import spark.components.supportClasses.ItemRenderer;

	public interface NPCFunctionality extends UserObject
	{
		function move(l:LatLng):void;									// Move
		function attack():void;							 				// Attack
		function draw(s:Scene3D, v:View3D, m:Map):void;					// Draw the object on the map
		function getPoint(m:Map):Point;									// Get the current location of the object
		function getCharacterName():String;				 				// Get the name of the character
		function getSpeed():Number;										// Get the speed of the character
		function canUsurpObjectList():Boolean;			 				// Can we usurp the object list??
		function getObjectListRenderer():ClassFactory;					// Return the item rendere for the object list
		function provideOLDataProvider(p:PhotoAssets):ArrayCollection;	// Provide the data provider for the object list
		function changeToState(event:Event, s:String, a:Application):void;	// Change the state of the object
		function getChainedState():StateEvent;							// Return the game state chained to the internal state of npc
		function getProximityTriggerToChainedState(p:Point, angle:Number):Point;// Returns the proximity to the chained state
	}
}