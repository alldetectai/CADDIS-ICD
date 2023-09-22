package com.tetratech.caddis.event
{
	import flash.events.Event;
	
	public class InsetToggleEvent extends Event
	{
		public static const INSET_TOGGLE:String = "insetToggleEvent";
		
		public function InsetToggleEvent(type:String)
		{
			super(type);
		}

	}
}