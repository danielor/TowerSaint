package models.constants
{
	import models.Portal;
	import models.Road;
	import models.SuperObject;
	import models.Tower;
	
	import mx.controls.Alert;
	import mx.utils.StringUtil;

	public class PurchaseConstants
	{
		// Units that are built use this static class to find out whether they
		// can be purchased with the resources available to the user.
		public function PurchaseConstants()
		{
			
		}
		
		// Function returns whether a superobject can be purchased.
		public static function canPurchase(s:SuperObject, level:Number, totalWood:Number, totalStone:Number, 
				totalMana:Number) : Boolean {
			return totalWood > PurchaseConstants.woodCost(s, level) && totalStone > PurchaseConstants.stoneCost(s, level) &&
				totalMana > PurchaseConstants.manaCost(s, level);
		}
		
		// Function returns a string that corresponds to what resources are missing from
		// a purchase?
		public static function missingResourcesString(s:SuperObject, level:Number, totalWood:Number, totalStone:Number, 
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
		
		
		// Wood cost for all objects
		public static function woodCost(s:SuperObject, level:Number):Number {
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
		public static function stoneCost(s:SuperObject, level:Number):Number {
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
		public static function manaCost(s:SuperObject, level:Number):Number {
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