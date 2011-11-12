package character.models.NPC
{
	import assets.PhotoAssets;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	
	import character.CharacterNameGenerator;
	import character.away3D.Peasant3D;
	import character.models.CharacterModifier;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import models.User;
	import models.interfaces.ObjectModifier;
	
	import mx.controls.Alert;
	import mx.core.BitmapAsset;

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
			// Get the peasant. Needs to be character modifier
			var xml:XML = cMod.getModifierForClass(this);
			var xmlList:XMLList = xml..level.(@name = 1);
			Alert.show(xmlList..@hitpoints.toString());
				
			// With the first level information we can now populate the model
			this.hitpoints = xmlList[0].hitpoints;
			this.strength = xmlList[0].strength;
			this.dexterity = xmlList[0].dexterity;
			this.wisdom = xmlList[0].wisdom;
			this.intelligence = xmlList[0].intelligence;
			this.building = xmlList[0].building;
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
		
		// Override the text and image representation
		override public function getImage(photo:PhotoAssets):BitmapAsset
		{
			return new photo.PeasantPic() as BitmapAsset;
		}
		override public function display():TextFlow
		{
			var textFlow:TextFlow = new TextFlow();

			// Setup the stuff
			var pGraph:ParagraphElement = new ParagraphElement();
			
			// Add the span
			var iSpan:SpanElement = new SpanElement();
			iSpan.text = getString();
			
			// The span element
			pGraph.addChild(iSpan);
			textFlow.addChild(pGraph);
			
			return textFlow;
		}
		
		public function getString():String {
			var s:String = "";
			s+="Name\t\t" + this.name.toString() + "\n";
			s+="Level\t\t" + level.toString() + "\n";
			s+="Experience\t" + experience.toString() + "\n";
			s+="Strength\t\t" + strength.toString() + "\n";
			s+="Dexterity\t\t" + dexterity.toString() + "\n";
			s+="Wisdom\t\t" + wisdom.toString() + "\n";
			s+="Intelligence\t" + intelligence.toString() + "\n";
			s+="Building\t\t" + building.toString() + "\n";
			return s;
		}
	}
}