package com.tetratech.caddis.event
{
	import flash.events.Event;
	
	public class MenuItemClickEvent extends Event
	{
		public static const MENU_ITEM_CLICK:String = "menuItemClick";
		
		public var operation:String;
		
		public function MenuItemClickEvent(type:String)
		{
			super(type);
		}

	}
}