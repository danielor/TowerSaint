package models
{
	import assets.PhotoAssets;
	
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	
	import flashx.textLayout.elements.TextFlow;

	public interface SuperObject
	{
		function draw(drag:Boolean, map:Map, photo:PhotoAssets) : void;
		function display() : TextFlow;
		function setPosition(pos:LatLng) : void;
	}
}