package com.tetratech.caddis.event
{
	import flash.events.Event;
	
	public class ModeSwitchEvent extends Event
	{
		public static const MODE_SWITCH:String = "modeSwitch";
		
		public var newMode:String;
		
		public function ModeSwitchEvent(type:String)
		{
			super(type);
		}
	}
}