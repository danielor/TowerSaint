//AS3ExporterAIR version 2.3, code Flash 10, generated by Prefab3D: http://www.closier.nl/prefab
package models.away3D.buildings
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.core.base.*;
	import away3d.loaders.data.*;
	import away3d.loaders.utils.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.*;
	import flash.utils.Dictionary;
	
	import models.interfaces.FilteredObject;
	
	public class Portal3D extends ObjectContainer3D implements FilteredObject
	{
		[Embed(source="assets/pictures/aw_0.jpg")]
		private var Aw_0_Bitmap_Bitmap:Class;
		
		private var objs:Object = {};
		private var geos:Array = [];
		private var oList:Array =[];
		private var focusFilters:Array = [];						// Focus filters
		private var aC:Array;
		private var aV:Array;
		private var aU:Array;
		private var _scale:Number;
		
		public function Portal3D(scale:Number = 1)
		{
			_scale = scale;
			setSource();
			addContainers();
			createFilters();
			buildMeshes();
			buildMaterials();
			cleanUp();
		}
		
		private function createFilters():void {
			// First object
			var gF:GlowFilter = new GlowFilter(0x4169e1,0,6.0,6.0,2,BitmapFilterQuality.MEDIUM,false, false);
			focusFilters.push(gF);
		}
		
		// The Filtered Object interface
		public function updateFilter(i:Number):void{
			for(var k:int = 0; k < focusFilters.length; k++){
				var gf:GlowFilter = focusFilters[k] as GlowFilter;
				gf.alpha = i;
			}
		}
		public function changeFilterState(b:Boolean):void {
			for(var k:int = 0; k < focusFilters.length; k++){
				var gf:GlowFilter = focusFilters[k] as GlowFilter;
				if(b){
					gf.alpha = 1;
				}else{
					gf.alpha = 0;
				}
			}
		}
		
		
		private function buildMeshes():void
		{
			var m0:Matrix3D = new Matrix3D();
			m0.rawData = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,16.905250000000006*_scale,-45.60765*_scale,26.581799999999987*_scale,1]);
			transform = m0;
			
			objs.obj0 = {name:"aw_0",  transform:m0, pivotPoint:new Vector3D(0,0,0), container:0, bothsides:false, material:null, ownCanvas:true, pushfront:false, pushback:false};
			objs.obj0.geo=geos[0];
			
			var ref:Object;
			var mesh:Mesh;
			var j:int;
			var av:Array;
			var au:Array;
			var v0:Vertex;
			var v1:Vertex;
			var v2:Vertex;
			var u0:UV;
			var u1:UV;
			var u2:UV;
			var aRef:Vector.<Face>;
			for(var i:int = 0;i<1;++i){
				ref = objs["obj"+i];
				if(ref != null){
					mesh = new Mesh();
					mesh.type = ".as";
					mesh.bothsides = ref.bothsides;
					mesh.name = ref.name;
					mesh.pushfront = ref.pushfront;
					mesh.pushback = ref.pushback;
					mesh.ownCanvas = ref.ownCanvas;
					mesh.filters = [focusFilters[i]]
					if(aC[ref.container]!= null)
						aC[ref.container].addChild(mesh);
					
					oList.push(mesh);
					mesh.transform = ref.transform;
					mesh.movePivot(ref.pivotPoint.x, ref.pivotPoint.y, ref.pivotPoint.z);
					if (ref.geo.geometry != null) {
						mesh.geometry = ref.geo.geometry;
						continue;
					}
					ref.geo.geometry = new Geometry();
					mesh.geometry = ref.geo.geometry;
					aRef = ref.geo.f;
					for(j = 0;j<aRef.length;++j){
						Face(aRef[j]).material = ref.material;
						ref.geo.geometry.addFace( Face(aRef[j]));
					}
					
				}
			}
		}
		
		private function setSource():void
		{
			var geo0vert:String ="c9.1f4835c1cdfb/-21.4d35/-137.1d81,c9.b225/-21.4d35/-158.634,a8.ff37/0.8c4765f6f4d0d8/-158.a5e,a8.d36d/0.8c4765f6f4d0d8/-137.21ab,ea.5526c4ddf9fd/-0.8c4765f6f4d0d8/-137.3ac5842537fc,eb.0465bc751e03/-0.8c4765f6f4d0d8/-158.01f1,ca.342b/21.4d35/-137.1d67,ca.16577c1951fc/21.4d35/-158.e34d08d27fc,c9.1703c78939fa/-21.4d35/-119.20d4,a8.afeb/0.8c4765f6f4d0d8/-119.243c,ea.14a41/-0.8c4765f6f4d0d8/-119.1d57,ca.010b3/21.4d35/-119.20bf,c9.4a1f/-21.4d35/-fe.082f79cd8ffd,a8.2333b5c6aa02/0.8c4765f6f4d0d8/-fe.d8f8140ebfe,ea.47252d566a03/-0.8c4765f6f4d0d8/-fe.02aed9b3bbfe,c9.17ea3/21.4d35/-fe.080ee12717ff,c9.3cc3/-21.4d35/-e4.846,a8.89cb/0.8c4765f6f4d0d8/-e4.95a,ea.4408e573d1fe/-0.8c4765f6f4d0d8/-e4.72b,c9.1713d/21.4d35/-e4.83f,c9.d5b1e356203/-21.4d35/-cb.24d4,a8.1f4a89cdb1fe/0.8c4765f6f4d0d8/-cb.55a5a96603fd,ea.120cf/-0.8c4765f6f4d0d8/-cb.55d8e26b9bff,c9.16dd7/21.4d35/-cb.24d4,c9.e3cf6b6c5fe/-21.4d35/-b5.01ee,a8.8a2f/0.8c4765f6f4d0d8/-b5.012d,ea.12499/-0.8c4765f6f4d0d8/-b5.02b4,c9.560f99830a05/21.4d35/-b5.0489d32d6bfe,c9.fbace54d604/-21.4d35/-9f.cae,a8.9097/0.8c4765f6f4d0d8/-9f.bed,ea.12b01/-0.8c4765f6f4d0d8/-9f.1f52aff74ffe,c9.578d71211a02/21.4d35/-9f.cb3,c9.1087b26b3602/-21.4d35/-8a.16f1,a8.9407/0.8c4765f6f4d0d8/-8a.360f7415dffe,ea.4668959345fc/-0.8c4765f6f4d0d8/-8a.16a9,c9.17b6f/21.4d35/-8a.16f0,c9.efbe285cdfd/-21.4d35/-76.3ddf77fbebff,a8.8d6d/0.8c4765f6f4d0d8/-76.44056761fbfd,ea.127c3/-0.8c4765f6f4d0d8/-76.37969be37ffe,c9.56ce85521204/21.4d35/-76.3dba373dabfe,c9.27dd/-21.4d35/-63.2aaebdfab3ff,a8.750d/0.8c4765f6f4d0d8/-63.3a16e4a96bff,ea.3f1f9c5ee1fe/-0.8c4765f6f4d0d8/-63.1ae975705bff,c9.51185826c1fd/21.4d35/-63.2a4f48132ffe,c8.58430cc091fd/-21.4d35/-50.4c7866885fff,a8.421d/0.8c4765f6f4d0d8/-51.e83fa216ffe,ea.331046c7e9fe/-0.8c4765f6f4d0d8/-50.2ec8ceed5ffe,c9.45229f1295fb/21.4d35/-50.4bc51ef4cbff,c8.43d8007a1dfa/-21.4d35/-3e.3fc869bcf3fe,a7.17205/0.8c4765f6f4d0d8/-3f.1437d340dbff,ea.1e665d406a03/-0.8c4765f6f4d0d8/-3e.f4091e493fe,c9.d133/21.4d35/-3e.3ea30be2bbfe,c8.24959cd609fb/-21.4d35/-2c.58af50e97bff,a7.edcb/0.8c4765f6f4d0d8/-2d.44b65ae9abff,e9.180dd/-0.8c4765f6f4d0d8/-2c.1001d1bf7fff,c9.116e330461fe/21.4d35/-2c.56fbec39efff,c7.16459/-21.4d35/-1b.36e5a85bcfff,a7.31fb/0.8c4765f6f4d0d8/-1c.28002ec8747f3,e9.2c3013aa9a03/-0.8c4765f6f4d0d8/-1a.1b1eb8005b7f2,c8.3fce3bdaadfd/21.4d35/-1b.20cde907ff7f3,c7.610d/-21.4d35/-a.1edf25293d7f4,a6.2b966899d1fe/0.8c4765f6f4d0d8/-c.017bce13a87f5,e8.495d48abba02/-0.8c4765f6f4d0d8/-9.0164859cc07f3,c8.03659f592603/21.4d35/-a.2e25d3ad07ff,c6.22cd43bb79fe/-21.4d35/6.d6d29918900e,a5.f8bb/0.8c4765f6f4d0d8/4.1157ca11ef80c,e7.16625/-0.8c4765f6f4d0d8/8.c28a7984780d,c7.42c7/21.4d35/6.a0b243ac7b087,c5.1a146b305dfe/-21.4d35/16.2ac1f35ccd00d,a4.e0bf/0.8c4765f6f4d0d8/14.1bcda1fda401,e6.477456eab1fe/-0.8c4765f6f4d0d8/19.176b639a5c01,c6.01d01/21.4d35/16.49c4e4bcdc01,c3.16c97/-21.4d35/27.0a8cd5e12010,a3.69cd/0.8c4765f6f4d0d8/23.37c656d74200f,e5.9551/-0.8c4765f6f4d0d8/2a.a73395e5401,c4.4173a842e1fd/21.4d35/27.07af6b3f9401,c2.739b/-21.4d35/37.0119b99ec401,a1.111bb/0.8c4765f6f4d0d8/33.1dd030417801,e3.3d7a2ff6adfd/-0.8c4765f6f4d0d8/3a.4765349d6801,c3.01f81/21.4d35/37.5bad5431800e,c0.8863/-21.4d35/46.1d0c,9f.4cc4120ad1fe/0.8c4765f6f4d0d8/42.1e5e3716cc01,e1.39e97dc18dfb/-0.8c4765f6f4d0d8/4b.1797a07c4803,c1.336d/21.4d35/46.4d479eaaa401,be.01b03/-21.4d35/56.1140cc1c8402,9d.3e0f32efadff/0.8c4765f6f4d0d8/50.594ff81df003,df.5c0d/-0.8c4765f6f4d0d8/5b.146b,be.14b95/21.4d35/56.1ca62a4f7801,bb.a9ab/-21.4d35/65.1dee74dc0c01,9b.4dfd/0.8c4765f6f4d0d8/5f.16cd1071cc02,dc.add9/-0.8c4765f6f4d0d8/6b.3262d1521002,bc.522b/21.4d35/65.2b3f18dbec01,b8.a63b/-21.4d35/74.55f,98.95ab/0.8c4765f6f4d0d8/6d.a8131a5ac01,d9.5d7f/-0.8c4765f6f4d0d8/7b.1de2d0a09801,b9.4cef/21.4d35/74.1be29668a802,b5.0267d64911fe/-21.4d35/82.16fc,95.573f/0.8c4765f6f4d0d8/7a.322af034b001,d5.e871/-0.8c4765f6f4d0d8/8a.1ffb,b5.480959e3b202/21.4d35/82.1e8b,b1.575d/-21.4d35/90.1998,91.116f7/0.8c4765f6f4d0d8/87.14e9,d1.2cb972682602/-0.8c4765f6f4d0d8/99.5a77aa040c02,b1.17fb1/21.4d35/90.4f9006533002,ad.00afc981bdfe/-21.4d35/9e.c2d,8d.14d2f/0.8c4765f6f4d0d8/94.01bd,cc.16445/-0.8c4765f6f4d0d8/a8.4b2477c05803,ad.44e615dd6dfe/21.4d35/9e.32d4e798b402,a8.21cad2939dfe/-21.4d35/ab.14d0,89.3a4b47b4f5fe/0.8c4765f6f4d0d8/a0.0556b743cc02,c7.148e3/-0.8c4765f6f4d0d8/b7.19bf6f7e5c02,a9.2b7f/21.4d35/ab.4993ffc32803,a3.1c6acb2041fe/-21.4d35/b8.1ab89076a803,85.0203f/0.8c4765f6f4d0d8/ab.32d73ba49803,c2.1891eb7a85fd/-0.8c4765f6f4d0d8/c5.d19,a4.0fb9/21.4d35/b8.1774,9d.14447/-21.4d35/c4.1652,80.485d/0.8c4765f6f4d0d8/b6.14a5,bc.112aadab8e03/-0.8c4765f6f4d0d8/d2.569c76526c04,9e.d471/21.4d35/c4.2386,97.16a3f/-21.4d35/d0.d64,7a.573e478cd1fe/0.8c4765f6f4d0d8/c0.3b8,b5.e78b/-0.8c4765f6f4d0d8/e0.975704e3ffe,98.38cfc422c9fd/21.4d35/d0.1bdd,91.ee1b/-21.4d35/db.3552dc52bc02,75.a307/0.8c4765f6f4d0d8/ca.4a44f34ad802,ae.bbad/-0.8c4765f6f4d0d8/ec.1dae,92.1a3757e2b9fe/21.4d35/db.26ad,8a.159b9/-21.4d35/e6.afd,6f.e05b/0.8c4765f6f4d0d8/d4.458,a6.14d43/-0.8c4765f6f4d0d8/f8.50d850dfc3fe,8b.d3ef/21.4d35/e6.415d89d1ec04,83.12aa7/-21.4d35/f0.25192975dc04,69.ae8d/0.8c4765f6f4d0d8/dc.2051,9e.117a1/-0.8c4765f6f4d0d8/104.29d3e19cfc06,84.9b87/21.4d35/f0.4ff8cc6a4403,7c.17c2b35841ff/-21.4d35/f9.2504,63.01487/0.8c4765f6f4d0d8/e4.572cd133a402,96.01e05/-0.8c4765f6f4d0d8/10f.283571587404,7c.1531f/21.4d35/fa.2930e65ca403,74.9899/-21.4d35/102.227a,5c.a05f/0.8c4765f6f4d0d8/ec.2d79883d2003,8c.1724b/-0.8c4765f6f4d0d8/119.1f69,74.17a1b/21.4d35/103.1076,6c.f7748fc01ff/-21.4d35/10b.7ac,55.d2ff/0.8c4765f6f4d0d8/f3.28e410d44003,83.1f5ad620edfe/-0.8c4765f6f4d0d8/123.141d,6c.4103e60821fe/21.4d35/10b.1e01,63.384fb594cdff/-21.4d35/112.221f,4e.b405/0.8c4765f6f4d0d8/f9.1f82,79.7003/-0.8c4765f6f4d0d8/12c.153f,64.3237/21.4d35/113.2b62058e4803,5a.450daaa79201/-21.4d35/119.2325,47.117e7f579dff/0.8c4765f6f4d0d8/ff.340141969802,6e.488018421dff/-0.8c4765f6f4d0d8/134.4e5a5c25bc04,5b.59f1/21.4d35/11a.14d7,51.efa1/-21.4d35/120.a3a,3f.448ff02579ff/0.8c4765f6f4d0d8/104.43f2c702dc05,63.160c1/-0.8c4765f6f4d0d8/13c.1125,52.03f1522295ff/21.4d35/120.540e35452804,48.50a5/-21.4d35/125.2507,38.4001/0.8c4765f6f4d0d8/109.1e881fecd403,58.39c6910f31fe/-0.8c4765f6f4d0d8/143.f9,48.35e6b545c9ff/21.4d35/126.18df,3e.2015d41be53fa/-21.4d35/12a.56280bffe404,30.281856c3d1ff/0.8c4765f6f4d0d8/10d.d50,4d.0af5/-0.8c4765f6f4d0d8/149.a6a,3e.52425e18c1ff/21.4d35/12b.19c9,34.11733/-21.4d35/12f.9c8,28.2237867ec2bfb/0.8c4765f6f4d0d8/110.2fe,41.2e95/-0.8c4765f6f4d0d8/14e.1250,35.005ddc1f573fa/21.4d35/12f.2673,2a.27024077a23fa/-21.4d35/132.212d,20.1036f/0.8c4765f6f4d0d8/113.267,34.565ec31751ff/-0.8c4765f6f4d0d8/152.20a3,2a.545c34d37dff/21.4d35/133.177c,20.1ce6ebda2d3fc/-21.4d35/135.1cc8,18.249f1246583fc/0.8c4765f6f4d0d8/115.22ca,28.331beb035dff/-0.8c4765f6f4d0d8/156.da8,20.1108f/21.4d35/136.2dc8b1d16806,16.c0dbbcecb3fa/-21.4d35/137.2370,10.1fbb9b4f223fd/0.8c4765f6f4d0d8/117.1741,1c.001dd4d8593f9/-0.8c4765f6f4d0d8/158.3e5,16.13ca3fd141bf9/21.4d35/138.3e4f3a36ac03,b.2f18fd46dbbf9/-21.4d35/139.dee,8.17fda2c53d3fd/0.8c4765f6f4d0d8/118.1c8f,f.120723d172bfc/-0.8c4765f6f4d0d8/15a.45cdc07c8c04,b.33c3b39c3c3fb/21.4d35/13a.8e,1.ddc64c19757d4/-21.4d35/13a.052,0.59b031995ace54/0.8c4765f6f4d0d8/119.bad,2.1f8ff3702f3fb/-0.8c4765f6f4d0d8/15b.198f,1.ed5985a4277d0/21.4d35/13a.4f3c34a72004,-9.0402a33b05c04/-21.4d35/13a.052,-7.351837673d405/0.8c4765f6f4d0d8/119.bad,-a.d53b24f7b404/-0.8c4765f6f4d0d8/15b.198f,-9.058fe7a7dc405/21.4d35/13a.4f3c34a72004,-13.1d9416ce8ac04/-21.4d35/139.dee,-10.6ce978363c03/0.8c4765f6f4d0d8/118.1c89,-17.002aed9b3bc06/-0.8c4765f6f4d0d8/15a.1e01,-13.223be4150e405/21.4d35/13a.8e,-1d.34a3cd14b5404/-21.4d35/137.236f,-18.1049d9ef5dc05/0.8c4765f6f4d0d8/117.35e7df4bbc04,-23.11201/-0.8c4765f6f4d0d8/158.5ae51832e804,-1e.01829/21.4d35/138.2ad,-28.6347/-21.4d35/135.1cc4,-20.25cd9b0f6201/0.8c4765f6f4d0d8/115.2287,-30.6ddd/-0.8c4765f6f4d0d8/156.205c1d42d804,-28.2846e7b1a201/21.4d35/136.13a9,-32.b81f/-21.4d35/132.2129,-28.2c49b02d6601/0.8c4765f6f4d0d8/113.1789,-3c.10fe5/-0.8c4765f6f4d0d8/152.211c,-32.115fd/21.4d35/133.177c,-3c.d4c1/-21.4d35/12f.19,-30.bb67/0.8c4765f6f4d0d8/110.1d29,-48.51dbec0d9201/-0.8c4765f6f4d0d8/14e.130e,-3c.2f79083158c06/21.4d35/12f.2673,-46.ac99/-21.4d35/12a.24fb,-38.21f4bb69a601/0.8c4765f6f4d0d8/10d.c43,-54.14ba9/-0.8c4765f6f4d0d8/149.1aa147ffc006,-46.130e7/21.4d35/12b.3c06d28e1ffd,-50.333b/-21.4d35/125.3b3,-40.d43d5be7a01/0.8c4765f6f4d0d8/109.bd3,-60.c3cd/-0.8c4765f6f4d0d8/143.198c3678c403,-50.c98b/21.4d35/126.39e5ffafb804,-59.e349/-21.4d35/120.17b13cff1404,-47.12efd/0.8c4765f6f4d0d8/104.1bc9,-6b.13f15/-0.8c4765f6f4d0d8/13c.1d9,-5a.041f/21.4d35/120.2416,-62.12aa7/-21.4d35/119.382,-4f.5e01/0.8c4765f6f4d0d8/ff.30f2f1fb5802,-76.44fb0a487201/-0.8c4765f6f4d0d8/134.512c228bd404,-63.15550af17601/21.4d35/11a.14ce,-6b.fe3d/-21.4d35/112.4f3c34a72004,-56.caa3/0.8c4765f6f4d0d8/f9.472403507802,-81.71f7/-0.8c4765f6f4d0d8/12c.33504e0ee7fd,-6c.e8524276201/21.4d35/113.2b381cb84003,-74.53bb/-21.4d35/10b.78e,-5d.e5ab/0.8c4765f6f4d0d8/f3.284cb9cf5c02,-8b.230c20fc8602/-0.8c4765f6f4d0d8/123.1421,-74.12877/21.4d35/10b.1de3,-7c.a7e9/-21.4d35/102.2250,-64.a68b/0.8c4765f6f4d0d8/ec.1459,-95.01039b2dce01/-0.8c4765f6f4d0d8/119.46676b8d5403,-7d.002fd/21.4d35/103.1046,-84.6b3f/-21.4d35/f9.24cb,-6b.0128dbec0dfe/0.8c4765f6f4d0d8/e5.0184d3c1bc01,-9e.d27e52fc9fe/-0.8c4765f6f4d0d8/10f.e7c,-84.504920047e02/21.4d35/fa.1168,-8b.42329411ea02/-21.4d35/f0.fa2,-71.7f53/0.8c4765f6f4d0d8/dc.54dd6d676c02,-a6.12aed/-0.8c4765f6f4d0d8/104.1e8cc8049c04,-8c.8def/21.4d35/f0.4f045389c002,-92.12d31/-21.4d35/e6.189eb9bbec03,-77.8737/0.8c4765f6f4d0d8/d4.18dd96fcf7fe,-ae.4ddb779db1fe/-0.8c4765f6f4d0d8/f8.1b64,-93.a875/21.4d35/e6.1b7f,-99.97b3/-21.4d35/db.1657,-7d.04f3c34a71ff/0.8c4765f6f4d0d8/cb.01ab,-b6.24c681cfbe02/-0.8c4765f6f4d0d8/ec.2d623fc63802,-9a.06684ab8f202/21.4d35/db.5833ea734802,-9f.338e014a0202/-21.4d35/d0.ca2,-82.a947/0.8c4765f6f4d0d8/c1.f8,-bd.9ce5/-0.8c4765f6f4d0d8/df.4546b5cae402,-a0.18635a8cb602/21.4d35/d0.3e6b2ac55c02,-a5.73af/-21.4d35/c4.1550,-87.b685/0.8c4765f6f4d0d8/b6.2313,-c3.1495b/-0.8c4765f6f4d0d8/d2.1463,-a6.0591/21.4d35/c4.2225,-aa.de7b/-21.4d35/b8.17a344b7bc04,-8c.37cd/0.8c4765f6f4d0d8/ac.003edd410c03,-c9.4247887cee02/-0.8c4765f6f4d0d8/c4.1fb9,-ab.75fd/21.4d35/b8.327a19c8f804,-af.22dfe41a99fe/-21.4d35/ab.2c701af19802,-90.af7d/0.8c4765f6f4d0d8/a0.344e171efc02,-cf.05a95ee9e9fe/-0.8c4765f6f4d0d8/b6.3c78e8d4c402,-b0.320f/21.4d35/ab.445490f64401,-b3.12025/-21.4d35/9e.172eda653402,-94.9407/0.8c4765f6f4d0d8/94.3939b43fd003,-d3.4d6e096ed602/-0.8c4765f6f4d0d8/a8.464,-b4.c071/21.4d35/9e.1302,-b7.39ddd9861a02/-21.4d35/90.16c5,-97.545e88df6203/0.8c4765f6f4d0d8/88.714,-d8.2a49/-0.8c4765f6f4d0d8/99.74c,-b8.9c13/21.4d35/90.476788a94c03,-bb.021f7/-21.4d35/82.2d3aaafc1402,-9b.02517/0.8c4765f6f4d0d8/7b.16a57ba7a801,-db.14ba9/-0.8c4765f6f4d0d8/89.53aebf5da402,-bb.4df2c0149a02/21.4d35/82.3d1990093802,-be.27bf/-21.4d35/74.022a230df801,-9d.1599b/0.8c4765f6f4d0d8/6d.4d81d3d3e802,-df.08926dc6ea02/-0.8c4765f6f4d0d8/7a.1f495fc7c001,-be.156ad/21.4d35/74.fae00137002,-c0.11035/-21.4d35/65.11272f99b801,-a0.1bbe7fb05a02/0.8c4765f6f4d0d8/60.07a,-e1.4efc2d602202/-0.8c4765f6f4d0d8/6a.2c8763688001,-c1.ba31/21.4d35/65.1c7c41797001,-c2.15cc5/-21.4d35/56.01977420dc01,-a2.8ff7/0.8c4765f6f4d0d8/51.4464dd498001,-e4.12341af715fe/-0.8c4765f6f4d0d8/5a.2311f31a4003,-c3.10801/21.4d35/56.4b2,-c4.40e5a16d8e03/-21.4d35/46.3098242b9c02,-a4.08539085ddfe/0.8c4765f6f4d0d8/43.08983fe4a401,-e6.afdc221d205/-0.8c4765f6f4d0d8/4a.052f2279a802,-c5.c2dd/21.4d35/46.381ffaa10c01,-c6.488f/-21.4d35/36.451a78e8f801,-a5.c111/0.8c4765f6f4d0d8/34.0574fbde6001,-e7.3c6c1a935dfc/-0.8c4765f6f4d0d8/39.2fb3f79e5401,-c6.587899d20e02/21.4d35/36.4b03df19e001,-c7.1ed61f7b2a01/-21.4d35/26.4089a997e001,-a6.ea5b/0.8c4765f6f4d0d8/24.25cfef1b46006,-e8.15261/-0.8c4765f6f4d0d8/28.2da6a4a38180f,-c8.31ab/21.4d35/26.2b21fe474a00f,-c8.129a8d024604/-21.4d35/16.23c092960c01,-a7.a9dd/0.8c4765f6f4d0d8/14.345309b840808,-e9.456878774dfd/-0.8c4765f6f4d0d8/17.3337468f15012,-c8.18411/21.4d35/16.185b7ee49480e,-c8.4a23309e6e02/-21.4d35/5.1cd82ffeee7055,-a8.0a9b/0.8c4765f6f4d0d8/4.2f255bc60700b,-ea.23b618608a03/-0.8c4765f6f4d0d8/6.4a67dffd3401,-c9.36fbc6ccc602/21.4d35/5.2f7f9492ca00d,-c9.129ce10e2a02/-21.4d35/-b.025ed09afe7f4,-a8.24fe62ed1e02/0.8c4765f6f4d0d8/-b.22e6e03e45ff4,-ea.13565/-0.8c4765f6f4d0d8/-a.296d6f91cbff,-c9.18457/21.4d35/-b.0195ff996d7f4,-c9.9eed/-21.4d35/-1c.10ef4e7c57ff,-a8.ec4f/0.8c4765f6f4d0d8/-1c.26b799ba63ff,-ea.1860f/-0.8c4765f6f4d0d8/-1b.357be5a44e7f8,-ca.11e0494b0603/21.4d35/-1c.a412a5eadff4,-c9.297595bb6a03/-21.4d35/-2d.2515ab6405ff2,-a8.ff19/0.8c4765f6f4d0d8/-2d.39922e03a7ff,-eb.0465bc751e03/-0.8c4765f6f4d0d8/-2d.3d22e038c7fe,-ca.5feb/21.4d35/-2d.251b7d81bfff1,-c9.22fe28b52dfd/-21.4d35/-3f.1b8ec4bc97ff2,-a8.e399/0.8c4765f6f4d0d8/-3f.fb90f4beaffb,-ea.58d367a1ca03/-0.8c4765f6f4d0d8/-3f.3f7de84073ff,-ca.4425/21.4d35/-3f.2c8e5f8c2bff,-c9.1485d2cf3203/-21.4d35/-51.1d0a,-a8.a5d7/0.8c4765f6f4d0d8/-51.256156e677ff,-ea.4a4175390203/-0.8c4765f6f4d0d8/-52.07a172f83bff,-ca.05ff/21.4d35/-51.4456e50227ff,-c9.00ce0e1c5202/-21.4d35/-64.2de6f66bfbff,-a8.516d/0.8c4765f6f4d0d8/-64.9a8a953d7ff,-ea.3677102701fd/-0.8c4765f6f4d0d8/-64.23a8,-c9.489e5cdcb1fd/21.4d35/-64.2ec67ae17bff,-c8.129b7/-21.4d35/-77.4e869907a7fd,-a7.177c3/0.8c4765f6f4d0d8/-77.28dac0a4afff,-ea.200279790e02/-0.8c4765f6f4d0d8/-78.1a2835956ffe,-c9.d787/21.4d35/-77.221e,-c8.c797/-21.4d35/-8b.247d,-a7.11585/0.8c4765f6f4d0d8/-8b.154e,-ea.93314fb5e05/-0.8c4765f6f4d0d8/-8c.14c,-c9.1b55b9994602/21.4d35/-8b.24da,-c8.6c39/-21.4d35/-a0.214c,-a7.2b4993116dfe/0.8c4765f6f4d0d8/-a0.1455,-e9.4eee3518ca03/-0.8c4765f6f4d0d8/-a1.117b0145c7ff,-c9.01a13/21.4d35/-a0.4e3e6b970bfd,-c8.01eaf/-21.4d35/-b6.1e57,-a7.6c1b/0.8c4765f6f4d0d8/-b6.1465,-e9.105bd/-0.8c4765f6f4d0d8/-b7.0177,-c8.15329/21.4d35/-b6.47344fa3b3fe,-c7.547f2185da02/-21.4d35/-cd.22c2,-a7.3179/0.8c4765f6f4d0d8/-cd.41b15b7dfbfc,-e9.2f63a40419fd/-0.8c4765f6f4d0d8/-ce.05934078f402,-c8.118b9/21.4d35/-cd.22ea,-c7.1470d/-21.4d35/-e6.f9d,-a7.0d7f/0.8c4765f6f4d0d8/-e6.c77,-e9.2713919011fe/-0.8c4765f6f4d0d8/-e6.2bdfc0105ffe,-c8.390551344602/21.4d35/-e6.fb1,-c7.495af49fd602/-21.4d35/-100.314dbfcb13fb,-a7.00177/0.8c4765f6f4d0d8/-100.21b,-e9.244b1b5989fc/-0.8c4765f6f4d0d8/-100.154d,-c8.e8e9/21.4d35/-100.152e,-c7.4bdfe57d8a03/-21.4d35/-11c.16b3,-a7.0c49/0.8c4765f6f4d0d8/-11c.27f,-e9.a6a9/-0.8c4765f6f4d0d8/-11c.1462,-c8.38bd23c3aa03/21.4d35/-11c.34b93141f3fb,-c7.52de5d356e02/-21.4d35/-13a.1fad,-a7.2a5d/0.8c4765f6f4d0d8/-13a.2376,-e9.c4a9/-0.8c4765f6f4d0d8/-13a.40ba8e9193fb,-c8.111c5/21.4d35/-13a.498aaf9397fc,-c8.01ec6fd2ddfe/-21.4d35/-15b.15c6,-a7.5555/0.8c4765f6f4d0d8/-15b.198f,-e9.efa1/-0.8c4765f6f4d0d8/-15b.11e7,-c8.49bf129f2202/21.4d35/-15b.15af";
			var geo0uvs:String ="0.270f/0,0.5/1,0/0";
			var geo0faces:String ="0,1,2,0,1,2,3,0,2,0,1,2,1,0,4,0,1,2,5,1,4,0,1,2,6,7,5,0,1,2,4,6,5,0,1,2,3,2,7,0,1,2,6,3,7,0,1,2,8,0,3,0,1,2,9,8,3,0,1,2,a,4,0,0,1,2,8,a,0,0,1,2,b,6,4,0,1,2,a,b,4,0,1,2,9,3,6,0,1,2,b,9,6,0,1,2,c,8,9,0,1,2,d,c,9,0,1,2,e,a,8,0,1,2,c,e,8,0,1,2,f,b,a,0,1,2,e,f,a,0,1,2,d,9,b,0,1,2,f,d,b,0,1,2,10,c,d,0,1,2,11,10,d,0,1,2,12,e,c,0,1,2,10,12,c,0,1,2,13,f,e,0,1,2,12,13,e,0,1,2,11,d,f,0,1,2,13,11,f,0,1,2,14,10,11,0,1,2,15,14,11,0,1,2,16,12,10,0,1,2,14,16,10,0,1,2,17,13,12,0,1,2,16,17,12,0,1,2,15,11,13,0,1,2,17,15,13,0,1,2,18,14,15,0,1,2,19,18,15,0,1,2,1a,16,14,0,1,2,18,1a,14,0,1,2,1b,17,16,0,1,2,1a,1b,16,0,1,2,19,15,17,0,1,2,1b,19,17,0,1,2,1c,18,19,0,1,2,1d,1c,19,0,1,2,1e,1a,18,0,1,2,1c,1e,18,0,1,2,1f,1b,1a,0,1,2,1e,1f,1a,0,1,2,1d,19,1b,0,1,2,1f,1d,1b,0,1,2,20,1c,1d,0,1,2,21,20,1d,0,1,2,22,1e,1c,0,1,2,20,22,1c,0,1,2,23,1f,1e,0,1,2,22,23,1e,0,1,2,21,1d,1f,0,1,2,23,21,1f,0,1,2,24,20,21,0,1,2,25,24,21,0,1,2,26,22,20,0,1,2,24,26,20,0,1,2,27,23,22,0,1,2,26,27,22,0,1,2,25,21,23,0,1,2,27,25,23,0,1,2,28,24,25,0,1,2,29,28,25,0,1,2,2a,26,24,0,1,2,28,2a,24,0,1,2,2b,27,26,0,1,2,2a,2b,26,0,1,2,29,25,27,0,1,2,2b,29,27,0,1,2,2c,28,29,0,1,2,2d,2c,29,0,1,2,2e,2a,28,0,1,2,2c,2e,28,0,1,2,2f,2b,2a,0,1,2,2e,2f,2a,0,1,2,2d,29,2b,0,1,2,2f,2d,2b,0,1,2,30,2c,2d,0,1,2,31,30,2d,0,1,2,32,2e,2c,0,1,2,30,32,2c,0,1,2,33,2f,2e,0,1,2,32,33,2e,0,1,2,31,2d,2f,0,1,2,33,31,2f,0,1,2,34,30,31,0,1,2,35,34,31,0,1,2,36,32,30,0,1,2,34,36,30,0,1,2,37,33,32,0,1,2,36,37,32,0,1,2,35,31,33,0,1,2,37,35,33,0,1,2,38,34,35,0,1,2,39,38,35,0,1,2,3a,36,34,0,1,2,38,3a,34,0,1,2,3b,37,36,0,1,2,3a,3b,36,0,1,2,39,35,37,0,1,2,3b,39,37,0,1,2,3c,38,39,0,1,2,3d,3c,39,0,1,2,3e,3a,38,0,1,2,3c,3e,38,0,1,2,3f,3b,3a,0,1,2,3e,3f,3a,0,1,2,3d,39,3b,0,1,2,3f,3d,3b,0,1,2,40,3c,3d,0,1,2,41,40,3d,0,1,2,42,3e,3c,0,1,2,40,42,3c,0,1,2,43,3f,3e,0,1,2,42,43,3e,0,1,2,41,3d,3f,0,1,2,43,41,3f,0,1,2,44,40,41,0,1,2,45,44,41,0,1,2,46,42,40,0,1,2,44,46,40,0,1,2,47,43,42,0,1,2,46,47,42,0,1,2,45,41,43,0,1,2,47,45,43,0,1,2,48,44,45,0,1,2,49,48,45,0,1,2,4a,46,44,0,1,2,48,4a,44,0,1,2,4b,47,46,0,1,2,4a,4b,46,0,1,2,49,45,47,0,1,2,4b,49,47,0,1,2,4c,48,49,0,1,2,4d,4c,49,0,1,2,4e,4a,48,0,1,2,4c,4e,48,0,1,2,4f,4b,4a,0,1,2,4e,4f,4a,0,1,2,4d,49,4b,0,1,2,4f,4d,4b,0,1,2,50,4c,4d,0,1,2,51,50,4d,0,1,2,52,4e,4c,0,1,2,50,52,4c,0,1,2,53,4f,4e,0,1,2,52,53,4e,0,1,2,51,4d,4f,0,1,2,53,51,4f,0,1,2,54,50,51,0,1,2,55,54,51,0,1,2,56,52,50,0,1,2,54,56,50,0,1,2,57,53,52,0,1,2,56,57,52,0,1,2,55,51,53,0,1,2,57,55,53,0,1,2,58,54,55,0,1,2,59,58,55,0,1,2,5a,56,54,0,1,2,58,5a,54,0,1,2,5b,57,56,0,1,2,5a,5b,56,0,1,2,59,55,57,0,1,2,5b,59,57,0,1,2,5c,58,59,0,1,2,5d,5c,59,0,1,2,5e,5a,58,0,1,2,5c,5e,58,0,1,2,5f,5b,5a,0,1,2,5e,5f,5a,0,1,2,5d,59,5b,0,1,2,5f,5d,5b,0,1,2,60,5c,5d,0,1,2,61,60,5d,0,1,2,62,5e,5c,0,1,2,60,62,5c,0,1,2,63,5f,5e,0,1,2,62,63,5e,0,1,2,61,5d,5f,0,1,2,63,61,5f,0,1,2,64,60,61,0,1,2,65,64,61,0,1,2,66,62,60,0,1,2,64,66,60,0,1,2,67,63,62,0,1,2,66,67,62,0,1,2,65,61,63,0,1,2,67,65,63,0,1,2,68,64,65,0,1,2,69,68,65,0,1,2,6a,66,64,0,1,2,68,6a,64,0,1,2,6b,67,66,0,1,2,6a,6b,66,0,1,2,69,65,67,0,1,2,6b,69,67,0,1,2,6c,68,69,0,1,2,6d,6c,69,0,1,2,6e,6a,68,0,1,2,6c,6e,68,0,1,2,6f,6b,6a,0,1,2,6e,6f,6a,0,1,2,6d,69,6b,0,1,2,6f,6d,6b,0,1,2,70,6c,6d,0,1,2,71,70,6d,0,1,2,72,6e,6c,0,1,2,70,72,6c,0,1,2,73,6f,6e,0,1,2,72,73,6e,0,1,2,71,6d,6f,0,1,2,73,71,6f,0,1,2,74,70,71,0,1,2,75,74,71,0,1,2,76,72,70,0,1,2,74,76,70,0,1,2,77,73,72,0,1,2,76,77,72,0,1,2,75,71,73,0,1,2,77,75,73,0,1,2,78,74,75,0,1,2,79,78,75,0,1,2,7a,76,74,0,1,2,78,7a,74,0,1,2,7b,77,76,0,1,2,7a,7b,76,0,1,2,79,75,77,0,1,2,7b,79,77,0,1,2,7c,78,79,0,1,2,7d,7c,79,0,1,2,7e,7a,78,0,1,2,7c,7e,78,0,1,2,7f,7b,7a,0,1,2,7e,7f,7a,0,1,2,7d,79,7b,0,1,2,7f,7d,7b,0,1,2,80,7c,7d,0,1,2,81,80,7d,0,1,2,82,7e,7c,0,1,2,80,82,7c,0,1,2,83,7f,7e,0,1,2,82,83,7e,0,1,2,81,7d,7f,0,1,2,83,81,7f,0,1,2,84,80,81,0,1,2,85,84,81,0,1,2,86,82,80,0,1,2,84,86,80,0,1,2,87,83,82,0,1,2,86,87,82,0,1,2,85,81,83,0,1,2,87,85,83,0,1,2,88,84,85,0,1,2,89,88,85,0,1,2,8a,86,84,0,1,2,88,8a,84,0,1,2,8b,87,86,0,1,2,8a,8b,86,0,1,2,89,85,87,0,1,2,8b,89,87,0,1,2,8c,88,89,0,1,2,8d,8c,89,0,1,2,8e,8a,88,0,1,2,8c,8e,88,0,1,2,8f,8b,8a,0,1,2,8e,8f,8a,0,1,2,8d,89,8b,0,1,2,8f,8d,8b,0,1,2,90,8c,8d,0,1,2,91,90,8d,0,1,2,92,8e,8c,0,1,2,90,92,8c,0,1,2,93,8f,8e,0,1,2,92,93,8e,0,1,2,91,8d,8f,0,1,2,93,91,8f,0,1,2,94,90,91,0,1,2,95,94,91,0,1,2,96,92,90,0,1,2,94,96,90,0,1,2,97,93,92,0,1,2,96,97,92,0,1,2,95,91,93,0,1,2,97,95,93,0,1,2,98,94,95,0,1,2,99,98,95,0,1,2,9a,96,94,0,1,2,98,9a,94,0,1,2,9b,97,96,0,1,2,9a,9b,96,0,1,2,99,95,97,0,1,2,9b,99,97,0,1,2,9c,98,99,0,1,2,9d,9c,99,0,1,2,9e,9a,98,0,1,2,9c,9e,98,0,1,2,9f,9b,9a,0,1,2,9e,9f,9a,0,1,2,9d,99,9b,0,1,2,9f,9d,9b,0,1,2,a0,9c,9d,0,1,2,a1,a0,9d,0,1,2,a2,9e,9c,0,1,2,a0,a2,9c,0,1,2,a3,9f,9e,0,1,2,a2,a3,9e,0,1,2,a1,9d,9f,0,1,2,a3,a1,9f,0,1,2,a4,a0,a1,0,1,2,a5,a4,a1,0,1,2,a6,a2,a0,0,1,2,a4,a6,a0,0,1,2,a7,a3,a2,0,1,2,a6,a7,a2,0,1,2,a5,a1,a3,0,1,2,a7,a5,a3,0,1,2,a8,a4,a5,0,1,2,a9,a8,a5,0,1,2,aa,a6,a4,0,1,2,a8,aa,a4,0,1,2,ab,a7,a6,0,1,2,aa,ab,a6,0,1,2,a9,a5,a7,0,1,2,ab,a9,a7,0,1,2,ac,a8,a9,0,1,2,ad,ac,a9,0,1,2,ae,aa,a8,0,1,2,ac,ae,a8,0,1,2,af,ab,aa,0,1,2,ae,af,aa,0,1,2,ad,a9,ab,0,1,2,af,ad,ab,0,1,2,b0,ac,ad,0,1,2,b1,b0,ad,0,1,2,b2,ae,ac,0,1,2,b0,b2,ac,0,1,2,b3,af,ae,0,1,2,b2,b3,ae,0,1,2,b1,ad,af,0,1,2,b3,b1,af,0,1,2,b4,b0,b1,0,1,2,b5,b4,b1,0,1,2,b6,b2,b0,0,1,2,b4,b6,b0,0,1,2,b7,b3,b2,0,1,2,b6,b7,b2,0,1,2,b5,b1,b3,0,1,2,b7,b5,b3,0,1,2,b8,b4,b5,0,1,2,b9,b8,b5,0,1,2,ba,b6,b4,0,1,2,b8,ba,b4,0,1,2,bb,b7,b6,0,1,2,ba,bb,b6,0,1,2,b9,b5,b7,0,1,2,bb,b9,b7,0,1,2,bc,b8,b9,0,1,2,bd,bc,b9,0,1,2,be,ba,b8,0,1,2,bc,be,b8,0,1,2,bf,bb,ba,0,1,2,be,bf,ba,0,1,2,bd,b9,bb,0,1,2,bf,bd,bb,0,1,2,c0,bc,bd,0,1,2,c1,c0,bd,0,1,2,c2,be,bc,0,1,2,c0,c2,bc,0,1,2,c3,bf,be,0,1,2,c2,c3,be,0,1,2,c1,bd,bf,0,1,2,c3,c1,bf,0,1,2,c4,c0,c1,0,1,2,c5,c4,c1,0,1,2,c6,c2,c0,0,1,2,c4,c6,c0,0,1,2,c7,c3,c2,0,1,2,c6,c7,c2,0,1,2,c5,c1,c3,0,1,2,c7,c5,c3,0,1,2,c8,c4,c5,0,1,2,c9,c8,c5,0,1,2,ca,c6,c4,0,1,2,c8,ca,c4,0,1,2,cb,c7,c6,0,1,2,ca,cb,c6,0,1,2,c9,c5,c7,0,1,2,cb,c9,c7,0,1,2,cc,c8,c9,0,1,2,cd,cc,c9,0,1,2,ce,ca,c8,0,1,2,cc,ce,c8,0,1,2,cf,cb,ca,0,1,2,ce,cf,ca,0,1,2,cd,c9,cb,0,1,2,cf,cd,cb,0,1,2,d0,cc,cd,0,1,2,d1,d0,cd,0,1,2,d2,ce,cc,0,1,2,d0,d2,cc,0,1,2,d3,cf,ce,0,1,2,d2,d3,ce,0,1,2,d1,cd,cf,0,1,2,d3,d1,cf,0,1,2,d4,d0,d1,0,1,2,d5,d4,d1,0,1,2,d6,d2,d0,0,1,2,d4,d6,d0,0,1,2,d7,d3,d2,0,1,2,d6,d7,d2,0,1,2,d5,d1,d3,0,1,2,d7,d5,d3,0,1,2,d8,d4,d5,0,1,2,d9,d8,d5,0,1,2,da,d6,d4,0,1,2,d8,da,d4,0,1,2,db,d7,d6,0,1,2,da,db,d6,0,1,2,d9,d5,d7,0,1,2,db,d9,d7,0,1,2,dc,d8,d9,0,1,2,dd,dc,d9,0,1,2,de,da,d8,0,1,2,dc,de,d8,0,1,2,df,db,da,0,1,2,de,df,da,0,1,2,dd,d9,db,0,1,2,df,dd,db,0,1,2,e0,dc,dd,0,1,2,e1,e0,dd,0,1,2,e2,de,dc,0,1,2,e0,e2,dc,0,1,2,e3,df,de,0,1,2,e2,e3,de,0,1,2,e1,dd,df,0,1,2,e3,e1,df,0,1,2,e4,e0,e1,0,1,2,e5,e4,e1,0,1,2,e6,e2,e0,0,1,2,e4,e6,e0,0,1,2,e7,e3,e2,0,1,2,e6,e7,e2,0,1,2,e5,e1,e3,0,1,2,e7,e5,e3,0,1,2,e8,e4,e5,0,1,2,e9,e8,e5,0,1,2,ea,e6,e4,0,1,2,e8,ea,e4,0,1,2,eb,e7,e6,0,1,2,ea,eb,e6,0,1,2,e9,e5,e7,0,1,2,eb,e9,e7,0,1,2,ec,e8,e9,0,1,2,ed,ec,e9,0,1,2,ee,ea,e8,0,1,2,ec,ee,e8,0,1,2,ef,eb,ea,0,1,2,ee,ef,ea,0,1,2,ed,e9,eb,0,1,2,ef,ed,eb,0,1,2,f0,ec,ed,0,1,2,f1,f0,ed,0,1,2,f2,ee,ec,0,1,2,f0,f2,ec,0,1,2,f3,ef,ee,0,1,2,f2,f3,ee,0,1,2,f1,ed,ef,0,1,2,f3,f1,ef,0,1,2,f4,f0,f1,0,1,2,f5,f4,f1,0,1,2,f6,f2,f0,0,1,2,f4,f6,f0,0,1,2,f7,f3,f2,0,1,2,f6,f7,f2,0,1,2,f5,f1,f3,0,1,2,f7,f5,f3,0,1,2,f8,f4,f5,0,1,2,f9,f8,f5,0,1,2,fa,f6,f4,0,1,2,f8,fa,f4,0,1,2,fb,f7,f6,0,1,2,fa,fb,f6,0,1,2,f9,f5,f7,0,1,2,fb,f9,f7,0,1,2,fc,f8,f9,0,1,2,fd,fc,f9,0,1,2,fe,fa,f8,0,1,2,fc,fe,f8,0,1,2,ff,fb,fa,0,1,2,fe,ff,fa,0,1,2,fd,f9,fb,0,1,2,ff,fd,fb,0,1,2,100,fc,fd,0,1,2,101,100,fd,0,1,2,102,fe,fc,0,1,2,100,102,fc,0,1,2,103,ff,fe,0,1,2,102,103,fe,0,1,2,101,fd,ff,0,1,2,103,101,ff,0,1,2,104,100,101,0,1,2,105,104,101,0,1,2,106,102,100,0,1,2,104,106,100,0,1,2,107,103,102,0,1,2,106,107,102,0,1,2,105,101,103,0,1,2,107,105,103,0,1,2,108,104,105,0,1,2,109,108,105,0,1,2,10a,106,104,0,1,2,108,10a,104,0,1,2,10b,107,106,0,1,2,10a,10b,106,0,1,2,109,105,107,0,1,2,10b,109,107,0,1,2,10c,108,109,0,1,2,10d,10c,109,0,1,2,10e,10a,108,0,1,2,10c,10e,108,0,1,2,10f,10b,10a,0,1,2,10e,10f,10a,0,1,2,10d,109,10b,0,1,2,10f,10d,10b,0,1,2,110,10c,10d,0,1,2,111,110,10d,0,1,2,112,10e,10c,0,1,2,110,112,10c,0,1,2,113,10f,10e,0,1,2,112,113,10e,0,1,2,111,10d,10f,0,1,2,113,111,10f,0,1,2,114,110,111,0,1,2,115,114,111,0,1,2,116,112,110,0,1,2,114,116,110,0,1,2,117,113,112,0,1,2,116,117,112,0,1,2,115,111,113,0,1,2,117,115,113,0,1,2,118,114,115,0,1,2,119,118,115,0,1,2,11a,116,114,0,1,2,118,11a,114,0,1,2,11b,117,116,0,1,2,11a,11b,116,0,1,2,119,115,117,0,1,2,11b,119,117,0,1,2,11c,118,119,0,1,2,11d,11c,119,0,1,2,11e,11a,118,0,1,2,11c,11e,118,0,1,2,11f,11b,11a,0,1,2,11e,11f,11a,0,1,2,11d,119,11b,0,1,2,11f,11d,11b,0,1,2,120,11c,11d,0,1,2,121,120,11d,0,1,2,122,11e,11c,0,1,2,120,122,11c,0,1,2,123,11f,11e,0,1,2,122,123,11e,0,1,2,121,11d,11f,0,1,2,123,121,11f,0,1,2,124,120,121,0,1,2,125,124,121,0,1,2,126,122,120,0,1,2,124,126,120,0,1,2,127,123,122,0,1,2,126,127,122,0,1,2,125,121,123,0,1,2,127,125,123,0,1,2,128,124,125,0,1,2,129,128,125,0,1,2,12a,126,124,0,1,2,128,12a,124,0,1,2,12b,127,126,0,1,2,12a,12b,126,0,1,2,129,125,127,0,1,2,12b,129,127,0,1,2,12c,128,129,0,1,2,12d,12c,129,0,1,2,12e,12a,128,0,1,2,12c,12e,128,0,1,2,12f,12b,12a,0,1,2,12e,12f,12a,0,1,2,12d,129,12b,0,1,2,12f,12d,12b,0,1,2,130,12c,12d,0,1,2,131,130,12d,0,1,2,132,12e,12c,0,1,2,130,132,12c,0,1,2,133,12f,12e,0,1,2,132,133,12e,0,1,2,131,12d,12f,0,1,2,133,131,12f,0,1,2,134,130,131,0,1,2,135,134,131,0,1,2,136,132,130,0,1,2,134,136,130,0,1,2,137,133,132,0,1,2,136,137,132,0,1,2,135,131,133,0,1,2,137,135,133,0,1,2,138,134,135,0,1,2,139,138,135,0,1,2,13a,136,134,0,1,2,138,13a,134,0,1,2,13b,137,136,0,1,2,13a,13b,136,0,1,2,139,135,137,0,1,2,13b,139,137,0,1,2,13c,138,139,0,1,2,13d,13c,139,0,1,2,13e,13a,138,0,1,2,13c,13e,138,0,1,2,13f,13b,13a,0,1,2,13e,13f,13a,0,1,2,13d,139,13b,0,1,2,13f,13d,13b,0,1,2,140,13c,13d,0,1,2,141,140,13d,0,1,2,142,13e,13c,0,1,2,140,142,13c,0,1,2,143,13f,13e,0,1,2,142,143,13e,0,1,2,141,13d,13f,0,1,2,143,141,13f,0,1,2,144,140,141,0,1,2,145,144,141,0,1,2,146,142,140,0,1,2,144,146,140,0,1,2,147,143,142,0,1,2,146,147,142,0,1,2,145,141,143,0,1,2,147,145,143,0,1,2,148,144,145,0,1,2,149,148,145,0,1,2,14a,146,144,0,1,2,148,14a,144,0,1,2,14b,147,146,0,1,2,14a,14b,146,0,1,2,149,145,147,0,1,2,14b,149,147,0,1,2,14c,148,149,0,1,2,14d,14c,149,0,1,2,14e,14a,148,0,1,2,14c,14e,148,0,1,2,14f,14b,14a,0,1,2,14e,14f,14a,0,1,2,14d,149,14b,0,1,2,14f,14d,14b,0,1,2,150,14c,14d,0,1,2,151,150,14d,0,1,2,152,14e,14c,0,1,2,150,152,14c,0,1,2,153,14f,14e,0,1,2,152,153,14e,0,1,2,151,14d,14f,0,1,2,153,151,14f,0,1,2,154,150,151,0,1,2,155,154,151,0,1,2,156,152,150,0,1,2,154,156,150,0,1,2,157,153,152,0,1,2,156,157,152,0,1,2,155,151,153,0,1,2,157,155,153,0,1,2,158,154,155,0,1,2,159,158,155,0,1,2,15a,156,154,0,1,2,158,15a,154,0,1,2,15b,157,156,0,1,2,15a,15b,156,0,1,2,159,155,157,0,1,2,15b,159,157,0,1,2,15c,158,159,0,1,2,15d,15c,159,0,1,2,15e,15a,158,0,1,2,15c,15e,158,0,1,2,15f,15b,15a,0,1,2,15e,15f,15a,0,1,2,15d,159,15b,0,1,2,15f,15d,15b,0,1,2,160,15c,15d,0,1,2,161,160,15d,0,1,2,162,15e,15c,0,1,2,160,162,15c,0,1,2,163,15f,15e,0,1,2,162,163,15e,0,1,2,161,15d,15f,0,1,2,163,161,15f,0,1,2,164,160,161,0,1,2,165,164,161,0,1,2,166,162,160,0,1,2,164,166,160,0,1,2,167,163,162,0,1,2,166,167,162,0,1,2,165,161,163,0,1,2,167,165,163,0,1,2,168,164,165,0,1,2,169,168,165,0,1,2,16a,166,164,0,1,2,168,16a,164,0,1,2,16b,167,166,0,1,2,16a,16b,166,0,1,2,169,165,167,0,1,2,16b,169,167,0,1,2,16c,168,169,0,1,2,16d,16c,169,0,1,2,16e,16a,168,0,1,2,16c,16e,168,0,1,2,16f,16b,16a,0,1,2,16e,16f,16a,0,1,2,16d,169,16b,0,1,2,16f,16d,16b,0,1,2,170,16c,16d,0,1,2,171,170,16d,0,1,2,172,16e,16c,0,1,2,170,172,16c,0,1,2,173,16f,16e,0,1,2,172,173,16e,0,1,2,171,16d,16f,0,1,2,173,171,16f,0,1,2,174,170,171,0,1,2,175,174,171,0,1,2,176,172,170,0,1,2,174,176,170,0,1,2,177,173,172,0,1,2,176,177,172,0,1,2,175,171,173,0,1,2,177,175,173,0,1,2,178,174,175,0,1,2,179,178,175,0,1,2,17a,176,174,0,1,2,178,17a,174,0,1,2,17b,177,176,0,1,2,17a,17b,176,0,1,2,179,175,177,0,1,2,17b,179,177,0,1,2,17c,178,179,0,1,2,17d,17c,179,0,1,2,17e,17a,178,0,1,2,17c,17e,178,0,1,2,17f,17b,17a,0,1,2,17e,17f,17a,0,1,2,17d,179,17b,0,1,2,17f,17d,17b,0,1,2";
			var geo0:FacesDefinition = new FacesDefinition();
			geo0.f = buildFaces( geo0faces.split(","),  buildVertices(read(geo0vert).split(",")), buildUVs(read(geo0uvs).split(",")) );
			geos.push(geo0);
		}
		
		private function buildFaces(aFaces:Array, vVerts:Vector.<Vertex>, vUVs:Vector.<UV>):Vector.<Face>
		{
			var vFaces:Vector.<Face> = new Vector.<Face>();
			var f:Face;
			for(var i:int = 0;i<aFaces.length;i+=6){
				f = new Face( vVerts[parseInt(aFaces[i], 16)],
					vVerts[parseInt(aFaces[i+1], 16)],
					vVerts[parseInt(aFaces[i+2], 16)],
					null,
					vUVs[parseInt(aFaces[i+3], 16)],
					vUVs[parseInt(aFaces[i+4], 16)],
					vUVs[parseInt(aFaces[i+5], 16)]);
				vFaces.push(f);
			}
			
			return vFaces;
		}
		
		private function buildVertices(aVerts:Array):Vector.<Vertex>
		{
			var tmpv:Array;
			var vVerts:Vector.<Vertex> = new Vector.<Vertex>();
			for(var i:int = 0;i<aVerts.length;i++){
				tmpv = aVerts[i].split("/");
				vVerts[i] = new Vertex( parseFloat(tmpv[0])*_scale, parseFloat(tmpv[1])*_scale, parseFloat(tmpv[2])*_scale  );
			}
			return vVerts;
		}
		
		private function buildUVs(aUvs:Array):Vector.<UV>
		{
			var tmpv:Array;
			var vUVs:Vector.<UV> = new Vector.<UV>();
			for(var i:int = 0;i<aUvs.length;++i){
				tmpv = aUvs[i].split("/");
				vUVs[i] = new UV(parseFloat(tmpv[0]), parseFloat(tmpv[1]));
			}
			
			return vUVs;
		}
		
		
		private function buildMaterials():void
		{
			var aw_0_Bitmap:Bitmap = new Aw_0_Bitmap_Bitmap();
			applyMaterialToMesh("aw_0", aw_0_Bitmap.bitmapData);
			
		}
		
		private function applyMaterialToMesh(id:String, bmd:BitmapData):void
		{
			for(var i:int;i<meshes.length;++i){
				if(meshes[i].name == id){
					if(!bmd){
						trace("Embed of "+id+" failed! Check source path or if CS4 call 911!");
					} else {
						meshes[i].material = new BitmapMaterial(bmd);
					}
					break;
				}
			}
		}
		
		private function cleanUp():void
		{
			for(var i:int = 0;i<1;++i){
				objs["obj"+i] == null;
			}
			aV = null;
			aU = null;
		}
		
		private function addContainers():void
		{
			aC = [];
			aC.push(this);
			var m0:Matrix3D = new Matrix3D();
			m0.rawData = Vector.<Number>([1,0,0,0,0,1,0,0,0,0,1,0,0*_scale,0*_scale,0*_scale,1]);
			transform = m0;
			name = "main";
			
		}
		
		public function get containers():Array
		{
			return aC;
		}
		
		
		public function get meshes():Array
		{
			return oList;
		}
		
		
		private function read(str:String):String
		{
			var start:int= 0;
			var chunk:String;
			var end:int= 0;
			var dec:String = "";
			var charcount:int = str.length;
			for(var i:int = 0;i<charcount;++i){
				if (str.charCodeAt(i)>=44 && str.charCodeAt(i)<= 48 ){
					dec+= str.substring(i, i+1);
				}else{
					start = i;
					chunk = "";
					while(str.charCodeAt(i)!=44 && str.charCodeAt(i)!= 45 && str.charCodeAt(i)!= 46 && str.charCodeAt(i)!= 47 && i<=charcount){
						i++;
					}
					chunk = ""+parseInt("0x"+str.substring(start, i), 16 );
					dec+= chunk;
					i--;
				}
			}
			return dec;
		}
		
	}
}
class FacesDefinition
{
	import away3d.core.base.Face;
	import away3d.core.base.Geometry;
	public var f:Vector.<Face>;
	public var geometry:Geometry;
}