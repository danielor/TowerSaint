package models
{
	import assets.PhotoAssets;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import managers.FocusPanelManager;
	
	import models.map.TowerSaintMarker;
	
	import mx.core.BitmapAsset;

	[Bindbale]
	[RemoteClass(alias="models.Tower")]
	public class Tower implements SuperObject
	{
		
		// Stats
		public var Experience:Number;
		public var Speed:Number;
		public var Power:Number;
		public var Armor:Number;
		public var Range:Number;
		public var Accuracy:Number;
		public var HitPoints:Number;
		public var isIsolated:Boolean;
		public var isCapital:Boolean;
		public var hasRuler:Boolean;
		public var Level:Number;
		
		// The user associated with the tower.
		public var user:User;
		
		// Mining capabilities.
		public var manaProduction:Number;
		public var stoneProduction:Number;
		public var woodProduction:Number;
		
		// Location
		public var latIndex:int;
		public var lonIndex:int;
		public var latitude:Number;
		public var longitude:Number;
		
		// State variables
		private var isModified:Boolean;
		
		public function Tower()
		{
			super();
		}
		
		public function draw(drag:Boolean, map:Map, _photo:PhotoAssets, fpm:FocusPanelManager) : void {
			// Add a test ground overlay
			var towerIcon:BitmapAsset = _getImage(_photo);
			
			// Extract the position associated with remoteObject(Tower)			
			var gposition:LatLng = new LatLng(latitude, longitude);
			
			// Create test overlays
			var markerOptions : MarkerOptions = new MarkerOptions();
			markerOptions.icon = towerIcon;
			markerOptions.iconAlignment = MarkerOptions.ALIGN_HORIZONTAL_CENTER | MarkerOptions.ALIGN_BOTTOM;
			markerOptions.hasShadow = true;
			markerOptions.radius = 5;
			markerOptions.draggable = drag;
			
			// Create the marker
			var marker:TowerSaintMarker = new TowerSaintMarker(this, gposition, markerOptions);
			marker.addEventListener(MapMouseEvent.CLICK, fpm.onMarkerClick);
			map.addOverlay(marker);
		}
		
		private function _getImage(_photo:PhotoAssets):BitmapAsset {
			var towerIcon:BitmapAsset;
			switch(Level){
				// Tower image
				case 0:
					towerIcon =  new _photo.TowerLevel0() as BitmapAsset;
					break;
				// Fort image
				case 1:
					towerIcon = new _photo.TowerLevel1() as BitmapAsset;
					break;
				// Castle image
				case 2:
					towerIcon = new _photo.TowerLevel2() as BitmapAsset;
					break;
				// TowerSaint image
				case 3:
					towerIcon = new _photo.TowerSaint() as BitmapAsset;
					break;
				default:
					towerIcon =  new _photo.TowerLevel0() as BitmapAsset;
					break;
			}
			return towerIcon
		}
		
		public function getImage(photo:PhotoAssets):BitmapAsset {
			return this._getImage(photo);
		}
		
		private function onMarkerClick(event:MapMouseEvent) : void {
			
		}
		
		/* Return the textflow representation of the model */
		public function display():TextFlow {
			var textFlow:TextFlow = new TextFlow();
			
			// Setup the stuff
			var pGraph:ParagraphElement = new ParagraphElement();
			
			// Add the span
			var iSpan:SpanElement = new SpanElement();
			iSpan.text = "tower";
			
			// The span element
			pGraph.addChild(iSpan);
			textFlow.addChild(pGraph);
			
			return textFlow;
		}
		
		public function setPosition(pos:LatLng) : void {
			latitude = pos.lat();
			longitude = pos.lng();
		}

		// Interface to the isModified flag, which is true when an object has been create.
		public function setIsModified(t:Boolean) : void {
			this.isModified = t;
		}
		public function getIsModified():Boolean {
			return this.isModified;
		}
	}
}