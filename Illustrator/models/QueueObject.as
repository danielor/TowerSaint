package models
{
	import mx.controls.ProgressBar;

	// A queue object containts the essential information associated with an operation
	// that requires the user to date
	public class QueueObject
	{
		public var description:String; 						/* Describe the operation */
		public var date:Date;								/* When will I be done? */
		public var endFunction:Function;					/* What will I call when I am done? */
		public var periodicFunction:Function;				/* What should I call while calling? */
		public var startDate:Date;							/* When did I start? */
		public var percentComplete:Number;					/* The percentage of the operation that is complete */
		public var buildObject:SuperObject;					/* The object that needs to be built */
		public var isActive:Boolean;						/* The queue object can be in active or passive mode */
		public var failureFunction:Function;				/* What do if the process is interrupted or fails? */
		
		// Variables associated with keeping the state
		private var progressBar:ProgressBar;					/* Tie a progress bar to the queue object for updating */
		
		public function QueueObject(dS:String, d:Date, ef:Function, pF:Function, bO:SuperObject, fF:Function)
		{
			this.description = dS;
			this.date = d;
			this.endFunction = ef;
			this.periodicFunction = pF;
			this.buildObject = bO;
			this.failureFunction = fF;
		
			// Setup the state variables
			this.startDate = new Date();
			this.percentComplete = 0.;
			this.progressBar = null;
			this.isActive = true;
		}
		
		// Un/Tie a progress bar into the queue object
		public function tieProgressBar(progress:ProgressBar) : void {
			this.progressBar = progress;
		}
		public function untieProgressBar() : void {
			this.progressBar = null;
		}
		
		// Update the state variables
		public function updateState(d:Date) : void {
			// How close are we to finishing?
			var totalMinutes:Number = this.numberOfMinutes(this.startDate, this.date);
			var currentMinute:Number = this.numberOfMinutes(this.startDate, d);
			this.percentComplete = currentMinute / totalMinutes;
			
			// Call the periodic function
			this.periodicFunction(this.percentComplete);
			
			// If we are visualizing the progress of the queue object
			// update the state of the progress bar.
			if(this.progressBar != null){
				this.progressBar.setProgress(this.percentComplete, 1.0);
			}
		}
		
		// Private function returns the number of minutes between two dates
		private function numberOfMinutes(firstDate:Date, secondDate:Date) : Number {
			var minutesPerDay:Number =  60. * 24.;
			return Math.ceil((firstDate.getTime() - secondDate.getTime()) / minutesPerDay);
		}
	}
}