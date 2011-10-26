package character.models
{
	import character.models.NPC.Peasant;
	
	import flash.utils.ByteArray;
	
	import models.interfaces.ObjectModifier;

	// Character modifier. Modifies the characteristics of a character depending on their experience
	public class CharacterModifier implements ObjectModifier
	{
		[Embed(source="character/models/modifiers/PeasantModifier.xml", mimeType="application/octet-stream")]
		private var PeasantModifier:Class;
		
		public function CharacterModifier()
		{
			
		}
		
		public function getModifierForClass(obj:Object):XML{
			var data:XML;
			if(obj is Peasant){
				var bData:ByteArray = new this.PeasantModifier();
				data = new XML(bData.readUTFBytes(bData.length));
			}
			
			return data;
		}
	}
}