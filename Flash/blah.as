
package {
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.base.Vertex;
	import away3d.core.math.Number3D;
	import away3d.materials.WireColorMaterial;
	import away3d.materials.WireframeMaterial;
	import away3d.primitives.LineSegment;
	import away3d.primitives.Sphere;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	[SWF(backgroundColor="#000000")]
	
	public class Example002 extends Sprite {
		
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		
		private var group:ObjectContainer3D;
		private var sphere:Sphere;
		
		public function Example002() {
			
			// set up the stage
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Add resize event listener
			stage.addEventListener(Event.RESIZE, onResize);
			
			// Initialise Papervision3D
			init3D();
			
			// Create the 3D objects
			createScene();
			
			// Initialise frame-enter loop
			this.addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function init3D():void {
			
			// Create a new scene where all the 3D object will be rendered
			scene = new Scene3D();
			
			// Create a new camera, passing some initialisation parameters
			camera = new Camera3D({zoom:15, focus:30, x:100, y:300, z:-200});
			camera.lookAt(new Number3D(0, 0, 0));
			
			// Create a new view that encapsulates the scene and the camera
			view = new View3D({scene:scene, camera:camera});
			
			// center the viewport to the middle of the stage
			view.x = stage.stageWidth / 2;
			view.y = stage.stageHeight / 2;
			addChild(view);
		}
		
		private function createScene():void {
			
			// Create an object container to group the objects on the scene
			group = new ObjectContainer3D();
			scene.addChild(group);
			
			// Create a new sphere object using a wirecolor material
			var sphereMaterial:WireColorMaterial = new WireColorMaterial(0x5500FF, {wirecolor:0xFF9900});
			sphere = new Sphere({material:sphereMaterial, radius:50, segmentsW:10, segmentsH:10});
			
			// Position the sphere and add it to the group
			sphere.x = -100;
			group.addChild(sphere);
			
			// Create a origin vertex
			var origin:Vertex = new Vertex(0, 0, 0);
			
			// Create the red-coloured x-axis with a width of 2 and add it to the group
			var xAxis:LineSegment = new LineSegment({material:new WireframeMaterial(0xFF0000, {width:2})});
			xAxis.start = origin;
			xAxis.end = new Vertex(100, 0, 0);
			group.addChild(xAxis);
			
			// Create the green-coloured y-axis with a width of 2 and add it to the group
			var yAxis:LineSegment = new LineSegment({material:new WireframeMaterial(0x00FF00, {width:2})});
			yAxis.start = origin;
			yAxis.end = new Vertex(0, 100, 0);
			group.addChild(yAxis);
			
			// Create the blue-coloured z-axis with a width of 2 and add it to the group
			var zAxis:LineSegment = new LineSegment({material:new WireframeMaterial(0x0000FF, {width:2})});
			zAxis.start = origin;
			zAxis.end = new Vertex(0, 0, 100);
			group.addChild(zAxis);
			
		}
		
		private function loop(event:Event):void {
			
			// rotate the group of objects
			group.yaw(5);
			
			// rotate the sphere
			sphere.yaw(-10);
			
			// Render the 3D scene
			view.render();
		}
		
		private function onResize(event:Event):void {
			view.x = stage.stageWidth / 2;
			view.y = stage.stageHeight / 2;
		}
	}
}
