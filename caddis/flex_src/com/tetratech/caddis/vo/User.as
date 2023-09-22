package com.tetratech.caddis.vo
{
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.User")]
	public class User
	{
		public var userId:Number;
		public var userName:String;
		public var password:String;
		public var email:String;
		public var firstName:String;
		public var middleName:String;
		public var lastName:String;
		public var role:String;
		public var roleId:Number;
		public var createdDate:Date;
		
		public function User()
		{
		
		}
	}
}