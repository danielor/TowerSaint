package character.models.NPC
{
	import character.CharacterNameGenerator;
	import character.models.CharacterModifier;
	
	import models.User;
	import models.interfaces.ObjectModifier;

	// Peasant is the object which builds things in your empire.
	[Bindable]
	[RemoteClass alias="character.models.Peasant"]
	public class Peasant extends NonPlayerCharacter
	{
		public var latitude:Number;						// The latitidue of the peasant
		public var longitude:Number; 					// The longitude of the peasant
		public var hitpoints:Number;					// The number of hit points associated with the peasant
		public var level:Number;						// The level of the peasant
		public var name:String;							// The name of the peasant
		public var user:User;							// The user that owns the peasant
		
		// Characteristics of a peasant
		private var strength:Number;					// The strength of a peasant
		private var dexterity:Number;					// The dexterity of a peasant
		private var wisdom:Number;						// The wisdom of a peasant
		private var building:Number;					
		
		public function Peasant()
		{
			super();
		}
		
		override public function intialize(u:User, cMod:ObjectModifier):void {
			this.name = CharacterNameGenerator.generateName(2); 			// Simple name for a simple creature.
			this.user = u;													// Set the user
			this.level = 1;													// Set the level
			
			// Get the peasant. Needs to be character modifier
			var xml:XML = cMod.getModifierForClass(this);
			
		}
	}
}