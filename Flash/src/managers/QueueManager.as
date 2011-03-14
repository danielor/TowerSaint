package managers
{
	import action.ActionQueue;
	import action.ActionQueueRenderer;
	
	import models.QueueObject;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.List;

	// Manage operations that take a period of time. Effectively a list of 
	// QueueObjects that describe well-defined operations.
	public class QueueManager
	{
		public var listOfQueueObjects:ArrayCollection;
		public function QueueManager()
		{
			this.listOfQueueObjects = new ArrayCollection();
		}
		
		public function addQueueObject(q:QueueObject)
		{
			this.listOfQueueObjects.addItem(q);
		}
		
		// Update should be called in the Away3D loop(which acts as timer), so
		// as to update the queue objects. If the date expires, the queue objects
		// are removed from the list.
		public function update(d:Date){
			
			for(var i:int = 0; i < this.listOfQueueObjects.length; i++){
				var obj:QueueObject = this.listOfQueueObjects[i] as QueueObject;
				if(obj.date < d){
			
					// Update the state
					obj.updateState(d);
				}else{
					// Call the end function
					if(obj.endFunction != null){
						obj.endFunction();
					}
					
					// Remove the item at the index
					this.listOfQueueObjects.removeItemAt(i);
				}
			}
		}
		
		// Setup the ActionQueue 
		public function realizeActionQueue():ActionQueue {
			var action:ActionQueue = new ActionQueue();
			var s:List = action.actionQueue;
			
			// Setup the list
			s.dataProvider = this.listOfQueueObjects;
			s.itemRenderer = new ActionQueueRenderer();
			
			// Setup the update state
			for(var i:int = 0; i < s.dataProvider.length; i++){
				var q:QueueObject = s.dataProvider[i] as QueueObject;
				var s:ActionQueueRenderer = s.dataGroup.getElementAt(i) as ActionQueueRenderer;
				q.tieProgressBar(s.progress);
			}
			
			return action;
		}
	}
}