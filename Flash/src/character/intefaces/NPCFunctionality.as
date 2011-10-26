package character.intefaces
{
	import models.interfaces.UserObject;

	public interface NPCFunctionality extends UserObject
	{
		public function move():void;							// Move
		public function attack():void;							// Attack
		public function alterWithModifier(xml:XML):void;		// Alter the NPC with a modifier
	}
}