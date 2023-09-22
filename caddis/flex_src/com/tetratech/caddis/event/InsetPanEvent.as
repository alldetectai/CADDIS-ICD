package com.tetratech.caddis.event
{
	import flash.events.Event;
	
	public class InsetPanEvent extends Event
	{
		public static const ORIGIN_MOVE:String = "originMove";
		
		public var deltaX:Number;
		public var deltaY:Number;
		
		public function InsetPanEvent(type:String)
		{
			super(type);
		}

	}
}