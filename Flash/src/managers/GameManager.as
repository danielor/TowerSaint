package managers
{
	import action.ActionQueue;
	import action.BuildActionGroup;
	
	import assets.PhotoAssets;
	
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.RectangleClipping;
	import away3d.core.render.*;
	import away3d.events.*;
	import away3d.lights.DirectionalLight3D;
	import away3d.materials.*;
	import away3d.primitives.*;
	import away3d.tools.utils.Drag3D;
	
	import com.facebook.graph.core.FacebookJSBridge;
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapAction;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapMoveEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import messaging.ChannelJavascriptBridge;
	import messaging.events.ChannelAttackEvent;
	import messaging.events.ChannelBuildEvent;
	import messaging.events.ChannelJSON;
	import messaging.events.ChannelMessageEvent;
	import messaging.events.ChannelMoveEvent;
	import messaging.events.ChannelUserLoginEvent;
	import messaging.events.ChannelUserLogoutEvent;
	
	import models.BoundarySuperObject;
	import models.GameChannel;
	import models.Portal;
	import models.Production;
	import models.QueueObject;
	import models.Road;
	import models.SuperObject;
	import models.Tower;
	import models.User;
	import models.away3D.ResourceProductionText;
	import models.constants.DateConstants;
	import models.constants.PurchaseConstants;
	import models.states.BackgroundState;
	import models.states.BuildState;
	import models.states.DrawState;
	import models.states.GameState;
	import models.states.InitState;
	import models.states.UpdateState;
	import models.states.events.BackgroundStateEvent;
	import models.states.events.BuildStateEvent;
	import models.states.events.DrawStateEvent;
	import models.states.events.UpdateStateEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.TabNavigator;
	import mx.controls.Alert;
	import mx.core.BitmapAsset;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.CollectionEvent;
	import mx.events.EventListenerRequest;
	import mx.events.ItemClickEvent;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.NavigatorContent;
	import spark.components.RichEditableText;
	import spark.components.Scroller;
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	import spark.components.VGroup;
	import spark.core.SpriteVisualElement;
	
	import wumedia.vector.VectorText;

	// The game manager runs the towersaint game.
	public class GameManager
	{
		// Private variables used to run the game(views, and state variables)
		private var user:User;												/* The user of the game */
		private var listOfUserModels:ArrayCollection						/* Array collection of all the objects the user owns */
		private var listOfLoggedInUsers:ArrayCollection;					/* Array collection of users that are logged in */
		private var map:Map;												/* The map, which is being played on */
		private var mapEventManager:EventManager;							/* The event manager for the map associated with the game manager */
		private var photo:PhotoAssets;										/* The game xml data.. pictures etc */
		private var gameFocus:GameFocusManager;								/* View Manager which handles the inspection of objects */
		private var app:Application;										/* The application view which is running this game */
		private var gameTimer:Timer;										/* Game timer refreshes the game periodically */
		private var sendButton:Button;										/* Button that sends text messages to the chat server */
		private var chatList:RichEditableText;								/* List of the global chat occurring */
		private var userList:List;											/* List of users in the game */
		private var listOfUserObjects:List;									/* List of user objects- Portals, and Tower */
		private var chatTextInput:TextInput									/* The text input for the chat */
		private var userObjectManager:UserObjectManager;					/* User object manager controls the collection of information from the server */
		private var channelBridge:ChannelJavascriptBridge;					/* The briged between GAE channel api and the actionscript */
		private var gameChannel:GameChannel;								/* The new game channel */
		private var sendChatButton:Button;									/* Send chat information through this button */
		private var buildObjectList:List;									/* The objects that can be built in the game */
		private var aPStateMatchine:Dictionary;								/* The state machine associated with the action panel */
		private var tabNavigator:TabNavigator;								/* Tab navigator (info, build, action) */
		private var newBuildObject:SuperObject;								/* The new build object(tower, portal, or road */
		private var mapGroup:VGroup;										/* The group that contains the map */
		private var queueManager:QueueManager;								/* The manager handles the queue manager */
		private var userBoundary:PolygonBoundaryManager;					/* The boundary of towers associated with this user */
		private var buildStateInformation:BuildState;						/* The build state encompasses the build state information */
		private var locationChanger:Button;									/* In the init state, changes the location of the capital */
		private var buildButton:Button;										/* In the init state, builds the capital */
		private var modelListEventManager:EventManager;						/* The model list event manager */
		private var stageEventManager:EventManager;							/* Listen/fans events in the stage */
	
		
		// Constants
		public static const emptyState:String = "Empty";							/* The constant string associated with the empty state */
		public static const buildState:String = "Build";							/* Constant string associated with the build state */
		public static const queueState:String = "Queue";							/* Constant will open a list of queued objects in the game */
		private var currentTabStateString:String;							/* State string associated with the tabNavigator */
		// Popups
		private var popup:TitleWindow;										/* A reference to any popup placed on top of the game manager */
		
		// Private variables associated with away3D objects
		private var mySprite:SpriteVisualElement;							/* Visual element is used to render the scene */							
		private var scene:Scene3D;											/* The scene where all of the 3D data will be drawn */
		private var camera:HoverCamera3D;									/* The camera */		
		private var renderer:BasicRenderer;									/* Renders all objects in the scend */
		private var view:View3D;											/* The perspective in the scend */
		private var light:DirectionalLight3D;								/* Where is the light coming from? */	
		private var sphere:Sphere;											/* A sphere? */
		private var dragManager:Drag3D;										/* The drag manager moves objects on a plane */
		[Embed(source="assets/font/verdana.swf", mimeType="application/octet-stream")]
		private var fontSWF:Class;											/* SWF contains an embedded font */
		private var resourceText:ResourceProductionText;					/* The complete mana field text draws the total mana, and the current mana production */
		
		// State machine variables
		private var initState:InitState;									/* Init state controls the initialization of a user in a game */
		private var backgroundState:BackgroundState;						/* The background state controls the state information about game existence */
		private var updateState:UpdateState;								/* Update state handles retrieving the intitial user objects */
		private var drawState:DrawState;									/* The draw state draws objects on the map */
		private var buildState:BuildState;									/* The state handles the building/cancelling of objects */
		private var isRunning:Boolean;										/* True if the game manager is running */
		
		// Map variables
		private var initialMapDragMouse:LatLng;								/* The location where the initial of map occurs */
		private var userMousePan:Boolean;									/* True if the user moves the mouse on the map */
		private var finishedLoadingMap:Boolean;								/* True if the map has finished loading */
		private var buildObjectPicture:Class;								/* The bitmap data associated with a new object */
		
		public function GameManager(u:User, m:Map, p:PhotoAssets, fPM:GameFocusManager, a:Application, 
									sB:Button, cL:RichEditableText, uL:List, lOU:List, cT:TextInput, uM:UserObjectManager, 
									sE:SpriteVisualElement, sCB:Button, bOL:List, tN:TabNavigator, mG:VGroup,
									bB:Button, lC:Button)
		{
			// Create the manager object
			this.user = u;
			this.map = m;
			this.photo = p;
			this.gameFocus = fPM;
			this.app = a;
			this.sendButton = sB;
			this.chatList = cL;
			this.userList = uL;
			this.listOfUserObjects = lOU;
			this.chatTextInput = cT;
			this.userObjectManager = uM;
			this.mySprite = sE;
			this.sendChatButton = sCB;
			this.buildObjectList = bOL;
			this.tabNavigator = tN;
			this.mapGroup = mG;
			this.locationChanger = lC;
			this.buildButton = bB;
			
			// Call the super
			super();
			
			// Initialize objects
			this.listOfUserModels = new ArrayCollection();
			this.listOfLoggedInUsers = new ArrayCollection();
			this.queueManager = new QueueManager(this.app, this.photo);
			
			// Setup the game channels
			this.channelBridge = new ChannelJavascriptBridge(this.app);
			this.modelListEventManager = new EventManager(this.listOfUserModels);
			this.userBoundary = new PolygonBoundaryManager(this.map, this.listOfUserModels, this.user);
			this.userBoundary.initDraw();
			this.modelListEventManager.addEventListener(CollectionEvent.COLLECTION_CHANGE, this.gameFocus.onCollectionChange);
			this.modelListEventManager.addEventListener(CollectionEvent.COLLECTION_CHANGE, this.userBoundary.onCollectionChange);
			
			// Create the stage event manager
			this.stageEventManager = new EventManager(this.app);
			//this.stageEventManager.addEventListener(MouseEvent.MOUSE_UP, this.focusPanelManager.onMouseUp);
			
			// Setup the focus of objects on the map
			this.gameFocus.map = this.map;
			this.gameFocus.listOfModels = this.listOfUserModels;
			
			// Setup some state variables
			//this.buildStateInformation = new BuildState(null, false);
			this.currentTabStateString = GameManager.emptyState;
		}
		
		// Run the game. Intialize active objects, events, and interfaces.
		public function run() : void{
			// Setup Map events
			this.initializeMap();
		
			// Setup up the game channels. The channels run the game
			this.setupGameChannels();
			
			// Initialize the game
			//this.initGame();
			
			// Get all user objects
			//this.getUserObjects();
			//this.map.addEventListener(MapEvent.MAPEVENT_MAPREADY, onMapReady);
			
			this.setupChat();	
			this.setupUIEvents();				// Sets up the events associated with UI elements
			this.setupActionPanelState();		// Setup the action panel state
			this.init3DView();					// Initialize away3D

			// Setup the state machine that uns
			this.setupStateMachine();
		}
		
		private function initializeMap() : void {
			// Set the appropriate zoom level
			this.map.setZoom(16, false);
			this.map.setDoubleClickMode(MapAction.ACTION_NOTHING);
		}
		
		
		// === GAME STATE MACHINE ===
		public function setupStateMachine():void {
			// Attach the state events to callback functions
			this.app.addEventListener(UpdateStateEvent.UPDATE_STATE, onUpdateState);	
			this.app.addEventListener(DrawStateEvent.DRAW_STATE, onDrawState);
			this.app.addEventListener(BackgroundStateEvent.BACKGROUND_STATE, onBackgroundState);
			this.app.addEventListener(BuildStateEvent.BUILD_COMPLETE, onBuildState);
			this.app.addEventListener(BuildStateEvent.BUILD_INIT, onBuildState);
			this.app.addEventListener(BuildStateEvent.BUILD_START, onBuildState);

			// Create the states
			this.initState = new InitState(this.map, this.locationChanger, this.userObjectManager, this.app,
				this.user, this.photo, this.gameFocus, this.buildButton, this.scene, this.listOfUserModels,
				this.view);
			this.backgroundState = new BackgroundState(this.map, this.app, this.gameFocus);
			this.updateState = new UpdateState(this.map, this.user, this.listOfUserModels, this.userObjectManager, this.app);
			this.drawState = new DrawState(this.listOfUserModels, this.map, this.view, this.scene, this.gameFocus, 
					this.photo, this.user, this.userObjectManager, this.queueManager, this, this.app);
			this.buildState = new BuildState(this.app, this.map);
			
			// Start the state machine
			var initialState:GameState;
			
			if(this.app.currentState == this.initState.getViewString()){
				initialState = this.initState;
			}else{
				initialState = this.updateState;
			}
			
			// Start the game loop
			this.changeGameState(initialState, null);
		}
		
		private function onUpdateState(event:UpdateStateEvent) : void {
			var lastState:GameState = event.getPreviousState();
			this.changeGameState(this.updateState, lastState);
		}
		private function onDrawState(event:DrawStateEvent) : void {
			var lastState:GameState = event.getPreviousState();
			this.changeGameState(this.drawState, lastState);
		}
		private function onBackgroundState(event:BackgroundStateEvent): void {
			var lastState:GameState = event.getPreviousState();
			this.changeGameState(this.backgroundState, lastState);
		}
		private function onBuildState(event:BuildStateEvent) : void {
			var lastState:GameState = event.getPreviousState();
			
			// Attach the state
			this.buildState.listOfQueueObjects = event.listOfQueueObjecs;
			this.buildState.buildStateEventType = event.type;
			
			this.changeGameState(this.buildState, lastState);
		}

		public function changeGameState(newState:GameState, lastState:GameState) : void {
			// Exit previous state
			if(lastState != null){
				lastState.exitState();
			}

			// Change the view
			if(this.app.currentState != newState.getViewString()){
				this.app.currentState = newState.getViewString();
			}
			
			// Enter new state
			newState.enterState();
		}
		
		// === GAME STATE MACHINE ===
		
		
		// ==== CHANNEL INTERFACE =====
		public function setupGameChannels() : void {
			
			// Setup the channel events
			this.app.addEventListener(ChannelAttackEvent.CHANNEL_ATTACK, onChannelAttack);
			this.app.addEventListener(ChannelBuildEvent.CHANNEL_BUILD, onChannelBuild);
			this.app.addEventListener(ChannelMessageEvent.CHANNEL_MESSAGE, onChannelMessage);
			this.app.addEventListener(ChannelMoveEvent.CHANNEL_MOVE, onChannelMove);
			this.app.addEventListener(ChannelUserLoginEvent.CHANNEL_LOGIN, onChannelLogin);
			this.app.addEventListener(ChannelUserLogoutEvent.CHANNEL_LOGOUT, onChannelLogout);
			
		}
		
		public function onChannelAttack(event:ChannelAttackEvent) : void {
			
		}
		
		public function onChannelBuild(event:ChannelBuildEvent) : void {
			// Get the build string
			Alert.show("onChannelBuild");
			var buildUser:String = event.buildUser;
			var buildObject:Object = event.buildObject;
			
			// Extract the built object
			var s:SuperObject;
			
			if(buildUser == this.user.alias){
				if(buildObject.Class == "Tower"){
					s = Tower.createUserTowerFromJSON(buildObject.Value, this.user);
				}else if(buildObject.Class == "Portal"){
					s = Portal.createUserPortalFromJSON(buildObject.Value, this.user);
				}else if(buildObject.Class == "Road"){
					s = Road.createUserRoadFromJSON(buildObject.Value, this.user);
				}else{
					return;
				}
				// The two lists can be fundamentally different
				this.listOfUserObjects.dataProvider.addItem(s);		// Add to the display list 
				this.listOfUserModels.addItem(s);					// Add to the list of user models 
				
			}else{
				if(buildObject.Class == "Tower"){
					s = Tower.createTowerFromJSON(buildObject.Value);
				}else if(buildObject.Class == "Portal"){
					s = Portal.createPortalFromJSON(buildObject.Value);
				}else if(buildObject.Class == "Road"){
					s = Road.createRoadFromJSON(buildObject.Value);
				}else{
					return;
				}
				
				// TODO: Get the object for other user
			}
			// Add the user object to the list of relevant user objects
			var bounds:LatLngBounds = this.map.getLatLngBounds();
			var pos:LatLng = s.getPosition(bounds);
			if(bounds.containsLatLng(pos)){
				s.draw(true, this.map, this.photo, this.gameFocus, true, this.scene, this.view);	
				
				// Remove the currently drawn object
				if(this.newBuildObject != null){
					this.newBuildObject.eraseFromMap(this.map);
				}
				
			}
			
			// Get the queue manager 
			var qObject:QueueObject = this.queueManager.getQueueObjectAtPosition(pos, this.map);
			this.queueManager.removeFromQueue(qObject);
			if(this.queueManager.isEmpty() && this.currentTabStateString == GameManager.queueState){
				this.changeState(GameManager.emptyState);
			}
		}
		
		
		
		public function onChannelMessage(event:ChannelMessageEvent) : void {
			// The message object
			var message:Object = event.getJSONObject();
			
			// Get the textflow
			if(this.chatList.textFlow == null){
				this.chatList.textFlow = new TextFlow();
			}
			
			// Setup the span element
			var newMessage:ParagraphElement = new ParagraphElement();
			
			// Setup up the user
			var span:SpanElement = new SpanElement();
			span.text = message.user + ": ";
			span.fontWeight = "bold";
			
			// Setup up the message
			var nspan:SpanElement = new SpanElement();
			nspan.text = message.message;
			
			// Add the message
			newMessage.addChild(span);
			newMessage.addChild(nspan);
			
			// Add a message to the textFlow
			this.chatList.textFlow.addChild(newMessage);
			
			// Remove the first child, if there are to many message
			if(this.chatList.textFlow.numChildren > 1000){
				this.chatList.textFlow.removeChildAt(0);
			}
			
		}	
		
		public function onChannelMove(event:ChannelMoveEvent) : void {
			
		}
		
		public function onChannelLogin(event:ChannelUserLoginEvent) : void {
			Alert.show("onChannelLogin");
			
			// Set the user list to the data provider
			this.listOfLoggedInUsers.addAll(event.userLoginArray);
			this.userList.dataProvider = this.listOfLoggedInUsers;
		}
		
		public function onChannelLogout(event:ChannelUserLogoutEvent) : void {
			Alert.show("onChannelLogout");
			
			var obj:Object = event.logout;
			var index:int;
			for(var i:int = 0; i < this.listOfLoggedInUsers.length; i++){
				var rObj:Object = this.listOfLoggedInUsers.getItemAt(i);
				if(!ObjectUtil.compare(obj, rObj)){
					this.listOfLoggedInUsers.removeItemAt(i);
					break;
				}
			}
			
		}
		
		// ==== CHAT SETUP ===
		private function setupChat() : void {
			this.sendButton.addEventListener(MouseEvent.MOUSE_UP, onSendChatButton);	
		}
		
		private function onSendChatButton(event:MouseEvent) : void {
			var s:String = this.chatTextInput.text;
			this.userObjectManager.sendMessage(this.user,s);
		}
		
		// === CHAT SETUP ===
		
		// ==== UI ====
		public function setupUIEvents() : void {
			// Master events
			this.buildObjectList.addEventListener(ItemClickEvent.ITEM_CLICK, onBuildItemClick);

			// Tie array collections
			this.listOfUserObjects.dataProvider = this.listOfUserModels;

			// User Dependent Events
			this.setupActionPanelState();

		}
		
		private function onBuildItemClick(event:ItemClickEvent) : void {
			// Extract the item index, and the corresponding class
			var itemIndex:int = event.index;
			switch(itemIndex){
				case 0:
					this.buildObjectPicture = this.photo.TowerLevel0;
					break;
				case 1:
					this.buildObjectPicture = this.photo.ThePortal;
					break;
				case 2:
					this.buildObjectPicture = this.photo.EastRoad;
					break;
			}
			
			// Remove the previous build object from the map
			if(this.newBuildObject != null){
				
				if(!this.queueManager.isInQueue(this.newBuildObject)){
					this.newBuildObject.eraseFromMap(this.map);
				}
				
			}
			//this.buildStateInformation.enterState(this.newBuildObject);
		}
		
		private function getItemFromClass(photo:Class, pos:LatLng):SuperObject{
			var obj:SuperObject;
			if(photo == this.photo.TowerLevel0){
				var t:Tower = new Tower();
				t.updatePosition(pos);
				obj = t;
			}else if(photo == this.photo.ThePortal){
				var p:Portal = new Portal();
				p.updatePosition(pos);
				obj = p;
			}else if(photo == this.photo.EastRoad){
				var r:Road = new Road();
				r.updatePosition(pos);
				obj = r;
			}
			return obj;
		}
		
		private function getBuildString():String {
			var s:String ="\n";
			
			// Create a temporary object without fixed position
			var pos:LatLng =  this.map.getCenter();
			var tempObject:SuperObject = this.getItemFromClass(this.buildObjectPicture, pos);
			
			// Find the cost for that temporary object
			var woodCost:Number = PurchaseConstants.woodCost(tempObject, 0);
			var stoneCost:Number = PurchaseConstants.stoneCost(tempObject, 0);
			var magicCost:Number = PurchaseConstants.manaCost(tempObject, 0);
			
			if(this.buildObjectPicture == this.photo.TowerLevel0){
				s+="Stone  :" + stoneCost.toString() + "\n";
				s+="Wood  :" + woodCost.toString() + "\n";
				s+="Magic  :" + magicCost.toString() + "\n";
			}else if(this.buildObjectPicture == this.photo.ThePortal){
				s+="Stone :" + stoneCost.toString() + "\n";
				s+="Wood  :" + woodCost.toString() + "\n";
				s+="Magic :" + magicCost.toString() + "\n";
			}else if(this.buildObjectPicture == this.photo.EastRoad){
				s+="Stone :" + stoneCost.toString() + "\n";
				s+="Wood  :" + woodCost.toString() + "\n";
			}
			
			return s;
		}
		
		public function setupActionPanelState() : void{
			// Create our panels
			var g:HGroup = new HGroup();
			var ap:BuildActionGroup = new BuildActionGroup();
			
			// Add to the state dictionary
			this.aPStateMatchine =  new Dictionary();
			this.aPStateMatchine[emptyState] = g;
			this.aPStateMatchine[buildState] = ap;
			this.aPStateMatchine[queueState] = this.queueManager.realizeActionQueue;
			
			// Add the relevant events.
			ap.buildButton.addEventListener(MouseEvent.MOUSE_DOWN, onBuildButton);
			ap.cancelButton.addEventListener(MouseEvent.MOUSE_DOWN, onCancelBuildButton);
		}
		
		public function onBuildButton(event:MouseEvent):void{
			// Copy the tower
			//var s:Object = ObjectUtil.clone(this.newBuildObject) as SuperObject;
			var d:Date = new Date();
			
			if(canPurchase(d)){
				
				// Build the object 
				this.userObjectManager.buildObject(this.newBuildObject, this.user);
				
				// Change the build state
				this.newBuildObject.updateBuildState(0.); // Make the build state transparent
				
				// Create a queue object associated with the purchase
				var b:LatLngBounds = this.map.getLatLngBounds();
				var buildTime:Date = PurchaseConstants.buildTime(this.newBuildObject, 0);
				var objectString:String = this.newBuildObject.getNameString();
				var q:QueueObject = new QueueObject("Building " + objectString + " at" + this.newBuildObject.getPosition(b), buildTime, onBuildEnd,
					this.newBuildObject.updateBuildState, this.newBuildObject, onBuildCancel );
				
				// Subtract the purchase prices from the current user.
				var woodCost:Number = PurchaseConstants.woodCost(this.newBuildObject, 0);
				var stoneCost:Number = PurchaseConstants.stoneCost(this.newBuildObject, 0);
				var manaCost:Number = PurchaseConstants.manaCost(this.newBuildObject, 0);
				this.user.purchaseObject(woodCost, stoneCost, manaCost);
				
				// Add the queue object to the queue manager, and syntheisze the active queue
				this.queueManager.addQueueObject(q);
				if(!this.queueManager.isVisible){
					this.changeState(GameManager.queueState);
				}
				
			}else{
				// Get the current production
				var totalWood:Number = this.resourceText.getWoodProduction(d);
				var totalStone:Number = this.resourceText.getManaProduction(d);
				var totalMana:Number = this.resourceText.getManaProduction(d);
				
				// Find out why the purchase failed, and tell the user
				var failureString:String = PurchaseConstants.missingResourcesString(this.newBuildObject, 0, totalWood, totalStone, totalMana);
				
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
				this.newBuildObject.eraseFromMap(this.map);
				
				// Change the state 
				this.changeState(GameManager.emptyState);
			}
			
			
		}
		
		// Function is called when building is cancelled.
		private function onBuildCancel(s:SuperObject, pC:Number) : void {
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
				this.changeState(GameManager.emptyState);
			}
		}
		
		// Function is called when building is complete
		private function onBuildEnd(s:SuperObject) : void {
			
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
				this.changeState(GameManager.emptyState);
			}
		}
		
		private function onNull(event:Event):void {
			
		}
		
		private function onCloseBuildPopup(event:Event) : void {
			PopUpManager.removePopUp(popup);
		}
		
		private function canPurchase(d:Date) : Boolean {
			
			// Get the current production
			var totalWood:Number = this.resourceText.getWoodProduction(d);
			var totalStone:Number = this.resourceText.getManaProduction(d);
			var totalMana:Number = this.resourceText.getManaProduction(d);
			
			return PurchaseConstants.canPurchase(this.newBuildObject, 0, totalWood, totalStone, totalMana);
		}
		
		public function onCancelBuildButton(event:MouseEvent) : void {
			// Remove the newest tower
			newBuildObject.eraseFromMap(this.map);
			
			// Remove from the boundary
			this.userBoundary.removeAndDraw(this.newBuildObject);
			
			// Change the state 
			this.changeState(GameManager.emptyState);
		}
		
		public function changeState(state:String) : void{
			// Change the focus to the last tab
			tabNavigator.selectedIndex = 2;					// hard-corded bleh
			
			// Grab the last container
			var nav:NavigatorContent = this.tabNavigator.getChildAt(2) as NavigatorContent;
			
			// Unravel the state
			if(this.currentTabStateString == "Queue"){
				this.queueManager.exitState();
			}
			
			try{
				for(var i:int = 0; i < nav.numChildren; i++){
					nav.removeElementAt(i);
				}
			}catch(e:RangeError){
				
			}
			
			// Get the current panel
			var d:IVisualElement;
			
			if(this.aPStateMatchine[state] is Function){
				var f:Function = this.aPStateMatchine[state];
				d = f() as IVisualElement;
			}else{
				d = this.aPStateMatchine[state] as IVisualElement;
			}
			
			nav.addElement(d);
			
			// Change state
			this.currentTabStateString = state;
		}
		
		// ==== UI ====
		
		// ====== AWAY3D =======
		private function init3DView() : void {
			// I am only initializing objects, since the 3D aspects of the
			// game have no user interactions
			initEngine();
			initObjects();
			initListeners();
			initText();
		}
		
		private function initEngine() : void {
			// Create the scene
			scene = new Scene3D();
			
			// Create the camera
			camera = new HoverCamera3D();
			camera.focus = 50;
			camera.distance = 1000;
			camera.minTiltAngle = 0;
			camera.maxTiltAngle = 180;
			camera.panAngle = 0;
			camera.tiltAngle = 180;
			camera.hover(true);
			
			// Create the renderer
			renderer = new BasicRenderer();
			
			// Create the view
			view = new View3D();
			view.x = 0;
			view.y = 0;
			view.scene = scene;
			view.camera = camera;
			view.renderer = renderer;
			view.clipping = new RectangleClipping({minX:0, minY:0, maxX:this.map.width, maxY:this.map.height});
	

			
			//view.clipping = new RectangleClipping({minX:-unscaledWidth/2,minY:-unscaledHeight/2,maxX:unscaledWidth/2,maxY:unscaledHeight/2});

			// Add the children to the sprite
			
			//this.mapGroup.removeElement(this.map);
			//mySprite.addChild(view);
			//mySprite.addChild(this.map);
			this.map.addChild(view);
			//this.mapGroup.addElementAt(mySprite, 1);
			
			// Create a drag object on a certain plane
			//dragManager = new Drag3D(view);
			//dragManager.plane = 'xy';
			//dragManager.debug = true;
			
			// Set the focus panel manager object
			//this.focusPanelManager.drag3D = dragManager;
			
		}
		
		private function initText() : void {
			// Setup up the vector font
			var fSWF:ByteArray = new this.fontSWF() as ByteArray;
			VectorText.extractFont(fSWF);
			
			// Setup the text fields
			var d:Date = new Date();
			this.resourceText = new ResourceProductionText("Verdana", this.user, d);
			
			// Setup up the locaition of the text
			this.resourceText.x = 980.;
			this.resourceText.y = -780.;
			this.resourceText.z = 0.;
			this.resourceText.size = 20;
			this.scene.addChild(this.resourceText);
			
		}
		
		private function initObjects() : void {
			// Create a new material 
			var towerIcon:BitmapAsset = new this.photo.cannonMaterial() as BitmapAsset;
			var towerData:BitmapData = towerIcon.bitmapData;
			var cannonMaterial:BitmapMaterial = new BitmapMaterial(towerData);
			cannonMaterial.smooth = true;
			
			// Create the sphere
			
			sphere = new Sphere();
			sphere.x = 980;
			sphere.y = -780;
			sphere.z = 0.;
			sphere.radius = 150;
			sphere.segmentsH = 12;
			sphere.segmentsW = 12;
			sphere.name = "mySphere";
			sphere.material = cannonMaterial;
			//scene.addChild(sphere);
			
		}
		
		// Setup the listeners
		private function initListeners() : void {
			// Setup some event listeners
			this.app.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.app.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		// Resize the window
		private function onResize(event:Event=null):void {
			//view.x = focusPanel.width / 2;
			//view.y = focusPanel.height / 2;
		}
		
		// Enter the frame
		private function onEnterFrame(event:Event) : void {
			this.camera.hover();
			// Update the state of the variables
			var d:Date = new Date();
			this.resourceText.updateState(d);
			this.queueManager.update(d);
			//this.dragManager.updateDrag();
			this.view.render();
			
			//if(finishedLoadingMap){
		//	camera.hover();
			
			// Change the z position of the sphere
			//sphere.z = (sphere.z + 10) % 100 - 100
			
			
		//	view.render();
		//	}
		}
		
		/*
		public function runFromInitManager(capital:Tower):void{
			// Remove the current marker from the map
			capital.eraseFromMap(this.map);
			capital.removeFocusOnObject();
			
			// Setup up the game channels. The channels run the game
			this.setupGameChannels();
			
			// Initialize the game
			this.initGame();
			
			// Setup Map Events
			this.initializeMap();
			
			// Draw on the map with appropriate boundaries, and at the game zoom level.
			//capital.draw(true, this.map, this.photo, this.focusPanelManager, true);
			
			// Setup up the renderer of objects
			this.listOfUserModels.addItem(capital);
			
			// Draw all user objects on the map
			var bounds:LatLngBounds = new LatLngBounds();
			var drawnObjects:ArrayCollection = this.drawUserObjectsInBounds(bounds);
			
			// Show all of the user objects
			this.listOfUserObjects.dataProvider = drawnObjects;
			
			// Create the user boundary
			userBoundary = new PolygonBoundaryManager(this.map, drawnObjects, this.user);
			userBoundary.initDraw();
			
			this.setupChat();
			this.setupUIEvents();
			this.init3DView();
			
		}
		
		// Setup function
		private function initializeMap() : void {
			// Set the appropriate zoom level
			this.map.setZoom(16, false);
			
			// Set the events
			this.mapEventManager = new EventManager(this.map);
			this.mapEventManager.addEventListener(MapEvent.TILES_LOADED, onTilesLoaded);
			this.mapEventManager.addEventListener(MapMouseEvent.CLICK, onMapMouseClick);
			this.mapEventManager.addEventListener(MapMouseEvent.DRAG_START, onMapDragStart);
			this.mapEventManager.addEventListener(MapMouseEvent.DRAG_END, onMapDragEnd);
			this.mapEventManager.addEventListener(MapMoveEvent.MOVE_END, onMapMoveEnd);
			this.mapEventManager.addEventListener(MapMouseEvent.ROLL_OUT, onMapRollOut);
			this.mapEventManager.addEventListener(MapMouseEvent.ROLL_OVER, onMapRollOver);
			this.mapEventManager.addEventListener(MapMouseEvent.MOUSE_MOVE, onMapMouseMove);
		}
		
		private function getUserObjects(): void {
			this.userObjectManager.GetUserObjects(this.user, onGetUserObjects);
		}
		
		private function onGetUserObjects(event:ResultEvent) : void {
			this.listOfUserModels = event.result as ArrayCollection;
			
			// Get the first object, and draw it on the map. It should be the capital
			var obj:SuperObject = this.listOfUserModels.getItemAt(0) as SuperObject;
			var bounds:LatLngBounds = this.map.getLatLngBounds();
			var pos:LatLng = obj.getPosition(this.map.getLatLngBounds());
			this.map.setCenter(pos);
			
			// Get the new bounds after recentering the position.
			bounds = this.map.getLatLngBounds();

			
			// Dereference the user
			this.user = this.user.cloneUser();
			for(var i:int = 0; i < this.listOfUserModels.length; i++){
				var sobj:SuperObject = this.listOfUserModels.getItemAt(i) as SuperObject;
				sobj.setUser(null);
			}
			
			// Draw all user objects on the map
			var drawnObjects:ArrayCollection = this.drawUserObjectsInBounds(bounds);
			
			// Show all of the user objects
			this.listOfUserObjects.dataProvider = drawnObjects;
		}
		
		// ==== CHANNEL INTERFACE =====
		public function setupGameChannels() : void {
			
			// Setup the channel events
			this.app.addEventListener(ChannelAttackEvent.CHANNEL_ATTACK, onChannelAttack);
			this.app.addEventListener(ChannelBuildEvent.CHANNEL_BUILD, onChannelBuild);
			this.app.addEventListener(ChannelMessageEvent.CHANNEL_MESSAGE, onChannelMessage);
			this.app.addEventListener(ChannelMoveEvent.CHANNEL_MOVE, onChannelMove);
			this.app.addEventListener(ChannelUserLoginEvent.CHANNEL_LOGIN, onChannelLogin);
			this.app.addEventListener(ChannelUserLogoutEvent.CHANNEL_LOGOUT, onChannelLogout);
			
		}
		
		public function onChannelAttack(event:ChannelAttackEvent) : void {
			
		}
		
		public function onChannelBuild(event:ChannelBuildEvent) : void {
			// Get the build string
			Alert.show("onChannelBuild");
			var buildUser:String = event.buildUser;
			var buildObject:Object = event.buildObject;
			
			// Extract the built object
			var s:SuperObject;
		
			if(buildUser == this.user.alias){
				if(buildObject.Class == "Tower"){
					s = Tower.createUserTowerFromJSON(buildObject.Value, this.user);
				}else if(buildObject.Class == "Portal"){
					s = Portal.createUserPortalFromJSON(buildObject.Value, this.user);
				}else if(buildObject.Class == "Road"){
					s = Road.createUserRoadFromJSON(buildObject.Value, this.user);
				}else{
					return;
				}
				// The two lists can be fundamentally different
				this.listOfUserObjects.dataProvider.addItem(s);		// Add to the display list 
				this.listOfUserModels.addItem(s);					// Add to the list of user models 
								
			}else{
				if(buildObject.Class == "Tower"){
					s = Tower.createTowerFromJSON(buildObject.Value);
				}else if(buildObject.Class == "Portal"){
					s = Portal.createPortalFromJSON(buildObject.Value);
				}else if(buildObject.Class == "Road"){
					s = Road.createRoadFromJSON(buildObject.Value);
				}else{
					return;
				}
				
				// TODO: Get the object for other user
			}
			// Add the user object to the list of relevant user objects
			var bounds:LatLngBounds = this.map.getLatLngBounds();
			var pos:LatLng = s.getPosition(bounds);
			if(bounds.containsLatLng(pos)){
				s.draw(true, this.map, this.photo, this.focusPanelManager, true, this.scene);	
			
				// Remove the currently drawn object
				if(this.newBuildObject != null){
					this.newBuildObject.eraseFromMap(this.map);
				}
			
			}
			
			// Get the queue manager 
			var qObject:QueueObject = this.queueManager.getQueueObjectAtPosition(pos, this.map);
			this.queueManager.removeFromQueue(qObject);
			if(this.queueManager.isEmpty() && this.currentTabStateString == this.queueState){
				this.changeState(this.emptyState);
			}
		}
		

		
		public function onChannelMessage(event:ChannelMessageEvent) : void {
			// The message object
			var message:Object = event.getJSONObject();
			
			// Get the textflow
			if(this.chatList.textFlow == null){
				this.chatList.textFlow = new TextFlow();
			}
			
			// Setup the span element
			var newMessage:ParagraphElement = new ParagraphElement();
			
			// Setup up the user
			var span:SpanElement = new SpanElement();
			span.text = message.user + ": ";
			span.fontWeight = "bold";
			
			// Setup up the message
			var nspan:SpanElement = new SpanElement();
			nspan.text = message.message;
			
			// Add the message
			newMessage.addChild(span);
			newMessage.addChild(nspan);
			
			// Add a message to the textFlow
			this.chatList.textFlow.addChild(newMessage);
							
			// Remove the first child, if there are to many message
			if(this.chatList.textFlow.numChildren > 1000){
				this.chatList.textFlow.removeChildAt(0);
			}
	
		}	
		
		public function onChannelMove(event:ChannelMoveEvent) : void {
			
		}
		
		public function onChannelLogin(event:ChannelUserLoginEvent) : void {
			Alert.show("onChannelLogin");
			
			// Set the user list to the data provider
			this.listOfLoggedInUsers.addAll(event.userLoginArray);
			this.userList.dataProvider = this.listOfLoggedInUsers;
		}
		
		public function onChannelLogout(event:ChannelUserLogoutEvent) : void {
			Alert.show("onChannelLogout");
			
			var obj:Object = event.logout;
			var index:int;
			for(var i:int = 0; i < this.listOfLoggedInUsers.length; i++){
				var rObj:Object = this.listOfLoggedInUsers.getItemAt(i);
				if(!ObjectUtil.compare(obj, rObj)){
					this.listOfLoggedInUsers.removeItemAt(i);
					break;
				}
			}
			
		}
		
		// ==== CHANNEL INTERFACE =====
		
		// ==== INIT GAME ===
		private function initGame() : void {
			this.userObjectManager.initGame(this.user, onInitGame);	
		}
		
		private function onInitGame(event:ResultEvent) : void {
			// Get the token.
			var token:String = event.result.token.toString();

			// Create the game channel
			this.gameChannel = new GameChannel();
			this.gameChannel.token = token;

			// Setup the javascript game channel
			this.channelBridge.initGameChannel(this.gameChannel);
			
			// Login in the user
			this.userObjectManager.loginUserToGame(this.user, onNull);
			
		}
			
		// ==== INIT GAME ===
		
		// ==== CHAT SETUP ===
		private function setupChat() : void {
			this.sendButton.addEventListener(MouseEvent.MOUSE_UP, onSendChatButton);	
		}
		
		private function onSendChatButton(event:MouseEvent) : void {
			var s:String = this.chatTextInput.text;
			this.userObjectManager.sendMessage(this.user,s);
		}
		
		// === CHAT SETUP ===
		
		// NULL result - nothing expected to be returned.
		private function onNull(event:ResultEvent) : void {
	
		}
		
		/// MAP
		// The drag events
		private function onMapDragStart(event:MapMouseEvent) : void {
			initialMapDragMouse = event.latLng;
		}
		
		// Draw object with bounds
		private function drawUserObjectsInBounds(bounds:LatLngBounds) : ArrayCollection {
			// Set the array of queue objects
			var arrayOfQueueObjects:ArrayCollection = new ArrayCollection();
			// We need to dereference the user object from all of the user objects
			// in the game objects, so that the game objects users' can be dereferenced
			// without affecting the global user object. 
			//xwthis.user = this.user.cloneUser();
			
			// Get dates
			var d:Date = new Date();
			var b:LatLngBounds = this.map.getLatLngBounds();
			
			// Create a list of draw objects to later draw their boundaries
			var listOfDrawnObjects:ArrayCollection = new ArrayCollection();
			
			for(var i:int = 0; i < this.listOfUserModels.length; i++){
				var obj:SuperObject = this.listOfUserModels.getItemAt(i) as SuperObject;
				var pos:LatLng = obj.getPosition(bounds);
				
				// Check if the object is visbile
				if(bounds.containsLatLng(pos)){
					// Check if the object has finished building
					if(!obj.isIncompleteState()){
						var mDate:Date = PurchaseConstants.buildTime(obj, 0);
						var foundingDate:Date = obj.getFoundingDate();
						var productionTime:Number = DateConstants.numberOfMinutes(mDate, d);
						var timeAlive:Number = DateConstants.numberOfMinutes(d, foundingDate);
						if(productionTime < timeAlive){
							Alert.show("Here" +  i.toString());
							// Draw the object
							obj.draw(true, this.map, this.photo, this.focusPanelManager, true, this.scene);
					
							// Finish the building of the object. The code must be here because no users
							// could be logged in the association graph of the user.
							//obj.setUser(null); // Dereferencing is necessary since the Key is not active in GAE
							onBuildEnd(obj);
							//this.userObjectManager.buildObjectComplete(obj, this.user);
							//obj.setUser(this.user);
							
							// Append the list of draw objects
							listOfDrawnObjects.addItem(obj);
						}else{
							arrayOfQueueObjects.addItem(obj);
						}
					}else{
						obj.draw(true, this.map, this.photo, this.focusPanelManager, true, this.scene);
						listOfDrawnObjects.addItem(obj);
					}
				}
			}
			
			// Create the polygon empire boundary for the current user
			userBoundary = new PolygonBoundaryManager(this.map, listOfDrawnObjects, this.user);
			userBoundary.initDraw()
			
			
			for(var j:int = 0; j < arrayOfQueueObjects.length; j++){
				var nobj:SuperObject = arrayOfQueueObjects[j] as SuperObject;
				
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
					effectiveBuildTime, onBuildEnd, nobj.updateBuildState, nobj, onBuildCancel);
			
				// Add the queue object to the manager
				this.queueManager.addQueueObject(q);
				if(!this.queueManager.isVisible){
					this.changeState(this.queueState);
				}
			}
			return listOfDrawnObjects;
		}
		

		
		private function onMapDragEnd(event:MapMouseEvent) : void {
			if(!this.buildStateInformation.isInState()){
				var finalDragPosition:LatLng = event.latLng;
				
				// The center of the map, and bounds
				var centerOfMap:LatLng = this.map.getCenter();
				var bounds:LatLngBounds = this.map.getLatLngBounds();
				var mapDimension:LatLng = new LatLng(bounds.getNorth() - bounds.getSouth(), bounds.getWest() - bounds.getEast());
				
				
				// The net distance
				var netDragLongitude:Number = finalDragPosition.lng() - initialMapDragMouse.lng();
				var netDragLatitude:Number = finalDragPosition.lat() - initialMapDragMouse.lat();
				
				// The new center position
				var newCenterLatitude:Number;
				var newCenterLongitude:Number;
				
				if(Math.abs(netDragLongitude) > Math.abs(netDragLatitude)) {
					if(netDragLongitude > 0.0){
						newCenterLatitude = centerOfMap.lat();
						newCenterLongitude = centerOfMap.lng() +  mapDimension.lng();
					}else{
						newCenterLatitude = centerOfMap.lat();
						newCenterLongitude = centerOfMap.lng() - mapDimension.lng();	
					}
				}else{
					if(netDragLatitude > 0.0){
						newCenterLatitude = centerOfMap.lat() + mapDimension.lat();
						newCenterLongitude = centerOfMap.lng();
					}else{
						newCenterLatitude = centerOfMap.lat() - mapDimension.lat();
						newCenterLongitude = centerOfMap.lng();
					}
				}
				
				// Create the new position, and pan to the new position
				centerOfMap = new LatLng(newCenterLatitude, newCenterLongitude);
				this.map.panTo(centerOfMap);
				
				// Set the mouse pan to true
				userMousePan = true;
			}
			
		}
		
		private function onMapMoveEnd(event:MapMoveEvent) : void {
			if(userMousePan == true){
				// Load all of the data in the new location
				var b:LatLngBounds = this.map.getLatLngBounds();
				this.userObjectManager.getAllObjectsWithinBounds(b);
				
				// The user mouse pan
				userMousePan = false;
			}
		}
		
		private function onMapRollOut(event:MapMouseEvent) : void {
			if(this.buildStateInformation.isInState()){
				CursorManager.removeAllCursors();		// Restore the system cursor

			}
		}
		
		private function onMapRollOver(event:MapMouseEvent) : void {
			if(this.buildStateInformation.isInState()){
				var asset:BitmapAsset = new this.buildObjectPicture() as BitmapAsset;
				var data:BitmapData = asset.bitmapData;
				var xShift:Number = data.width / 2.;
				var yShift:Number = data.height;
				CursorManager.setCursor(this.buildObjectPicture, CursorManagerPriority.HIGH, -xShift, -yShift);
			}
		}
		
		private function onMapMouseMove(event:MapMouseEvent) : void {
			if(this.buildStateInformation.isInState()){
				
			}
		}
		
		private function onMapMouseClick(event:MapMouseEvent) : void {
			if(this.buildStateInformation.isInState()){
				var pos:LatLng = event.latLng;
				
				// Change the state of the state
				this.buildStateInformation.nextStatge();
		
				
				// Check if the user has clicked a location inside his empire.
				if(this.buildStateInformation.getNumberOfStages() == 1 && this.buildStateInformation.getStage() == 1){
					if(this.userBoundary.isInsidePolygon(pos)){
						if(!intersectsVisibleBoundaryObject(pos)){
							this.buildStateInformation.exitState()
							
							// Setup the action state
							var b:BuildActionGroup = this.aPStateMatchine[this.buildState] as BuildActionGroup;
							b.buildImage.source = new this.buildObjectPicture() as BitmapAsset;
						
							// Create/Set the text flow object
							var textFlow:TextFlow = new TextFlow();
							var pGraph:ParagraphElement = new ParagraphElement();
							var iSpan:SpanElement = new SpanElement();
							iSpan.text = getBuildString();
							pGraph.addChild(iSpan);
							textFlow.addChild(pGraph);
							b.buildText.textFlow = textFlow;
							
							// Change the state
							this.changeState(this.buildState);
							
							// Create an object from the object picture
							newBuildObject = this.getItemFromClass(this.buildObjectPicture, pos);
							newBuildObject.initialize(this.user);
							newBuildObject.draw(true, this.map, this.photo, this.focusPanelManager, true, this.scene);
							
							// Add the object to the empire boundary
							this.userBoundary.addAndDraw(newBuildObject);
							
							// Change the cursor manager
							CursorManager.removeAllCursors();
						}
					}
				}
			}else if(this.buildStateInformation.getStage() == 2){
				
			}

		}
		
		private function isInsideVisibleEmpire(pos:LatLng) : Boolean {
			for(var i:int = 0; i < this.listOfUserModels.length; i++){
				var s:SuperObject = this.listOfUserModels[i] as SuperObject;
				if(s.hasBoundary()){
					var b:BoundarySuperObject = s as BoundarySuperObject;
					if(b.isInsideBoundary(pos, this.map)){
						return true;
					}
				}
			}
			
			return false;
		}
		
		private function intersectsVisibleBoundaryObject(pos:LatLng) : Boolean {
			for(var i:int = 0; i < this.listOfUserModels.length; i++){
				var s:SuperObject = this.listOfUserModels[i] as SuperObject;
				if(! s.isOverLappingBoundsOfObject(pos, this.map, this.photo)) {
					return false;
				}
			}
			return true;
		}
		
		private function onTilesLoaded(event:MapEvent) : void {
			finishedLoadingMap = true;
		}
		// ===== MAP ====
		
		// ==== UI ====
		public function setupUIEvents() : void {
			// Master events
			this.buildObjectList.addEventListener(ItemClickEvent.ITEM_CLICK, onBuildItemClick);
		
			// User Dependent Events
			this.setupActionPanelState();
		}
		
		private function onBuildItemClick(event:ItemClickEvent) : void {
			// Extract the item index, and the corresponding class
			var itemIndex:int = event.index;
			switch(itemIndex){
				case 0:
					this.buildObjectPicture = this.photo.TowerLevel0;
					break;
				case 1:
					this.buildObjectPicture = this.photo.ThePortal;
					break;
				case 2:
					this.buildObjectPicture = this.photo.EastRoad;
					break;
			}
			
			// Remove the previous build object from the map
			if(this.newBuildObject != null){
				
				if(!this.queueManager.isInQueue(this.newBuildObject)){
					this.newBuildObject.eraseFromMap(this.map);
				}
				
			}
			this.buildStateInformation.enterState(this.newBuildObject);
		}
		
		private function getItemFromClass(photo:Class, pos:LatLng):SuperObject{
			var obj:SuperObject;
			if(photo == this.photo.TowerLevel0){
				var t:Tower = new Tower();
				t.updatePosition(pos);
				obj = t;
			}else if(photo == this.photo.ThePortal){
				var p:Portal = new Portal();
				p.updatePosition(pos);
				obj = p;
			}else if(photo == this.photo.EastRoad){
				var r:Road = new Road();
				r.updatePosition(pos);
				obj = r;
			}
			return obj;
		}
		
		private function getBuildString():String {
			var s:String ="\n";
			
			// Create a temporary object without fixed position
			var pos:LatLng =  this.map.getCenter();
			var tempObject:SuperObject = this.getItemFromClass(this.buildObjectPicture, pos);
			 
			// Find the cost for that temporary object
			var woodCost:Number = PurchaseConstants.woodCost(tempObject, 0);
			var stoneCost:Number = PurchaseConstants.stoneCost(tempObject, 0);
			var magicCost:Number = PurchaseConstants.manaCost(tempObject, 0);
			
			if(this.buildObjectPicture == this.photo.TowerLevel0){
				s+="Stone  :" + stoneCost.toString() + "\n";
				s+="Wood  :" + woodCost.toString() + "\n";
				s+="Magic  :" + magicCost.toString() + "\n";
			}else if(this.buildObjectPicture == this.photo.ThePortal){
				s+="Stone :" + stoneCost.toString() + "\n";
				s+="Wood  :" + woodCost.toString() + "\n";
				s+="Magic :" + magicCost.toString() + "\n";
			}else if(this.buildObjectPicture == this.photo.EastRoad){
				s+="Stone :" + stoneCost.toString() + "\n";
				s+="Wood  :" + woodCost.toString() + "\n";
			}
			
			return s;
		}
	
		public function setupActionPanelState() : void{
			// Create our panels
			var g:HGroup = new HGroup();
			var ap:BuildActionGroup = new BuildActionGroup();
			
			// Add to the state dictionary
			this.aPStateMatchine =  new Dictionary();
			this.aPStateMatchine[emptyState] = g;
			this.aPStateMatchine[buildState] = ap;
			this.aPStateMatchine[queueState] = this.queueManager.realizeActionQueue;
			
			// Add the relevant events.
			ap.buildButton.addEventListener(MouseEvent.MOUSE_DOWN, onBuildButton);
			ap.cancelButton.addEventListener(MouseEvent.MOUSE_DOWN, onCancelBuildButton);
		}
		
		public function onBuildButton(event:MouseEvent):void{
			// Copy the tower
			//var s:Object = ObjectUtil.clone(this.newBuildObject) as SuperObject;
			var d:Date = new Date();
	
			if(canPurchase(d)){
				
				// Build the object 
				this.userObjectManager.buildObject(this.newBuildObject, this.user);
				
				// Change the build state
				this.newBuildObject.updateBuildState(0.); // Make the build state transparent
				
				// Create a queue object associated with the purchase
				var b:LatLngBounds = this.map.getLatLngBounds();
				var buildTime:Date = PurchaseConstants.buildTime(this.newBuildObject, 0);
				var objectString:String = this.newBuildObject.getNameString();
				var q:QueueObject = new QueueObject("Building " + objectString + " at" + this.newBuildObject.getPosition(b), buildTime, onBuildEnd,
					this.newBuildObject.updateBuildState, this.newBuildObject, onBuildCancel );
				
				// Subtract the purchase prices from the current user.
				var woodCost:Number = PurchaseConstants.woodCost(this.newBuildObject, 0);
				var stoneCost:Number = PurchaseConstants.stoneCost(this.newBuildObject, 0);
				var manaCost:Number = PurchaseConstants.manaCost(this.newBuildObject, 0);
				this.user.purchaseObject(woodCost, stoneCost, manaCost);
				
				// Add the queue object to the queue manager, and syntheisze the active queue
				this.queueManager.addQueueObject(q);
				if(!this.queueManager.isVisible){
					this.changeState(this.queueState);
				}
			
			}else{
				// Get the current production
				var totalWood:Number = this.resourceText.getWoodProduction(d);
				var totalStone:Number = this.resourceText.getManaProduction(d);
				var totalMana:Number = this.resourceText.getManaProduction(d);
				
				// Find out why the purchase failed, and tell the user
				var failureString:String = PurchaseConstants.missingResourcesString(this.newBuildObject, 0, totalWood, totalStone, totalMana);

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
				this.newBuildObject.eraseFromMap(this.map);
				
				// Change the state 
				this.changeState(this.emptyState);
			}
			
			
		}
		
		// Function is called when building is cancelled.
		private function onBuildCancel(s:SuperObject, pC:Number) : void {
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
				this.changeState(this.emptyState);
			}
		}
		
		// Function is called when building is complete
		private function onBuildEnd(s:SuperObject) : void {

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
				this.changeState(this.emptyState);
			}
		}
		
		private function onCloseBuildPopup(event:Event) : void {
			PopUpManager.removePopUp(popup);
		}
		
		private function canPurchase(d:Date) : Boolean {
		
			// Get the current production
			var totalWood:Number = this.resourceText.getWoodProduction(d);
			var totalStone:Number = this.resourceText.getManaProduction(d);
			var totalMana:Number = this.resourceText.getManaProduction(d);
			
			return PurchaseConstants.canPurchase(this.newBuildObject, 0, totalWood, totalStone, totalMana);
		}
		
		public function onCancelBuildButton(event:MouseEvent) : void {
			// Remove the newest tower
			newBuildObject.eraseFromMap(this.map);
			
			// Remove from the boundary
			this.userBoundary.removeAndDraw(this.newBuildObject);
			
			// Change the state 
			this.changeState(this.emptyState);
		}
		
		public function changeState(state:String) : void{
			// Change the focus to the last tab
			tabNavigator.selectedIndex = 2;					// hard-corded bleh
			
			// Grab the last container
			var nav:NavigatorContent = this.tabNavigator.getChildAt(2) as NavigatorContent;
			
			// Unravel the state
			if(this.currentTabStateString == "Queue"){
				this.queueManager.exitState();
			}
		
			try{
				for(var i:int = 0; i < nav.numChildren; i++){
					nav.removeElementAt(i);
				}
			}catch(e:RangeError){
				
			}
			
			// Get the current panel
			var d:IVisualElement;
			
			if(this.aPStateMatchine[state] is Function){
				var f:Function = this.aPStateMatchine[state];
				d = f() as IVisualElement;
			}else{
				d = this.aPStateMatchine[state] as IVisualElement;
			}
			 
			nav.addElement(d);
			
			// Change state
			this.currentTabStateString = state;
		}
		
		// ==== UI ====
		
		// ====== AWAY3D =======
		private function init3DView() : void {
			// I am only initializing objects, since the 3D aspects of the
			// game have no user interactions
			initEngine();
			initObjects();
			initListeners();
			initText();
		}
		
		private function initEngine() : void {
			// Create the scene
			scene = new Scene3D();
			
			// Create the camera
			camera = new HoverCamera3D();
			camera.focus = 50;
			camera.distance = 1000;
			camera.minTiltAngle = 0;
			camera.maxTiltAngle = 180;
			camera.panAngle = 0;
			camera.tiltAngle = 180;
			camera.hover(true);
			
			// Create the renderer
			renderer = new BasicRenderer();
			
			// Create the view
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			view.renderer = renderer;
			
			// Add the children to the sprite
			
			//this.mapGroup.removeElement(this.map);
			//mySprite.addChild(view);
			//mySprite.addChild(this.map);
			this.map.addChild(view);
			//this.mapGroup.addElementAt(mySprite, 1);
			
		}
		
		private function initText() : void {
			// Setup up the vector font
			var fSWF:ByteArray = new this.fontSWF() as ByteArray;
			VectorText.extractFont(fSWF);
			
			// Setup the text fields
			var d:Date = new Date();
			this.resourceText = new ResourceProductionText("Verdana", this.user, d);
			
			// Setup up the locaition of the text
			this.resourceText.x = 980.;
			this.resourceText.y = -780.;
			this.resourceText.z = 0.;
			this.resourceText.size = 20;
			this.scene.addChild(this.resourceText);
			
		}
		
		private function initObjects() : void {
			// Create a new material 
			var towerIcon:BitmapAsset = new this.photo.cannonMaterial() as BitmapAsset;
			var towerData:BitmapData = towerIcon.bitmapData;
			var cannonMaterial:BitmapMaterial = new BitmapMaterial(towerData);
			cannonMaterial.smooth = true;
			
			// Create the sphere
			/*
			sphere = new Sphere();
			sphere.x = -400;
			sphere.y = 0;
			sphere.z = -800;
			sphere.radius = 150;
			sphere.segmentsH = 12;
			sphere.segmentsW = 12;
			sphere.name = "mySphere";
			sphere.material = cannonMaterial;
			scene.addChild(sphere);
			
		}
		
		// Setup the listeners
		private function initListeners() : void {
			// Setup some event listeners
			this.app.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.app.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		// Resize the window
		private function onResize(event:Event=null):void {
			//view.x = focusPanel.width / 2;
			//view.y = focusPanel.height / 2;
		}
		
		// Enter the frame
		private function onEnterFrame(event:Event) : void {
			this.camera.hover();
			
			// Update the state of the variables
			var d:Date = new Date();
			this.resourceText.updateState(d);
			this.queueManager.update(d);
			this.view.render();
			//if(finishedLoadingMap){
				//camera.hover();
				
				// Change the z position of the sphere
				//sphere.z = (sphere.z + 10) % 100 - 100
				
				
				//view.render();
			//}
		}
		*/
		// === AWAY3D ===
	}
}