package models.states
{
	import assets.PhotoAssets;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapMoveEvent;
	
	import flash.events.Event;
	
	import managers.EventManager;
	import managers.GameFocusManager;
	import managers.GameManager;
	import managers.PolygonBoundaryManager;
	import managers.QueueManager;
	import managers.UserObjectManager;
	
	import models.Production;
	import models.QueueObject;
	import models.User;
	import models.constants.DateConstants;
	import models.constants.PurchaseConstants;
	import models.interfaces.SuperObject;
	import models.states.events.BackgroundStateEvent;
	import models.states.events.BuildStateEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Application;

	public class DrawState implements GameState
	{
		private const viewString:String = "inApp";						/* The view state */
		private var isMapReady:Boolean;									/* True if the map is ready */
		public var isInState:Boolean;									/* Boolean variable associated with the state */
		public var listOfUserModels:ArrayCollection;					/* The list of user models */
		public var map:Map;												/* The map where we will be drawing */
		public var scene:Scene3D;										/* The scene associated with the game */
		public var view:View3D;											/* The view where all of the objects sit on */
		public var gameFocus:GameFocusManager;							/* Focus on the game */
		public var photo:PhotoAssets;									/* The photo assets */
		public var user:User;											/* The user running the game */
		public var userObjectManager:UserObjectManager;					/* The manager of the user objects */
		public var queueManager:QueueManager;							/* Manages the queue */
		public var gameManager:GameManager;								/* Manages the entirety of the game */
		public var app:Application;										/* The flex application running everything */
		public var userBoundary:PolygonBoundaryManager;					/* The manager of the boundary */
		public var buildState:BuildState;								/* The build state */
		public var mapEventManager:EventManager;						/* The event manager associated with the map */
		public function DrawState(lOuM:ArrayCollection, m:Map, v:View3D, s:Scene3D, gF:GameFocusManager, p:PhotoAssets, u:User,
					uOM:UserObjectManager, qM:QueueManager, gm:GameManager, a:Application, uB:PolygonBoundaryManager,
					bS:BuildState)
		{
			this.listOfUserModels = lOuM;
			this.map = m;
			this.view = v;
			this.scene = s;
			this.gameFocus = gF;
			this.photo = p;
			this.user = u;
			this.userObjectManager = uOM;
			this.queueManager = qM;
			this.gameManager = gm;
			this.app = a;
			this.userBoundary = uB;
			this.isInState = false;
			this.isMapReady = true;
			this.buildState = bS;
		}
		
		public function isChatActive():Boolean
		{
			return true;
		}
		
		public function isMapActive():Boolean
		{
			return true;
		}
		
		public function isFocusActive():Boolean
		{
			return true;
		}
		
		public function isGameActive():Boolean
		{
			return true;
		}
		
		public function enterState():void
		{
			this.isInState = true;
			this.draw();
			
			// Create the event manager
			this.mapEventManager = new EventManager(this.map);
			this.mapEventManager.addEventListener(MapMoveEvent.MOVE_END, onMapMoveEnd);
		}
		
		public function exitState():void
		{
			this.mapEventManager.RemoveEvents();
			this.isInState = false;
		}
		
		public function isActiveState():Boolean
		{
			return this.isInState;
		}
		
		public function hasView():Boolean
		{
			return false;
		}
		
		public function onMapReady(event:PropertyChangeEvent):void {
			this.isMapReady = event.newValue as Boolean;
		}
		
		private function onMapMoveEnd(event:MapMoveEvent):void {
			this.isMapReady = true;
			this.draw();
		}
		
		// Draw ..
		public function draw() : void {
			// Defer drawing until the map is ready... it could be that the
			// server is faster then the map.
			if(this.isMapReady){
				// Set the array of queue objects
				var arrayOfQueueObjects:ArrayCollection = new ArrayCollection();
				// We need to dereference the user object from all of the user objects
				// in the game objects, so that the game objects users' can be dereferenced
				// without affecting the global user object. 
				//xwthis.user = this.user.cloneUser();
				
				// Get dates
				var d:Date = new Date();
				var bounds:LatLngBounds = this.map.getLatLngBounds();
				
				// Create a list of draw objects to later draw their boundaries
				var listOfDrawnObjects:ArrayCollection = new ArrayCollection();
				
				for(var i:int = 0; i < this.listOfUserModels.length; i++){
					var obj:SuperObject = this.listOfUserModels[i] as SuperObject;
					var pos:LatLng = obj.getPosition(bounds);
					
					// Check if the object is visbile
					if(bounds.containsLatLng(pos)){
						if(!obj.isDrawn()){
							// Check if the object has finished building
							if(!obj.isIncompleteState()){
								var mDate:Date = PurchaseConstants.buildTime(obj, 0);
								var foundingDate:Date = obj.getFoundingDate();
								var productionTime:Number = DateConstants.numberOfMinutes(mDate, d);
								var timeAlive:Number = DateConstants.numberOfMinutes(d, foundingDate);
								if(productionTime < timeAlive){
									// Draw the object
									obj.draw(true, this.map, this.photo, this.gameFocus, true, this.scene, this.view);
									
									// Finish the building of the object. The code must be here because no users
									// could be logged in the association graph of the user.
									//obj.setUser(null); // Dereferencing is necessary since the Key is not active in GAE
									updateUserState(obj);
									//this.userObjectManager.buildObjectComplete(obj, this.user);
									//obj.setUser(this.user);
									
									// Append the list of draw objects
									listOfDrawnObjects.addItem(obj);
								}else{
									arrayOfQueueObjects.addItem(obj);
								}
							}else{
								obj.draw(true, this.map, this.photo, this.gameFocus, true, this.scene, this.view);
								listOfDrawnObjects.addItem(obj);
							}
						}else{
							if(obj.isVisible(this.map)){
								obj.redrawModelInShiftedFrame();
							}else{
								obj.view();
							}
						}
					}else{
						obj.hide();
					}
				}
				
				// If there are active queue objects redraw them if necessary
				var arr:ArrayCollection = this.queueManager.getListOfSuperObjects();
				for(var j:int = 0; j < arr.length; j++){
					var s:SuperObject = arr[j] as SuperObject;
					var spos:LatLng = s.getPosition(bounds);
					if(bounds.containsLatLng(spos)){
						// Redraw and draw
						s.redrawModelInShiftedFrame();
						this.userBoundary.addAndDraw(s);
					}else{
						s.hide()
					}
				}
				
				
				
				
				// REMOVE AWAY3D values
				if(arrayOfQueueObjects.length){
					var b:BuildStateEvent = new BuildStateEvent(BuildStateEvent.BUILD_START);
					b.attachPreviousState(this);
					b.listOfQueueObjects = arrayOfQueueObjects;
					this.app.dispatchEvent(b);
					return;
				}
				
				// Cancel the build object if we leave the current map pane.
				if(this.buildState.hasUnitializedBuildObject()){
					var ts:SuperObject = this.buildState.newBuildObject;
					var tq:QueueObject = new QueueObject(null, null, null, ts);
					var bS:BuildStateEvent = new BuildStateEvent(BuildStateEvent.BUILD_CANCEL);
					bS.listOfQueueObjects = new ArrayCollection([tq]);
					bS.attachPreviousState(this);
					this.app.dispatchEvent(bS);
					return;
				}
			
				
				// After completeting the drawing return to the background state
				var e:BackgroundStateEvent = new BackgroundStateEvent(BackgroundStateEvent.BACKGROUND_STATE);
				e.attachPreviousState(this);
				this.app.dispatchEvent(e);
			}
		}
		
		// Update build information after the build state is finished
		// TODO: A user state manager needs to be written that one can send property events
		public function updateUserState(s:SuperObject):void {
			// Get the production associated with the superobject
			var production:Production = s.getProduction();
			
			// Purchase the objects, update resource total
			this.user.updateProduction(production.woodProduction, production.stoneProduction, production.manaProduction);
			
			// Send the new production stats to the server.
			this.userObjectManager.updateProduction(this.user, false, this.onNull);
			
			// Complete the production
			this.userObjectManager.buildObjectComplete(s, this.user);
			
			// Change the state if there is nothing left in the queue
			if(this.queueManager.isEmpty()){
				this.gameManager.changeState(GameManager._emptyState);
			}
		}
		
		
		private function onNull(event:Event):void {

		}
		
		public function getViewString():String
		{
			return this.viewString;
		}
		
		public function getStateString():String
		{
			return "draw";
		}
		
		public function getNextState():GameState
		{
			return null;
		}
	}
}