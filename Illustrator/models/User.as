package models
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	import models.constants.GameConstants;
	
	import mx.controls.Alert;

	[Bindable]
	[RemoteClass(alias='models.User')]
	public class User
	{
		// The User information
		public var FacebookID:Number;
		public var Experience:Number;
		public var Empire:String;
		public var isEmperor:Boolean;
		
		// Complete mining information
		public var completeManaProduction : Number;
		public var completeStoneProduction : Number;
		public var completeWoodProduction : Number;
		public var totalMana:Number;												/* The current  wood stockpiles */
		public var totalStone:Number;												/* The current stone stockpiles */			
		public var totalWood:Number;												/* The current mana stockpiles */
		public var productionDate:Date;												/* The last time the production value of any of the
																					   resources was updated. */
		// Renderer information
		public var alias:String;
		public var level:Number;
		
		public function User()
		{
			super();
			
			//  Setup the level
			this.level = GameConstants.getUserLevelFromExperience(this.Experience);
		}
		
		// Create 
		public function initializeUserWithId(id:Number) : void{
			this.FacebookID = id;
			this.Experience = 0;
			this.Empire = "Empire";
			this.isEmperor = true;
			this.completeManaProduction = 0;
			this.completeStoneProduction = 0;
			this.completeWoodProduction = 0;
			this.totalMana = 0;
			this.totalStone = 0;
			this.totalWood = 0;
			this.productionDate = new Date();
			this.level = 0;
			this.alias = "danielo2";
		}
		
		public function isEqual(u:User) : Boolean{
			if(this.FacebookID == u.FacebookID && this.Experience == u.Experience && this.Empire == u.Empire &&
				this.completeManaProduction == u.completeManaProduction && this.completeStoneProduction == u.completeStoneProduction &&
				this.completeWoodProduction == u.completeWoodProduction && this.totalMana == u.totalMana &&
				this.totalStone == u.totalStone && this.totalWood == u.totalWood && this.productionDate == u.productionDate &&
				this.level == level && this.alias == alias){
				return true;
			}else{
				return false;
			}
		}
		
		// Clone the user
		public function cloneUser():User {
			var u:User = new User();
			u.FacebookID = this.FacebookID;
			u.Experience = this.Experience;
			u.Empire = this.Empire;
			u.isEmperor = this.isEmperor;
			u.completeManaProduction = this.completeManaProduction;
			u.completeStoneProduction = this.completeStoneProduction;
			u.completeWoodProduction = this.completeWoodProduction;
			u.totalMana = this.totalMana;
			u.totalStone = this.totalStone;
			u.totalWood = this.totalWood;
			u.productionDate = this.productionDate;
			u.level = this.level;
			u.alias = this.alias;
			return u;
		}
		
		public static function createUserFromJSON(buildObject:Object) : User {
			var obj:Object = buildObject.Value;
			var u:User = new User();
			u.alias = obj.alias;
			return u;
		}
		
		public function purchaseObject(woodCost:Number, stoneCost:Number, manaCost:Number) : void {
			this.totalMana -= manaCost;
			this.totalStone -= stoneCost;
			this.totalWood -= woodCost;
		}
		
		public function updateProduction(woodProduction:Number, stoneProduction:Number, manaProduction:Number) : void {
			Alert.show(this.completeManaProduction.toString() + ":" + this.completeStoneProduction.toString() + ":" + this.completeWoodProduction.toString());
			this.completeManaProduction += manaProduction;
			this.completeStoneProduction += stoneProduction;
			this.completeWoodProduction += woodProduction;
			this.productionDate = new Date();
			Alert.show(this.completeManaProduction.toString() + ":" + this.completeStoneProduction.toString() + ":" + this.completeWoodProduction.toString());

		}
		
		public function toString():String {
			var s:String = "";
			s = s + this.FacebookID.toString() + ":";
			s = s + this.Experience.toString() + ":";
			s = s + this.Empire.toString() + ":";
			s = s + this.isEmperor.toString() + ":";
			s = s + this.completeManaProduction.toString() + ":";
			s = s + this.completeStoneProduction.toString() + ":";
			s = s + this.level.toString() + ":";
			s = s + this.alias.toString() + ":";
			s = s + this.totalMana.toString() + ":";
			s = s + this.totalStone.toString() + ":";
			s = s + this.totalWood.toString() + ":";
			s = s + this.completeWoodProduction.toString() + "\n";
			return s;
		}
		
		// IExternalizable interface		
		public function writeExternal(output:IDataOutput) : void {
			output.writeInt(this.FacebookID);
			output.writeInt(this.Experience);
			output.writeUTF(this.Empire);
			output.writeInt(this.completeManaProduction);
			output.writeInt(this.completeStoneProduction);
			output.writeInt(this.completeWoodProduction);
		}
		public function readExternal(input:IDataInput) : void {
			this.FacebookID = input.readInt();
			this.Experience = input.readInt();
			this.Empire = input.readUTF();
			this.isEmperor = input.readBoolean();
			this.completeManaProduction = input.readInt();
			this.completeStoneProduction = input.readInt();
			this.completeWoodProduction = input.readInt();
		}
	}
}