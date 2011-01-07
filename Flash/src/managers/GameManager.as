package managers
{
	import assets.PhotoAssets;
	
	import away3dlite.cameras.*;
	import away3dlite.containers.*;
	import away3dlite.core.base.*;
	import away3dlite.core.render.*;
	import away3dlite.events.*;
	import away3dlite.lights.DirectionalLight3D;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	
	import com.facebook.graph.core.FacebookJSBridge;
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapMoveEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	
	import messaging.ChannelJavascriptBridge;
	import messaging.events.ChannelAttackEvent;
	import messaging.events.ChannelBuildEvent;
	import messaging.events.ChannelJSON;
	import messaging.events.ChannelMessageEvent;
	import messaging.events.ChannelMoveEvent;
	import messaging.events.ChannelUserLoginEvent;
	import messaging.events.ChannelUserLogoutEvent;
	
	import models.GameChannel;
	import models.SuperObject;
	import models.Tower;
	import models.User;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.BitmapAsset;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;
	
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.List;
	import spark.components.TextInput;
	import spark.components.TitleWindow;
	import spark.core.SpriteVisualElement;

	// The game manager runs the towersaint game.
	public class GameManager
	{
		// Private variables used to run the game(views, and state variables)
		private var user:User;												/* The user of the game */
		private var listOfUserModels:ArrayCollection						/* Array collection of all the objects the user owns */
		private var map:Map;												/* The map, which is being played on */
		private var mapEventManager:EventManager;							/* The event manager for the map associated with the game manager */
		private var photo:PhotoAssets;										/* The game xml data.. pictures etc */
		private var focusPanelManager:FocusPanelManager;					/* View Manager which handles the inspection of objects */
		private var app:Application;										/* The application view which is running this game */
		private var gameTimer:Timer;										/* Game timer refreshes the game periodically */
		private var sendButton:Button;										/* Button that sends text messages to the chat server */
		private var chatList:List;											/* List of the global chat occurring */
		private var userList:List;											/* List of users in the game */
		private var listOfUserObjects:List;									/* List of user objects- Portals, and Tower */
		private var chatTextInput:TextInput									/* The text input for the chat */
		private var userObjectManager:UserObjectManager;					/* User object manager controls the collection of information from the server */
		private var channelBridge:ChannelJavascriptBridge;					/* The briged between GAE channel api and the actionscript */
		private var gameChannel:GameChannel;								/* The new game channel */
		
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
		
		// Map variales
		private var initialMapDragMouse:LatLng;								/* The location where the initial of map occurs */
		private var userMousePan:Boolean;									/* True if the user moves the mouse on the map */
		private var finishedLoadingMap:Boolean;								/* True if the map has finished loading */
		
		public function GameManager(u:User, m:Map, p:PhotoAssets, fPM:FocusPanelManager, a:Application, 
									sB:Button, cL:List, uL:List, lOU:List, cT:TextInput, uM:UserObjectManager, 
									sE:SpriteVisualElement)
		{
			// Create the manager object
			this.user = u;
			this.map = m;
			this.photo = p;
			this.focusPanelManager = fPM;
			this.app = a;
			this.sendButton = sB;
			this.chatList = cL;
			this.userList = uL;
			this.listOfUserObjects = lOU;
			this.chatTextInput = cT;
			this.userObjectManager = uM;
			this.mySprite = sE;
			
			// Call the super
			super();
			
			// Initialize objects
			this.listOfUserModels = new ArrayCollection();
			
			// Setup the game channels
			var f:ChannelJavascriptBridge = new ChannelJavascriptBridge(this.app);
		}
		
		// Run the game. Intialize active objects, events, and interfaces.
		public function run() : void{
			// Setup Map events
			this.initializeMap();
			
			// Get all user objects
			this.getUserObjects();
			
			// Setup up the game channels. The channels run the game
			this.setupGameChannels();
			
			// Initialize the game
			this.initGame();
		}
		
		public function runFromInitManager(capital:Tower):void{
			// Remove the current marker from the map
			capital.eraseFromMap(this.map);
			capital.removeFocusOnObject();
			
			// Setup Map Events
			this.initializeMap();
			
			// Draw on the map with appropriate boundaries, and at the game zoom level.
			capital.draw(true, this.map, this.photo, this.focusPanelManager, true);
			
			// Setup up the renderer of objects
			this.listOfUserModels.addItem(capital);
			this.listOfUserObjects.dataProvider = this.listOfUserModels;
			
			// Setup up the game channels. The channels run the game
			this.setupGameChannels();
			
			// Initialize the game
			this.initGame();
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
		}
		
		private function getUserObjects(): void {
			this.userObjectManager.GetUserObjects(this.user, onGetUserObjects);
		}
		
		private function onGetUserObjects(event:ResultEvent) : void {
			this.listOfUserModels = event.result as ArrayCollection;
			Alert.show(this.listOfUserModels.toString());
			
			// Get the first object, and draw it on the map. It should be the capital
			var obj:SuperObject = this.listOfUserModels.getItemAt(0) as SuperObject;
			var bounds:LatLngBounds = this.map.getLatLngBounds();
			var pos:LatLng = obj.getPosition(this.map.getLatLngBounds());
			this.map.setCenter(pos);
			
			// Draw all user objects on the map
			this.drawUserObjectsInBounds(bounds);
			
			// Show all of the user objects
			this.listOfUserObjects.dataProvider = this.listOfUserModels;
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
			
		}
		
		public function onChannelMessage(event:ChannelMessageEvent) : void {
			
		}
		
		public function onChannelMove(event:ChannelMoveEvent) : void {
			
		}
		
		public function onChannelLogin(event:ChannelUserLoginEvent) : void {
			
		}
		
		public function onChannelLogout(event:ChannelUserLogoutEvent) : void {
			
		}
		
		// ==== CHANNEL INTERFACE =====
		
		// ==== INIT GAME ===
		private function initGame() : void {
			this.userObjectManager.initGame(this.user, onInitGame);	
		}
		
		private function onInitGame(event:ResultEvent) : void {
			this.gameChannel = event.result as GameChannel;
			Alert.show(this.gameChannel.token.toString());
		}
		// ==== INIT GAME ===
		
		/// MAP
		// The drag events
		private function onMapDragStart(event:MapMouseEvent) : void {
			initialMapDragMouse = event.latLng;
		}
		
		// Draw object with bounds
		private function drawUserObjectsInBounds(bounds:LatLngBounds) : void {
			for(var i:int = 0; i < this.listOfUserModels.length; i++){
				var obj:SuperObject = this.listOfUserModels.getItemAt(i) as SuperObject;
				var pos:LatLng = obj.getPosition(bounds);
				if(bounds.containsLatLng(pos)){
					obj.draw(true, this.map, this.photo, this.focusPanelManager, true);
				}
			}
		}
		
		private function onMapDragEnd(event:MapMouseEvent) : void {
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
		
		private function onMapMoveEnd(event:MapMoveEvent) : void {
			if(userMousePan == true){
				// Load all of the data in the new location
				var b:LatLngBounds = this.map.getLatLngBounds();
				this.userObjectManager.getAllObjectsWithinBounds(b);
				
				// The user mouse pan
				userMousePan = false;
			}
		}
		
		private function onMapMouseClick(event:MapMouseEvent) : void {
			/*
			if(imageState.isClicked){
				// The image state
				imageState.isClicked = false;
				
				// The location
				var pos:LatLng = event.latLng;
				var obj:SuperObject = imageState.endObject as SuperObject;
				
				// The draw function
				obj.setPosition(pos);
				obj.draw(true, this.map, this.photo, this.focusPanelManager);
				obj.setIsModified(true);
				
				// The control button for sending info
				//controlButton.name = "Submit"
			}
			*/
		}
		
		private function onTilesLoaded(event:MapEvent) : void {
			finishedLoadingMap = true;
		}
		

		
		private function init3DView() : void {
			// I am only initializing objects, since the 3D aspects of the
			// game have no user interactions
			initEngine();
			initObjects();
			initListeners();
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
			camera.panAngle =90;
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
			mySprite.addChild(this.map);
			mySprite.addChild(view);
		}
		
		private function initObjects() : void {
			// Create a new material 
			var towerIcon:BitmapAsset = new this.photo.cannonMaterial() as BitmapAsset;
			var towerData:BitmapData = towerIcon.bitmapData;
			var cannonMaterial:BitmapMaterial = new BitmapMaterial(towerData);
			cannonMaterial.smooth = true;
			
			// Create the sphere
			sphere = new Sphere();
			sphere.x = 100;
			sphere.y = 0;
			sphere.z = 100;
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
			//focusPanel.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		// Resize the window
		private function onResize(event:Event=null):void {
			//view.x = focusPanel.width / 2;
			//view.y = focusPanel.height / 2;
		}
		
		// Enter the frame
		private function onEnterFrame(event:Event) : void {
			//if(finishedLoadingMap){
				//camera.hover();
				
				// Change the z position of the sphere
				//sphere.z = (sphere.z + 10) % 100 - 100
				
				
				//view.render();
			//}
		}
	}
}