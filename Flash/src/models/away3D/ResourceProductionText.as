package models.away3D
{
	import away3d.primitives.TextField3D;
	
	import models.User;
	
	import mx.controls.Alert;
	import mx.utils.StringUtil;

	/*
	The class implements a textfield3D object that updates itself with respcet
	to time
	*/
	public class ResourceProductionText extends TextField3D
	{
		private var user:User;									/* Which user's production */
		private var templateString:String;						/* The template string for the display */
		public function ResourceProductionText(font:String, u:User, d:Date){
			super(font, null);			/* Instantatiate the text field */
			
			// State information
			this.user = u;
			
			// Instantiate the state
			this.templateString = "Mana Production  :{0}-{1}\nStone Production :\t{2}-{3}\nWood Production :\t{4}-{5}";
			this.updateState(d);
			Alert.show(this.user.completeManaProduction.toString() + ":" + this.user.completeStoneProduction.toString() + ":" +
				this.user.productionDate.toUTCString());
		}
		
		/*
		Calculate the current text output for global production variables
		*/
		public function updateState(d:Date) : void {
			// Calculate the date difference
			var minutesPerDay:Number =  60. * 24.;
			var numberOfMinutesAtProduction:Number = Math.ceil((d.getTime() - user.productionDate.getTime()) / minutesPerDay);
			var inSeconds:Number = 60.; 
			
			// Get the updated totals
			var mProd:Number = _alwaysPositive(this.user.completeManaProduction, this.user.totalMana, numberOfMinutesAtProduction) / inSeconds;
			var sProd:Number = _alwaysPositive(this.user.completeStoneProduction, this.user.totalStone, numberOfMinutesAtProduction) / inSeconds;
			var wProd:Number = _alwaysPositive(this.user.completeWoodProduction, this.user.totalWood, numberOfMinutesAtProduction) / inSeconds;
			
			// Save the updated text
			this.text = StringUtil.substitute(this.templateString, mProd.toFixed(1), this.user.completeManaProduction, sProd.toFixed(1), this.user.completeStoneProduction,
											  wProd.toFixed(1), this.user.completeWoodProduction);
		}
		
		/*
		Always positive. How can an individual owe material 
		*/
		private function _alwaysPositive(uP:Number, tP:Number, nM:Number) : Number {
			var temp:Number = uP * nM + tP;
			if(temp >= 0.){
				return temp;
			}else{
				return 0;
			}
		}
	}
}