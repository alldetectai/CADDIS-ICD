package com.tetratech.caddis.vo
{
	import com.tetratech.caddis.drawing.CShape;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.Linkage")]
	public class Linkage
	{
		public var id:Number;
		public var shape:CShape;
		public var citationIds:ArrayCollection;
		public var causeId:Number
		public var effectId:Number
		public var strongLinkage:Boolean;
		public var effectRelationship:Boolean;
		public var causeEffectIds:ArrayCollection;
		
		public function Linkage()
		{
			citationIds = new  ArrayCollection();
			causeEffectIds = new ArrayCollection();
		}

	}
}