package messaging
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONParseError;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import messaging.events.ChannelAttackEvent;
	import messaging.events.ChannelBuildEvent;
	import messaging.events.ChannelJSON;
	import messaging.events.ChannelMessageEvent;
	import messaging.events.ChannelMoveEvent;
	import messaging.events.ChannelUserLoginEvent;
	import messaging.events.ChannelUserLogoutEvent;
	
	import models.GameChannel;
	
	import mx.controls.Alert;
	
	import spark.components.Application;

	public class ChannelJavascriptBridge
	{
		public var app:Application;								/* The application */
		public function ChannelJavascriptBridge(a:Application)
		{
			// The external inteface
			ExternalInterface.addCallback("onChannelOpen", onChannelOpen);
			ExternalInterface.addCallback("onChannelMessage", onChannelMessage);
			ExternalInterface.addCallback("onChannelError", onChannelError);
			ExternalInterface.addCallback("onChannelClose", onChannelClose);
		
			// The application
			this.app = a;
		}
		
		
		public function initGameChannel(gc:GameChannel) : void {
			var token:String = gc.token;
			ExternalInterface.call("CTA.openChannel", token);
		}
		
		
		public function onChannelOpen() : void {
			
		}
		
		public function onChannelMessage(message : String) : void {
			
			var resultObject:Object;
			
			// Parse the json
			if(message != null){
				try {
					resultObject = JSON.decode(message);
				}catch(e:JSONParseError){
					Alert.show(e.text);
				}
			}			
			
			// Array of all the accepted types, which have an associated event
			// which will be sent to the gameManager
			var a:Array = [ChannelAttackEvent, ChannelBuildEvent, ChannelMessageEvent, ChannelMoveEvent, 
				ChannelUserLoginEvent, ChannelUserLogoutEvent];
	
			try{
			for(var i:int = 0; i < a.length; i++){
				var obj:Object = new a[i]();
				var json:ChannelJSON = obj as ChannelJSON;
				if(json.isType(resultObject)){
					
					// Decode the json
					json.fromJSON(message);
					
					// Send the message associated with the json
					var e:Event = obj as Event;
					this.app.dispatchEvent(e);
				}
			} 
			}catch(e:Error){
				Alert.show(e.toString());
			}
		}
		
		public function onChannelError(error:String) : void {
			Alert.show("Channel Error" + error);
		}
		
		public function onChannelClose() : void {

		}
	}
}