package models.away3D
{
	import away3d.animators.Animator;
	import away3d.animators.PathAnimator;
	import away3d.animators.utils.PathUtils;
	import away3d.core.base.Object3D;
	import away3d.core.geom.Path;
	import away3d.core.geom.PathCommand;
	
	import character.intefaces.NPCFunctionality;
	
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import managers.GameFocusManager;
	
	import models.constants.GameConstants;
	import models.interfaces.UserObject;
	import models.states.events.StateEvent;
	
	import mx.controls.Alert;
	import mx.managers.FocusManager;
	
	// PathBoneAnimator - an Animator that combines the functionality of bone animator
	// and path animator for multiple objects. 
	public class PathBoneAnimator extends Animator
	{
		private var _userObject:UserObject;					// The object that attaches to the animator
		private var _totalTime:Number;						// The total time for the animation
		private var _currentTime:Number;					// The current time of the animation
		private var _targetLocation:LatLng;					// Where we would like to ened up.
		private var _map:Map;								// The map one which the game is
		private var _isActive:Boolean;						// Is the animator active??
		private var _endAtAnimationEnd:Boolean;				// End where the animation ends.
		private var _endVector:Vector3D;					// Where the animation stops...
		private var _focusManager:GameFocusManager;			// The game focus manager(Focus will follow)
		private var _chainedState:StateEvent;				// What are we going to do after moving???
		
		// Away 3d path private variables
		private var _path:Path;
		private var _commands:Vector.<PathCommand>;
		private var _cCommand:PathCommand;
		private var _nCommand:PathCommand;
		private var _position:Vector3D = new Vector3D();
		private var _tangent:Vector3D = new Vector3D();
		private var _rotation:Vector3D = new Vector3D();
		private var _worldAxis:Vector3D = new Vector3D(0,1,0);
		
		public function PathBoneAnimator(uO:UserObject, tT:Number, tL:LatLng, m:Map, fM:GameFocusManager,
										 path:Path=null, target:Object3D=null, init:Object=null)
		{
			// Call the animator class
			super(target, init);

			this._userObject = uO;
			this._totalTime = tT;
			this._targetLocation = tL;
			this._currentTime = 0;
			this._map = m;
			this._focusManager = fM;
			
			// Set the state
			this._isActive = true;
			this._endAtAnimationEnd = true;
			this._alterPathDueToChainState(path);
			
			// Tie into Path animator functionality
			this.init3D(path, target, init);
		}
		
		// Alter the path due to the chained state
		private function _alterPathDueToChainState(pp:Path):void {
			if(this._userObject is NPCFunctionality){
				var npc:NPCFunctionality = this._userObject as NPCFunctionality;
				var s:StateEvent = npc.getChainedState();
				this.chainedState = s;		// May be null... but we want that.
				if(s != null){				// We are going to be attacking/building after moving
					this.chainedState = s;
					
					// Modify the path
					if(pp != null){
						var v:Vector.<PathCommand> = pp.array;
						var p:PathCommand = v[v.length -1]; 
						
						// Get the new point
						var eV:Vector3D = p.pEnd;
						var sV:Vector3D = p.pStart;
						var endPoint:Point = new Point(p.pEnd.x, p.pEnd.y);
						var angle:Number = Math.atan2(eV.y - sV.y, eV.x - sV.x);
						
						// Get the new point
						var np:Point = npc.getProximityTriggerToChainedState(endPoint, angle);
						var nE:Vector3D = new Vector3D(np.x, np.y, 0.);
						var cE:Vector3D = new Vector3D((sV.x + nE.x) / 2, (sV.y + nE.y)/2, 0.);
						
						// Update the path
						p.pControl = cE;
						p.pEnd = nE;
						v[v.length - 1] = p;
						pp.aSegments = v;
						
						// Reset the target location to the new point
						var l:LatLng = GameConstants.fromAway3DtoMap(np, this._map);
						this.targetLocation = l;
					}
	
				}
			}
		}
		
		// Get the user Object
		public function get userObject():UserObject{
			return this._userObject;
		}
		public function get targetLocation():LatLng{
			return this._targetLocation;
		}
		public function set targetLocation(l:LatLng):void {
			this._targetLocation = l;
		}
		public function get isActive():Boolean{
			return this._isActive;
		}
		public function set isActive(b:Boolean):void {
			this._isActive = b;
		}
		public function set endAtAnimationEnd(b:Boolean):void {
			this._endAtAnimationEnd = b;
		}
		public function set chainedState(s:StateEvent):void {
			this._chainedState = s;
		}
		public function get chainedState():StateEvent {
			return this._chainedState;
		}

		// Restart the animator
		public function restartAnimator():void {
			this._currentTime = 0;
			//this.init3D(path, target);
		}
		public function set animationTime(s:Number):void {
			this._totalTime = s;
		}
		
		// Tween with velocity
		public function tweenWithVelocity():void {
			if(this._isActive){
				this.update(this._currentTime);
				this._currentTime = this._currentTime + 1. / this._totalTime;
			}
		}
		
		
		protected override function updateTarget():void
		{
		}
		
		protected override function getDefaultFps():Number
		{
			return 1;
		}
		
		protected override function updateProgress(val:Number):void
		{
			super.updateProgress(val);
			if(!this.isPlaying && this._endAtAnimationEnd ){
				return;
			}
			
			if (_currentFrame == _commands.length) {
				_cCommand = _nCommand = _commands[_currentFrame-1];
			} else {
				_cCommand = _commands[_currentFrame];
				
				if (_currentFrame == _commands.length - 1) {
					if (loop){
						_nCommand = _commands[0];
					}else{
						_nCommand = _commands[_currentFrame];
					}
				} else {
					_nCommand = _commands[_currentFrame+1];
				}
			}
			
			var start:Vector3D = _cCommand.pStart;
			var control:Vector3D = _cCommand.pControl;
			var end:Vector3D = _cCommand.pEnd;
			
			//calculate position
			var dt:Number = 2 * _invFraction;
			_position.x = start.x + _fraction * (dt * (control.x - start.x) + _fraction * (end.x - start.x));
			_position.y = start.y + _fraction * (dt * (control.y - start.y) + _fraction * (end.y - start.y));
			_position.z = start.z + _fraction * (dt * (control.z - start.z) + _fraction * (end.z - start.z));
		
			// Do we return to the beginning?	
			if(this._endAtAnimationEnd){
				if(!start.equals(_position)){
					_target.position = _position;
					if(this._focusManager.isFocusObject(this._userObject)){
						this._focusManager.updateViewAtPosition(_position);
					}
				}
			}else{
				_target.position = _position;
				if(this._focusManager.isFocusObject(this._userObject)){
					this._focusManager.updateViewAtPosition(_position);
				}
			}

			if (alignToPath) {
				
				//calculate tangent
				_tangent.x = _position.x + control.x - start.x + _fraction * (end.x - 2 * control.x + start.x);
				_tangent.y = _position.y + control.y - start.y + _fraction * (end.y - 2 * control.y + start.y);
				_tangent.z = _position.z + control.z - start.z + _fraction * (end.z - 2 * control.z + start.z);
				
				if(rotations.length) {
					if(rotations[_currentFrame+1] == null) {
						_rotation.x = rotations[rotations.length-1].x;
						_rotation.y = rotations[rotations.length-1].y;
						_rotation.z = rotations[rotations.length-1].z;
					} else {
						_rotation.x = rotations[_currentFrame].x*_invFraction + rotations[_currentFrame+1].x*_fraction;
						_rotation.y = rotations[_currentFrame].y*_invFraction + rotations[_currentFrame+1].y*_fraction;
						_rotation.z = rotations[_currentFrame].z*_invFraction + rotations[_currentFrame+1].z*_fraction;
					}
					
					_worldAxis = path.worldAxis;
					_worldAxis.x = 0;
					_worldAxis.y = 1;
					_worldAxis.z = 0;
					_worldAxis = PathUtils.rotatePoint(_worldAxis, _rotation);
					
					_target.lookAt(_tangent, _worldAxis);
				} else {
					_target.lookAt(_tangent);
				}
			} else if (targetObject != null) {
				_target.lookAt(targetObject.scenePosition);
			}
			if (offset) {
				_target.moveRight(offset.x);
				_target.moveUp(offset.y);
				_target.moveForward(offset.z);
			}
		}
		
		/**
		 * sets an optional offset to the position on the path, ideal for cameras or reusing the same <code>Path</code> object for parallel animations
		 */
		public var offset:Vector3D;
		
		/**
		 * Defines an optional array of rotations in order to follow a path that is twisted along its axis.
		 */
		public var rotations:Array;
		
		/**
		 * Defines a target object that the 3d object looks at while animating along the path. Defaults to null.
		 */
		public var targetObject:Object3D;
		
		/**
		 * Defines whether the 3d object aligns its rotation to the axis of the path while animating along the path. Defaults to false.
		 */
		public var alignToPath:Boolean;
		
		/**
		 * defines the path used by the animation.
		 * 
		 * @see Path
		 */
		public function get path():Path
		{
			return _path;
		}
		
		public function set path(val:Path):void
		{
			_path = val;
			_commands = path.array;
			_totalFrames = _commands.length;
		}
		
		/**
		 * returns the current interpolated position on the path with no optional offset applied
		 */
		public function get position():Vector3D
		{
			return _position;
		}
		
		/**
		 * returns the current interpolated rotation along the path.
		 */
		public function get rotation():Vector3D
		{
			return _rotation;
		}
		
		/**
		 * Creates a new <code>PathAnimator</code>
		 * 
		 * @param	path		[optional]	Defines the <code>Path</code> object used tp define the path of the animation.
		 * @param	target		[optional]	Defines the 3d object to which the animation is applied.
		 * @param	init		[optional]	An initialisation object for specifying default instance properties.
		 */
		private function init3D(path:Path = null, target:Object3D = null, init:Object = null):void
		{
			
			this.path = path;
			
			targetObject = ini.getObject3D("targetObject");
			alignToPath = ini.getBoolean("alignToPath",false);
			offset = ini.getVector3D("offset");
			rotations = ini.getArray("rotations");
		}
		
		/**
		 * Updates a position Vector3D on the path at a given time. Do not use this handler to animate, it's in there to add dummy's or place camera before or after
		 * the animated object. Use the update() method or progress property instead.
		 *
		 * @param p	Vector3D. The Vector3D to update according to the "t" time parameter.
		 * @param t	Number. A Number  from 0 to 1
		 * @see animateOnPath
		 * @see update
		 */
		public function getPositionOnPath( p:Vector3D, t:Number):void
		{
			t = (t<0)? 0 : (t>1)?1 : t;
			var m:Number = path.array.length*t;
			var i:int = Math.floor(m);
			var command:PathCommand = path.array[i];
			var nT:Number = m-i;
			var dt:Number = 2 * (1 - nT);
			p.x = command.pEnd.x + nT * (dt * (command.pControl.x - command.pStart.x) + nT * (command.pEnd.x - command.pStart.x));
			p.y = command.pStart.y + nT * (dt * (command.pControl.y - command.pStart.y) + nT * (command.pEnd.y - command.pStart.y));
			p.z = command.pStart.z + nT * (dt * (command.pControl.z - command.pStart.z) + nT * (command.pEnd.z - command.pStart.z));
		}
		
		
		/**
		 * returns the segment index that is used at a given time;
		 * @param	 t		[Number]. A Number between 0 and 1. If no params, actual pathanimator time segment index is returned.
		 */
		public function getTimeSegment(t:Number = NaN):Number
		{
			t = (isNaN(t))? _time : t;
			return Math.floor(path.array.length*t);
		}
		
		/**
		 * Returns a position on the path determined by the elapsed time given.
		 * 
		 * @param		time					A number representing the elapsed time in seconds.
		 * @param		position	[optional]	A 3d number object representing the instance to be returned. 
		 *
		 * @return								A Vector3D object representing the position.
		 */
		public function getPathPosition(time:Number, position:Vector3D = null):Vector3D
		{
			var p:Number = (time - delay)/length;
			p = (p<0)? 0 : (p>1)?1 : p;
			var m:Number = path.array.length*p;
			var i:int = Math.floor(m);
			var command:PathCommand = path.array[i];
			var nT:Number = m-i;
			var dt:Number = 2 * (1 - nT);
			
			if (!position)
				position = new Vector3D();
			
			position.x = command.pStart.x + nT * (dt * (command.pControl.x - command.pStart.x) + nT * (command.pEnd.x - command.pStart.x));
			position.y = command.pStart.y + nT * (dt * (command.pControl.y - command.pStart.y) + nT * (command.pEnd.y - command.pStart.y));
			position.z = command.pStart.z + nT * (dt * (command.pControl.z - command.pStart.z) + nT * (command.pEnd.z - command.pStart.z));
			
			return position;
		}
	}
}