package com.tetratech.caddis.vo
{
	import com.tetratech.caddis.drawing.CShape;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.SelectedLinkage")]
	public class SelectedLinkage
	{
		public var label:String;
		public var citations:ArrayCollection;
		public var diagramName:String;
		public var shape1:CShape = new CShape();
		public var shape2:CShape = new CShape();
		public var causeEffects:ArrayCollection;
		public var dataSets:ArrayCollection;
		
		public function SelectedLinkage()
		{
			citations = new ArrayCollection();
			causeEffects  = new ArrayCollection();
			dataSets = new ArrayCollection();
		}
		
	}
}