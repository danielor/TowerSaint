package models.states
{
	import away3d.animators.PathAnimator;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	import away3d.events.AnimatorEvent;
	
	import character.intefaces.NPCFunctionality;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import managers.GameFocusManager;
	
	import models.away3D.PathBoneAnimator;
	import models.constants.GameConstants;
	import models.interfaces.SuperObject;
	import models.interfaces.UserObject;
	import models.states.events.BackgroundStateEvent;
	import models.states.events.MoveStateEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import spark.components.Application;

	public class MoveState implements GameState
	{
		private var isInState:Boolean;						/*Boolean flag if it is in state */
		private const viewString:String = "inApp";			/*The view associated with the state */ 
		private const stateString:String = "move";			/*State's string name */
		private var _moveStateEventType:String;				/* The move state associated with a model */
		private var _moveObject:UserObject;					/* The object we will move */
		private var _originalLocation:LatLng;				/* The original location of the object */
		private var _map:Map;								/* A reference to the map where the game runs */
		private var _animationList:ArrayCollection;			/* List of animators which updated dynamic objects */
		private var _targetLocation:LatLng;					/* The target location of the animation */
		private var _scene:Scene3D;							/* The scene to draw all the animations */
		private var _view:View3D;							/* The view to draw the animations */
		private var _focusManager:GameFocusManager;			/* Focus follows the moving object */
		private var _app:Application;						/* The application running the state */
		
		public function MoveState(m:Map, v:View3D, s:Scene3D, fM:GameFocusManager, app:Application)
		{
			this.isInState = false;
			this._map = m;
			this._scene = s;
			this._view = v;
			this._app = app;
			this._focusManager = fM;
			this.moveStateEventType = MoveStateEvent.MOVE_START;
			this._animationList = new ArrayCollection();
		}
		
		public function isChatActive():Boolean
		{
			return true;
		}
		
		// Set functions control the state
		public function set moveStateEventType(s:String):void {
			this._moveStateEventType = s;
		}
		public function set moveObject(s:UserObject):void {
			this._moveObject = s;	
		}
		public function set targetLocation(l:LatLng):void {
			this._targetLocation = l;
		}
		public function get animationList():ArrayCollection {
			return this._animationList;
		}
		
		public function isMapActive():Boolean
		{
			return true;
		}
		
		public function isFocusActive():Boolean
		{
			return true;
		}
		
		public function isGameActive():Boolean
		{
			return true;
		}
		
		public function enterState():void
		{
			this.isInState = true;
			if(this._moveStateEventType == MoveStateEvent.MOVE_START){
				this._moveStart();
			}else if(this._moveStateEventType == MoveStateEvent.MOVE_STEP){
				// TODO: do something...
			}else if(this._moveStateEventType == MoveStateEvent.MOVE_END){
				this._moveEnd();	
			}
			
			// Return to the background state
			var e:BackgroundStateEvent = new BackgroundStateEvent(BackgroundStateEvent.BACKGROUND_STATE);
			e.attachPreviousState(this);
			this._app.dispatchEvent(e);
		}
		
		// Internal function actually perform the substate tasks
		private function _moveStart():void {
			// Save the original location so that the panel can pop back if it needs to.
			var b:LatLngBounds = this._map.getLatLngBounds();
			this._originalLocation = this._moveObject.getPosition(b);
			
			// Create a path between its original location and the new location.
			var sP:Point = GameConstants.fromMapToAway3D(this._originalLocation, this._map);
			var eP:Point = GameConstants.fromMapToAway3D(this._targetLocation, this._map);
			
			// Convert to world coordinates
			var startVector:Vector3D = new Vector3D(sP.x, sP.y, 0.);
			var controlVector:Vector3D = new Vector3D((sP.x + eP.x) / 2., (sP.y + eP.y) / 2, 0.);
			var endVector:Vector3D = new Vector3D(eP.x, eP.y, 0.);
			
			// Create a path 
			var pC:PathCommand = new PathCommand(PathCommand.CURVE, startVector, controlVector, endVector);
			var pathPoint:Vector.<PathCommand> = new Vector.<PathCommand>();
			pathPoint.push(pC);
			var p:Path = new Path();
			p.aSegments = pathPoint;
			
			// Get the 3D object that will be moved.
			var m:Mesh = this._moveObject.get3DObject();
			
			// Get the speed of the move object
			var meters:Number = this._originalLocation.distanceFrom(this._targetLocation);
			var s:Number = 1000;
			
			if(this._moveObject is NPCFunctionality){
				var npc:NPCFunctionality = this._moveObject as NPCFunctionality;
				s = GameConstants.convertSpeedIntoTime(npc.getSpeed(), meters);
			}
			// Create the path animator
			var init:Object = {
				duration:s,
				lookat:false,
				targetobject:null,
				offset:new Vector3D(0,0,0),
				rotations:null,
				fps:24,
				easein:false,
				easeout:false
			};
			

			var pan:PathBoneAnimator = new PathBoneAnimator(this._moveObject, s, this._targetLocation, 
				 this._map, this._focusManager, p, m, init);
			pan.loop = false;
			
			// Setup the events associated with the path animator
			pan.addEventListener(AnimatorEvent.STOP, onAnimatorStop);

			this._animationList.addItem(pan);
		}
		
		private function onAnimatorStop(evt:AnimatorEvent):void {
			// Stop the animation
			
			// Remove the animator at the point
			var pan:PathBoneAnimator = evt.animator as PathBoneAnimator;
			pan.isActive = false;
			var uo:UserObject = pan.userObject;
			var tL:LatLng = pan.targetLocation;
			var m:Mesh = uo.get3DObject();
			var p:Point = GameConstants.fromMapToAway3D(tL, this._map);
	
			
			// Remove the item from the animation list	
			this.animationList.removeItemAt(this.animationList.getItemIndex(evt.animator));

			// Set the location and the mesh position
			uo.setPosition(tL);
			m.x = p.x;
			m.y = p.y;
		}
		
		
		private function _moveEnd():void {
			
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
			return false;
		}
		
		public function getViewString():String
		{
			return this.viewString;
		}
		
		public function getStateString():String
		{
			return this.stateString;
		}
		
		public function getNextState():GameState
		{
			return null;
		}
	}
}