package character
{
	import character.intefaces.NPCFunctionality;
	import character.models.CharacterModifier;
	
	import com.google.maps.Map;
	
	import flash.geom.Point;
	
	import models.User;
	import models.constants.GameConstants;
	
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
		
		// Find characters within a point
		public function findCharactersCloseToPoint(p:Point, m:Map, arr:ArrayCollection):void {
 
			for(var i:int = 0; i < this.listOfCharacters.length; i++){
				var npc:NPCFunctionality = this.listOfCharacters[i] as NPCFunctionality;
				var np:Point = npc.getPoint(m);
				
				// Calculate the distance
				var xDiff:Number = np.x - p.x;
				var yDiff:Number = np.y - p.y;
				var distance:Number = Math.sqrt(xDiff * xDiff + yDiff * yDiff);
				if(distance < GameConstants.proximityDistance()){
					arr.addItem(npc);
				}
			}
		}
	}
}