package models
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;

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
		}
		
		public function toString():String {
			var s:String = "";
			s = s + this.FacebookID.toString() + ":";
			s = s + this.Experience.toString() + ":";
			s = s + this.Empire.toString() + ":";
			s = s + this.isEmperor.toString() + ":";
			s = s + this.completeManaProduction.toString() + ":";
			s = s + this.completeStoneProduction.toString() + ":";
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