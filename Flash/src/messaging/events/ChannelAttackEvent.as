package messaging.events
{
	import flash.events.Event;

	public class ChannelAttackEvent extends Event implements ChannelJSON
	{
		// Static properties identifying the type of event, and json type
		public static const JSON_TYPE:String = "ATTACK";
		public static const CHANNEL_ATTACK:String = "ChannelAttack";
		
		// The event interface
		public function ChannelAttackEvent()
		{
			super(CHANNEL_ATTACK);	
		}
		
		override public function clone():Event {
			return new ChannelAttackEvent();
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