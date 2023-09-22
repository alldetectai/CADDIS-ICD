package com.tetratech.caddis.vo
{
	import mx.controls.Image;
	
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.UploadedReferenceResult")]
	public class UploadedRefResult
	{	
		public var row:int;
		public var item:String;
		public var success:Boolean;
		public var status:Class;
		
		public function UploadedRefResult()
		{

		}
	}
}