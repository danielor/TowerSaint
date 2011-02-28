package messaging.events
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;

	public class ChannelUserLogoutEvent extends Event implements ChannelJSON
	{
		// Static properties identifying the type of event, and json type
		public static const JSON_TYPE:String = "LOGOUT";
		public static const CHANNEL_LOGOUT:String = "ChannelLogout";
		
		// The LOGOUT object
		public var logout:Object;
		
		public function ChannelUserLogoutEvent()
		{
			super(CHANNEL_LOGOUT);	
		}
		
		override public function clone():Event {
			return new ChannelUserLogoutEvent();
		}
		
		// ChannelJSON interface
		public function fromJSON(message:String) : void {
			var obj:Object = JSON.decode(message);
			logout = obj.LOGOUT;
			
		}
		
		public function getJSONObject() : Object {
			return logout;		
		}
		
		public function isType(t:Object) : Boolean{
			return t.hasOwnProperty(JSON_TYPE);
		}
	}
}