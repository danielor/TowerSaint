package models.away3D
{
	import away3d.animators.PathAnimator;
	import away3d.core.base.Object3D;
	import away3d.core.geom.Path;
	
	import models.interfaces.UserObject;
	
	public class PathBoneAnimator extends PathAnimator
	{
		private var _userObject:UserObject;					// The object that attaches to the animator
		public function PathBoneAnimator(uO:UserObject, path:Path=null, target:Object3D=null, init:Object=null)
		{
			this._userObject = uO;
			super(path, target, init);
		}
		
		// Get the user Object
		public function get userObject():UserObject{
			return this._userObject;
		}
	}
}