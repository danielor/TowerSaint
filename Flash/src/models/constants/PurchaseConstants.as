package models.constants
{
	import models.building.Portal;
	import models.building.Road;
	import models.interfaces.BuildingObject;
	import models.building.Tower;
	
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	
	import wumedia.parsers.swf.Data;

	public class PurchaseConstants
	{
		// Units that are built use this static class to find out whether they
		// can be purchased with the resources available to the user.
		public function PurchaseConstants()
		{
			
		}
		
		// Function returns whether a superobject can be purchased.
		public static function canPurchase(s:BuildingObject, level:Number, totalWood:Number, totalStone:Number, 
				totalMana:Number) : Boolean {
			return totalWood > PurchaseConstants.woodCost(s, level) && totalStone > PurchaseConstants.stoneCost(s, level) &&
				totalMana > PurchaseConstants.manaCost(s, level);
		}
		
		// Function returns a string that corresponds to what resources are missing from
		// a purchase?
		public static function missingResourcesString(s:BuildingObject, level:Number, totalWood:Number, totalStone:Number, 
													  totalMana:Number) : String {
			var resourceString:String = "";
			var templateString:String = "You need {0} more {1} to build a {2}"
			var resourceAmount:Number;
			var resourceType:String;
			if(totalWood <= PurchaseConstants.woodCost(s, level)){
				resourceAmount = PurchaseConstants.woodCost(s, level) - totalWood;
				resourceType = "Wood";
			}else if(totalStone <= PurchaseConstants.stoneCost(s, level)){
				resourceAmount = PurchaseConstants.stoneCost(s, level) - totalStone;
				resourceType = "Stone";
			}else if(totalMana <= PurchaseConstants.manaCost(s, level)){
				resourceAmount = PurchaseConstants.manaCost(s, level) - totalMana;
				resourceType = "Mana";
			}
				
			
			
			resourceString += StringUtil.substitute(templateString, resourceAmount.toString(), resourceType, s.getNameString());
			return resourceString;
		} 
	
		
		// Get the maximum time associated with all building objects
		public static function getMaximumTime(level:Number):Date {
			var towerTime:Date = PurchaseConstants.getTowerBuildTime(level);
			var roadTime:Date = PurchaseConstants.getRoadBuildTime(level);
			var portalTime:Date = PurchaseConstants.getPortalBuildTime(level);
			
			// Place into array
			var a:Array = new Array(towerTime, roadTime, portalTime);
			a.sort(ObjectUtil.dateCompare);
			return a[0] as Date;
		}
		
		// Get the time associated with building an object
		public static function buildTime(s:BuildingObject, level:Number) : Date {
			if(s is Tower){
				return PurchaseConstants.getTowerBuildTime(level);
			}else if(s is Portal){
				return PurchaseConstants.getPortalBuildTime(level);
			}else if(s is Road){
				return PurchaseConstants.getRoadBuildTime(level);
			}else{
				return new Date();
			}
		}
		
		// Get the tower build time
		public static function getTowerBuildTime(level:Number) : Date {
			var d:Date = new Date();
			if(level == 0){
				//d.setSeconds(d.setSeconds() + 10);
				//d.setMinutes(d.getMinutes() + 5);
				d.setMinutes(d.getMinutes() + 1);
			}else if(level == 1){
				d.setHours(d.getHours() + 5);
			}else if(level == 2){
				d.setDate(d.getDate() + 1);
			}else if(level == 3){
				d.setDate(d.getDate() + 5);
			}
			return d;
		}
		
		// Get the road build time
		public static function getRoadBuildTime(level:Number) : Date {
			var d:Date = new Date();
			if(level == 0){
				d.setMinutes(d.getMinutes() + 1);
			}else if(level == 1){
				d.setMinutes(d.getMinutes() + 5);
			}else if(level == 2){
				d.setHours(d.getHours() + 1);
			}else if(level == 3){
				d.setHours(d.getHours() + 5);
			}
			return d;
		}
		
		// Get the portal build time
		public static function getPortalBuildTime(level:Number) : Date {
			 var d:Date = new Date();
			 if(level == 0){
				 d.setMinutes(d.getMinutes() + 1);
			 }else if(level == 1){
				 d.setHours(d.getHours() + 1);
			 }else if(level == 2){
				 d.setHours(d.getHours() + 5);
			 }else if(level == 3){
				 d.setHours(d.getDate() + 1);
			 }
			 return d;
		}
		
		// Wood cost for all objects
		public static function woodCost(s:BuildingObject, level:Number):Number {
			if(s is Tower){
				return PurchaseConstants.getTowerWoodCost(level);
			}else if(s is Portal){
				return PurchaseConstants.getPortalWoodCost(level);
			}else if(s is Road){
				return PurchaseConstants.getPortalWoodCost(level);
			}else{
				return 0.0;
			}
		}
		
		// Base objects wood production
		public static function getTowerWoodCost(level:Number) :Number {
			return Math.pow(10, 2 * level) * 1000;
		}
		public static function getPortalWoodCost(level:Number) :Number {
			return Math.pow(10, level) * 500;
		}
		public static function getRoadWoodCost(level:Number) : Number {
			return Math.pow(10, level) * 250;
		}
		
		// Stone cost for all objects
		public static function stoneCost(s:BuildingObject, level:Number):Number {
			if(s is Tower){
				return PurchaseConstants.getTowerStoneCost(level);
			}else if(s is Portal){
				return PurchaseConstants.getPortalStoneCost(level);
			}else if(s is Road){
				return PurchaseConstants.getRoadStoneCost(level);
			}else{
				return 0.0;
			}
		}
		
		// Base objects stone production
		public static function getTowerStoneCost(level:Number) :Number{
			return Math.pow(10, 2 * level) * 1000;
		}
		public static function getPortalStoneCost(level:Number) :Number{
			return Math.pow(10, level) * 500;
		}
		public static function getRoadStoneCost(level:Number) : Number{
			return Math.pow(10, level) * 250;
		}
		
		// Mana cost for all objects
		public static function manaCost(s:BuildingObject, level:Number):Number {
			if(s is Tower){
				return PurchaseConstants.getTowerManaCost(level);
			}else if(s is Portal){
				return PurchaseConstants.getPortalManaCost(level);
			}else if(s is Road){
				return PurchaseConstants.getRoadManaCost(level);
			}else{
				return 0.0;
			}
		}
		
		// Base objects mana production
		public static function getTowerManaCost(level:Number) :Number {
			return Math.pow(10, 2 * level) * 1000;
		}
		public static function getPortalManaCost(level:Number) : Number {
			return int(Math.pow(10, 1.5 * level) * 2000);
		}
		public static function getRoadManaCost(level:Number) :Number {
			return 0.0;
		}
	}
}