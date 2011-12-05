package character.models.NPC
{
	import action.PeasantBuild;
	
	import assets.PhotoAssets;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	
	import character.CharacterNameGenerator;
	import character.away3D.Peasant3D;
	import character.models.CharacterModifier;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import managers.EventManager;
	import managers.GameManager;
	
	import models.User;
	import models.away3D.buildings.ManaProduction3D;
	import models.building.Barracks;
	import models.building.Home;
	import models.building.ManaProduction;
	import models.building.Portal;
	import models.building.Road;
	import models.building.StoneProduction;
	import models.building.Tower;
	import models.building.TownHall;
	import models.building.WoodProduction;
	import models.constants.GameConstants;
	import models.interfaces.BuildingObject;
	import models.interfaces.ObjectModifier;
	import models.states.BackgroundState;
	import models.states.GameState;
	import models.states.events.BuildStateEvent;
	import models.states.events.GameStartEvent;
	import models.states.events.StateEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.BitmapAsset;
	import mx.core.ClassFactory;
	import mx.events.CollectionEvent;
	import mx.events.ItemClickEvent;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Application;
	import spark.components.supportClasses.ItemRenderer;

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
		public var strength:Number;					// The strength of a peasant
		public var dexterity:Number;					// The dexterity of a peasant
		public var wisdom:Number;						// The wisdom of a peasant
		public var intelligence:Number;				// Intelligence of a peasant
		public var building:Number;					// The building rate of the peasant
		public var speed:Number;						// The speed that peasant moves at.
		
		// State variables 	
		public static var PEASANT_BUILD_FOCUS:String = "PeasantBuildFocus";
		public static var PEASANT_BUILD_START:String = "PeasantBuildStart";
		public static var PEASANT_ATTACK:String = "PeasantAttack";
		public static var PEASANT_IDLE:String = "PeasantIdle";
		
		// The internal state of the peasant
		private var _internalState:String;				// The internal state holds information about chained states
		private var _buildObject:BuildingObject;			// The build object
		
		// The XML modifiers
		[Embed(source="character/models/modifiers/PeasantBuildModifier.xml", mimeType="application/octet-stream")]
		public static  var PeasantBuildModifier:Class;
		
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
				
			// With the first level information we can now populate the model
			this.hitpoints = xmlList[0].hitpoints;
			this.strength = xmlList[0].strength;
			this.dexterity = xmlList[0].dexterity;
			this.wisdom = xmlList[0].wisdom;
			this.intelligence = xmlList[0].intelligence;
			this.building = xmlList[0].building;
			this.speed = xmlList[0].speed;
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
		
		override public function getSpeed():Number{
			return this.speed;
		}
		
		// Override the object list functionality
		override public function canUsurpObjectList():Boolean {
			return true;
		}
		override public function getObjectListRenderer():ClassFactory{
			return new ClassFactory(PeasantBuild);
		}
		override public function provideOLDataProvider(p:PhotoAssets):ArrayCollection {
			// Create an arrayCollection
			var arr:ArrayCollection = new ArrayCollection();
			
			// Extractt the xml
			var b:ByteArray = new Peasant.PeasantBuildModifier();
			var data:XML = new XML(b.readUTFBytes(b.length));
			var listOfBuildObjects:XMLList = data.children();

			for each(var building:XML in listOfBuildObjects){
				var name:String = building.@name;
				var ic:BitmapAsset = this.getIconsFromName(p, name);
				var obj:Object = {		// Create the object to be rendered
					wood: building.wood,
					stone : building.stone,
					mana : building.mana,
					title : name,
					icon : ic
				};
				
				arr.addItem(obj);
			}
		
			return arr;
		}
		
		// Get icons from a name
		private function getIconsFromName(p:PhotoAssets, s:String):BitmapAsset{
			if(s == "Tower"){
				return new p.TowerLevel0() as BitmapAsset;
			}else if(s == "Road"){
				return new p.EastRoad() as BitmapAsset;
			}else{
				return new p.ThePortal() as BitmapAsset;
			}
		}
	
		// Change the state
		override public function changeToState(event:Event, s:String, a:Application):Object{
			if(event is ItemClickEvent){
				var evt:ItemClickEvent = event as ItemClickEvent;
				var b:ByteArray = new Peasant.PeasantBuildModifier();
				var data:XML = new XML(b.readUTFBytes(b.length));
				var objL:XMLList = data.children();
				var obj:XML = objL[evt.index];
				// Create different objects from depending on the name
				var name:String = obj.@name;
				var so:BuildingObject;
				if(name == "Tower"){
					so = new Tower();
				}else if(name == "Portal"){
					so = new Portal();
				}else if(name == "Road"){
					so = new Road();
				}else if(name == "Barracks"){
					so = new Barracks();
				}else if(name == "TownHall"){
					so = new TownHall();
				}else if(name == "WoodProduction"){
					so = new WoodProduction();
				}else if(name == "StoneProduction"){
					so = new StoneProduction();
				}else if(name == 'ManaProduction'){
					so = new ManaProduction();
				}else if(name == 'Home'){
					so = new Home();
				}else{
					return null;
				}
				// Set the internal state
				this._internalState = Peasant.PEASANT_BUILD_FOCUS;
				this._buildObject = so;
			
				// Create a build event to start the process
				var p:PropertyChangeEvent = new PropertyChangeEvent(BackgroundState.MOUSE_BUILD);
				p.newValue = BackgroundState.MOUSE_BUILD;
				a.dispatchEvent(p);
				return so;
			}
			return null;
		}
		
		public function getBuildObject():BuildingObject {
			return this._buildObject;
		}
		
		override public function getChainedState():StateEvent {
			if(this._internalState == Peasant.PEASANT_BUILD_FOCUS){
				var e:BuildStateEvent = new BuildStateEvent(BuildStateEvent.BUILD_INIT);
				return e;
			}
			
			return null;
		}
		
		override public function getProximityTriggerToChainedState(p:Point, angle:Number):Point {
			var np:Point = new Point();
			var dis:Number = GameConstants.proximityDistance();
			np.x = p.x - Math.cos(angle) * dis ;
			np.y = p.y - Math.sin(angle) * dis;
			return np;
		}
		
		override public function changeInternalState(s:String):void {
			this._internalState = s;
		}
		
		override public function isBlocking(g:GameState):Boolean {
			return this._internalState == Peasant.PEASANT_BUILD_START;
		}
		
		override public function getInternalState():String {
			return this._internalState;
		}
		
		override public function getInterruptStateString(s:String):String {
			var s:String = "";
			if(this._internalState == Peasant.PEASANT_BUILD_START){
				s += "Would you like to stop the build?";
			}
			return s;
		}
		
		override public function  alterInternalStateOnGameState(r:StateEvent):void{
			if(r is BuildStateEvent){
				this._internalState = Peasant.PEASANT_BUILD_START;
			}
		}
		
		override public function setInternalIdleState():void{
			this._internalState = Peasant.PEASANT_IDLE;
		}
	}
}