// ActionScript file
// Written by Daniel Ortiz
package managers.states {
	import flash.utils.Dictionary;

	/*
		The servicestate interface contains constants of all the 
		active AMF services in the application. The interface provides
		an implementation for talking to these application specific
		constants.
	*/
	public interface ServiceState
	{
		function getAllConstants():Array;
		function intializeServices():void;
		function getServices():Dictionary;
	}
}