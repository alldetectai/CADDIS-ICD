package com.tetratech.caddis.drawing
{
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.Connector")]
	public class CConnector
	{
		/* START OF DATABASE FEILDS */	
		public var id:Number;
		public var line:CLine;
		public var shape:CShape;
		public var index:int;
		public var start:Boolean;
		/* END OF DATABASE FEILDS */
		public function CConnector()
		{
		}
		
		public function init(line:CLine,shape:CShape,index:int,start:Boolean):void
		{
			this.line = line;
			this.shape = shape;
			this.index = index;
			this.start = start;
		}

		public function destroy():void
		{
			line = null;
			shape = null;
		}
	}
}