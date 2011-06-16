package models.states
{
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import managers.GameManager;
	import managers.PolygonBoundaryManager;
	import managers.QueueManager;
	import managers.UserObjectManager;
	
	import models.Production;
	import models.QueueObject;
	import models.SuperObject;
	import models.User;
	import models.away3D.ResourceProductionText;
	import models.constants.DateConstants;
	import models.constants.PurchaseConstants;
	import models.states.events.BackgroundStateEvent;
	import models.states.events.BuildStateEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.messaging.Producer;
	
	import spark.components.Application;
	import spark.components.TitleWindow;
	
	public class BuildState implements GameState
	{
		private const viewString:String = "inApp";						/* The view associated with the state */
		private var isInState:Boolean;									/* Flag determines the state */
		private var app:Application;									/* The application associated with the game */
		private var _listOfQueueObjects:ArrayCollection;				/* The queue objects to be added/removed */
		private var _buildStateEventType:String;						/* The event type that created the event */
		private var map:Map;											/* The map where the game runs */
		private var user:User;											/* The user playing the game */
		private var userObjectManager:UserObjectManager;				/* User obect manager manages the connection ot the server */
		private var queueManager:QueueManager;							/* Manages objects that take time */
		private var userBoundary:PolygonBoundaryManager; 				/* Manage the boundary of the empire */
		private var gameManager:GameManager;							/* The game manager */
		private var _newBuildObject:SuperObject;						/* The object that is begin built */
		private var resourceText:ResourceProductionText;				/* Away3D resource field */
		private var popup:TitleWindow;									/* A reference to any popup placed on top of the game manager */

		public function BuildState(a:Application, m:Map, u:User, uOM:UserObjectManager, qM:QueueManager, uB:PolygonBoundaryManager,
					gm:GameManager, rT:ResourceProductionText)
		{
			this.app = a;
			this.map = m;
			this.user = u;
			this.userObjectManager = uOM;
			this.queueManager = qM;
			this.userBoundary = uB;
			this.gameManager = gm;
			this.resourceText = rT;
			this.isInState = false;
		}
		
		// Event objects that need to be set
		public function set listOfQueueObjects(arr:ArrayCollection) : void {
			this._listOfQueueObjects = arr;
		}
		public function set buildStateEventType(type:String) : void {
			this._buildStateEventType = type;
		}
		public function set newBuildObject(s:SuperObject):void {
			this._newBuildObject = s;
		}
		
		// GameState interface
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
		public function getStateString():String {
			return "build";
		}
		
		public function enterState():void
		{
			this.isInState = true;
			if(this._buildStateEventType == BuildStateEvent.BUILD_CANCEL){
				this._buildCancel();
			}else if(this._buildStateEventType == BuildStateEvent.BUILD_COMPLETE){
				this._buildComplete();
			}else if(this._buildStateEventType == BuildStateEvent.BUILD_INIT){
				this._buildInit();
			}else if(this._buildStateEventType == BuildStateEvent.BUILD_START){
				this._buildStart();
			}
			
			// Return to the background state
			var e:BackgroundStateEvent = new BackgroundStateEvent(BackgroundStateEvent.BACKGROUND_STATE);
			e.attachPreviousState(this);
			this.app.dispatchEvent(e);
		}
		
		// Null function call
		private function onNull(e:Event):void {
			
		}

		
		// Internal functions used to handle all of the states.
		private function _buildCancel():void {
			for(var i:int = 0; i < this._listOfQueueObjects.length; i++){
				var q:QueueObject = this._listOfQueueObjects[i] as QueueObject;
				var s:SuperObject = q.buildObject;
				var pC:Number = q.percentComplete;
				
				// Return the material left over from the purchase
				var woodCost:Number = -int(PurchaseConstants.woodCost(s, 0) * (1. - pC));
				var stoneCost:Number = -int(PurchaseConstants.stoneCost(s, 0) * (1. - pC));
				var manaCost:Number = -int(PurchaseConstants.manaCost(s, 0) * (1. -pC));
				
				// Get the production
				this.user.purchaseObject(woodCost, stoneCost, manaCost);
				
				// Update the production
				this.userObjectManager.updateProduction(this.user, false, this.onNull);
				this.userObjectManager.buildObjectCancel(s, this.user);
				
				// Change the state
				s.eraseFromMap(this.map);
				
				// Remove the superobject from the boundary
				this.userBoundary.removeAndDraw(s);
				
				if(this.queueManager.isEmpty()){
					this.gameManager.changeState(GameManager._emptyState);
				}
			}
		}
		

		
		// Internal function used to handle build Complete
		private function _buildComplete():void {
			// Get the production associated with the superobject
			for(var i:int = 0; this._listOfQueueObjects.length; i++){
				var q:QueueObject = this._listOfQueueObjects[i] as QueueObject;
				var s:SuperObject = q.buildObject;
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
		}
		private function _buildInit():void {
			var d:Date = new Date();
			
			if(canPurchase(d)){
				
				// Build the object 
				this.userObjectManager.buildObject(this._newBuildObject, this.user);
				
				// Change the build state
				this._newBuildObject.updateBuildState(0.); // Make the build state transparent
				
				// Create a queue object associated with the purchase
				var b:LatLngBounds = this.map.getLatLngBounds();
				var buildTime:Date = PurchaseConstants.buildTime(this._newBuildObject, 0);
				var objectString:String = this._newBuildObject.getNameString();
				var q:QueueObject = new QueueObject("Building " + objectString + " at" + this._newBuildObject.getPosition(b), buildTime,
					this._newBuildObject.updateBuildState, this._newBuildObject );
				
				// Subtract the purchase prices from the current user.
				var woodCost:Number = PurchaseConstants.woodCost(this._newBuildObject, 0);
				var stoneCost:Number = PurchaseConstants.stoneCost(this._newBuildObject, 0);
				var manaCost:Number = PurchaseConstants.manaCost(this._newBuildObject, 0);
				this.user.purchaseObject(woodCost, stoneCost, manaCost);
				
				// Add the queue object to the queue manager, and syntheisze the active queue
				this.queueManager.addQueueObject(q);
				if(!this.queueManager.isVisible){
					this.gameManager.changeState(GameManager._queueState);
				}
				
			}else{
				// Get the current production
				var totalWood:Number = this.resourceText.getWoodProduction(d);
				var totalStone:Number = this.resourceText.getManaProduction(d);
				var totalMana:Number = this.resourceText.getManaProduction(d);
				
				// Find out why the purchase failed, and tell the user
				var failureString:String = PurchaseConstants.missingResourcesString(this._newBuildObject, 0, totalWood, totalStone, totalMana);
				
				// Setup and create a popup to inform the user.
				var s:SimplePopup = new SimplePopup();
				popup = s;

				PopUpManager.addPopUp(s, this.app, true);
				PopUpManager.centerPopUp(s);
				
				// Setup up the events
				s.addEventListener(CloseEvent.CLOSE, onCloseBuildPopup);
				s.okButton.addEventListener(MouseEvent.CLICK, onCloseBuildPopup);
				s.theText.text = failureString;
				s.title = "You do not have enough resources!";
				
				// Remove the current build object from the map
				this._newBuildObject.eraseFromMap(this.map);
				
				// Change the state 
				this.gameManager.changeState(GameManager._emptyState);
			}			
		}
		
		private function onCloseBuildPopup(event:Event) : void {
			PopUpManager.removePopUp(popup);
		}
		
		
		private function canPurchase(d:Date):Boolean {
			// Get the current production
			var totalWood:Number = this.resourceText.getWoodProduction(d);
			var totalStone:Number = this.resourceText.getManaProduction(d);
			var totalMana:Number = this.resourceText.getManaProduction(d);
			
			return PurchaseConstants.canPurchase(this._newBuildObject, 0, totalWood, totalStone, totalMana);
		}
		
		private function _buildStart():void {
			var d:Date = new Date();
			var b:LatLngBounds = new LatLngBounds();
			for(var j:int = 0; j < this._listOfQueueObjects.length; j++){
				var nobj:SuperObject = this._listOfQueueObjects[j] as SuperObject;
				
				// Add time to the production date
				var maxDate:Date = PurchaseConstants.buildTime(nobj, 0);
				var fDate:Date = nobj.getFoundingDate();
				var netMinutes:Number = DateConstants.numberOfMinutes(maxDate, d) - DateConstants.numberOfMinutes(d, fDate);
				var netSeconds:Number = DateConstants.numberOfSeconds(maxDate, d) - DateConstants.numberOfSeconds(d, fDate);
				var effectiveBuildTime:Date = new Date();
				DateConstants.addTimeToDate(effectiveBuildTime, netMinutes, netSeconds);
				
				// Create a new queue object
				var objectString:String = nobj.getNameString();
				var q:QueueObject = new QueueObject("Building " + objectString + " at" + nobj.getPosition(b),
					effectiveBuildTime, nobj.updateBuildState, nobj);
				
				// Add the queue object to the manager
				this.queueManager.addQueueObject(q);
				if(!this.queueManager.isVisible){
					this.gameManager.changeState(GameManager._queueState);
				}
			}
		}
		public function exitState():void
		{
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
		
 		public function getViewString():String
		{
			return null;
		}
		
		public function getNextState():GameState
		{
			return null;
		}
	}
}