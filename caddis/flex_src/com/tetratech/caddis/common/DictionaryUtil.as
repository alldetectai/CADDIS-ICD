package com.tetratech.caddis.common
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	public class DictionaryUtil
	{
		public function DictionaryUtil()
		{
			throw new Error("This class cannot be created");
		}
		
		/* this utility method is used to create a dictionary for a collection
		of objects that had an id as a field */
		public static function collectionToDictionary(c:ArrayCollection):Dictionary
		{
			var d:Dictionary = new Dictionary();
			for(var i:int=0;i<c.length;i++)
			{
				d[c[i].id] = c[i];
			}
			return d;
		}
	}
}