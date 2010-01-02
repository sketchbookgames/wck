﻿package Box2DAS.Collision {
	
	import Box2DAS.*;
	import Box2DAS.Collision.*;
	import Box2DAS.Collision.Shapes.*;
	import Box2DAS.Common.*;
	import Box2DAS.Dynamics.*;
	import Box2DAS.Dynamics.Contacts.*;
	import Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	public class b2WorldManifold {
		
		public var m_normal:V2;
		public var m_points:Array = [];
		
		/// Evaluate the manifold with supplied transforms. This assumes
		/// modest motion from the original state. This does not change the
		/// point count, impulses, etc. The radii must come from the shapes
		/// that generated the manifold.
		/// void Initialize(const b2Manifold* manifold,
		///				const b2Transform& xfA, float32 radiusA,
		///				const b2Transform& xfB, float32 radiusB);
		public function Initialize(manifold:b2Manifold, xfA:XF, radiusA:Number, xfB:XF, radiusB:Number):void {
			if (manifold.m_pointCount == 0) {
				return;
			}
			var normal:V2;
			var planePoint:V2;
			var i:uint;
			var clipPoint:V2;
			var cA:V2;
			var cB:V2;
			switch (manifold.m_type) {
				case b2Manifold.e_circles:
					var pointA:V2 = xfA.multiply(manifold.m_localPoint.v2);
					var pointB:V2 = xfB.multiply(manifold.m_points[0].m_localPoint.v2);
					normal = V2.subtract(pointB, pointA).normalize();
					m_normal = normal;
					cA = pointA.add(V2.multiplyN(normal, radiusA));
					cB = pointB.subtract(V2.multiplyN(normal, radiusB));
					m_points[0] = V2.add(cA, cB).multiplyN(.5);
					//trace('CIRC', m_normal.x, m_normal.y);
					break;
			
				case b2Manifold.e_faceA:
					normal = xfA.r.multiplyV(manifold.m_localPlaneNormal.v2);
					planePoint = xfA.multiply(manifold.m_localPoint.v2);		
					// Ensure normal points from A to B.
					m_normal = normal;
					for(i = 0; i < manifold.m_pointCount; ++i) {
						clipPoint = xfB.multiply(manifold.m_points[i].m_localPoint.v2);
						cA = V2.add(clipPoint, V2.multiplyN(normal, radiusA - normal.dot(V2.subtract(clipPoint, planePoint))));
						cB = V2.subtract(clipPoint, V2.multiplyN(normal, radiusB));
						m_points[i] = V2.add(cA, cB).multiplyN(.5);
					}					
					//trace('FA', m_normal.x, m_normal.y);
					break;
			
				case b2Manifold.e_faceB:
					normal = xfB.r.multiplyV(manifold.m_localPlaneNormal.v2);
					planePoint = xfB.multiply(manifold.m_localPoint.v2);
					// Ensure normal points from A to B.
					m_normal = normal.multiplyN(-1);
					for(i = 0; i < manifold.m_pointCount; ++i) {
						clipPoint = xfA.multiply(manifold.m_points[i].m_localPoint.v2);
						cA = V2.subtract(clipPoint, V2.multiplyN(normal, radiusA))
						cB = V2.add(clipPoint, V2.multiplyN(normal, radiusB - normal.dot(V2.subtract(clipPoint, planePoint))));
						m_points[i] = V2.add(cA, cB).multiplyN(.5);
					}					
					//trace('FB', m_normal.x, m_normal.y);
					break;
			}
		
		}
		
		/**
		 * If there are more than one contact points, this getter will return the average.
		 */
		public function GetPoint():V2 {
			if(m_points.length == 0) {
				return null;
			}
			if(m_points.length == 1) {
				return m_points[0];
			}
			return new V2((m_points[0].x + m_points[1].x) / 2, (m_points[0].y + m_points[1].y) / 2);
		}
	}
}