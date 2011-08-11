package managers
{
	import assets.PhotoAssets;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.events.MouseEvent3D;
	import away3d.tools.utils.Drag3D;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapMouseEvent;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import models.Tower;
	import models.constants.GameConstants;
	import models.interfaces.SuperObject;
	import models.map.TowerSaintMarker;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.core.BitmapAsset;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.ItemClickEvent;
	import mx.utils.ObjectUtil;
	
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.RichEditableText;
	
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
		private var _focusObject:SuperObject;								/* The object with focus */ 
		private var _queueManager:QueueManager;								/* Manager partially created objects */
		
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
			this._map = m;
			this._app = a;		
			
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
		public function get focusObject():SuperObject {
			return this._focusObject;
		}
		public function set queueManager(qM:QueueManager):void{
			this._queueManager = qM;
		}
		
		// Set the map variable
		public function set map(m:Map) : void{
			this._map = m;
			this._map.addEventListener(MapMouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		public function set listOfModels(arr:ArrayCollection) : void {
			this._listOfModels = arr;
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
		
		// Upon pressing down give focus to the event
		public function onMouseClick(e:MapMouseEvent) : void {
			var found:Boolean = false;
			for(var i:int = 0; i < this._listOfModels.length; i++){
				var s:SuperObject = this._listOfModels[i] as SuperObject;
				if(s.isVisible(this._map)){
					var p:LatLng = e.latLng;
					var bounds:LatLngBounds = s.getBounds();
					if(bounds.containsLatLng(p)){
						this.displayModel(s);
						found = true;
					}
				}
			}
			var queueFound:Boolean = false;
			if(!this._queueManager.isEmpty() && !found){
				var arr:ArrayCollection = this._queueManager.getListOfSuperObjects();
				for(var j:int = 0; j < arr.length; j++){
					var sl:SuperObject = arr[j] as SuperObject;
					if(sl.isVisible(this._map)){
						var p2:LatLng = e.latLng;
						var bbounds:LatLngBounds = sl.getBounds();
						if(bbounds.containsLatLng(p2)){

							//this._queueManager.
							var iEv:ItemClickEvent = new ItemClickEvent(ItemClickEvent.ITEM_CLICK, false, false, "Focus", j, null, null);
							this._queueManager.onQueueItemClick(iEv);
							queueFound = true;
						}
					}
				}
			}
			
			if(!found && !queueFound){
				this.removeFocus();
				this._focusObject = null;
			}
		}
		
		private function onMouseDown(e:MouseEvent3D) : void {
			/*
			if(previousTime == null){
				this.previousTime = new Date();
			}else{
				var currentTime:Date = new Date();
				var mili:Number = currentTime.valueOf() - this.previousTime.valueOf();
				
				// A double click
				if(ObjectUtil.compare(this.focusModel, e.object as ObjectContainer3D)){
					if(mili < 500){
						this.isDragging = true;
					}
				}
				this.previousTime = currentTime;
			}
			*/
			Alert.show("Mouse down");
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
			this.focusImage.source = null;
			this.hasFocus = false;
		}
		
		public function displayModel(m:SuperObject) : void {
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
			
			// Change the state of the action group
			///this._gameManager.changeState(GameManager._emptyState);
			
			// Save a reference to the focused object
			this._focusObject = m;
			
 		}
		
	}
}