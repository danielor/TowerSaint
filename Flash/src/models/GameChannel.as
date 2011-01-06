package models
{
	[Bindable]
	[RemoteObject(alias="models.GameChannel")]
	// Contains informtion associated with the game channels for
	// chat, user, game events
	public class GameChannel
	{
		// The tokens associated with the game channels
		public var userManagerToken:String;	
		public function GameChannel()
		{
			super();
		}
	}
}