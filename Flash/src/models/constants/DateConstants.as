package models.constants
{
	public class DateConstants
	{
		public function DateConstants()
		{
		}
		
		// TODO: Handle year/month modifications
		public static function numberOfMinutes(d:Date, d2:Date) : Number{
			var minutes:Number = 0;
			minutes += (d.getDay() - d2.getDay()) * 24. * 60.;
			minutes += (d.getHours() - d2.getHours()) * 60.;
			minutes += (d.getMinutes() - d2.getMinutes());
			return minutes;
		}
		
		public static function numberOfSeconds(d:Date, d2:Date) : Number {
			var seconds:Number = 0;
			seconds += (d.getDay() - d2.getDay()) * 24. * 60. * 60.;
			seconds += (d.getHours() - d2.getHours()) * 60. * 60.;
			seconds += (d.getMinutes() - d2.getMinutes()) * 60.;
			seconds += (d.getSeconds() - d2.getSeconds());
			return seconds;
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