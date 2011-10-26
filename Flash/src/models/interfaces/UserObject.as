package models.interfaces
{
	import models.User;

	public interface UserObject
	{
		function initialize(u:User, obj:ObjectModifier) : void;										// Initialize a user object
	}
}