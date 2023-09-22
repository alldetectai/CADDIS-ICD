package com.tetratech.caddis.event
{
	import flash.events.Event;
	
	public class InsetZoomEvent extends Event
	{
		public static const ZOOM_LEVEL_CHANGE:String = "insetZoomLevelChange";
		
		public var zoomLevel:int;
		
		public function InsetZoomEvent(type:String)
		{
			super(type);
		}

	}
}