package messaging.events
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	
	import mx.controls.Alert;

	public class ChannelMessageEvent  extends Event implements ChannelJSON
	{
		// Static properties identifying the type of event, and json type
		public static const JSON_TYPE:String = "MESSAGE";
		public static const CHANNEL_MESSAGE:String = "ChannelMessage";
		
		// The message
		public var message:Object;
		
		public function ChannelMessageEvent()
		{
			super(CHANNEL_MESSAGE);	
		}
		
		override public function clone():Event {
			return new ChannelMessageEvent();
		}
		
		// ChannelJSON interface
		public function fromJSON(m:String) : void {
			var obj:Object = JSON.decode(m);
			message = obj.MESSAGE;
		}
		
		public function getJSONObject() : Object {
			return message;		
		}
		
		public function isType(t:Object) : Boolean{
			return t.hasOwnProperty(JSON_TYPE);
		}
	}
}