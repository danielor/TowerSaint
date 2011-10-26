package models.interfaces
{
	// Object modifiers modify game objects with static xml data.
	public interface ObjectModifier
	{
		function getModifierForClass(obj:Object):XML;					// Get the modifier for the class
	}
}