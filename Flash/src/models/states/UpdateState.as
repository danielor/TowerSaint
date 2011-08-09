package models.states
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import flash.utils.Dictionary;
	
	import managers.EventManager;
	import managers.QueueManager;
	import managers.UserObjectManager;
	
	import models.Bounds;
	import models.User;
	import models.interfaces.SuperObject;
	import models.states.events.DrawStateEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import spark.components.Application;

	// Update state ask the server to update all of the objects within the bounds of the map
	public class UpdateState implements GameState
	{
		private var map:Map;										/* The map */
		private var mapEventManager:EventManager;					/* The map event manager */
		private var isInState:Boolean;								/* Flag determines if in this state */
		private const viewString:String = 'inApp';					/* The view associated with the state */
		private var user:User;										/* The current user */
		private var listOfUserModels:ArrayCollection;				/* List of user */
		private var userObjectManager:UserObjectManager;			/* The manager of objects */
		private var app:Application;								/* The application that runs this state */
		private var arrayOfBounds:ArrayCollection;					/* Array of bounds */
		private var modelDictionary:Dictionary;						/* Dictionary stores the objects on the map */
		private var queueManager:QueueManager;						/* The queue manager for building objects */
		public function UpdateState(m:Map, u:User, lOfO:ArrayCollection, uOM:UserObjectManager, a:Application,
						qm:QueueManager)
		{
			this.map = m;
			this.user = u;
			this.listOfUserModels = lOfO;
			this.userObjectManager = uOM;
			this.app = a;
			this.queueManager = qm;
			this.isInState = false;
			
			// Initialize the data
			this.arrayOfBounds = new ArrayCollection();
		}
		
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
		public function getStateString():String {
			return "update";
		}
		
		public function isGameActive():Boolean
		{
			return true;
		}
		
		public function enterState():void
		{
			this.isInState = true;
			
			// Get the current bound
			var bound:LatLngBounds = this.map.getLatLngBounds();
			var b:Bounds = new Bounds();
			b.fromGoogleBounds(bound);
	
			if(this.arrayOfBounds.getItemIndex(bound) == -1){
				//this.userObjectManager.get(this.user, onGetUserObjects);
				this.userObjectManager.getObjectInBounds(b, this.onGetUserObjects);
			}else{
				// Dispatch an event to the draw state
				var dSE:DrawStateEvent = new DrawStateEvent(DrawStateEvent.DRAW_STATE);
				dSE.attachPreviousState(this);
				this.app.dispatchEvent(dSE);
				
			}
			
		}
		
		public function onGetUserObjects(event:ResultEvent) : void {
			var arr:ArrayCollection = event.result as ArrayCollection;
			// Get the first object, and draw it on the map. It should be the capital
			if(arr.length != 0){
				var obj:SuperObject = arr.getItemAt(0) as SuperObject;
				var bounds:LatLngBounds = this.map.getLatLngBounds();
				var pos:LatLng = obj.getPosition(this.map.getLatLngBounds());
				if(this.listOfUserModels.length == 0){
					this.map.setCenter(pos);
				}
				// Get the new bounds after recentering the position.
				bounds = this.map.getLatLngBounds();
				
				// Dereference the user
				this.user = this.user.cloneUser();
				var found:Boolean;
				for(var i:int = 0; i < arr.length; i++){
					var sobj:SuperObject = arr.getItemAt(i) as SuperObject;
					sobj.setUser(null);
					
					// Check if the object has *not* completed building. If it has not,
					// and exists in the queue. There is no need to add it.
					if(!this.queueManager.isInQueue(sobj)){
						
						// A specialized comparison needs to be performed because the current object
						// is an indeterminate state. So, when comparing an incoming object with an
						// existing object it is *essential* to only compare the information that is
						// stored on the server.
						found = false;
						for(var j:int = 0; j < this.listOfUserModels.length; j++){
							var s:SuperObject = this.listOfUserModels[j] as SuperObject;
							//Alert.show(s.display().getText() + ":\n" + sobj.display().getText());
							if(s.statelessEqual(sobj)){
								found = true;
								break;
							}
						}
						if(!found){
							this.listOfUserModels.addItem(sobj);
						}
					}
				}
				
				// Save the bound
				this.arrayOfBounds.addItem(bounds);
			}
			
		
			
			// Dispatch an event to the draw state
			var dSE:DrawStateEvent = new DrawStateEvent(DrawStateEvent.DRAW_STATE);
			dSE.attachPreviousState(this);
			this.app.dispatchEvent(dSE);

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
			return true;
		}
		
		public function getViewString():String
		{
			return this.viewString;
		}
		
		public function getNextState():GameState
		{
			return null;
		}
	}
}