package models
{
	import assets.PhotoAssets;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	
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
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import managers.EventManager;
	import managers.GameFocusManager;
	
	import models.away3D.Portal3D;
	import models.constants.GameConstants;
	import models.interfaces.SuperObject;
	import models.map.TowerSaintMarker;
	
	import mx.core.BitmapAsset;

	[Bindable]
	[RemoteClass(alias="models.Portal")]
	public class Portal  extends BaseObject
	{
		// Information
		public var hitPoints:int;
		public var level:int;
		public var isComplete:Boolean;
		
		// Who owns it?
		public var user:User;
		
		// The Start location.
		public var startLocationLatitude:Number;
		public var startLocationLongitude:Number;
		public var startLocationLatitudeIndex:int;
		public var startLocationLongitudeIndex:int;
		
		// The End location
		public var endLocationLatitude:Number;
		public var endLocationLongitude:Number;
		public var endLocationLatitudeIndex:int;
		public var endLocationLongitudeIndex:int;
		public var foundingDate:Date;											/* The date the tower was begun */
		
		public function Portal()
		{
			// Create the 3d model
			this.model = new Portal3D(.1);
		}
	
		override public function isObject(s:SuperObject):Boolean{
			return s is Portal;
		}
		
		
		override public function initialize(u:User):void {
			this.user = u;
			this.hitPoints = 10;
			this.level = 0;
		}

		public static function createUserPortalFromJSON(buildObject:Object, u:User) : Portal {
			var p:Portal = new Portal();
			p.hitPoints = buildObject.hitpoints;
			p.level = buildObject.level;
			p.user = u;
			p.startLocationLatitude = buildObject.startlocationlatitude;
			p.startLocationLongitude = buildObject.startlocationlongitude;
			p.endLocationLatitude = buildObject.endlocationlatitude;
			p.endLocationLongitude = buildObject.endlocationlongitude;
			p.isComplete = buildObject.iscomplete;
			return p;
		}
		
		public static function createPortalFromJSON(buildObject:Object) : Portal {
			var p:Portal = new Portal();
			p.hitPoints = buildObject.hitpoints;
			p.endLocationLatitude = buildObject.endLocationLatitude;
			p.endLocationLongitude = buildObject.endLocationLongitude;
			p.startLocationLatitude = buildObject.startLocationLatitude;
			p.startLocationLongitude = buildObject.startLocationLongitude;
			p.user = User.createUserFromJSON(buildObject.user);
			return p;
		}
		
		
		override public function getNameString():String {
			return "Portal";
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
		
	
		// Compare two operators
		override public function isEqual(s:SuperObject) : Boolean {
			if(s is Portal){
				// Convert to the portal interface
				var p:Portal = s as Portal;
				
				// Create the positions
				var thisStart:LatLng = new LatLng(this.startLocationLatitude, this.startLocationLongitude);
				var thisEnd:LatLng = new LatLng(this.endLocationLatitude, this.endLocationLongitude);
				var cStart:LatLng = new LatLng(p.startLocationLatitude, p.startLocationLongitude);
				var cEnd:LatLng = new LatLng(p.endLocationLatitude, p.endLocationLongitude);
				if(thisStart.equals(cStart) && thisEnd.equals(cEnd) && this.hitPoints == p.hitPoints && 
					this.level == level && this.user.isEqual(p.user)){
					return true;
				}else{
					return false;
				}
			}else{
				return false;
			}
		}
		
		// Update the position of the tower
		override public function updatePosition(loc:LatLng): void{
			this.startLocationLatitude = loc.lat();
			this.startLocationLongitude = loc.lng();
			
			if(this.marker != null){
				this.marker.setLatLng(loc);
			}	
		}
		
		/* Get the image of the bitmap asset */
		override public function getImage(photo:PhotoAssets):BitmapAsset {
			return new photo.ThePortal() as BitmapAsset;
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
		
		public function getString() : String {
			var s:String = "";
			s += "HitPoints\t" + hitPoints.toString() + "\n";
			s += "Level\t\t" + level.toString() + "\n";
			s += "StartLatitude\t" + startLocationLatitude.toPrecision(5) + "\n";
			s += "StartLongitude\t" + startLocationLongitude.toPrecision(5) + "\n";
			s += "EndLatitude\t" + endLocationLatitude.toPrecision(5) + "\n";
			s += "EndLongitude\t" + endLocationLongitude.toPrecision(5) + "\n";
			return s;
		}
		
		override public function setPosition(pos:LatLng) : void {
			startLocationLatitude = pos.lat();
			startLocationLongitude = pos.lng();
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
			var sL:LatLng = new LatLng(this.startLocationLatitude, this.startLocationLongitude);
			var eL:LatLng = new LatLng(this.endLocationLatitude, this.endLocationLongitude);
			if(b.containsLatLng(sL)){
				return sL;
			}else{
				return eL;
			}
		}
		

	}
}