package managers.states
{
	import flash.events.SecurityErrorEvent;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.remoting.RemoteObject;

	public class TowerSaintServiceState implements ServiceState
	{
		// String constants used to control the service state
		private const userRemoteServiceString:String = "user";
		private const portalRemoteServiceString:String = "portal";
		private const towerRemoteServiceString:String = "tower";
		private const roadRemoteServiceString:String = "road";	
		private const URL:String = "http://localhost:8083";
		private const latOffset:Number = .001;					/* Latitude granularity */
		private const lonOffset:Number = .001;					/* Longitude granularity */
		private const maxInfluence:Number = 10;					/* The max influence */

		// Dictionary holds all of the remote objects
		private var remoteObjectCollection:Dictionary;
		
		public function TowerSaintServiceState()
		{
			// Initialize object
			this.remoteObjectCollection = new Dictionary();
			intializeServices();
		}
		
		/* Return all of the server state constants */
		public function getAllConstants():Array{
			var listOfConstants:Array = new Array();
			listOfConstants.push(this.portalRemoteServiceString);
			listOfConstants.push(this.towerRemoteServiceString);
			listOfConstants.push(this.roadRemoteServiceString);
			return listOfConstants;
		}
		
		/*Initialize all of the server AMF objects */
		public function intializeServices() : void {
			var channel:AMFChannel = new AMFChannel("pyamf-channel", URL);
			var channels:ChannelSet = new ChannelSet();
			channels.addChannel(channel);
			
			var constants:Array = this.getAllConstants();
			for(var i:int = 0; i < constants.length; i++){
				var s:String = constants[i] as String;
				createRemoteObject(channels, s);
			}
		}
		
		/* Return the services that are appropriate to this object */
		public function getServices():Dictionary {
			return this.remoteObjectCollection;
		}
		
		/* Return the lattice granurality */
		public function getLatOffset():Number {
			return this.latOffset;
		}
		public function getLonOffset():Number {
			return this.lonOffset;
		}
		public function getMaxInfluence():Number {
			return this.maxInfluence;
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