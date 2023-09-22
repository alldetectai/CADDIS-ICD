package com.tetratech.caddis.drawing
{
	import flash.geom.Point;
	
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.Point")]
	public class CPoint extends Point
	{
		public var id:Number;
		
		public function CPoint()
		{
			super();
		}

		public function getClone():CPoint
		{
			var p:CPoint = new CPoint();
			p.x = x;
			p.y = y;
			return p;
		}
	}
}