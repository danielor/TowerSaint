package managers
{
	import action.ActionQueue;
	import action.ActionQueueRenderer;
	import action.BuildActionGroup;
	import action.BuildInspectPopup;
	
	import assets.PhotoAssets;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.elements.TextFlow;
	
	import models.QueueObject;
	import models.interfaces.SuperObject;
	import models.states.events.BuildStateEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.TitleWindow;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.ProgressBar;
	import mx.core.BitmapAsset;
	import mx.core.ClassFactory;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.ItemClickEvent;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.DataGroup;
	import spark.components.List;
	import spark.components.RichEditableText;
	
	import wumedia.parsers.swf.Data;

	// Manage operations that take a period of time. Effectively a list of 
	// QueueObjects that describe well-defined operations.
	public class QueueManager
	{
		public var listOfQueueObjects:ArrayCollection;				/* List of queue objects */
		public var isVisible:Boolean;								/* Boolean variable which determines whether something is visible */								
		public var currentQueue:ActionQueue;						/* The current queue of objects */
		public var app:Application;									/* The application that runs me */
		public var photo:PhotoAssets;								/* The  visual game objects */
		public var gameManager:GameManager;							/* The manager of all the game states */
		
		// State information
		private var currentList:List;								/* The current list of the view */
		private var popup:BuildInspectPopup;						/* Reference to the inpsect popup */
	    private var selectedIndex:int;								/* The index selected from the queue */
		
		public function QueueManager(a:Application, p:PhotoAssets, gm:GameManager)
		{
			// Save a reference to the application
			this.app = a;
			this.photo = p;
			this.gameManager = gm;
			
			// Initialize state/structures
			this.listOfQueueObjects = new ArrayCollection();
			this.popup = null;
			this.isVisible = false;
			this.currentQueue = null;
		}
		
		public function addQueueObject(q:QueueObject) : void
		{
			this.listOfQueueObjects.addItem(q);
		}
		
		// Update should be called in the Away3D loop(which acts as timer), so
		// as to update the queue objects. If the date expires, the queue objects
		// are removed from the list.
		public function update(d:Date) : void{
	
			for(var i:int = 0; i < this.listOfQueueObjects.length; i++){
				var obj:QueueObject = this.listOfQueueObjects[i] as QueueObject;
				if(obj.isActive){
					if(obj.date > d){
				
						// Update the state
						obj.updateState(d);
					}else{
						// Change to the build state to finish building the object
						var b:BuildStateEvent = new BuildStateEvent(BuildStateEvent.BUILD_COMPLETE);
						b.listOfQueueObjects = new ArrayCollection([obj]);
						b.attachPreviousState(this.gameManager.getActiveState());
						this.app.dispatchEvent(b);
						/*
						if(obj.endFunction != null){
							obj.endFunction(obj.buildObject);
						}
						*/
						// Remove the item at the index
						obj.isActive = false;
					}
				}
			}
			
			if(this.currentQueue != null && this.listOfQueueObjects.length != 0 && this.hasActiveQueueObjects()){
				var s:List = this.currentQueue.actionQueue;
				var data:DataGroup = s.dataGroup;
				var vec:Vector.<int> = data.getItemIndicesInView();
				for(var j:int = 0; j < vec.length; j++){
					var index:int = vec[j];
					
					// Get the queue object and the item rendere
					var item:ActionQueueRenderer = data.getElementAt(index) as ActionQueueRenderer;
					
					// Update the progress bar
					var q:QueueObject = item.data as QueueObject;
					var progress:ProgressBar = item.progress;
					progress.setProgress(q.percentComplete, 1.0);
				}
				
				// If the popup is open update it!
				if(this.popup != null){
					// Get the progress bar from the current popup
					var bIP:BuildInspectPopup = this.popup as BuildInspectPopup;
					var p:ProgressBar = bIP.progress;
					
					// Update manually the progress bar.
					var tieIndex:int = vec[this.selectedIndex];
					var tq:QueueObject = this.listOfQueueObjects[tieIndex] as QueueObject;
					p.setProgress(tq.percentComplete, 1.0);
				}
			}
		
		}
		
		// Check if it has a superobject in queue
		public function hasSuperObject(s:SuperObject):Boolean {
			for(var j:int = 0; j < this.listOfQueueObjects.length; j++){
				var q:QueueObject = this.listOfQueueObjects[j] as QueueObject;
				if(ObjectUtil.compare(q.buildObject, s) == 0){
					return true;
				}
			}
			return false;
		}
		
		// Check if it has active members
		private function hasActiveQueueObjects():Boolean {
			for(var i:int = 0; i < this.listOfQueueObjects.length; i++){
				var q:QueueObject = this.listOfQueueObjects[i] as QueueObject;
				if(q.isActive){
					return true;
				}
			}
			return false;
		}
		
		// Returns true if a superobject is in the queue
		public function isInQueue(s:SuperObject) : Boolean {
			for(var i:int = 0; i < this.listOfQueueObjects.length; i++){
				var obj:QueueObject = this.listOfQueueObjects[i] as QueueObject;
				var sObj:SuperObject = obj.buildObject;
				if(s.statelessEqual(sObj)){
					return true;
				}
			}
			return false;
		}
		
		
		// Returns true if the queue is empty
		public function isEmpty():Boolean {
			return this.listOfQueueObjects.length == 0;
		}
		
		// Returns the superobject at a position
		public function getQueueObjectAtPosition(pos:LatLng, m:Map):QueueObject {
			var q:QueueObject;
			var bounds:LatLngBounds = m.getLatLngBounds();
			
			// Search for the positions of the super object
			for(var i:int = 0; i < this.listOfQueueObjects.length; i++){
				var tempQ:QueueObject = this.listOfQueueObjects[i] as QueueObject;
				var buildObject:SuperObject = tempQ.buildObject;
		
				var cPos:LatLng = buildObject.getPosition(bounds);
				if(cPos.equals(pos)){
					q = tempQ;
					break;
				}
			}
			return q;
		}
		
		// Remove queue object from the queue. End of the queue life cycle
		public function removeFromQueue(q:QueueObject) : void {
			for(var i:int = 0; i < this.listOfQueueObjects.length; i++){
				var t:QueueObject = this.listOfQueueObjects[i] as QueueObject;
				if(ObjectUtil.compare(t, q) == 0){
					this.listOfQueueObjects.removeItemAt(i);
				}
			}
		}
		
		// Get an array Collection of provisional items in the queue
		public function getListOfSuperObjects():ArrayCollection {
			var arr:ArrayCollection = new ArrayCollection();
			for(var i:int = 0; i < this.listOfQueueObjects.length; i++){
				var obj:QueueObject = this.listOfQueueObjects[i] as QueueObject;
				arr.addItem(obj.buildObject);
			}
			return arr;
		}
		
		// Setup the ActionQueue 
		public function realizeActionQueue():ActionQueue {
			// Change the manager state
			this.isVisible = true;
			
			// Create an action queue
			var act:ActionQueue = new ActionQueue();
			var s:List = act.actionQueue;
			
	
			// Setup the list
			s.dataProvider = this.listOfQueueObjects;
			s.itemRenderer = new ClassFactory(ActionQueueRenderer);

			
			this.currentQueue = act;

			// Setup the events
			s.addEventListener(FlexEvent.CREATION_COMPLETE, onListInitialize);
			this.currentList = s;
			
			return act;
		}
		
		private function onListInitialize(event:FlexEvent) : void {
			var s:List = event.target as List;
			this.currentList.addEventListener(ItemClickEvent.ITEM_CLICK, onQueueItemClick);
		}
		
		// When the item is clicked create a popup with all of the relevant information.
		public function onQueueItemClick(event:ItemClickEvent) : void {
			// Create/Center/Add popup
			var b:BuildInspectPopup = new BuildInspectPopup();
			popup = b;
			PopUpManager.addPopUp(b, this.app, true);
			PopUpManager.centerPopUp(b);
			b.addEventListener(CloseEvent.CLOSE, onClosePopup);
			
			// Get the index/queue object of the click event
			var i:int = event.index;
			this.selectedIndex = i;
			var q:QueueObject = this.listOfQueueObjects[i] as QueueObject;
			var s:SuperObject = q.buildObject;
			
			// Get the data associated with the superobject
			var t:TextFlow = s.display();
			var bA:BitmapAsset = s.getImage(this.photo);
			
			// Add the inspect information of the new object
			var focusImage:Image = popup.focusImage;
			var bodyText:RichEditableText = popup.bodyText;
			focusImage.source = bA;
			bodyText.textFlow = t;
			popup.description.text = q.description;
			
			// Set up the progress bar.
			var queue:ProgressBar = popup.progress;

			// Setup the buttons/events
			var cancelButton:Button = popup.cancelButton;
			var okButton:Button = popup.okButton;
			cancelButton.addEventListener(MouseEvent.CLICK, onPopupCancelButton);
			okButton.addEventListener(MouseEvent.CLICK, onClosePopup);
			
		}
		 
		private function onPopupCancelButton(event:Event) : void {
			// Remove the popup
			PopUpManager.removePopUp(this.popup);
			
			// Return to the previous state
			this.popup = null;
			
			// Get the index
			var s:List = this.currentQueue.actionQueue;
			var data:DataGroup = s.dataGroup;
			var vec:Vector.<int> = data.getItemIndicesInView();
			var tieIndex:int = vec[this.selectedIndex];
			var tq:QueueObject = this.listOfQueueObjects[tieIndex] as QueueObject;
			
			// Call the queue object
			this.listOfQueueObjects.removeItemAt(tieIndex);
			
			var b:BuildStateEvent = new BuildStateEvent(BuildStateEvent.BUILD_CANCEL);
			b.listOfQueueObjects = new ArrayCollection([tq]);
			b.attachPreviousState(this.gameManager.getActiveState());
			this.app.dispatchEvent(b);
			//tq.failureFunction(tq.buildObject, tq.percentComplete);
			
		}
		

		
		// Remove the popup from the screen. Return to a previous state
		private function onClosePopup(event:Event) : void {
			PopUpManager.removePopUp(this.popup);
			
			// Return to the previous state
			this.popup = null;
		}
		
		// Undo the ActionQueue
		public function exitState() : void {
			this.currentQueue = null;
			this.isVisible = false;
		}
	}
}