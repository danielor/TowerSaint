package character.away3D
{
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.base.Vertex;
	import away3d.core.utils.Color;
	import away3d.materials.ColorMaterial;
	import away3d.materials.WireColorMaterial;
	import away3d.materials.WireframeMaterial;
	import away3d.primitives.LineSegment;
	import away3d.primitives.RegularPolygon;
	
	import flash.display.Scene;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;

	// Focus circle draws a circle around the object that has focus.
	public class FocusCircle
	{
		private var arrayOfSegments:ArrayCollection;			// An Array collection of line segments
		private var currentCenter:Point;						// The current point
		private var radius:Number;								// The radius
		private var numberOfSegments:Number;					// The number of segments
		private var scene:Scene3D;								// The scened where we will be drawing the focus
		public function FocusCircle(r:Number, p:Point, s:Scene3D, seg:int = 20)
		{
			this.radius = r;
			this.currentCenter = p;
			this.numberOfSegments = seg;
			this.scene = s;
			
			// Create the list
			arrayOfSegments = new ArrayCollection();
			
			this._draw();
		}
		
		// Draw the circle
		private function _draw():void{	
			// Setup the wire color material and draw.
			var outlineMaterial:ColorMaterial = new ColorMaterial(0x00FF00);
			outlineMaterial.alpha = 1.;
			
			
			// Iterate around a circle
			var line:LineSegment;
			var angleStep:Number = 360 / this.numberOfSegments;
			var x:Number = this.radius + this.currentCenter.x;
			var y:Number = this.currentCenter.y;
			var angle:Number;
			for(var i:int = 0; i < this.numberOfSegments + 1; ++i){
				// Create the line
				line = new LineSegment({material:outlineMaterial});
				line.start = new Vertex(x, y, 0);
				angle = angleStep * i;
				x = Math.cos(-angle/180 * Math.PI) * radius + currentCenter.x;
				y = Math.sin(angle/ 180 * Math.PI) * radius + currentCenter.y;
				line.end = new Vertex(x, y, 0);
				scene.addChild(line);
				this.arrayOfSegments.addItem(line);
			}
			
		}
		
		// Change the focus to
		public function changeFocusToPoint(p:Point):void{
			var xDiff:Number = p.x - this.currentCenter.x;
			var yDiff:Number = p.y - this.currentCenter.y;
			for(var i:int = 0; i < this.arrayOfSegments.length; i++){
				var l:LineSegment = this.arrayOfSegments[i] as LineSegment;
				
				var s:Vertex = l.start;
				var e:Vertex = l.end;
				s.x = s.x + xDiff; s.y = s.y + yDiff;
				e.x = e.x + xDiff; e.y = e.y + yDiff;
				
			}
			
			// Save the current center
			this.currentCenter = p;
		}
	}
}