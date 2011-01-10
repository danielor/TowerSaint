package messaging.events
{
	import flash.events.Event;

	public class ChannelBuildEvent extends Event implements ChannelJSON
	{
		// Static properties identifying the type of event, and json type
		public static const JSON_TYPE:String = "BUILD";
		public static const CHANNEL_BUILD:String = "ChannelBuild";
		
		public function ChannelBuildEvent()
		{
			super(CHANNEL_BUILD);	
		}
		
		override public function clone():Event {
			return new ChannelBuildEvent();
		}
		
		// ChannelJSON interface
		public function fromJSON(message:String) : void {
			
		}
		
		public function getJSONObject() : Object {
			return new Object();		
		}
		
		public function isType(t:Object) : Boolean{
			return t.hasOwnProperty(JSON_TYPE);
		}
	}
}