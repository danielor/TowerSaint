package messaging.events
{
	import flash.events.Event;

	public class ChannelUserLoginEvent extends Event implements ChannelJSON
	{
		// Static properties identifying the type of event, and json type
		public static const JSON_TYPE:String = "LOGIN";
		public static const CHANNEL_LOGIN:String = "ChannelLogin";
		
		public function ChannelUserLoginEvent()
		{	
			super(CHANNEL_LOGIN);	
		}
		
		override public function clone():Event {
			return new ChannelUserLoginEvent();
		}
				
		// ChannelJSON interface
		public function fromJSON(message:String) : void {
			
		}
		
		public function isType(t:String) : Boolean{
			return JSON_TYPE == t;
		}
	}
}