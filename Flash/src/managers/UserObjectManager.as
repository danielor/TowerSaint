package managers
{
	import assets.PhotoAssets;
	
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import flash.utils.Dictionary;
	
	import managers.states.TowerSaintServiceState;
	
	import models.Bounds;
	import models.SuperObject;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.AbstractOperation;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	public class UserObjectManager
	{
		// The map
		public var map:Map;
		
		// State variables
		public var serverState:TowerSaintServiceState;
		public var listOfObjects:ArrayCollection;
		public var photo:PhotoAssets;
		public var focusPanelManager:FocusPanelManager;
		
		/*
			Constructor - Takes in the map(view), and state constants
		*/
		public function UserObjectManager(m:Map, sS:TowerSaintServiceState, p:PhotoAssets, fPM:FocusPanelManager)
		{
			// The state variables
			this.map = m;
			this.serverState = sS;
			this.photo = p;
			this.focusPanelManager = fPM;
			
			// The containers
			this.listOfObjects = new ArrayCollection();
		}
		
		/* 
			Function asynchoously gets all objects within visible bounds of the map.
			The objects recived are drawn on the map
		*/
		public function getAllObjectsWithinBounds(bounds:LatLngBounds) : void {
			// Clear the container
			listOfObjects.removeAll();
			
			// Get all of the services
			var a:Array = this.serverState.getAllConstants();
			
			// Get the bounds
			var b:Bounds = new Bounds();
			b.fromGoogleBounds(bounds);
			
			// Call the server
			for(var i:int = 0; i < a.length; i++){
				var s:String = a[i] as String;
				getObjectWithinBound(s, b);
			}
		}
		
		/*
			Function interfaces with the backend by calling the remote objects 
			getObjectWithinBound method
		*/
		private function getObjectWithinBound(serviceString:String, bounds:Bounds) : void {
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary[serviceString] as RemoteObject;
			
			// The abstract call
			var operation:AbstractOperation = _service.getOperation("getObjectInBounds");
			operation.addEventListener(ResultEvent.RESULT, onGetAllObjects);	
			operation.send(bounds);
			
		}
		
		/* 
			Draw all of the objects one gets from the server
		*/
		private function onGetAllObjects(event:ResultEvent) : void {
			var tArray:ArrayCollection = event.result as ArrayCollection;
			for(var i:Number = 0; i < tArray.length; i++){
				var s:SuperObject = tArray.getItemAt(i) as SuperObject;
				s.draw(false, this.map, this.photo, this.focusPanelManager);
			}
		}
		
		/*
			Function return all objects that have been modified in an array
		*/
		public function getAllModifiedObjects():Array {
			var a:Array = new Array();
			for(var i:int = 0; i < this.listOfObjects.length; i++){
				var s:SuperObject = this.listOfObjects.getItemAt(i) as SuperObject;
				if(s.getIsModified()){
					a.push(s);
				}
			}
			return a;
		}
	}
}