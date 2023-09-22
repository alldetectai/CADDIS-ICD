package com.tetratech.caddis.vo
{
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.Term")]
	public class Term
	{
		
		public var id:Number;
		public var term:String;
		public var desc:String;
		public var isEELTerm:Boolean;
		public var legendType:Number;
		public function Term()
		{
		}

	}
}