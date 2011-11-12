package character.intefaces
{
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	
	import flash.geom.Point;
	
	import models.interfaces.UserObject;

	public interface NPCFunctionality extends UserObject
	{
		function move(l:LatLng):void;					// Move
		function attack():void;							// Attack
		function draw(s:Scene3D, v:View3D, m:Map):void;	// Draw the object on the map
		function getPoint(m:Map):Point;					// Get the current location of the object
		function getCharacterName():String;				// Get the name of the character
	}
}