package character.models.NPC
{
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	
	import character.CharacterNameGenerator;
	import character.away3D.Peasant3D;
	import character.models.CharacterModifier;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import models.User;
	import models.interfaces.ObjectModifier;
	
	import mx.controls.Alert;

	// Peasant is the object which builds things in your empire.
	[Bindable]
	[RemoteClass(alias="character.models.Peasant")]
	public class Peasant extends NonPlayerCharacter
	{
		public var latitude:Number;						// The latitidue of the peasant
		public var longitude:Number; 					// The longitude of the peasant
		public var hitpoints:Number;					// The number of hit points associated with the peasant
		public var level:Number;						// The level of the peasant
		public var name:String;							// The name of the peasant
		public var experience:Number;					// The experience of the peasant.
		public var user:User;							// The user that owns the peasant
		
		// Characteristics of a peasant
		private var strength:Number;					// The strength of a peasant
		private var dexterity:Number;					// The dexterity of a peasant
		private var wisdom:Number;						// The wisdom of a peasant
		private var intelligence:Number;				// Intelligence of a peasant
		private var building:Number;					
		
		public function Peasant()
		{
			this.model = new Peasant3D(.15);
		}
		
		override public function initialize(u:User, cMod:ObjectModifier):void {
			this.name = CharacterNameGenerator.generateName(2); 			// Simple name for a simple creature.
			this.user = u;													// Set the user
			this.level = 1;													// Set the level
			Alert.show(this.name);
			// Get the peasant. Needs to be character modifier
			var xml:XML = cMod.getModifierForClass(this);
			var xmlList:XMLList = xml..level.(@name = 1);
			
			// With the first level information we can now populate the model
			this.hitpoints = xmlList.@hitpoints;
			this.strength = xmlList.@strength;
			this.dexterity = xmlList.@dexterity;
			this.wisdom = xmlList.@wisdom;
			this.intelligence = xmlList.@intelligence;
			this.building = xmlList.@building;
			this.experience = 0;
		
		}
		
		// Get the name string
		override public function getNameString():String {
			return "Peasant";
		}
		
		// Specialized drawing 
		override public function draw(s:Scene3D, v:View3D, m:Map):void{
			this.model.rotationZ = 30; // Modifications to the model
			this.internalDraw(s, v, m);
		}
		
		// Get the position of the npc
		override public function getPosition(b:LatLngBounds):LatLng {
			return new LatLng(this.latitude, this.longitude);
		}
		
		// Set the position
		override public function setPosition(pos:LatLng):void{
			this.latitude = pos.lat();
			this.longitude = pos.lng();
		}
		
		override public function getCharacterName():String {
			return this.name;
		}
	}
}