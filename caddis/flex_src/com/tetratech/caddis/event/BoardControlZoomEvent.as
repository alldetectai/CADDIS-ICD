package com.tetratech.caddis.event
{
	import flash.events.Event;
	
	public class BoardControlZoomEvent extends Event
	{
		public static const ZOOM_LEVEL_CHANGE:String = "boardControlZoomLevelChange";
		
		public var zoomLevel:int;
		
		public function BoardControlZoomEvent(type:String)
		{
			super(type);
		}

	}
}