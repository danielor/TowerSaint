package managers.states
{
	import flash.utils.Dictionary;
	
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.remoting.RemoteObject;

	public class TowerSaintServiceState implements ServiceState
	{
		// String constants used to control the service state
		private static const userRemoteServiceString:String = "user";
		private static const portalRemoteServiceString:String = "portal";
		private static const towerRemoteServiceString:String = "tower";
		private static const roadRemoteServiceString:String = "road";	
		private static const URL:String = "http://localhost:8083";

		// Dictionary holds all of the remote objects
		private var remoteObjectCollection:Dictionary;
		
		public function TowerSaintServiceState()
		{
			// Initialize object
			remoteObjectColection = new Dictionary();
			initializeServices();
		}
		
		/* Return all of the server state constants */
		public function getAllConstants():Array{
			var listOfConstants:Array = new Array();
			listOfConstants.push(userRemoteServiceString);
			listOfConstants.push(portalRemoteServiceString);
			listOfConstants.push(towerRemoteServiceString);
			listOfConstants.push(roadRemoteServiceString);
			return listOfConstants;
		}
		
		/*Initialize all of the server AMF objects */
		public function intializeServices() : void {
			var channel:AMFChannel = new AMFChannel("pyamf-channel", URL);
			var channels:ChannelSet = new ChannelSet();
			channels.addChannel(channel);
			
			var constants:Array = this.getAllConstants();
			for(var remoteString:String in constants){
				createRemoteObject(channels, remoteString);
			}
		}
		
		/* Create the remote objects that corresponds to object services */
		private function createRemoteObject(channel:ChannelSet, remoteString:String) : void{
			// Set up the remote object
			var remoteObject:RemoteObject = new RemoteObject(remoteString);
			remoteObject.showBusyCursor = true;
			remoteObject.channelSet = channel;
			remoteObject.addEventListener(FaultEvent.FAULT, _onRemoteServiceFault);
			remoteObject.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onRemoteServiceFault);
		
			// Save the object
			remoteObjectCollection[remoteString] = remoteObject;
		}
		
		/* Internal functions for displaying connection errors */
		private function _onRemoteServiceFault(event:FaultEvent) : void {
			var errorMsg:String = "Service error:\n" + event.fault.faultCode;
			Alert.show(event.fault.faultDetail, errorMsg);
		}
		
		private function _onRemoteServiceSecurityError(event:SecurityErrorEvent) : void {
			var errorMsg:String = "Service security error";
			Alert.show(event.text, errorMsg);
		}
	}
}