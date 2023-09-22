package com.tetratech.caddis.common
{
	import mx.collections.ArrayCollection;
	
	public class ArrayCollectionUtil
	{
		public function ArrayCollectionUtil()
		{
			throw new Error("This class cannot be created");
		}
		
		//utility function to create a fresh copy of an array collection
		public static function copyArrayCollection(ac:ArrayCollection):ArrayCollection
		{
			var nac:ArrayCollection = new ArrayCollection();
			for(var i:int=0;i<ac.length;i++)
				nac.addItem(ac[i]);
			return nac;
		}
	}
}