
package com.tetratech.caddis.vo
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.ShapeAttribute")]
	public class ShapeAttribute
	{
		public var type:Number;
		public var values:ArrayCollection;
		
		public function ShapeAttribute()
		{
			values = new ArrayCollection();
		}

	}
}