package com.tetratech.caddis.event
{
	import flash.events.Event;
	
	public class BoardControlPanEvent extends Event
	{
		public static const ORIGIN_CHANGE:String = "originChange";
		public static const ORIGIN_CENTERED:String = "originCentered";
		
		public var deltaX:Number;
		public var deltaY:Number;
		
		public function BoardControlPanEvent(type:String)
		{
			super(type);
		}

	}
}