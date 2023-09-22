package com.tetratech.caddis.vo
{
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.CauseEffectLinkage")]
	public class CauseEffectLinkage
	{
		public var causeTerm:Term; 
		public var causeTrajectory:Number;
		public var effectTerm:Term;
		public var effectTrajectory:Number;
		
		
		public function CauseEffectLinkage()
		{
		}
	}
}