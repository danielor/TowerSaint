package managers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	
	/**
	 * @daniel
	 * The event handler was found on the web. It allows the removal of all events from an objects,
	 * so that managers define their own behavior over the actionscript objects. 
	 * It was modified to add specific event manager functionality between the game
	 * managers.
	 */
	public class EventManager extends EventDispatcher
	{
		private var eventList:Array;
		private var functionMap:Dictionary;
		private var _dispatcher:*;
		public function EventManager(dispatcher:*)
		{
			eventList = new Array();
			functionMap = new Dictionary();
			_dispatcher = dispatcher;
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
		{
			eventList.push( { TYPE:type, LISTENER:onListen } );
			
			// Save the function to the function map
			if(!functionMap.hasOwnProperty(type)){			
				functionMap[type] = new Array();
			}
			
			// Make sure that the Function is unique
			if((functionMap[type] as Array).lastIndexOf(listener) == -1){
				(functionMap[type]).push(listener);

			}
			
			if (_dispatcher.hasEventListener(type))
			{
				_dispatcher.removeEventListener(type, onListen);
			}
			
			_dispatcher.addEventListener(type, onListen, useCapture, priority, useWeakReference);
		}
		
		// Function is called upon all events in the manager
		private function onListen(event:Event) : void {
			var arr:Array = this.functionMap[event.type];
			for(var i:int = 0; i < arr.length; i++){
				(arr[i])(event);
			}
		}
		
		public function RemoveEvent(type:String):void
		{
			var total:int = eventList.length ;
			for (var i:int = 0; i < total; i++)
			{
				if (eventList[i].TYPE == type)
				{
					// Remove the function map associated with the object
					var s:String = eventList[i].TYPE as String;
					delete this.functionMap[s];
					
					// Remove the dispatcher
					_dispatcher.removeEventListener(eventList[i].TYPE, eventList[i].LISTENER);
					eventList.splice(i, 1);
					total = eventList.length;                  
				}              
			}
		}
		
		
		public function RemoveEvents():void
		{
			var total:int = eventList.length ;
			for (var i:int = 0; i < total; i++)
			{
				_dispatcher.removeEventListener(eventList[i].TYPE, eventList[i].LISTENER);
			
				// Remove the function map associated with the object
				var s:String = eventList[i].TYPE as String;
				delete this.functionMap[s];
			}
			eventList = [];
		}
		
	}
}
	