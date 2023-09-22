package com.tetratech.caddis.vo
{
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.Comment")]
	public class Comment
	{
		public var diagramId:Number;
		public var commentor:String;
		public var commentText:String;
		public var createdDate:Date;
		public var email:String;
		public var userId:Number;
		public function Comment()
		{
		}

	}
}