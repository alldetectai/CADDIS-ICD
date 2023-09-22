package com.tetratech.caddis.vo
{
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.LookupValue")]
	public class LookupValue
	{
		public var id:Number;
		public var code:String;
		public var desc:String;
		
		public function LookupValue()
		{
		
		}
	}
}