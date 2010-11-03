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

	[Bindable]
	[RemoteClass(alias="models.Road")]
	public class Road implements SuperObject
	{
		// Information
		public var hitPoints:Number;
		public var level:Number;
		
		// Who owns it?
		public var user:User;
		
		// Location 
		public var latIndex:int;
		public var lonIndex:int;
		public var latitude:Number;
		public var longitude:Number;
		
		// State variables
		private var isModified:Boolean;
	
		
		public function Road()
		{
			super();
		}
		
		public function draw(drag:Boolean, map:Map, photo:PhotoAssets, fpm:FocusPanelManager) : void{
			
			// Add a ground overlay
			var roadIcon:BitmapAsset = getRoadFromNeighbors(photo);
			
			// Extract the position associated with remoteObject(Tower)			
			var gposition:LatLng = new LatLng(latitude, longitude);
			
			// Create test overlays
			var markerOptions : MarkerOptions = new MarkerOptions();
			markerOptions.icon = roadIcon;
			markerOptions.iconAlignment = MarkerOptions.ALIGN_HORIZONTAL_CENTER | MarkerOptions.ALIGN_BOTTOM;
			markerOptions.hasShadow = false;
			markerOptions.radius = 5;
			markerOptions.draggable = drag;
			
			// Create the marker
			var marker:TowerSaintMarker = new TowerSaintMarker(this, gposition, markerOptions);
			marker.addEventListener(MapMouseEvent.CLICK, fpm.onMarkerClick);
			map.addOverlay(marker);
		}

		

		
		public function getRoadFromNeighbors(_photo:PhotoAssets):BitmapAsset {
			
			// TODO: This value needs to be calculated properly so that depending on the
			// neighbor list different bitmaps are used.
			var neighborType:Number = 0;
			// North - (0, 1)
			// East - (0, 2)
			// South - (0, 4)
			// West - (0, 8)
			switch(neighborType){
				case 0:
					return new _photo.EastRoad() as BitmapAsset;
				case 1:
					return new _photo.NorthRoad() as BitmapAsset;
				case 2:
					return new _photo.EastRoad() as BitmapAsset;
				case 3:
					return new _photo.NorthEastRoad() as BitmapAsset;
				case 4:
					return new _photo.SouthRoad() as BitmapAsset;
				case 5:
					return new _photo.NorthSouthRoad() as BitmapAsset;
				case 6:
					return new _photo.SouthEastRoad() as BitmapAsset;
				case 7:
					return new _photo.NorthSouthEastRoad() as BitmapAsset;
				case 8:
					return new _photo.WestRoad() as BitmapAsset;
				case 9:
					return new _photo.NorthWestRoad() as BitmapAsset;
				case 10:
					return new _photo.EastWestRoad() as BitmapAsset;
				case 11:
					return new _photo.NorthEastWestRoad() as BitmapAsset;
				case 12:
					return new _photo.SouthWestRoad() as BitmapAsset;
				case 13:
					return new _photo.NorthSouthWestRoad() as BitmapAsset;
				case 14:
					return new _photo.SouthEastWestRoad() as BitmapAsset;
				case 15:
					return new _photo.NorthSouthEastWestRoad() as BitmapAsset;
				default:
					return new _photo.EastRoad() as BitmapAsset;
			}
		}
		
		public function getImage(photo:PhotoAssets):BitmapAsset {
			return getRoadFromNeighbors(photo);			
		}
		
		/* Return the textflow representation of the model */
		public function display():TextFlow {
			var textFlow:TextFlow = new TextFlow();
			
			// Setup the stuff
			var pGraph:ParagraphElement = new ParagraphElement();
			
			// Add the span
			var iSpan:SpanElement = new SpanElement();
			iSpan.text = getString();
			
			// The span element
			pGraph.addChild(iSpan);
			textFlow.addChild(pGraph);
			
			return textFlow;
		}
		
		public function getString():String {
			var s:String = "";
			s+="HitPoints\t" + hitPoints.toString() + "\n";
			s+="Level\t\t" + level.toString() + "\n";
			s+="Latitude\t\t" + latitude.toPrecision(5) + "\n";
			s+="Lognitude\t" + longitude.toPrecision(5) + "\n";
			return s;
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
