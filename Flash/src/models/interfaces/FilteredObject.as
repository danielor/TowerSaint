package models.interfaces
{
	public interface FilteredObject
	{
		function updateFilter(i:Number):void;							// Update the filter
		function changeFilterState(b:Boolean):void;					// Turn the filter on or off.
	}
}