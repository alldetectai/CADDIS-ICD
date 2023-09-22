package com.tetratech.caddis.drawing
{
	import com.tetratech.caddis.common.Constants;
	import com.tetratech.caddis.vo.User;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.Diagram")]
	
	public class CDiagram
	{
		/* START OF DATABASE FEILDS */		
		public var id:Number;
		public var orginialId:Number;
		public var name:String;
		public var description:String;
		public var color:Number;
		public var lines:ArrayCollection;
		public var shapes:ArrayCollection;
		public var width:int;
		public var height:int;
		//list has tiersIndex which are non collapsible
		//public var nonCollapsibleBins:ArrayCollection;
		public var diagramStatus:String;
		public var diagramStatusId:Number;
		public var goldSeal:Boolean;
		public var locked:Boolean;
		public var createdBy:Number;
		public var updatedBy:Number;
		public var createdDate:Date;
		public var updatedDate:Date;
		public var creatorUser:User;
		public var updatedUser:User;
		public var lockedUser:User;
		public var openToPublic:Boolean;
		public var userList:ArrayCollection;
		public var location:String;
		public var keywords:String;
		
		/* END OF DATABASE FEILDS */
	
		public function CDiagram()
		{
			this.lines = new ArrayCollection();
			this.shapes = new ArrayCollection();
			//this.nonCollapsibleBins =  new ArrayCollection();
			this.lockedUser = new User();
			this.creatorUser = new User();
			this.userList = new ArrayCollection();
		}
		
		public function getNumberOfBins():Number
		{
			return this.height/Constants.TIER_HEIGHT;
		}
	}
}