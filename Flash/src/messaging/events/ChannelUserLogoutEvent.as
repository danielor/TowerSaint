package messaging.events
{
	import flash.events.Event;

	public class ChannelUserLogoutEvent extends Event implements ChannelJSON
	{
		// Static properties identifying the type of event, and json type
		public static const JSON_TYPE:String = "LOGOUT";
		public static const CHANNEL_LOGOUT:String = "ChannelLogout";
		
		public function ChannelUserLogoutEvent()
		{
			super(CHANNEL_LOGOUT);	
		}
		
		override public function clone():Event {
			return new ChannelUserLogoutEvent();
		}
		
		// ChannelJSON interface
		public function fromJSON(message:String) : void {
			
		}
		
		public function isType(t:String) : Boolean{
			return JSON_TYPE == t;
		}
	}
}