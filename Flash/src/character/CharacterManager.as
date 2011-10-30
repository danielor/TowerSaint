package character
{
	import character.intefaces.NPCFunctionality;
	import character.models.CharacterModifier;
	
	import models.User;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;

	public class CharacterManager
	{
		private var user:User;										// The user managing his character
		private var char:CharacterModifier;							// Instantiate a character modifier
		private var listOfCharacters:ArrayCollection;				// The list of characters 
		public function CharacterManager(u:User)
		{
			this.user = u;
			this.char = new CharacterModifier();			// Modifies the characters
			this.listOfCharacters = new ArrayCollection();	// The list of characters
		}
		
		// Create a character class
		public function initializeObjectFromClass(c:Class):Object{
			var npc:NPCFunctionality = new c() as NPCFunctionality;
			npc.initialize(this.user, this.char);
			return npc;
		}
		
		// Add to Manager
		public function addToManager(obj:Object):void {
			this.listOfCharacters.addItem(obj);
		}
	}
}