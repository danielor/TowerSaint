package models
{
	import assets.PhotoAssets;
	
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	
	import flashx.textLayout.elements.TextFlow;
	
	import managers.FocusPanelManager;
	
	import mx.core.BitmapAsset;

	public interface SuperObject
	{
		function draw(drag:Boolean, map:Map, photo:PhotoAssets, fpm:FocusPanelManager) : void;
		function display() : TextFlow;
		function setPosition(pos:LatLng) : void;
		
		// Interface to the isModified flag, which is true when an object has been create.
		function setIsModified(t:Boolean) : void;
		function getIsModified():Boolean;
		
		// Get the image representation
		function getImage(photo:PhotoAssets):BitmapAsset;
	}
}