package com.tetratech.caddis.drawing
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.Rectangle")]
	public class CRectangle extends CShape
	{

		public function CRectangle()
		{
			super();	        
		}
		
		public override function drawForEdit(selected:Boolean):void
		{						
			var g:Graphics = this.graphics;
			g.clear();
			
			g.beginFill(color);
        	g.lineStyle(thickness, EDGE_COLOR);
        	
        	g.drawRect(origin.x, origin.y, cwidth, cheight);
        	g.endFill(); 
        	     	
        	super.drawForEdit(selected);   
		}
		
		public override function drawForView():void
		{
			var g:Graphics = this.graphics;
			g.clear();
			
			g.beginFill(color);
        	
        	if(highlightBorder)
        		g.lineStyle(HIDDEN_EDGE_THICKNESS, HIDDEN_EDGE_COLOR);
        	else
        		g.lineStyle(thickness, EDGE_COLOR);
        	g.drawRect(origin.x, origin.y, cwidth, cheight);
        	g.endFill(); 
        	
        	super.drawForView();
		}
	
		public override function clone():CShape
		{
			var s:CRectangle = new CRectangle();
			return super.createClone(s,false);
		}
		
		public override function cloneDrawing():CShape
		{
			var s:CRectangle = new CRectangle();
			return this.createClone(s,true);
		}
	
	}
}