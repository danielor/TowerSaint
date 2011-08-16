package models
{
	import assets.ColladaAssetLoader;
	import assets.PhotoAssets;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.events.MouseEvent3D;
	import away3d.loaders.Collada;
	
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.interfaces.IProjection;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.overlays.Polygon;
	import com.google.maps.overlays.PolygonOptions;
	import com.google.maps.styles.FillStyle;
	import com.google.maps.styles.StrokeStyle;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	import managers.EventManager;
	import managers.GameFocusManager;
	
	import messaging.ChannelJavascriptBridge;
	import messaging.events.ChannelAttackEvent;
	
	import models.away3D.Tower3D;
	import models.constants.GameConstants;
	import models.interfaces.BoundarySuperObject;
	import models.interfaces.SuperObject;
	import models.map.TowerSaintMarker;
	
	import mx.controls.Alert;
	import mx.controls.List;
	import mx.core.BitmapAsset;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	[Bindbale]
	[RemoteClass(alias="models.Tower")]
	public class Tower extends BaseObject
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
		public var isComplete:Boolean;
		public var hasRuler:Boolean;
		public var Level:Number;
		public var foundingDate:Date;											/* The date the tower was begun */
		
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
	
		// Item Renderer interface (HUserObjectRenderer)
		public const alias:String = "Tower";											/* The name of the tower */
		
		public function Tower()
		{
				/* Create the 3d model */
			this.model = new Tower3D(.1);											/* Create the view */	
		}
		
		
		// Factory functions for differenct cases
		public static function createCapitalAtPosition(loc:LatLng, u:User):Tower {
			var t:Tower = new Tower();
			t.Experience = 0;
			t.Speed = 1;
			t.Power = 1;
			t.Armor = 1;
			t.Range = 1;
			t.Accuracy = .5;
			t.HitPoints = 100;
			t.isIsolated = false;
			t.isCapital = true;
			t.hasRuler = true;
			t.user = u;
			t.manaProduction = 5000 + Math.floor( Math.random() * 50);
			t.stoneProduction = 5000 + Math.floor( Math.random() * 50);
			t.woodProduction = 5000 + Math.floor( Math.random() * 50);
			t.Level = 0;
			t.latitude = loc.lat();
			t.longitude = loc.lng();
			return t;
		}
		
		
		// True if it is an object
		override public function isObject(s:SuperObject):Boolean {
			return s is Tower;
		}
		
		public static function createUserTowerFromJSON(buildObject:Object, u:User) : Tower {
			var t:Tower = new Tower();
			t.Experience = buildObject.experience;
			t.Speed = buildObject.speed;
			t.Power = buildObject.power;
			t.Armor = buildObject.armor;
			t.Range = buildObject.range;
			t.Accuracy = buildObject.accuracy;
			t.HitPoints = buildObject.hitpoints;
			t.isIsolated = buildObject.isisolated;
			t.isCapital = buildObject.iscapital;
			t.hasRuler = buildObject.hasRuler;
			t.isComplete = buildObject.iscomplete;
			t.user = u;
			t.manaProduction = buildObject.manaproduction;
			t.stoneProduction = buildObject.stoneproduction;
			t.woodProduction = buildObject.woodproduction;
			t.Level = buildObject.level;
			t.latitude = buildObject.latitude;
			t.longitude = buildObject.longitude;
			t.isInitialized = true;
			return t;
		}
		
		public static function createTowerFromJSON(buildObject:Object):Tower{
			var t:Tower = new Tower();
			t.Level = buildObject.level;
			t.latitude = buildObject.latitude;
			t.longitude = buildObject.longitude;
			t.isCapital = buildObject.iscapital;
			t.stoneProduction = buildObject.stoneproduction;
			t.Power = buildObject.power;
			t.Level = buildObject.level;
			t.Armor = buildObject.armor;
			t.hasRuler = buildObject.hasruler;
			t.Experience = buildObject.experience;
			t.woodProduction = buildObject.woodproduction;
			t.Range = buildObject.range;
			t.isIsolated = buildObject.isisolated;
			t.user = User.createUserFromJSON(buildObject.user);
			t.HitPoints = buildObject.hitpoints;
			t.Speed = buildObject.speed;
			t.Accuracy = buildObject.accuracy;
			return t;
		}
		
		override public function initialize(u:User): void {
			this.Experience = 0;
			this.Speed = 1;
			this.Power = 1;
			this.Armor = 1;
			this.Range = 1;
			this.Accuracy = .5;
			this.HitPoints = 100;
			this.isIsolated = false;
			this.isCapital = false;
			this.hasRuler = true;
			this.isInitialized = true;
			//this.user = u;
			this.manaProduction = 50 + Math.floor( Math.random() * 50);
			this.stoneProduction = 50 + Math.floor( Math.random() * 50);
			this.woodProduction = 50 + Math.floor( Math.random() * 50);
			this.Level = 0;

		}
		

		// Update the position of the tower
		override public function updatePosition(loc:LatLng): void{
			this.latitude = loc.lat();
			this.longitude = loc.lng();
		
			if(this.marker != null){
				this.marker.setLatLng(loc);
			}	
		}
		
		/*
		public function toString() : String {
			var s:String = "";
			s = s + this.Experience.toString() + ":";
			s = s + this.Speed.toString() + ":";
			s = s + this.Power.toString() + ":";
			s = s + this.Armor.toString() + ":";
			s = s + this.Range.toString() + ":";
			s = s + this.HitPoints.toString() + ":";
			s = s + this.isIsolated.toString() + ":";
			s = s + this.isCapital.toString() + ":";
			s = s + this.hasRuler.toString() + "\n";
			s = s + this.manaProduction.toString() + ":";
			s = s + this.stoneProduction.toString() + ":";
			s = s + this.woodProduction.toString() + ":";
			s = s + this.Level.toString() + ":";
			s = s + this.latIndex.toString() + ":";
			s = s + this.lonIndex.toString() + ":";
			s = s + this.latitude.toString() + ":";
			s = s + this.longitude.toString() + ":";
			return s;
		}
		*/
	
		
		override public function getNameString():String {
			return "Tower";
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

		// Check if the tower is equal to another object
		override public function isEqual(s:SuperObject) : Boolean {
			if(s is Tower){
				var t:Tower = s as Tower;
				var pos:LatLng = new LatLng(this.latitude, this.longitude);
				var tpos:LatLng = new LatLng(t.latitude, t.longitude);
				if(pos.equals(tpos) && this.Experience == t.Experience && this.Speed == t.Speed && this.Power == t.Power &&
					this.Armor == t.Armor && this.Range == t.Range && this.Accuracy == t.Accuracy && 
					this.HitPoints == t.HitPoints && this.isIsolated == t.isIsolated && this.isCapital == t.isCapital &&
					this.hasRuler == t.hasRuler && this.user.isEqual(t.user) && this.Level == t.Level &&
					this.manaProduction == t.manaProduction && this.stoneProduction == t.stoneProduction &&
					this.woodProduction == t.woodProduction){
					return true;
				}else{
					return false;
				}
			}else{
				return false;
			}
		}

		
		override public function getProduction():Production {
			return new Production(this.woodProduction, this.stoneProduction, this.manaProduction);
		}
		
		/*
		public function removeFocusOnObject() : void {
			// Change focus state
			hasFocus = false;
			
			// Remove from the map
			var m:Map = towerMarker.getMap();
			if(m != null){
				m.removeOverlay(this.focusPolygon);
			}
		}
		*/
		

		/*
		public function getMarker():TowerSaintMarker {
			return towerMarker;
		}
		
		public function getMarkerEventManager():EventManager {
			return tMEventManager;
		}
		*/
		override public function getImage(_photo:PhotoAssets):BitmapAsset {
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
		
		
		override public function hasBoundary():Boolean {
			return true;
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
		
		
		private function getString():String {
			var s:String = "";
			if(this.isCapital){
				s+="Capital\n";
			}
			s+="Experience\t" + Experience.toString() + "\n";
			s+="Speed\t\t" + Speed.toString() + "\n";
			s+="Power\t\t" + Power.toString() + "\n";
			s+="Armor\t\t" + Armor.toString() + "\n";
			s+="Range\t\t" + Range.toString() + "\n";
			s+="Accuracy\t" + Accuracy.toPrecision(2) + "\n";
			s+="HitPoints\t" + HitPoints.toString() + "\n";
			s+="Level\t\t" + Level.toString() + "\n";
			s+="ManaProduction\t" + manaProduction.toString() + "\n";
			s+="StoneProduction\t" + stoneProduction.toString() + "\n";
			s+="WoodProduction\t" + woodProduction.toString() + "\n";
			return s;
		}
		
		override public function setPosition(pos:LatLng) : void {
			latitude = pos.lat();
			longitude = pos.lng();
		}

		// Interface to the isModified flag, which is true when an object has been create.

		override public function getMaxInfluence():Number {
			switch(this.Level){
				case 0:
					return 5.;
				case 1:
					return 10.;
				case 2:
					return 20.;
				case 3:
					return 40.;
				default:
					return 5.;
			}
		}
		override public function getPosition(b:LatLngBounds):LatLng{
			return new LatLng(this.latitude, this.longitude);
		}
		
		
		override public function isOverLappingBoundsOfObject(pos:LatLng, m:Map, photo:PhotoAssets) : Boolean {
			var iPos:LatLng = this.marker.getLatLng();
			var bounds:LatLngBounds = GameConstants.getBaseLatticeBounds(iPos, m, photo);
			return bounds.containsLatLng(pos);
		}
	}
}