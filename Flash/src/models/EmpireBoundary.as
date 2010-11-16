package models
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	
	import managers.states.TowerSaintServiceState;
	
	import models.Portal;
	import models.Road;
	import models.Tower;
	
	import mx.collections.ArrayCollection;
	import mx.controls.List;

	// A model for all empire boundaries with the bounds.
	public class EmpireBoundary
	{
		// The objects of the boundary
		private var lattice:ArrayCollection;
		private var map:Map;
		private var service:TowerSaintServiceState;
		private var bounds:LatLngBounds;
		private var hasLattice:Boolean;
		private const noEmpire:String = "noEmpire";
		
		public function EmpireBoundary(m:Map, s:TowerSaintServiceState, b:LatLngBounds)
		{
			map = m;
			service = s;
			bounds = b;
			
			// Initial state
			lattice = new ArrayCollection();
			hasLattice = false;
		}
		
		/*
			Function will analyze the influence of all the super objects. It will then create
			a lattice(2D array), which stores the empire which has the most influence at that lattice
			location. If there is a conflict, that lattice location will be divided.
		*/
		public function draw(listOfObjects:ArrayCollection):void{
			if(!hasLattice){
				this.hasLattice = true;
				_createLattice();
			}
		}
		
		/* 
			Function creates the lattice data structure
		*/
		private function _createLattice():void{
			// The bounding variables
			var southWest:LatLng = bounds.getSouthWest();
			var northEast:LatLng = bounds.getNorthEast();
			
			// The initial position
			var initialPosition:LatLng = new LatLng(southWest.lat() + .5 * this.service.getLatOffset(),
													southWest.lng() + .5 * this.service.getLonOffset());
			for(var i:int = 0; i < int((northEast.lat() - southWest.lat()) / this.service.getLatOffset()); i++){
				for(var j:int = 0; j <  int((northEast.lng() - southWest.lng()) / this.service.getLatOffset()); j++){
					var currentObj:Object = new Object();
					var currentPosition:LatLng = new LatLng(initialPosition.lat() + i * this.service.getLatOffset(), 
															initialPosition.lng() + j * this.service.getLonOffset());
					currentObj[currentPosition] = noEmpire;
					this.lattice.addItem(currentObj);
				}
			}
		}
	}
}