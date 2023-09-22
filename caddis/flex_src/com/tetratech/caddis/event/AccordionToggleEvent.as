package com.tetratech.caddis.event
{
	import flash.events.Event;
	
	public class AccordionToggleEvent extends Event
	{
		public static const ACCORDION_TOGGLE:String = "accordionToggleEvent";
		
		public function AccordionToggleEvent(type:String)
		{
				super(type);
		}
	}
}