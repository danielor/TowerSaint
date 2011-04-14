package models.constants
{
	public class DateConstants
	{
		public function DateConstants()
		{
		}
		
		public static function numberOfMinutes(d:Date, d2:Date) : Number{
			return Math.ceil((d.getTime() - d2.getTime()) / 60 * 24);
		}
		
		public static function numberOfSeconds(d:Date, d2:Date) : Number {
			return Math.ceil((d.getTime() - d2.getTime()) / 60 * 24);
		}
		
		public static function addTimeToDate(d:Date, nOfM:Number = 0, nOfS:Number = 0) : void{
			if(nOfM != 0){
				d.setMinutes(d.getMinutes() + nOfM);
			}
			
			if(nOfS != 0){
				d.setSeconds(d.getSeconds() + nOfS);
			}
		}
	}
}