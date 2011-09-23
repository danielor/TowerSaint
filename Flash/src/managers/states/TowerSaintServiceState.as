package managers.states
{
	import flash.events.SecurityErrorEvent;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.InvokeEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	public class TowerSaintServiceState implements ServiceState
	{
		// String constants used to control the service state
		private const serviceString:String = "towersaint"
		//private const URL:String = "http://towersaint.appspot.com/";
		private const URL:String = "http://localhost:8081/"
		private const latticeGranularity:Number = .001;
		
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
			listOfConstants.push(this.serviceString);

			return listOfConstants;
		}
		
		public function getAllDrawableConstants():Array {
			var listOfConstants:Array = new Array();
			listOfConstants.push(this.serviceString);
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
		public function getLatticeGranularity():Number {
			return this.latticeGranularity;
		}
		
		/* Create the remote objects that corresponds to object services */
		private function createRemoteObject(channel:ChannelSet, remoteString:String) : void{
			// Set up the remote object
			var remoteObject:RemoteObject = new RemoteObject(remoteString);
			remoteObject.showBusyCursor = true;
			remoteObject.channelSet = channel;
			remoteObject.addEventListener(FaultEvent.FAULT, _onRemoteServiceFault);
			remoteObject.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onRemoteServiceFault);
			//remoteObject.addEventListener(InvokeEvent.INVOKE, _onRemoteInvoke);
			//remoteObject.addEventListener(ResultEvent.RESULT, _onRemoteResult);
			
			// Save the object
			remoteObjectCollection[remoteString] = remoteObject;
		}
		
		/* Internal functions for displaying connection errors */
		private function _onRemoteServiceFault(event:FaultEvent) : void {
			
			var errorMsg:String = "Service error:\n" + event.fault.faultCode;
			Alert.show(event.fault.faultDetail, errorMsg);
		}
		
		private function _onRemoteInvoke(event:InvokeEvent) : void {
			var errorMsg:String = "Invoke error:\n" + event.toString();
			Alert.show("Invoke", errorMsg);
		}
		
		private function _onRemoteResult(event:ResultEvent) : void {
			var msg:String = "Result event:\n" + event.type + event.toString();
			Alert.show("Result", msg);
		}
		
		private function _onRemoteServiceSecurityError(event:SecurityErrorEvent) : void {
			var errorMsg:String = "Service security error";
			Alert.show(event.text, errorMsg);
		}
	}
}