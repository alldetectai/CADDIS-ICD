package com.tetratech.caddis.drawing
{
	import flash.display.Graphics;
	
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.Pentagon")]
	public class CPentagon extends CShape
	{

		public function CPentagon()
		{
			super();	        
		}
		
		public override function drawForEdit(selected:Boolean):void
		{						
			var g:Graphics = this.graphics;
			g.clear();
			
			g.beginFill(color);
        	g.lineStyle(thickness, EDGE_COLOR);
        	g.moveTo(origin.x+cwidth/2,origin.y);
        	g.lineTo(origin.x+cwidth,origin.y+cheight*0.5);
        	g.lineTo(origin.x+cwidth*0.8,origin.y+cheight);
        	g.lineTo(origin.x+cwidth*0.2,origin.y+cheight);
        	g.lineTo(origin.x,origin.y+cheight*0.5);
        	g.lineTo(origin.x+cwidth/2,origin.y);
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
        	g.moveTo(origin.x+cwidth/2,origin.y);
        	g.lineTo(origin.x+cwidth,origin.y+cheight*0.5);
        	g.lineTo(origin.x+cwidth*0.8,origin.y+cheight);
        	g.lineTo(origin.x+cwidth*0.2,origin.y+cheight);
        	g.lineTo(origin.x,origin.y+cheight*0.5);
        	g.lineTo(origin.x+cwidth/2,origin.y);
        	g.endFill(); 
        	
        	super.drawForView();
		}
		
		public override function clone():CShape
		{
			var s:CPentagon = new CPentagon();
			return super.createClone(s,false);
		}
		
		public override function cloneDrawing():CShape
		{
			var s:CPentagon = new CPentagon();
			return this.createClone(s,true);
		}
	}
}