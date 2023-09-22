package com.tetratech.caddis.common
{
	import mx.collections.ArrayCollection;
	
	/* Utility class to create a SET of items 
	the set will never contain two items that 
	are equal as defined by (a == b) */
	public class Set
	{
		private var items:ArrayCollection;
		
		public function Set()
		{
			items = new ArrayCollection();
		}
		
		public function addItem(item:Object):void
		{
		 	if(!containsItem(item))
		 	{
		 		items.addItem(item);
		 	}
		}
		
		public function addItems(items:ArrayCollection):void
		{
			for(var i:int=0;i<items.length;i++)
			{
				addItem(items[i]);
			}
		}
		
		public function removeItem(item:Object):void
		{
			if(containsItem(item))
			{	
				items.removeItemAt(items.getItemIndex(item));
			}
		}
		
		public function containsItem(item:Object):Boolean
		{
			return items.contains(item);
		}
		
		public function toArrayCollection():ArrayCollection
		{
			return items;
		}
	}
}