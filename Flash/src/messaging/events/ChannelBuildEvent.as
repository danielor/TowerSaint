package messaging.events
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;

	public class ChannelBuildEvent extends Event implements ChannelJSON
	{
		// Static properties identifying the type of event, and json type
		public static const JSON_TYPE:String = "BUILD";
		public static const CHANNEL_BUILD:String = "ChannelBuild";
		
		// The build object
		public var buildUser:String;
		public var buildObject:Object;
		
		public function ChannelBuildEvent()
		{
			super(CHANNEL_BUILD);	
		}
		
		override public function clone():Event {
			return new ChannelBuildEvent();
		}
		
		// ChannelJSON interface
		public function fromJSON(message:String) : void {
			var obj:Object = JSON.decode(message);
			
			// The object
			buildUser = obj.alias;
			buildObject = obj.buildObject;
		}
		
		public function getJSONObject() : Object {
			return new Object();		
		}
		
		public function isType(t:Object) : Boolean{
			return t.hasOwnProperty(JSON_TYPE);
		}
	}
}