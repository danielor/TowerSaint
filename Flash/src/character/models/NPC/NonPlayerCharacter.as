package character.models.NPC
{
	import assets.PhotoAssets;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	
	import character.intefaces.NPCFunctionality;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import flash.geom.Point;
	
	import flashx.textLayout.elements.TextFlow;
	
	import models.User;
	import models.constants.GameConstants;
	import models.interfaces.ObjectModifier;
	
	import mx.controls.Alert;
	import mx.core.BitmapAsset;
	
	public class NonPlayerCharacter implements NPCFunctionality
	{
		protected var model:Mesh;						// The NPC model
		private var map:Map;							// A reference to the map
		public function NonPlayerCharacter()
		{
			
		}
		
		public function initialize(u:User, obj:ObjectModifier):void {
			
		}
		
		public function move(l:LatLng):void {
			// Get the location of the transformation
			var currentPoint:Point = GameConstants.fromMapToAway3D(l, this.map);
			
			// Update the position of the model
			this.model.x = currentPoint.x;
			this.model.y = currentPoint.y;
		}
		
		public function getSpeed():Number {
			return 0.;
		}
		
		public function attack():void {
			
		}
		
		// The user object interface
		public function getNameString():String{
			return "";
		}
		
		// How the object is drawn?
		public function draw(s:Scene3D, v:View3D, m:Map):void {
			// The map
			this.internalDraw(s, v, m);
		}
		
		protected function internalDraw(s:Scene3D, v:View3D, m:Map):void{
			// The map
			this.map = m;
			
			// Get the location of the model
			var b:LatLngBounds = m.getLatLngBounds();
			var pos:LatLng = this.getPosition(b);
			
			// Update the position of the model
			var currentPoint:Point = GameConstants.fromMapToAway3D(pos,this.map);
			this.model.x = currentPoint.x;
			this.model.y = currentPoint.y;
			this.model.z = 0.;
	
			// Add to the scne
			s.addChild(this.model);
		}
		
		// Get the 3d model of the object
		public function get3DObject():Mesh {
			return this.model;
		}
		
		// Get the position of the npc... must overload
		public function getPosition(b:LatLngBounds):LatLng{
			return null;
		}
		
		// Get the current position of the object
		public function getPoint(m:Map):Point {
			var b:LatLngBounds = m.getLatLngBounds();
			var pos:LatLng = this.getPosition(b);
			return GameConstants.fromMapToAway3D(pos, map);
		}
			
		// Set the position of the npc
		public function setPosition(pos:LatLng):void {
		
		}
		
		// Return the character name
		public function getCharacterName():String {
			return "";
		}
		
		public function getImage(photo:PhotoAssets):BitmapAsset
		{
			return null;
		}
		public function display():TextFlow
		{
			return null;
		}
	}
}