package models
{
	import assets.PhotoAssets;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.overlays.Polygon;
	import com.google.maps.overlays.PolygonOptions;
	import com.google.maps.styles.FillStyle;
	import com.google.maps.styles.StrokeStyle;
	
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import managers.EventManager;
	import managers.GameFocusManager;
	
	import models.away3D.RoadPath;
	import models.constants.GameConstants;
	import models.interfaces.SuperObject;
	import models.map.TowerSaintMarker;
	
	import mx.core.BitmapAsset;

	[Bindable]
	[RemoteClass(alias="models.Road")]
	public class Road  extends BaseObject
	{
		// Information
		public var hitPoints:Number;
		public var level:Number;
		public var isComplete:Boolean;
		public var foundingDate:Date;											/* The date the tower was begun */
		
		// Who owns it?
		public var user:User;
		
		// Location 
		public var latIndex:int;
		public var lonIndex:int;
		public var latitude:Number;
		public var longitude:Number;
		
		
		
		public function Road()
		{
			// Create the 3d model
			this.model = new RoadPath();
		}
		

		override public function isObject(s:SuperObject):Boolean{
			return s is Road;
		}
		
		override public function initialize(u:User) : void {
			this.user = user;
			this.hitPoints = 50;
			this.level = 0;
		}
		
		public static function createUserRoadFromJSON(buildObject:Object, u:User):Road {
			var r:Road = new Road();
			r.hitPoints = buildObject.hitpoints;
			r.level = buildObject.level;
			r.latitude = buildObject.latitude;
			r.longitude = buildObject.longitude;
			r.isComplete = buildObject.iscomplete;
			return r;
		}
		
		public static function createRoadFromJSON(buildObject:Object):Road{
			var r:Road = new Road();
			r.level = buildObject.level;
			r.latitude = buildObject.latitude;
			r.longitude = buildObject.longitude;
			r.user = User.createUserFromJSON(buildObject.user);
			return r;
		}
		
		override public function getNameString():String {
			return "Road";
		}
		
		override public function getProduction():Production {
			return new Production(0., 0., 0.);
		}

		override public function isIncompleteState():Boolean{
			return this.isComplete;
		}
		
		override public function getFoundingDate():Date{
			return this.foundingDate;
		}
		
		override public function setUser(u:User):void {
			this.user = u;
		}
		
		override public function getBoundaryPolygon():Polygon {
			return new Polygon([]);
		}
		
		override public function isEqual(s:SuperObject) : Boolean {
			if(s is Road){
				var r:Road = s as Road;
				var pos:LatLng = new LatLng(this.latitude, this.longitude);
				var cpos:LatLng = new LatLng(this.latitude, this.longitude);
				if(pos.equals(cpos) && this.hitPoints == r.hitPoints  && this.level == r.level && 
					this.user.isEqual(r.user)){
					return true;
				}else{
					return false;
				}
			}else{
				return false;
			}
			
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
		
		override public function getImage(photo:PhotoAssets):BitmapAsset {
			return getRoadFromNeighbors(photo);			
		}
		
		override public function getNumberOfBuildStages():Number{
			return 2;
		}
		
		// Build the road in stages
		override public function drawStage(bS:Number, l:LatLng):void{
			
		}
		
		/* Return the textflow representation of the model */
		override public function display():TextFlow {
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
		
		override public function setPosition(pos:LatLng) : void {
			latitude = pos.lat();
			longitude = pos.lng();
		}
		

		override public function getMaxInfluence():Number {
			switch(this.level){
				case 1:
					return 1.;
				case 2:
					return 2.;
				case 3:
					return 5.;
				case 4:
					return 10.;
				default:
					return 1.;
			}
		}
		
		override public function hasBoundary():Boolean {
			return false;
		}
		
		override public function getPosition(b:LatLngBounds):LatLng{
			return new LatLng(this.latitude, this.longitude);
		}
		
	}
}
