package messaging.events
{
	import flash.events.Event;

	public interface ChannelJSON
	{
		function fromJSON(s:String) : void;
		function isType(s:Object) : Boolean;
		function getJSONObject() : Object;
	}
}