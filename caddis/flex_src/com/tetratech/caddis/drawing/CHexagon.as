package com.tetratech.caddis.drawing
{
	import flash.display.Graphics;
	
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.Hexagon")]
	public class CHexagon extends CShape
	{
		public function CHexagon()
		{
			super();	        
		}
		
		public override function drawForEdit(selected:Boolean):void
		{						
			var g:Graphics = this.graphics;
			g.clear();
			
			g.beginFill(color);
        	g.lineStyle(thickness, EDGE_COLOR);
        	g.moveTo(origin.x, origin.y+cheight/2);
        	g.lineTo(origin.x+10,origin.y);
        	g.lineTo(origin.x+cwidth-10,origin.y);
        	g.lineTo(origin.x+cwidth,origin.y+cheight/2);
        	g.lineTo(origin.x+cwidth-10,origin.y+cheight);
        	g.lineTo(origin.x+10,origin.y+cheight);
        	g.lineTo(origin.x,origin.y+cheight/2);
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
        		g.lineStyle(thickness,EDGE_COLOR);
        	g.moveTo(origin.x, origin.y+cheight/2);
        	g.lineTo(origin.x+10,origin.y);
        	g.lineTo(origin.x+cwidth-10,origin.y);
        	g.lineTo(origin.x+cwidth,origin.y+cheight/2);
        	g.lineTo(origin.x+cwidth-10,origin.y+cheight);
        	g.lineTo(origin.x+10,origin.y+cheight);
        	g.lineTo(origin.x,origin.y+cheight/2);
        	g.endFill(); 
        	
        	super.drawForView();
		}
		
		public override function clone():CShape
		{
			var s:CHexagon = new CHexagon();
			return super.createClone(s,false);
		}
		
		public override function cloneDrawing():CShape
		{
			var s:CHexagon = new CHexagon();
			return this.createClone(s,true);
		}
	}
}