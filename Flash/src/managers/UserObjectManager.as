package managers
{
	import assets.PhotoAssets;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import managers.states.TowerSaintServiceState;
	
	import models.Bounds;
	import models.Location;
	import models.SuperObject;
	import models.User;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.AbstractOperation;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	import mx.utils.ObjectUtil;
	
	import spark.components.Application;
	import spark.components.Button;
	
	public class UserObjectManager
	{
		public var app:Application; 													/* A reference to the application that runs the user object manager */
		
		// The map
		public var map:Map;
		
		// The user
		public var user:User;
		
		// State variables
		public var serverState:TowerSaintServiceState;
		public var listOfObjects:ArrayCollection;
		public var photo:PhotoAssets;
		
		// The list of bounds
		public var listOfBounds:ArrayCollection;
		
		// Networking variables
		public var listOfOpenConnections:ArrayCollection;
		
		/*
		Constructor - Takes in the map(view), and state constants
		*/
		public function UserObjectManager(m:Map, uU:User, sS:TowerSaintServiceState, p:PhotoAssets, a:Application)
		{
			// The state variables
			this.map = m;
			this.user = uU;
			this.serverState = sS;
			this.photo = p;
			this.app = a;
			
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
				//Alert.show(this.listOfBounds.toString());
				// Get all of the services
				var a:Array = this.serverState.getAllDrawableConstants();
				
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
		Checks if the a position for the capital of a new empire is the minimum distance from
		all other towers
		*/
		public function satisfiesMinimumDistance(pos:LatLng, f:Function) : void {
			var l:Location = Location.googleToAMFLocation(pos);
			
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// The abstract call
			var operation:AbstractOperation = _service.getOperation("satisfiesMinimumDistance");
			operation.addEventListener(ResultEvent.RESULT, f);	
			operation.send(l);
		}
		
		/* 
		Adds a user alias associated with a new user
		*/
		public function setUserAlias(u:User, s:String, f:Function) : void {
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// The abstract call
			var operation:AbstractOperation = _service.getOperation("setUserAlias");
			operation.addEventListener(ResultEvent.RESULT, f);	
			operation.send(u, s);
		}
		
		/* 
		Function saves updated objects
		*/
		public function saveUserObjects(arr:Array, u:User, f:Function) : void {
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// The abstract call
			var operation:AbstractOperation = _service.getOperation("saveUserObjects");
			operation.addEventListener(ResultEvent.RESULT, f);	
			operation.send(arr, u);
		}
		
		/*
		Function builds objects in the game
		*/
		public function buildObject(s:Object, u:User) : void {
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// The abstract call
			var operation:AbstractOperation = _service.getOperation("buildObject");
			operation.addEventListener(ResultEvent.RESULT, onNull);	
			operation.send(s, u);
		}
		
		/*
		Function finishes builds objects in the game
		*/
		public function buildObjectComplete(s:Object, u:User) : void {
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// The abstract call
			var operation:AbstractOperation = _service.getOperation("buildObjectComplete");
			operation.addEventListener(ResultEvent.RESULT, onNull);	
			operation.send(s, u);
		}
		
		/* Function cancels objects in a game */
		public function buildObjectCancel(s:Object, u:User) : void {
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// The abstract call
			var operation:AbstractOperation = _service.getOperation("buildObjectCancel");
			operation.addEventListener(ResultEvent.RESULT, onNull);	
			operation.send(s, u);
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
		Updates all objects belonging to the user
		*/
		/*
		public function updateTowerSaintService():void
		{
			var modified_objects:Array = getAllModifiedObjects();
			
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// The abstract call
			var operation:AbstractOperation = _service.getOperation("saveUserObjects");
			operation.addEventListener(ResultEvent.RESULT, onSaveUserObjects);	
			operation.send(modified_objects);
		}
		*/
		
		public function saveUser(u:User, f:Function) : void
		{
			// Save the user
			this.user = u;
			
			// Create the service
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// If this.user is a new user, the service will create the user on the server.
			// If not, then 
			var operation:AbstractOperation = _service.getOperation("getCurrentUser");
			operation.addEventListener(ResultEvent.RESULT, f);
			operation.send(this.user);
		}
		
		public function GetUserObjects(u:User, f:Function) : void {
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// If this.user is a new user, the service will create the user on the server.
			// If not, then 
			var operation:AbstractOperation = _service.getOperation("getUserObjects");
			operation.addEventListener(ResultEvent.RESULT, f);
			operation.send(u);
		}
		
		
		public function initGame(u:User, f:Function) : void {
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// If this.user is a new user, the service will create the user on the server.
			// If not, then 
			var operation:AbstractOperation = _service.getOperation("initGameChannels");
			operation.addEventListener(ResultEvent.RESULT, f);
			operation.send(u);
		}
		
		/* 
		Function logins user telling everyone over the channel api that we have logged in
		*/
		public function loginUserToGame(u:User, f:Function) : void {
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// If this.user is a new user, the service will create the user on the server.
			// If not, then 
			var operation:AbstractOperation = _service.getOperation("loginUserToGame");
			operation.addEventListener(ResultEvent.RESULT, f);
			operation.send(u);
		}
		
		/* 
		Function updates the global user production variables
		b - The boolean flag determines if it is an inialization update or not
		*/
		public function updateProduction(u:User, b:Boolean, f:Function) : void {
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// If this.user is a new user, the service will create the user on the server.
			// If not, then 
			var operation:AbstractOperation = _service.getOperation("updateProduction");
			operation.addEventListener(ResultEvent.RESULT, f);
			operation.send(u, b);
		}
		
		/* 
		Function closes the game and all of the user channels
		*/
		public function closeGame(u:User) : void {
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// If this.user is a new user, the service will create the user on the server.
			// If not, then 
			var operation:AbstractOperation = _service.getOperation("closeGame");
			operation.addEventListener(ResultEvent.RESULT, onNull);
			operation.send(u);
		}
		
		/* 
		Function sends a message to the server. Response occurs over the channel javascript api.
		*/
		public function sendMessage(u:User, s:String) : void {
			var servicesDictionary:Dictionary = this.serverState.getServices();
			var _service:RemoteObject = servicesDictionary["towersaint"] as RemoteObject;
			
			// If this.user is a new user, the service will create the user on the server.
			// If not, then 
			var operation:AbstractOperation = _service.getOperation("sendMessage");
			operation.addEventListener(ResultEvent.RESULT, onNull);
			operation.send(u, s);
		}
		
		
		private function onNull(e:Event):void {
			
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