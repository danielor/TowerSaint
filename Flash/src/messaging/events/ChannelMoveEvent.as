package messaging.events
{
	import flash.events.Event;
	public class ChannelMoveEvent extends Event implements ChannelJSON
	{
		// Static properties identifying the type of event, and json type
		public static const JSON_TYPE:String = "MOVE";
		public static const CHANNEL_MOVE:String = "ChannelMove";
		
		public function ChannelMoveEvent()
		{	
			super(CHANNEL_MOVE);	
		}
		
		override public function clone():Event {
			return new ChannelMoveEvent();
		}
				
		// ChannelJSON interface
		public function fromJSON(message:String) : void {
			
		}
		
		public function isType(t:String) : Boolean{
			return JSON_TYPE == t;
		}
	}
}