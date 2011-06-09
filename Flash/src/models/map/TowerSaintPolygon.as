package models.map
{
	import com.google.maps.LatLng;
	import com.google.maps.overlays.Polygon;
	import com.google.maps.overlays.PolygonOptions;
	
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	
	import pl.bmnet.gpcas.geometry.Clip;
	import pl.bmnet.gpcas.geometry.Poly;
	import pl.bmnet.gpcas.geometry.PolyDefault;

	public class TowerSaintPolygon extends PolyDefault
	{
		private var isAtValidLocation:Boolean;				/* True if the polygon is active */
		public function TowerSaintPolygon( isA:Boolean)
		{
			this.isAtValidLocation = isA;
			super(false);
		}
		
		/*
		Set the function as active 
		*/
		public function setValid(b:Boolean):void{
			this.isAtValidLocation = b;
		}
		public function isValid() : Boolean{
			return this.isAtValidLocation;
		}
		
		// Create a tower saint polygon from a poly
		public static function createTSPolygonFromPoly(p:Poly, b:Boolean) :TowerSaintPolygon{
			var tsp:TowerSaintPolygon = new TowerSaintPolygon(b);
			tsp.addPoly(p);
			return tsp;
		}
		
	}
}