package managers
{
	import assets.PhotoAssets;
	
	import com.google.maps.MapMouseEvent;
	
	import flashx.textLayout.elements.TextFlow;
	
	import models.SuperObject;
	import models.map.TowerSaintMarker;
	
	import mx.controls.Image;
	import mx.core.BitmapAsset;
	
	import spark.components.Button;
	import spark.components.RichEditableText;
	
	public class FocusPanelManager
	{
		// The display objects of the focus panel
		public var focusImage:Image;
		public var controlButton:Button;
		public var bodyText:RichEditableText;
		public var titleText:RichEditableText;
		
		// The photo assets
		public var _photo:PhotoAssets;
		
		public function FocusPanelManager(fI:Image, cB:Button, bT:RichEditableText, tT:RichEditableText, 
										  p:PhotoAssets)
		{
			// The panel
			this.focusImage = fI;
			this.controlButton = cB;
			this.bodyText = bT;
			this.titleText = tT;
			
			// The photo assets
			this._photo = p;
		}
		
		public function onMarkerClick(event:MapMouseEvent) : void {
			// Display the model associated with the 
			var marker:TowerSaintMarker = event.currentTarget as TowerSaintMarker;

			// Display the model in the focusPanelManager
			displayModel(marker.model);
		}
		
		public function displayModel(m:SuperObject) : void {
			// Get the objects from the model
			var t:TextFlow = m.display();
			var bA:BitmapAsset = m.getImage(this._photo);
			
			// Set the 
			this.bodyText.textFlow = t;
			this.focusImage.source = bA;
 		}
		
	}
}