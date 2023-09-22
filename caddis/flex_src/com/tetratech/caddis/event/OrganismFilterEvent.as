package com.tetratech.caddis.event
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class OrganismFilterEvent extends Event
	{
		public static const ORGANISM_FILTER_SOME:String = "someOrganisms";
		public static const ORGANISM_FILTER_ALL:String = "allOrganisms";
		
		public var filters:ArrayCollection;
		
		public function OrganismFilterEvent(type:String)
		{
			super(type);
		}

	}
}