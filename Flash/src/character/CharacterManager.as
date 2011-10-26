package character
{
	import models.User;

	public class CharacterManager
	{
		var user:User;										// The user managing his character
		public function CharacterManager(u:User)
		{
			this.user = u;
		}
	}
}