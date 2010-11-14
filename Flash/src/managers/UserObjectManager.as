package managers
{
	import assets.PhotoAssets;
	
	import com.google.maps.LatLng;
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
		
		// The list of bounds
		public var listOfBounds:ArrayCollection;
	
		// Networking variables
		public var listOfOpenConnections:ArrayCollection;
		
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
			this.listOfBounds = new ArrayCollection();
			this.listOfOpenConnections = new ArrayCollection();
		}
		
		/* 
			Function asynchoously gets all objects within visible bounds of the map.
			The objects recived are drawn on the map
		*/
		public function getAllObjectsWithinBounds(bounds:LatLngBounds) : void {
			if(!hasBounds(bounds)){
				// Add the bounds to the list
				this.listOfBounds.addItem(bounds);
				Alert.show(this.listOfBounds.toString());
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
		}
		
		/* 
			Function asynchronously gets all objects withing influence range of the visible
			bounds of the map. The objects are used to calculate the empire boundaries.
		*/
		public function getAllObjectsWithinInfluenceOfBounds(bounds:LatLngBounds) : void {
			if(!hasBounds(bounds)){
				
			}
		}
		
		/* 
			Private function used to diminish the laod on the server by only get data in
			latlngbounds that is not part of the arrayCollection of bounds
		*/
		private function hasBounds(bounds:LatLngBounds) :Boolean {
			for(var i:int = 0; i < this.listOfBounds.length; i++){
				var innerBounds:LatLngBounds = this.listOfBounds.getItemAt(i) as LatLngBounds;
				if(innerBounds.equals(bounds)){
					return true;
				}
			}
			return false;
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
			
			// List of open abstract operations
			this.listOfOpenConnections.addItem(operation);
		}
		
		/*
		Remove the first instance of the abstract operation, that has an open
		connection with the server.
		*/
	
		private function removeFirstOperationFromOpenConnection(op:mx.rpc.AbstractOperation) : void{
			for(var i:int = 0; i <this.listOfOpenConnections.length; i++){
				var cOp:AbstractOperation = this.listOfOpenConnections[i] as AbstractOperation;
				if(cOp == op){
					this.listOfOpenConnections.removeItemAt(i);
					return;
				}
			}	
		}
		
		
		/* 
		Returns true if there are any open connections
		*/
		private function hasOpenConnections():Boolean {
			return (this.listOfOpenConnections.length == 0);
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
			
			// Save the list of objects
			this.listOfObjects.addAll(tArray);
			
			// Get the abstract operation that has finished
			var op:AbstractOperation = event.target as AbstractOperation;
			removeFirstOperationFromOpenConnection(op);
			
		
			// Check if all the open connections are closed
			if(!hasOpenConnections()){
				
				// Draw the empire boundaries
				drawEmpireBoundaries();
			}
			
			
		}
		
		/*
			Function draws the empire boundaries around super objects. First it must calculate
			the boundary of all the object pieces. Then, it must check for intersections.
			After finding the interesections, the relative power of an empire at that position 
			is calculated to determine to whom belongs the  lattice point.
		*/
		
		public function drawEmpireBoundaries():void {
			// Get all objects withint the current bounds
			var listOfObjects:ArrayCollection = getObjectWithinBounds();
			
			
		}
		
		/*
			The user object stores all of the objects from the server. This function acts a filter
			and returns only the objects that are currently being displayed by the map
		*/
		
		public function getObjectWithinBounds():ArrayCollection{
			var objectsOnMap:ArrayCollection =  new ArrayCollection();
			
			for(var i:int = 0; i < this.listOfObjects.length; i++){
				var s:SuperObject = this.listOfObjects[i] as SuperObject;
				if(s.isVisible(this.map)){
					
				}
			}
			
			return objectsOnMap;
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