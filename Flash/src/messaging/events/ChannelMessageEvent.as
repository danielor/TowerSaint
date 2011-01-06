package messaging.events
{
	import flash.events.Event;

	public class ChannelMessageEvent  extends Event implements ChannelJSON
	{
		// Static properties identifying the type of event, and json type
		public static const JSON_TYPE:String = "MESSAGE";
		public static const CHANNEL_MESSAGE:String = "ChannelMessage";
		
		public function ChannelMessageEvent()
		{
			super(CHANNEL_MESSAGE);	
		}
		
		override public function clone():Event {
			return new ChannelMessageEvent();
		}
		
		// ChannelJSON interface
		public function fromJSON(message:String) : void {
			
		}
		
		public function isType(t:String) : Boolean{
			return JSON_TYPE == t;
		}
	}
}