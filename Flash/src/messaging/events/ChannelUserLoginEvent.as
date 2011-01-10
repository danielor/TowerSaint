package messaging.events
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;

	public class ChannelUserLoginEvent extends Event implements ChannelJSON
	{
		// Static properties identifying the type of event, and json type
		public static const JSON_TYPE:String = "LOGIN";
		public static const CHANNEL_LOGIN:String = "ChannelLogin";
		
		// Array of logins
		public var userLoginArray:ArrayCollection;
		
		public function ChannelUserLoginEvent()
		{	
			// Setup the event
			super(CHANNEL_LOGIN);
			
			// Create the state information
			userLoginArray = new ArrayCollection();
		}
		
		override public function clone():Event {
			return new ChannelUserLoginEvent();
		}
				
		// ChannelJSON interface
		public function fromJSON(message:String) : void {
			var obj:Object = JSON.decode(message);
			var value:Object = obj.LOGIN;
			
			// Depending on the type of object
			if(value is Array){
				var a:Array = value as Array;
				for(var i:int = 0; i < a.length; i++){
					this.userLoginArray.addItem(a[i]);
				}
			}else{
				this.userLoginArray.addItem(value);
			}
		}
		
		// Return the decoded json object
		public function getJSONObject() : Object {
			return this.userLoginArray;			
		}
		
		public function isType(t:Object) : Boolean{
			return t.hasOwnProperty(JSON_TYPE);
		}
	}
}