	<?xml version="1.0" encoding="utf-8"?>
	<s:Application xmlns:fx="http://ns.adobe.com/mxml/2009" 
				   xmlns:s="library://ns.adobe.com/flex/spark" 
				   xmlns:mx="library://ns.adobe.com/flex/mx" 
				   xmlns:maps="com.google.maps.*" currentState="start" applicationComplete="initApp()" width="600" height="450">
		<fx:Script>
			<![CDATA[
				import assets.PhotoAssets;
				
				import away3dlite.cameras.*;
				import away3dlite.containers.*;
				import away3dlite.core.base.*;
				import away3dlite.core.render.*;
				import away3dlite.events.*;
				import away3dlite.lights.DirectionalLight3D;
				import away3dlite.materials.*;
				import away3dlite.primitives.*;
				
				import com.facebook.graph.Facebook;
				import com.facebook.graph.controls.Distractor;
				import com.google.maps.LatLng;
				import com.google.maps.LatLngBounds;
				import com.google.maps.Map;
				import com.google.maps.MapEvent;
				import com.google.maps.MapMouseEvent;
				import com.google.maps.MapMoveEvent;
				import com.google.maps.MapType;
				import com.google.maps.ProjectionBase;
				import com.google.maps.overlays.GroundOverlay;
				import com.google.maps.overlays.Marker;
				import com.google.maps.overlays.MarkerOptions;
				import com.google.maps.overlays.Polygon;
				import com.google.maps.overlays.PolygonOptions;
				import com.google.maps.styles.FillStyle;
				import com.google.maps.styles.StrokeStyle;
				
				import flash.display.*;
				import flash.events.*;
				import flash.net.*;
				import flash.utils.Dictionary;
				
				import managers.FocusPanelManager;
				import managers.UserObjectManager;
				import managers.states.TowerSaintServiceState;
				
				import models.Bounds;
				import models.Location;
				import models.Portal;
				import models.Road;
				import models.SuperObject;
				import models.Tower;
				import models.User;
				import models.states.ImageState;
				
				import mx.collections.ArrayCollection;
				import mx.controls.Alert;
				import mx.core.BitmapAsset;
				import mx.events.DragEvent;
				import mx.messaging.ChannelSet;
				import mx.messaging.channels.AMFChannel;
				import mx.rpc.AbstractOperation;
				import mx.rpc.events.FaultEvent;
				import mx.rpc.events.ResultEvent;
				import mx.rpc.remoting.RemoteObject;
				import mx.utils.ObjectProxy;
				
				
				// The facebook data
				//protected var _sessionId:FacebookSessionUtil;
				protected var _facebook:Facebook;
				protected const API_KEY:String = "19c9fe5eb3168ff03f9277a78e88d095";
				protected const SECRET:String = "7daf6801550ed6972685d7f8f52b2136";
				[Bindable] protected var _user:User;
				[Bindable] public var _friends:Array = new Array();
				
				// Away 3D data
				private var scene:Scene3D;
				private var camera:HoverCamera3D;
				private var renderer:BasicRenderer;
				private var view:View3D;
				private var light:DirectionalLight3D;
				private var listOfCannons:ArrayCollection = new ArrayCollection();
				
				// Map data			
				protected const latOffset:Number = .001;
				protected const lonOffset:Number = .001;
				private var initialMapDragCenter:LatLng;
				private var initialMapDragMouse:LatLng;
				private var userMousePan:Boolean;
				private var centerOfMap:LatLng;
				private var mapDimension:LatLng;
				
				// My Cannonball
				private var sphere:Sphere;
				
				// The image data
				[Bindable] public var _photo:PhotoAssets = new PhotoAssets();
				
				// State/Manager data
				[Bindable] public var _serverState:TowerSaintServiceState;
				[Bindable] public var _userObjectManager:UserObjectManager;
				[Bindable] public var _focusPanelManager:FocusPanelManager;
				
				// State variable
				[Bindable] private var finishedLoadingMap:Boolean = false;
				[Bindable] public var imageState:ImageState = new ImageState();
				
				// Call the JS Exeternal call to make sure that everything is functioning
				//protected var topURL:String=ExternalInterface.call('top.location.toString');
				
				// Init App
				protected function initApp() : void
				{
					Alert.show("Init");
					Facebook.setCanvasSize(700, 500);
					Facebook.setCanvasAutoResize();
					Facebook.init("142447749129831", handleInit);
					Facebook.addJSEventListener('auth.login', onAuthLogin);
					Facebook.addJSEventListener('auth.logout', onAuthLogin);
					Facebook.addJSEventListener('auth.sessionChange', onAuthLogin);
					Facebook.addJSEventListener('auth.statusChange', onAuthLogin);
					Facebook.addJSEventListener('xfbml.render', onAuthLogin);
					Facebook.addJSEventListener('edge.create ', onAuthLogin);
					Facebook.addJSEventListener('comments.add', onAuthLogin);
					Facebook.addJSEventListener('fb.log ', onAuthLogin);
					
				}
				
				// Javascript event listeners
				protected function onAuthLogin(result:Object, fail:Object): void {
					Alert.show(result.toString() + ":" +  fail.toString());
				}
				
				protected function play() : void
				{
					//Alert.show(topURL);
					//this.login();
					this.currentState = "inApp";
					init3DView();
				}
				
				protected function handleInit(success:Object, fail:Object) : void {
					Alert.show("handleInit");
					this.login();
				}
				
				protected function getMeHandler(response:Object, fail:Object) : void
				{	
					// Create the user
					var f_id:Number = parseInt(response.id);
					this._user = new User(f_id);
					
					this._userObjectManager.saveUser(this._user);
					
					// Save the text associated with the user
					fb_name.text = response.name as String;
				}
				
				protected function login() : void {
					Alert.show("Logged in with response");
					Facebook.login(loginHandler, {perms:"read_stream, publish_stream"});
				}
				
				protected function logout() : void {
					Facebook.logout(logoutHandler);
					//currentState = "start";
				}
				
				protected function loginHandler(success:Object, fail:Object) : void {
					Alert.show("Here");
					if (success) {
						Facebook.api("/me", getMeHandler);
						usrImage.source = Facebook.getImageUrl(success.uid, "small");
						//init3DView();
					} else {
						ExternalInterface.call("redirect","142447749129831", "read_stream,publish_stream","http://apps.facebook.com/TowerSaint/");
					}
				}
				
				protected function logoutHandler(response:Object, fail:Object) : void {
					
				}
				
				// Map handlers. The map handler gets called after you are logged
				// into facebook
				private function onMapReady(event:Event) : void {
					// Setup the map location
					centerOfMap = new LatLng(42.366662,-71.106262);
					this.map.setCenter(centerOfMap, 11, MapType.NORMAL_MAP_TYPE);
					
					// Calculate the bounds of the map
					var bounds:LatLngBounds = this.map.getLatLngBounds();
					mapDimension = new LatLng(bounds.getNorth() - bounds.getSouth(), bounds.getWest() - bounds.getEast());
					
					// Initialize the services needed with the server over amf
					this._focusPanelManager = new FocusPanelManager(focusImage, controlButton, bodyText, titleText, _photo);
					this._serverState = new TowerSaintServiceState();
					this._userObjectManager = new UserObjectManager(this.map, this._user, this._serverState, this._photo, this._focusPanelManager);
					//this._userObjectManager.saveUser();
					
					// Get all objects within the bounds of the server.	
					this._userObjectManager.getAllObjectsWithinBounds(bounds);				
					
					// Set an event listener upon the complete loading of the information
					this.map.addEventListener(MapEvent.TILES_LOADED, onTilesLoaded);
					this.map.addEventListener(MapMouseEvent.CLICK, onMapMouseClick);
					this.map.addEventListener(MapMouseEvent.DRAG_START, onMapDragStart);
					this.map.addEventListener(MapMouseEvent.DRAG_END, onMapDragEnd);
					this.map.addEventListener(MapMoveEvent.MOVE_END, onMapMoveEnd);
				}
				
				// The drag events
				private function onMapDragStart(event:MapMouseEvent) : void {
					initialMapDragMouse = event.latLng;
				}
				
				private function onMapDragEnd(event:MapMouseEvent) : void {
					var finalDragPosition:LatLng = event.latLng;
					
					// The center of the map, and bounds
					var center:LatLng = this.map.getCenter();
					var bounds:LatLngBounds = this.map.getLatLngBounds();
					
					// Calculate the net distance to move
					
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
					if(userMousePan == true && event.latLng.equals(centerOfMap)){
						// Load all of the data in the new location
						var b:LatLngBounds = this.map.getLatLngBounds();
						this._userObjectManager.getAllObjectsWithinBounds(b);
						
						// The user mouse pan
						userMousePan = false;
					}
				}
				
				// Create the basic polygon
				private function createBasicScopePolygon(loc:LatLng) : void {
					var latlng:LatLng = loc
					var lat:Number = latlng.lat();
					var lon:Number = latlng.lng();
					var polygon:Polygon = new Polygon([
						new LatLng(lat - latOffset, lon - lonOffset),
						new LatLng(lat - latOffset, lon + lonOffset),
						new LatLng(lat + latOffset, lon + lonOffset),
						new LatLng(lat + latOffset, lon - lonOffset),
						new LatLng(lat - lonOffset, lon - lonOffset)
					], 
						new  PolygonOptions({ 
							strokeStyle: new StrokeStyle({
								color: 0x0000ff,
								thickness: 10,
								alpha: 0.7}), 
							fillStyle: new FillStyle({
								color: 0x0000ff,
								alpha: 0.7})
						}));
					map.addOverlay(polygon);
				}
				
				
				
				private function onMapMouseClick(event:MapMouseEvent) : void {
					if(imageState.isClicked){
						// The image state
						imageState.isClicked = false;
						
						// The location
						var pos:LatLng = event.latLng;
						var obj:SuperObject = imageState.endObject as SuperObject;
						
						// The draw function
						obj.setPosition(pos);
						obj.draw(true, this.map, _photo, this._focusPanelManager);
						obj.setIsModified(true);
						
						// The control button for sending info
						controlButton.name = "Submit"
					}
				}
				
				private function onTilesLoaded(event:MapEvent) : void {
					finishedLoadingMap = true;
				}
				
				
				private function onControlButtonClicked(event:MouseEvent) : void{
					var but:Button = event.currentTarget as Button;
					if(but.name == "Submit"){
						
					}
				}
				
				
				// Button handlers for the create amf objects
				protected function onImageClick(event:MouseEvent) : void {
					imageState.isClicked = true;
					var im:Image = event.currentTarget as Image;
					
					if(im.id == "towerImage"){
						imageState.endObject = new Tower();
					}else if(im.id == "portalImage"){
						imageState.endObject = new Portal();
					}else if(im.id == "roadImage"){
						imageState.endObject = new Road();
					}
				}
				
				// Away3D information
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
					
					var towerIcon:BitmapAsset = new _photo.cannonMaterial() as BitmapAsset;
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
					addEventListener(Event.ENTER_FRAME, onEnterFrame);
					focusPanel.addEventListener(Event.RESIZE, onResize);
					onResize();
				}
				
				// Resize the window
				private function onResize(event:Event=null):void {
					view.x = focusPanel.width / 2;
					view.y = focusPanel.height / 2;
				}
				
				// Enter the frame
				private function onEnterFrame(event:Event) : void {
					if(finishedLoadingMap){
						//camera.hover();
						
						// Change the z position of the sphere
						//sphere.z = (sphere.z + 10) % 100 - 100
						
						
						//view.render();
					}
				}
				
				
				
				protected function onSendButtonClicked(event:MouseEvent) : void {
					// The network connection
					var netConnection:NetConnection = new NetConnection();
					netConnection.connect("http://towersaint.appspot.com/");
					
					// The responseder
					//var responder:Responder = new Responder(onSendButtonComplete, onSendButtonFail);
					//netConnection.call("myservice.echo", responder, sendServer.text);
				}
				
				/*	protected function onSendButtonComplete(results : String): void {
				reponseServer.text = results;	
				}
				
				protected function onSendButtonFail(results : Object) : void {
				for each(var thisResult in results){
				reponseServer.text += thisResult;
				}
				}*/
			]]>
		</fx:Script>
		<s:states>
			<s:State name="inApp"/>
			<s:State name="start"/>
		</s:states>
		<fx:Declarations>
			<!-- Place non-visual elements (e.g., services, value objects) here -->
		</fx:Declarations>
		
		<s:Label includeIn="inApp" id="fb_name"  left="100" top="10"/>
		<mx:Image includeIn="inApp" id="usrImage" top="10" left="10"/>
		<s:Button includeIn="inApp" x="462.05" y="28.95" label="Send" id="sendButton" click="onSendButtonClicked(event)"/>
		
		<s:VGroup includeIn="inApp" top="50" left="0" right="0" bottom="0">
			<s:SpriteVisualElement id="mySprite"/>
			<maps:Map id="map" width="100%" height="80%" mapevent_mapready="onMapReady(event)" key="ABQIAAAA5PSKhvT9XxMwIJsiXZLnshROkT7oJpmGVVDvh2HNZs_1KkkwNxQMSTOQJaZvC41MHmPhrh-NHIDstw" sensor="true"/>
			<s:HGroup width="100%" height="20%">
				<s:Panel width="60%" height="100%" id="focusPanel">
					<mx:Image x="10.15" y="-0.15" width="101" height="75" id="focusImage"/>
					<s:Button x="136" y="450" label="Upgrade" id="controlButton" click="onControlButtonClicked(event)"/>
					<s:RichEditableText x="133" y="5.75" width="392" height="62" id="bodyText"/>
				</s:Panel>
				<s:VGroup width="30%" height="100%">
					<s:RichEditableText x="300" y="402.05" height="75" id="titleText" width="89"/>
					<s:HGroup width="151" height="40" top="10" right="50">
						<mx:Image id = "towerImage" width="44" height="57" useHandCursor="true" buttonMode="true" click="onImageClick(event)"
								  source="@Embed(source='assets/pictures/Tower_Level0.png')"/>
						<mx:Image id = "portalImage" width="44" height="57" useHandCursor="true" buttonMode="true" click="onImageClick(event)" 
								  source="@Embed(source='assets/pictures/Portal.png')"/>
						<mx:Image id = "roadImage" width="44" height="57" useHandCursor="true" buttonMode="true" click="onImageClick(event)" 
								  source="@Embed(source='assets/pictures/NorthSouthEastWestRoad.png')"/>
					</s:HGroup>
				</s:VGroup>
			</s:HGroup>	
		</s:VGroup>
		
		<s:Button includeIn="start" x="315" y="221" label="Play" click="play()"/>
		
	</s:Application>
