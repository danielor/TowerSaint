package models.states
{
	import action.BuildActionGroup;
	
	import assets.PhotoAssets;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapMouseEvent;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import managers.GameFocusManager;
	import managers.GameManager;
	import managers.PolygonBoundaryManager;
	import managers.QueueManager;
	import managers.UserObjectManager;
	
	import models.Portal;
	import models.Production;
	import models.QueueObject;
	import models.Road;
	import models.Tower;
	import models.User;
	import models.away3D.ResourceProductionText;
	import models.constants.DateConstants;
	import models.constants.PurchaseConstants;
	import models.interfaces.SuperObject;
	import models.states.events.BackgroundStateEvent;
	import models.states.events.BuildStateEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.BitmapAsset;
	import mx.events.CloseEvent;
	import mx.events.PropertyChangeEvent;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
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
		private var photo:PhotoAssets;									/* The photos used in the game */
		private var listOfUserModels:ArrayCollection;					/* The list of models associated with the game */
		private var scene:Scene3D										/* The scene where the away3D objects exist */
		private var view:View3D											/* The view associated with the 3D scene */
		private var gameFocusManager:GameFocusManager;					/* The focus panel manager handles game object focus */
		private var currentPolygons:ArrayCollection;					/* The polygons that make up the current boundary */
		private var buildStage:Number;									/* For multi stage builds this count holds the stage */
		private var buildStageTimer:Timer;								/* The build stage timer */
		private var buildStatePosition:LatLng;							/* The build stage position */
		// Constants determine whether the state has the active mouse
		public function BuildState(a:Application, m:Map, u:User, uOM:UserObjectManager, qM:QueueManager, uB:PolygonBoundaryManager,
					gm:GameManager, rT:ResourceProductionText, p:PhotoAssets, lOFM:ArrayCollection, s:Scene3D, v:View3D,
					fPM:GameFocusManager)
		{
			this.app = a;
			this.map = m;
			this.user = u;
			this.userObjectManager = uOM;
			this.queueManager = qM;
			this.userBoundary = uB;
			this.gameManager = gm;
			this.resourceText = rT;
			this.photo = p;
			this.listOfUserModels = lOFM;
			this.scene = s;
			this.view = v;
			this.gameFocusManager = fPM;
			this.buildStage = 0;
			this.isInState = false;
			this.buildStageTimer = null;
		}
		
		// Event objects that need to be set
		public function set listOfQueueObjects(arr:ArrayCollection) : void {
			this._listOfQueueObjects = arr;
		}
		public function set buildStateEventType(type:String) : void {
			this._buildStateEventType = type;
		}
		public function set newBuildObject(s:SuperObject):void {
			// Check if an object needs to be removes from the map
			if(this._newBuildObject != null){
				if(!this.queueManager.hasSuperObject(this._newBuildObject)){
					// Erase object and boundary
					this._newBuildObject.eraseFromMap(this.map, this.scene);
					this.userBoundary.removeAndDraw(this._newBuildObject);
					
				}
			}
			// Remove all cursors
			CursorManager.removeAllCursors();
			this._newBuildObject = s;
		}
		
		public function hasUnitializedBuildObject():Boolean {
			if(this._newBuildObject == null){
				return false;
			}else{
				return !this._newBuildObject.hasInit();
			}
		}
		
		public function get newBuildObject():SuperObject {
			return this._newBuildObject;
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
				s.eraseFromMap(this.map, this.scene);
				
				// Remove the superobject from the boundary
				this.userBoundary.removeAndDraw(s);
				this.queueManager.removeFromQueue(q);
				
				if(this.queueManager.isEmpty()){
					this.gameManager.changeState(GameManager._emptyState);
				}
			}
			
			// Recreate the boundaries of the partially created objets
			var arr:ArrayCollection = this.queueManager.getListOfSuperObjects();
		
			for(var j:int = 0; j < arr.length; j++){
				var js:SuperObject = arr[j] as SuperObject;
				this.userBoundary.addAndDraw(js);
			}
		}
		
		// Internal function used to flush to the background state even if the 
		// operation is very expensive
		private function _flushToBackground():void{
			// Return to the background state
			var e:BackgroundStateEvent = new BackgroundStateEvent(BackgroundStateEvent.BACKGROUND_STATE);
			e.attachPreviousState(this);
			this.app.dispatchEvent(e);
		}
		
		// Internal function used to handle build Complete
		private function _buildComplete():void {
			_flushToBackground();
			// Get the production associated with the superobject
			for(var i:int = 0; this._listOfQueueObjects.length; i++){
				var b:LatLngBounds = this.map.getLatLngBounds();
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
				/*
				if(this.queueManager.isEmpty()){
					this.gameManager.changeState(GameManager._emptyState);
				}
				*/
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
				this._newBuildObject.eraseFromMap(this.map, this.scene);
				this.userBoundary.removeAndDraw(this._newBuildObject);
				
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
		
		// The map mouse move
		public function onMapMouseMove(event:MapMouseEvent):void {
			if(this._newBuildObject.isDynamicBuild()){
				// Draw properly 
				if(this.buildStage >= 1){
					if(this.buildStageTimer == null){
						// Set a timer for a certain 
						this.buildStageTimer = new Timer(250, 1);
						this.buildStageTimer.addEventListener(TimerEvent.TIMER, onMapMouseTimerDraw);
						this.buildStageTimer.start();
					}else{
						this.buildStageTimer.reset();
						this.buildStatePosition = event.latLng;			// The lat lng
						this.buildStageTimer.start();
					}
				}else{
					// Highlight the objects with focus, when a dynamic object 
					this.gameFocusManager.setFocusFromMapEvent(event);
				}
			}
		}
		
		// Dynamically draw object after a timer interval
		private function onMapMouseTimerDraw(event:TimerEvent):void {
			this.buildStageTimer = null;
			this._newBuildObject.drawStage(1, this.buildStatePosition, this.photo);
		}
		
		// Deferred events handle map inputs.(Called in background state)
		public function onMapMouseClick(event:MapMouseEvent):void {
			var pos:LatLng = event.latLng;
			
			if(this.userBoundary.isInsidePolygon(pos)){
				if(this._newBuildObject.isDynamicBuild()){
					// If the focus is true. Get the EXACT location of the build
					// object
					if(this.gameFocusManager.focusActive){
						if(this.buildStage == 0){
							var b:LatLngBounds = this.map.getLatLngBounds();
							var s:SuperObject = this.gameFocusManager.focusObject;
							pos = s.getPosition(b);
						}else{
							// Remove the focus
							this.gameFocusManager.removeFocus();
						}
					}
					
					// The shift key switches the build stage
					if(event.shiftKey){
						this.buildStage = this.buildStage - 1;
					}else {
						this.buildStage = this.buildStage + 1;
					}
					
					// If initial??
					if(this.buildStage == 1){
						this._newBuildObject.drawStage(0, pos, this.photo);
						_drawBuildFromClick(pos);
					}
					
					
					// If we have reached the critical stage
					if(this._newBuildObject.getNumberOfBuildStages() == this.buildStage){
						this.buildStage = 0;
						_finishBuildFromClick();
					}
					
				}else{
					if(!this.intersectsCurrentObject(pos)){
						_drawBuildFromClick(pos);
						_finishBuildFromClick();
					}
				}
			}else{
				if(this._newBuildObject.isDynamicBuild()){
					this.buildStage = this.buildStage - 1;
				}
			}
		}
		
		// Change the mouse state
		private function _finishBuildFromClick():void {
			// Setup the action state
			var b:BuildActionGroup = this.gameManager.getActionGroup(GameManager._buildState) as BuildActionGroup;
			var c:Class = this.pictureForObject();
			b.buildImage.source = new c as BitmapAsset;
			
			// Create/Set the text flow object
			var textFlow:TextFlow = new TextFlow();
			var pGraph:ParagraphElement = new ParagraphElement();
			var iSpan:SpanElement = new SpanElement();
			iSpan.text = getBuildString();
			pGraph.addChild(iSpan);
			textFlow.addChild(pGraph);
			b.buildText.textFlow = textFlow;
			
			// Change the state
			this.gameManager.changeState(GameManager._buildState);;
			
			// Add the object to the empire boundary
			this.userBoundary.addAndDraw(_newBuildObject);
			
			// Change the cursor manager
			CursorManager.removeAllCursors();
			
			// Change the deferred event
			var p:PropertyChangeEvent = new PropertyChangeEvent(BackgroundState.MOUSE_FOCUS);
			p.newValue = BackgroundState.MOUSE_FOCUS;
			this.app.dispatchEvent(p);
		}
		
		// Update the draw elements
		private function _drawBuildFromClick(pos:LatLng):void {
			// Create an object from the object picture
			this._newBuildObject.initialize(this.user);
			this._newBuildObject.setPosition(pos);
			this._newBuildObject.draw(true, this.map, this.photo, this.gameFocusManager, true, this.scene, this.view);
			this._newBuildObject.addEventListener(MapMouseEvent.DRAG_END, onDragEnd);
		}
	
		// If the build object check if it is a valid location.
		private function onDragEnd(e:MapMouseEvent):void {
			var b:Boolean = userBoundary.isInsidePolygon(e.latLng);
			this._newBuildObject.setValid(b, true);
			this.userBoundary.refreshAndDraw(this._newBuildObject);
		}
		
		// Returns a build string that populates the textflow in the build action group
		private function getBuildString():String {
			var s:String ="\n";
			
			// Create a temporary object without fixed position
			var pos:LatLng =  this.map.getCenter();
			
			// Find the cost for that temporary object
			var woodCost:Number = PurchaseConstants.woodCost(this._newBuildObject, 0);
			var stoneCost:Number = PurchaseConstants.stoneCost(this._newBuildObject, 0);
			var magicCost:Number = PurchaseConstants.manaCost(this._newBuildObject, 0);
			
			var c:Class = this.pictureForObject();
			if(c == this.photo.TowerLevel0){
				s+="Stone  :" + stoneCost.toString() + "\n";
				s+="Wood  :" + woodCost.toString() + "\n";
				s+="Magic  :" + magicCost.toString() + "\n";
			}else if(c == this.photo.ThePortalMouse){
				s+="Stone :" + stoneCost.toString() + "\n";
				s+="Wood  :" + woodCost.toString() + "\n";
				s+="Magic :" + magicCost.toString() + "\n";
			}else if(c == this.photo.EastRoad){
				s+="Stone :" + stoneCost.toString() + "\n";
				s+="Wood  :" + woodCost.toString() + "\n";
			}
			
			return s;
		
		}
		
		private function intersectsCurrentObject(pos:LatLng):Boolean {
			for(var i:int = 0; i < this.listOfUserModels.length; i++){
				var s:SuperObject = this.listOfUserModels[i] as SuperObject;
				if(! s.isOverLappingBoundsOfObject(pos, this.map, this.photo)){
					return false;
				}
			}
			return true;
		}
		
		public function onMapRollOut(event:MapMouseEvent):void {
			// Remove the cursor when one leaves the map
			CursorManager.removeAllCursors();
		}
		public function onMapRollOver(event:MapMouseEvent):void {
			var buildObjectPicture:Class = this.pictureForObject();
			var asset:BitmapAsset = new buildObjectPicture() as BitmapAsset;
			var data:BitmapData = asset.bitmapData;
			var xShift:Number = data.width / 2.;
			var yShift:Number = data.height;
			CursorManager.setCursor(buildObjectPicture, CursorManagerPriority.HIGH, -xShift, -yShift);
		}
		
		private function pictureForObject():Class {
			if(this._newBuildObject is Tower){
				return photo.TowerLevel0;
			}else if(this._newBuildObject is Portal){
				return photo.ThePortalMouse;
			}else {
				return photo.EastRoad;
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