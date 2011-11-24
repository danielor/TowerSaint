package managers
{
	import action.FocusList;
	
	import assets.PhotoAssets;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.tools.utils.Drag3D;
	
	import character.CharacterManager;
	import character.away3D.FocusCircle;
	import character.intefaces.NPCFunctionality;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapMouseEvent;
	
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import models.QueueObject;
	import models.Road;
	import models.Tower;
	import models.constants.GameConstants;
	import models.interfaces.FilteredObject;
	import models.interfaces.SuperObject;
	import models.interfaces.UserObject;
	import models.map.TowerSaintMarker;
	import models.states.BuildState;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.Menu;
	import mx.core.BitmapAsset;
	import mx.core.ClassFactory;
	import mx.events.CloseEvent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.ItemClickEvent;
	import mx.events.MenuEvent;
	import mx.managers.CursorManager;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.List;
	import spark.components.RichEditableText;
	import spark.components.TitleWindow;
	import spark.components.supportClasses.ItemRenderer;
	
	// The Game focus manager, shows a visual manifestation of the focused object(atm it is text)
	// and allows for specific manipulation of the focused object.
	public class GameFocusManager
	{
		// The display objects of the focus panel
		public var focusImage:Image;
		public var bodyText:RichEditableText;
		public var titleText:RichEditableText;
		
		// The photo assets
		public var _photo:PhotoAssets;
		
		private var hasFocus:Boolean;										/* Does an object have focus */
		private var _listOfModels:ArrayCollection;							/* The list of models associated with the game */
		private var focusModel:ObjectContainer3D;							/* The model that has been clicked */
		private var previousTime:Date;										/* The previous date */
		private var isDragging:Boolean;										/* Boolean variable for draggin */
		private var _map:Map;												/* The google map which runs the game */
		private var _app:Application;										/* The application running the manager */
		private var _drag3D:Drag3D;											/* Drag focused objects in a plane */
		private var _gameManager:GameManager;								/* The game manager */
		private var _focusObject:UserObject;								/* The object with focus */ 
		private var _queueManager:QueueManager;								/* Manager partially created objects */
		private var _focusView:FocusCircle;									/* The graphical representation of focus */
		private var _view:View3D;											/* The view that draws all of the data */
		private var _scene:Scene3D;											/* The scene that draws all of the data */
		private var _focusLatLng:LatLng;									/* The position of focus in the game */
		private var _foundObjects:ArrayCollection;							/* The objects found at the focus point */
		private var _charManager:CharacterManager;							/* The manager of characters */
		private var _focusMenu:Menu;										/* Focus menu allows one to select one of multiple objects */
		private var _focusMenuXML:XML;										/* Focus menu xml - contains the items to be used */
		private var _popup:TitleWindow;										/* Active popup reference */
		private var _userObjectList:List;									/* The  user object list */
		private var _userObjectEventManager:EventManager;					/* The event manager of the user object list */
		private var _buildState:BuildState;									/* The build state */
		public function GameFocusManager(fI:Image, bT:RichEditableText, tT:RichEditableText, 
										  p:PhotoAssets, m:Map, a:Application)
		{
			// The panel
			this.focusImage = fI;
			this.bodyText = bT;
			this.titleText = tT;
			
			// The photo assets
			this._photo = p;
			this.hasFocus = false;
			this.previousTime = null;
			this.isDragging = false;
			this._focusObject = null;
			this._map = m;
			this._app = a;	
			this._focusView = null;
			this._focusMenuXML = new XML();
			this.setUpXML();
		}
		
		// Setup the xml document
		private function setUpXML():void {
			var xml:XML = <root></root>
			this._focusMenuXML = xml;
		}
		
		// Interface to the drag object
		public function set drag3D(d:Drag3D):void {
			this._drag3D = d;
		}
		public function set gameManager(gM:GameManager):void {
			this._gameManager = gM;
		}
		public function get drag3D():Drag3D {
			return this._drag3D;
		}
		public function get focusObject():UserObject {
			return this._focusObject;
		}
		public function get focusActive():Boolean {
			return this.hasFocus;
		}
		public function set queueManager(qM:QueueManager):void{
			this._queueManager = qM;
		}
		public function set view(v:View3D):void {
			this._view = v;
		}
		public function set scene(s:Scene3D):void {
			this._scene = s;
		}
		public function set map(m:Map) : void{
			this._map = m;
			this._map.addEventListener(MapMouseEvent.MOUSE_MOVE, onMouseMove);
		}
		public function set listOfModels(arr:ArrayCollection) : void {
			this._listOfModels = arr;
		}
		public function set characterManager(c:CharacterManager):void {
			this._charManager = c;
		}
		public function set userObjectList(l:List):void {
			this._userObjectList = l;
		}
		public function set userObjectEventManager(uOEM:EventManager):void {
			this._userObjectEventManager = uOEM;
		}
		public function set buildState(b:BuildState):void {
			this._buildState = b;
		}
		
		// Called when the user model chnges
		public function onCollectionChange(e:CollectionEvent) : void {
			// Add the event listeners when the collection is added to
			if(e.kind == CollectionEventKind.ADD || e.kind == CollectionEventKind.REPLACE){
				for(var i:int = 0; i < e.items.length; i++){
					var currentValue:Object = e.items[i];
					/*
					if(currentValue is ObjectContainer3D){
						var obj:ObjectContainer3D = currentValue as ObjectContainer3D;
			
						//obj.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDown);
						//obj.addEventListener(MouseEvent3D.MOUSE_UP, onMouseUp);
					}
					*/
					if(currentValue is Tower){
						var tower:Tower = currentValue as Tower;
					}
				}
			}
		}
		
		// Is the focus object?
		public function isFocusObject(o:UserObject):Boolean {
			return ObjectUtil.compare(o, this._focusObject) == 0;
		}
		
		// Update the focus circle to vector
		public function updateViewAtPosition(v:Vector3D):void {
			var p:Point = new Point(v.x, v.y);
			this._focusView.changeFocusToPoint(p);
		}
		
		// Realize the focus of the selected object
		private function _realizeFocus(o:Object):void {
			if(this._focusObject is NPCFunctionality){
				var np:NPCFunctionality = this._focusObject as NPCFunctionality;
				if(np.canUsurpObjectList()){
					this._gameManager.resetBuildObjectListEvents();
				}
			}
			
			if(o is SuperObject){
				var s:SuperObject = o as SuperObject;
				// TODO: Possible change of interface.
				if(s is Road){
					var r:Road = s as Road;
					if(r.isOnRoad(this._focusLatLng)){
						this.displayModel(s);
					}
				}else{
					var bounds:LatLngBounds = s.getBounds();
					if(bounds.containsLatLng(this._focusLatLng)){
						this.displayModel(s);
					}
				}
			}else if(o is QueueObject){
				var q:QueueObject = o as QueueObject;
				var j:int = this._queueManager.listOfQueueObjects.getItemIndex(q);
				var iEv:ItemClickEvent = new ItemClickEvent(ItemClickEvent.ITEM_CLICK, false, false, "Focus", j, null, null);
				this._queueManager.onQueueItemClick(iEv);
			}else if(o is NPCFunctionality){
				var npc:NPCFunctionality = o as NPCFunctionality;
				this.displayModel(npc);
				
				// Are we to modififying the user object list
				if(npc.canUsurpObjectList()){
					var dp:ArrayCollection = npc.provideOLDataProvider(this._photo);
					var it:ClassFactory = npc.getObjectListRenderer();
				
					this._userObjectList.dataProvider = dp;
					this._userObjectList.itemRenderer = it;
					
					// Attach the event
					this._userObjectEventManager.RemoveEvents();
					this._userObjectEventManager.addEventListener(ItemClickEvent.ITEM_CLICK, onModifiedFocusItemClick);

				}
			}
		}
		
		// On a modified focus item click.
		public function onModifiedFocusItemClick(event:ItemClickEvent):void {
			if(this._focusObject is NPCFunctionality){
				var npc:NPCFunctionality = this._focusObject as NPCFunctionality;
				var obj:Object = npc.changeToState(event, "Build", this._app);
				if(obj is SuperObject){
					var s:SuperObject = obj as SuperObject;
					this._buildState.newBuildObject = s;
				}
				Alert.show("Finished Focus");
				//npc.realizeModifiedFocusClick(this._app, this._gameManager);
			}
		}
		
		// Activate the menu selector
		private function _activateMenuObjectSelector(arr:ArrayCollection):void{
			// Get the global position
			var mousePoint:Point = new Point(this._app.mouseX, this._app.mouseY);
					
			// Reset the xml
			var menu:ArrayCollection = new ArrayCollection();
	
			for(var i:int = 0; i < arr.length; i++){
				// Get the focus menu string
				var s:String = this._getFocusMenuString(arr[i]);
				
				// Add the relevant information to the XML document
				menu.addItem({'label':s});
			
			}
			
			// Create the focus list
			var fL:FocusList = new FocusList();
			this._popup = fL;

			// Add to the popupmanager
			PopUpManager.addPopUp(fL, this._app, true);
			
			fL.x = this._app.mouseX;
			fL.y = this._app.mouseY;
			// Set the data and events
			fL.nameList.dataProvider = menu;
			fL.addEventListener(ItemClickEvent.ITEM_CLICK, onFocusListItemClick);
			fL.cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			fL.addEventListener(CloseEvent.CLOSE, onFocusListClose);
		}
		
		// The focus list close
		private function onFocusListClose(evt:CloseEvent):void {
			PopUpManager.removePopUp(_popup);
		}
		
		// Get the function to click
		private function onCancelButtonClick(evt:MouseEvent):void{
			PopUpManager.removePopUp(_popup);
		}
		
		// Upon the focus click
		private function onFocusListItemClick(evt:ItemClickEvent):void {
			var index:Number = evt.index;
			this._realizeFocus(this._foundObjects[index]);
			PopUpManager.removePopUp(this._popup);
		}
		
		// Returns the string label for the menu.
		private function _getFocusMenuString(obj:Object):String{
			var s:String = "";
			var uO:UserObject = obj as UserObject;
			s+= uO.getNameString();
			
			// Specialized functionality for characeters
			if(uO is NPCFunctionality){
				var npc:NPCFunctionality = uO as NPCFunctionality;
				s += ":" + npc.getCharacterName();
			}
			return s;
		}
		
		// Choose the focus of an object
		private function onFocusMenuClick(event:MenuEvent):void {
			for(var i:int = 0; i < this._foundObjects.length; i++){
				var obj:Object = this._foundObjects[i];
				var s:String = _getFocusMenuString(obj);
				if(s == event.item.@label){			// Compare the xml label
					this._realizeFocus(obj);
				}
			}
			this._focusMenu.hide();
		}
		
		// Lose focus from the map event
		public function loseFocus():void {
			if(this._focusObject is NPCFunctionality){
				var npc:NPCFunctionality = this._focusObject as NPCFunctionality;
				if(npc.canUsurpObjectList()){
					this._gameManager.resetBuildObjectListEvents();
				}
			}
			this.removeFocus();
			this._focusObject = null;
		}
		
		// Upon pressing down give focus to the event
		public function setFocusFromMapEvent(e:MapMouseEvent) : void {
			this._foundObjects = new ArrayCollection();
			this._focusLatLng = e.latLng;
			var p:Point = GameConstants.fromMapToAway3D(this._focusLatLng, this._map);
			for(var i:int = 0; i < this._listOfModels.length; i++){
				var s:SuperObject = this._listOfModels[i] as SuperObject;
				if(s.isCloseToPoint(p)){
					this._foundObjects.addItem(s);
				}
			}
			var arr:ArrayCollection = this._queueManager.listOfQueueObjects
			for(var j:int = 0; j < arr.length; j++){
				var q:QueueObject = arr[j] as QueueObject
				var sl:SuperObject = q.buildObject;
				if(s.isCloseToPoint(p)){
					this._foundObjects.addItem(q);
				}
			}
			this._charManager.findCharactersCloseToPoint(p, this._map, this._foundObjects);
			if(this._foundObjects.length > 1){
				this._activateMenuObjectSelector(this._foundObjects);
			}else if(this._foundObjects.length == 1){
				this._realizeFocus(this._foundObjects[0]);
			}
		}
		
		private function onMouseDown(e:MouseEvent3D) : void {
	
			this.isDragging = true;
			this.focusModel = e.object as ObjectContainer3D;
			this.attachFocus(this.focusModel);
			this._drag3D.object3d = this.focusModel;
		}
		
		public function onMouseUp(e:MouseEvent) : void {
			if(this.isDragging){
				this.isDragging = false;
				this._drag3D.object3d = null;
			}
		}
		
		private function onMouseMove(e:MapMouseEvent) : void {
			if(this.isDragging){
				// Convert to away3D coordiates
				this._drag3D.updateDrag();

			}
		}
		
		public function onMarkerClick(event:MapMouseEvent) : void {
			// Display the model associated with the 
			var marker:TowerSaintMarker = event.currentTarget as TowerSaintMarker;

			// Display the model in the focusPanelManager
			displayModel(marker.getModel());
		}
		
		// Attach focus. Highlights the focused object. 
		public function attachFocus(obj:ObjectContainer3D) : void {
			displayModel(obj as SuperObject);
			this.hasFocus = true;
		}
		public function removeFocus() : void {
			
			// Remove the focus
			this.bodyText.textFlow = null;
			this.titleText.textFlow = null;
			this.focusImage.source = null;
			this.hasFocus = false;
			
			// Remove the focus
			if(this._focusView != null){
				var poi:Point = GameConstants.hideAWAY3DCoordinate();
				this._focusView.changeFocusToPoint(poi);
			}
			
			// Change the view focus if available.
			if(this._focusObject != null){
				this._removeViewFocus(this._focusObject, false);
			}
		}
		
		// The 3d object
		private function _removeViewFocus(m:UserObject, b:Boolean):void {
			var o:Mesh = m.get3DObject();
			if(o is FilteredObject){
				var f:FilteredObject = o as FilteredObject;
				f.changeFilterState(b);
			}
		}
		
		public function displayModel(m:UserObject) : void {
			// Get the objects from the model
			var t:TextFlow = m.display();
			var bA:BitmapAsset = m.getImage(this._photo);
			var nameString:String = m.getNameString();
			
			// Create the title textflow
			var title:TextFlow = new TextFlow();
			var pGraph:ParagraphElement = new ParagraphElement();
			var iSpan:SpanElement = new SpanElement();
			iSpan.text = nameString;
			pGraph.addChild(iSpan);
			title.addChild(pGraph);
			
			// Set the focus
			this.titleText.textFlow = title;
			this.bodyText.textFlow = t;
			this.focusImage.source = bA;
			
			// Set the focus
			this.hasFocus = true;
			
			// Draw the bounding circle
			var b:LatLngBounds = this._map.getLatLngBounds();
			var pos:LatLng = m.getPosition(b);
			
			// Create the focus view ... For now a simple representation of focus.
			if(this._focusView == null){
				var poi:Point = GameConstants.hideAWAY3DCoordinate();
				this._focusView = new FocusCircle(50, poi, this._scene);
			}
			
			// Update focus circle to object
			var p:Point = GameConstants.fromMapToAway3D(pos, this._map);
			this._focusView.changeFocusToPoint(p);
			
			// Remove the view focus
			if(this._focusObject != null){
				_removeViewFocus(this._focusObject, false);
			}
			
			// Save a reference to the focused object
			this._focusObject = m;
			
			// Change the view focus if available.
			_removeViewFocus(this._focusObject, true);
			
 		}
		
	}
}