package models.states
{
	import assets.PhotoAssets;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.controls.ZoomControl;
	import com.google.maps.overlays.Polygon;
	import com.google.maps.services.ClientGeocoder;
	import com.google.maps.services.GeocodingEvent;
	import com.google.maps.services.Placemark;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.formats.BaselineOffset;
	
	import managers.EventManager;
	import managers.GameFocusManager;
	import managers.PolygonBoundaryManager;
	import managers.UserObjectManager;
	
	import models.Tower;
	import models.User;
	import models.map.TowerSaintMarker;
	import models.states.events.BackgroundStateEvent;
	import models.states.events.DrawStateEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.TitleWindow;

	// Init State starts the game. It has a modified view, but it deactivates
	// the majority of the objects visible in the game.
	public class InitState implements GameState
	{
		private var map:Map;								/* A reference to the google maps reference */
		private var searchButton:Button;					/* Allows the user to shift the location by address */
		private var userObjectManager:UserObjectManager;	/* User object manager controls the game, should be called after the initManager */
		private var app:Application;						/* The application running the manager */
		private var popup:TitleWindow;						/* Popup window designed to get information from the user */
		private var activeManager:Boolean;					/* True if he manager is running the game state */
		private var currentCapital:Tower;					/* The current location of the new empire */
		private var currentUser:User;						/* The current user of the game */
		private var photo:PhotoAssets;						/* The assets to the draw the markers */
		private var fpm:GameFocusManager;					/* The manager used to inspect focus panel manager */
		private var initialMapDragMouse:LatLng;				/* The initial position associated with a map drag */
		private var scopePolygon:Polygon;					/* The polygon is drawn around the capital */
		private var buildButton:Button;						/* The button associated with leaving the manager */
		private var validInitialization:Boolean;			/* Is the new city a valid initialization */
		private var zoomControl:ZoomControl;				/* The zoom control used by the initManager to focus on a new capital */
		private var scence:Scene3D;							/* Where the capital will be drawn. */
		private var mapEventHandler:EventManager;			/* Event manager manages the state of objects */
		private var isInState:Boolean;						/* True if the value is within the current state */
		private var listOfUserModels:ArrayCollection;		/* The list of user models */
		private var pEBoundary:PolygonBoundaryManager;		/* Create a boundary */
		private var view:View3D;							/* The away3D view */
		private var firstLocation:Boolean;					/* The first location placed on the map */
		private const viewString:String = "initUser";		/* The view(app) string associated with the state */
		
		public function InitState(m:Map, s:Button, uOM:UserObjectManager, a:Application, u:User, 
					ph:PhotoAssets, fpm:GameFocusManager, bB:Button, sce:Scene3D, lOfO:ArrayCollection, v:View3D)
		{
			this.map = m;
			this.searchButton = s;
			this.userObjectManager = uOM;
			this.app = a;
			this.currentUser = u;
			this.photo = ph;
			this.fpm = fpm;
			this.buildButton = bB;
			this.scence = sce;
			this.listOfUserModels = lOfO
			this.view = v;
			this.firstLocation = true;
				
			// Out of state. Initialization of certain objects
			this.isInState = false;				
			
			// Create the current capital
			var p:LatLng = new LatLng(0., 0.);
			this.currentCapital = Tower.createCapitalAtPosition(p, this.currentUser);
		}
		
		/* GameState interface */
		public function isChatActive() : Boolean {
			return false;
		}
		public function isMapActive() : Boolean {
			return true;
		}
		public function isFocusActive():Boolean {
			return false;
		}
		public function isGameActive():Boolean {
			return false;
		}
		public function getStateString():String {
			return "init";
		}
		
		public function isActiveState():Boolean{
			return this.isInState;
		}
		public function hasView():Boolean {
			return true;
		}
		public function getViewString():String {
			return viewString;
		}
		public function getNextState():GameState {
			return null;
		}
		
		/* The actual entering/exiting of the state */
		public function enterState():void {
			this.isInState = true;
			
			// Setup the initial map state.
			// Set up the button manager
			this.searchButton.addEventListener(MouseEvent.MOUSE_UP, onChangeLocationClick);
			this.buildButton.addEventListener(MouseEvent.MOUSE_DOWN, onBuildButton);
			this.buildButton.enabled = false;
			
			// Create an event handler associated with the dragging of the map
			this.mapEventHandler = new EventManager(this.map);
			this.mapEventHandler.addEventListener(MapMouseEvent.DRAG_START, onMapDragStart);
			this.mapEventHandler.addEventListener(MapMouseEvent.DRAG_END, onMapDragEnd);
			this.mapEventHandler.addEventListener(MapMouseEvent.MOUSE_DOWN, this.fpm.onMouseClick);			
			// Create the address popup associated with the location of the capital
			this.createAddressPopup();
		}
		public function exitState() : void {
			this.isInState = false;
			this.mapEventHandler.RemoveEvents();
		}
		
		// Get the new capital
		public function getNewCapital():Tower {
			return this.currentCapital;
		}
		
		private function createAddressPopup() : void {
			// Remove the marker from the address popup
			this.currentCapital.eraseFromMap(this.map);
			
			// Setup the events for the popup
			var fc:FoundCity = new FoundCity();
			popup = fc;
			
			// Get the location button
			//this.searchButton = this.app.getChildByName("locationChanger") as Button;
			this.searchButton.addEventListener(MouseEvent.MOUSE_UP, onChangeLocationClick);
			
			// Setup up the popup
			PopUpManager.addPopUp( fc, this.app, true);
			PopUpManager.centerPopUp(fc);
			
			fc.locationButton.addEventListener(MouseEvent.MOUSE_UP, onLocationButton);
			
		}
		
		private function onBuildButton(event:MouseEvent) : void {
			this.InitializeUserAlias();
		}
		
		
		private function InitializeUserAlias() : void {
			// Create the popup
			var ua:UserAlias = new UserAlias();
			popup = ua;
			
			// Setup the popup manager
			PopUpManager.addPopUp(ua, this.app, true);
			PopUpManager.centerPopUp(ua);
			
			// Setup events on the popup
			ua.aliasButton.addEventListener(MouseEvent.MOUSE_UP, onAliasButton);
		}
		
		private function onAliasButton(event:MouseEvent) : void {
			// Extract information from the alias
			var ua:UserAlias = popup as UserAlias;
			var s:String = ua.aliasText.text;
			
			// Call the function associated with setting the user alias
			this.userObjectManager.setUserAlias(this.currentUser, s, onSetUserAlias);
		}
		
		private function onSetUserAlias(event:ResultEvent) : void {
			var b:Boolean = event.result as Boolean;
			var ua:UserAlias = this.popup as UserAlias;
			if(b){
				PopUpManager.removePopUp(popup);
				this.currentUser.alias = ua.aliasText.text;
				this.end();
			}else{
				ua.title = "User Alias: Taken";
			}
		}
		
		private function end() : void {

			// Make the tower user specific
			this.currentCapital.user = null;
			
			// Save the capital
			
			//this.userObjectManager.saveUserObjects(a, this.currentUser, ignoreResult);
			
			// Save the updated production
			_updateProductionOfUser();
			this.userObjectManager.buildObject(this.currentCapital, this.currentUser);
			this.userObjectManager.updateProduction(this.currentUser, true, ignoreResult);
			this.userObjectManager.buildObjectComplete(this.currentCapital, this.currentUser, false);
			
			// Build the tower
			this.mapEventHandler.RemoveEvents();
			
			// Remove the zooming properties of the map
			this.map.disableScrollWheelZoom();
			this.map.disableContinuousZoom();
			this.map.removeControl(this.zoomControl);
			
			// Change the state
			
			// Remove the marker from the map
			//this.currentCapital.eraseFromMap(this.map);
			
			// Go into the draw state
			var e:BackgroundStateEvent = new BackgroundStateEvent(BackgroundStateEvent.BACKGROUND_STATE);
			e.attachPreviousState(this);
			this.app.dispatchEvent(e);
			//this.app.currentState = "inApp";
		}
		
		private function _updateProductionOfUser() : void {
			// Setup the production variables
			this.currentUser.completeManaProduction = this.currentCapital.manaProduction;
			this.currentUser.completeStoneProduction = this.currentCapital.stoneProduction;
			this.currentUser.completeWoodProduction = this.currentCapital.woodProduction;
			this.currentUser.productionDate = new Date();
			this.currentUser.totalMana = 0;
			this.currentUser.totalStone = 0;
			this.currentUser.totalWood = 0;
		}
		
		private function ignoreResult(event:ResultEvent) : void {
			
		}
		
		// The change of location should cause the new location popup to happen.
		public function onChangeLocationClick(m:MouseEvent): void {
			createAddressPopup();
		}
		
		// Event manager
		public function onLocationButton(m:MouseEvent) : void {
			var f:FoundCity = popup as FoundCity;
			var s:String = f.empireLocation.text;
			if(s.length != 0){
				
				// Geocode the address inputted from the user
				var geocoder:ClientGeocoder = new ClientGeocoder();
				geocoder.addEventListener(GeocodingEvent.GEOCODING_SUCCESS, onGeodesicSuccess);
				geocoder.addEventListener(GeocodingEvent.GEOCODING_FAILURE, onGeodesicFailure);
				geocoder.geocode(s);
				
			}else{
				f.title = "Found your City: Put some meat on your location!";
			}
		}
		
		public function onGeodesicSuccess(event:GeocodingEvent) : void {
			if (event.response.placemarks.length > 0) {
				PopUpManager.removePopUp(popup);
				// Set the placemarks
				var p:Placemark = event.response.placemarks[0];
				var loc:LatLng = new LatLng(p.point.lat(), p.point.lng());
				
				// Change the location of the 
				this.map.setCenter(loc, 16);
				this.currentCapital.updatePosition(loc);
				
				if(this.firstLocation){
					this.currentCapital.draw(true, this.map, this.photo, this.fpm, true, this.scence, this.view);
					this.listOfUserModels.addItem(this.currentCapital);
					this.currentCapital.addEventListener(MapMouseEvent.DRAG_END, this.onDragEnd);
					this.firstLocation = false;
				}else{
					// Create a *drag* event to update all of the state information	
					var m:MapMouseEvent = new MapMouseEvent(MapMouseEvent.DRAG_END, this.currentCapital, loc);
					this.currentCapital.onTowerDragEnd(m);
				}
				
				// Check if the marker is at a reasonable position.
				this.userObjectManager.satisfiesMinimumDistance(loc, onSatisfiesMinimumDistance);
			}
		}
		
		public function onDragEnd(event:MapMouseEvent) : void {
			// Get the marker
			var marker:TowerSaintMarker = this.currentCapital.getMarker();
			var location:LatLng = marker.getLatLng();
			
			// Check if the marker is at a reasonable position.
			this.userObjectManager.satisfiesMinimumDistance(location, onSatisfiesMinimumDistance);
		}
		
		private function onSatisfiesMinimumDistance(event:ResultEvent) : void {
			// Set focus on the capital if one suceeds
			var b:Boolean = event.result as Boolean;
			this.currentCapital.setFocusOnObject(b);
			this.buildButton.enabled = !b;
			this.currentCapital.atValidLocation = !b;
		}
		
		public function onGeodesicFailure(event:GeocodingEvent) : void {
			var f:FoundCity = popup as FoundCity;
			f.title = "Found your City: You have confused Google!!! Please enter a proper address";
		}
		
		// The Map interface assosciated with the initManager
		
		protected function onMapDragStart(event:MapMouseEvent) : void {
			initialMapDragMouse = event.latLng;
			
			// Send an event to the tower as if it is to be dragged
			var m:MapMouseEvent = new MapMouseEvent(MapMouseEvent.DRAG_START, this.currentCapital, this.initialMapDragMouse);
			this.currentCapital.onTowerDragStart(m);
		}
		
		protected function onMapDragEnd(event:MapMouseEvent) : void {
			// Get the zoom level
			var zoom:Number = this.map.getZoom();
			if(zoom > 4){
				var finalDragPosition:LatLng = event.latLng;
				
				// The center of the map, and bounds
				var centerOfMap:LatLng = this.map.getCenter();
				var bounds:LatLngBounds = this.map.getLatLngBounds();
				var mapDimension:LatLng = new LatLng(bounds.getNorth() - bounds.getSouth(), bounds.getWest() - bounds.getEast());
				
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
				
				// Update the location of the tower
				currentCapital.updatePosition(centerOfMap);
				
				// Dispatch an event to end the "dragging" of the capital
				// Send an event to the tower as if it is to be dragged
				var m:MapMouseEvent = new MapMouseEvent(MapMouseEvent.DRAG_END, this.currentCapital, centerOfMap);
				this.currentCapital.onTowerDragEnd(m);
				
				// Find out if the position is reasonable or not
				// Check if the marker is at a reasonable position.
				this.userObjectManager.satisfiesMinimumDistance(centerOfMap, onSatisfiesMinimumDistance);
			}
		}
	
	}
}