package managers
{
	import assets.PhotoAssets;
	
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapType;
	import com.google.maps.controls.ZoomControl;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.Polygon;
	import com.google.maps.services.ClientGeocoder;
	import com.google.maps.services.GeocodingEvent;
	import com.google.maps.services.Placemark;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import managers.EventManager;
	
	import models.interfaces.SuperObject;
	import models.Tower;
	import models.User;
	import models.map.TowerSaintMarker;
	
	import mx.containers.ControlBar;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.Spacer;
	import mx.controls.TextInput;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;
	
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.Panel;
	import spark.components.TitleWindow;
	import spark.components.VGroup;

	// The init manager initializes the user into the game. It sets up the starting location of
	// the capital of the user. Furthermore, it sets up the name of the users's empire.
	public class InitManager
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
		private var mapDimension:LatLng; 					/* The dimensions(lat, lng) of a map associated with the zoom level */
		private var scopePolygon:Polygon;					/* The polygon is drawn around the capital */
		private var buildButton:Button;						/* The button associated with leaving the manager */
		private var validInitialization:Boolean;			/* Is the new city a valid initialization */
		private var zoomControl:ZoomControl;				/* The zoom control used by the initManager to focus on a new capital */
		
		// The event handler
		private var mapEventHandler:EventManager;
		
		public function InitManager(m:Map, s:Button, uOM:UserObjectManager, a:Application, u:User, ph:PhotoAssets, fpm:GameFocusManager, bB:Button)
		{
			// Setup the constructor variables
			this.map = m;
			this.searchButton = s;
			this.userObjectManager = uOM;
			this.app = a;
			this.currentUser = u;
			this.photo = ph;
			this.fpm = fpm;
			this.buildButton = bB;
			
			// Create the current capital
			var p:LatLng = new LatLng(0., 0.);
			this.currentCapital = Tower.createCapitalAtPosition(p, this.currentUser);
			
			// Setup the map
			this.mapEventHandler = new EventManager(this.map);
			this.map.enableScrollWheelZoom();
			this.map.enableContinuousZoom();
			this.zoomControl = new ZoomControl();
			this.map.addControl(this.zoomControl);
			
			// The manager is not active
			this.activeManager = false;
			
			// Setup event listenres associated with the init manager for the map
			this.mapEventHandler = new EventManager(this.map);
			this.mapEventHandler.addEventListener(MapMouseEvent.DRAG_END, onMapDragEnd);
			this.mapEventHandler.addEventListener(MapMouseEvent.DRAG_START, onMapDragStart);

			// Setup the statep
		}
		
		// Run the initialization manager
		public function run() : void {
			// Setup up map functionality in this manager
			this.mapEventHandler.RemoveEvents();

			// The manager is now active
			this.activeManager = true;
			
			// Set up the button manager
			this.searchButton.addEventListener(MouseEvent.MOUSE_UP, onChangeLocationClick);
			this.buildButton.addEventListener(MouseEvent.MOUSE_DOWN, onBuildButton);
			this.buildButton.enabled = false;
			
			// Create the address popup associated with the location of the capital
			this.createAddressPopup();
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
			var a:Array = new Array();
			a.push(this.currentCapital);
			this.userObjectManager.saveUserObjects(a, this.currentUser, ignoreResult);

			// Save the updated production
			_updateProductionOfUser();
			this.userObjectManager.updateProduction(this.currentUser, true, ignoreResult);
			
			// Build the tower
			this.mapEventHandler.RemoveEvents();
			
			// Remove the zooming properties of the map
			this.map.disableScrollWheelZoom();
			this.map.disableContinuousZoom();
			this.map.removeControl(this.zoomControl);
			
			// Change the state
			this.app.currentState = "inApp";
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
				this.map.setCenter(loc, 10);
				this.currentCapital.updatePosition(loc);
				
				// Get the marker
				//this.currentCapital.draw(true, this.map, this.photo, this.fpm, false);

				// Set the events associated with dragging to test the whether an
				// individual can	
				var e:EventManager = this.currentCapital.getMarkerEventManager();
				e.addEventListener(MapMouseEvent.DRAG_END, this.onDragEnd);
			
				// Remove the popup
				
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
			
		}
		
		public function onGeodesicFailure(event:GeocodingEvent) : void {
			var f:FoundCity = popup as FoundCity;
			f.title = "Found your City: You have confused Google!!! Please enter a proper address";
		}
		
		// The Map interface assosciated with the initManager
		
		protected function onMapDragStart(event:MapMouseEvent) : void {
			initialMapDragMouse = event.latLng;
		}
		
		protected function onMapDragEnd(event:MapMouseEvent) : void {
			// Get the zoom level
			var zoom:Number = this.map.getZoom();
			if(zoom > 4){
				var finalDragPosition:LatLng = event.latLng;
				
				// The center of the map, and bounds
				var centerOfMap:LatLng = this.map.getCenter();
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
				
				// Update the location of the tower
				currentCapital.updatePosition(centerOfMap);
			}
		}
	}
}