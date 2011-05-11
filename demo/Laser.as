package {
	import wck.BodyShape;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Fixture;
	import flash.events.Event;
	import flash.geom.Point;
	import Box2DAS.Dynamics.StepEvent;
	import flash.display.MovieClip;
	import flash.display.CapsStyle;
	
	public class Laser extends BodyShape{
		
		protected var magnitude:Number = 1000;//length of raycast
		
		protected var p1:Point //start point
		protected var p2:Point //end point
		protected var v1:V2 //start point in world.scale
		protected var v2:V2 //end point in world.scale
		
		//stored by raycast callback.
		protected var valid:Boolean;
		protected var fixture:b2Fixture;
		protected var point:V2;
		
		protected var liveUpdate:Boolean = true;
		
		public function Laser(){
		}
		public override function create():void{
			//type = 'Static'
			//slow it down for draggalbe demo.
			linearDamping=5;
			angularDamping=5;
			this.applyGravity=false;
			
			super.create();
			
			updateVector();
			
			listenWhileVisible(world, StepEvent.STEP, step, false, 10);
		}
		protected function updateVector():void{
			//convert start and end locations to world.
			p1 = new Point(0,0);
			p2 = new Point(magnitude, 0); //assumes that art is facing right at 0º
			p1 = world.globalToLocal(this.localToGlobal(p1));
			p2 = world.globalToLocal(this.localToGlobal(p2));
			
			v1 = new V2(p1.x, p1.y);
			v2 = new V2(p2.x, p2.y);
			v1.divideN(world.scale);
			v2.divideN(world.scale);
		}
		
		
		protected function step(e:Event=null):void{
			if(!world)return;
			
			updateVector();
			
			graphics.clear();
			graphics.lineStyle(3, 0xff0000, 1, false, "normal", CapsStyle.NONE);
			graphics.moveTo(0,0);
			
			startRayCast(v1, v2);
		}
		protected function startRayCast(v1:V2, v2:V2):void{
			valid = false;
			
			world.b2world.RayCast(rcCallback, v1, v2); //see onRayCast();
			
			if(valid){
				var body:BodyShape = fixture.m_userData.body //tip for finding the wck body.
				drawLaser();
			}else{//if none were found
				point=v2; //full length
				drawLaser();
			}
			
		}
		protected function rcCallback(_fixture:b2Fixture, _point:V2, normal:V2, fraction:Number):Number{
			//found one
			if(_fixture.IsSensor()){//is it a sensor?
				return -1//pass through
			}
			
			//set this one as the current closest find
			valid = true;
			fixture = _fixture;
			point = _point;
			
			return fraction;//then check again for any closer finds.
		}
		
		protected function drawLaser():void{
			var pt:Point = new Point(point.x*world.scale, point.y*world.scale);
			pt = globalToLocal(world.localToGlobal(pt));
			
			
			graphics.lineTo(pt.x, pt.y);
		}
		
		
		
	}
}