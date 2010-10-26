package managers
{
	import flashx.textLayout.elements.TextFlow;
	
	import models.SuperObject;
	
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
		
		public function FocusPanelManager(fI:Image, cB:Button, bT:RichEditableText, tT:RichEditableText)
		{
			this.focusImage = fI;
			this.controlButton = cB;
			this.bodyText = bT;
			this.titleText = tT;
		}
		
		public function displayModel(m:SuperObject) : void {
			var t:TextFlow = m.display();
			
		}
		
	}
}