package com.tetratech.caddis.event
{
	import flash.events.Event;
	
	public class IntroductionLoadEvent extends Event
	{
		public static const LOAD_DIAGRAM:String = "introLoadDiagram";
		
		public var id:Number;
		
		public function IntroductionLoadEvent(type:String)
		{
			super(type);
		}

	}
}