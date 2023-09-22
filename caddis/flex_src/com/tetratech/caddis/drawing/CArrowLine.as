package com.tetratech.caddis.drawing
{
	import com.tetratech.caddis.common.GraphicsUtil;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	

	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.SArrowLine")]
	public class CArrowLine extends CLine
	{
		//line arrow
		public var arrow:Sprite; 
		
		public function CArrowLine()
		{
			super();
			arrow = new Sprite();
			this.addChild(arrow);
		}
		
		public override function draw(selected:Boolean):void
		{
			if(points.length>0)
			{
				var g:Graphics = this.graphics;
				g.clear();
				
				var p:CPoint = new CPoint();
	        	var i:int = 0;
					
				//draw dots when selected
				if(selected)
	   			{		 
	   				for(i=0;i<points.length-1;i++)
					{
						var p1:CPoint = points[i];
						var p2:CPoint = points[i+1];
				
						p.x = (p1.x+p2.x)/2;
						p.y = (p1.y+p2.y)/2;
	   				
	   					g.beginFill(0x85FFA3);
        				g.lineStyle(1,0x85FFA3);
	        			g.drawCircle(p.x,p.y,4);
	        			g.endFill();
	   					
	   				}
	   				       		
	        		for(i=0;i<points.length;i++)
		        	{
		        		g.beginFill(0x668CFF);
        				g.lineStyle(1,0x668CFF);
		        		p = points[i];
	        			g.drawCircle(p.x,p.y,4);
	        			g.endFill();
	        		}
	        		
	   			}
	   			
	   			//draw line
	        	g.lineStyle(thickness, color);
	        	p = points[0];
	        	g.moveTo(p.x,p.y);
	        	for(i=1;i<=points.length-1;i++)
	        	{
	        		p = points[i];
	        		g.lineTo(p.x,p.y);
	        	} 	
	        	g.endFill(); 	
	   				
   				//check if you need to draw the arrow
   				if(!selected && points.length > 1)
   				{
	   				var prevLastPoint:CPoint = points[points.length-2];
	   				var lastPoint:CPoint = getLastPoint();
	   				
	   				var g:Graphics = arrow.graphics;
	   				
	   				g.clear();
					g.beginFill(color);
					g.moveTo(lastPoint.x,lastPoint.y);
					g.lineTo(lastPoint.x-12,lastPoint.y-4);
					g.lineTo(lastPoint.x-12,lastPoint.y+4);
					g.lineTo(lastPoint.x,lastPoint.y);
					g.endFill();
					
					if (lastPoint.x > prevLastPoint.x)
					{
						var val:Number = - ((lastPoint.y - prevLastPoint.y)/(lastPoint.x - prevLastPoint.x)); 
						var rads:Number = Math.atan(val);
						GraphicsUtil.rotate(arrow,-rads,lastPoint.x,lastPoint.y);
					}
					else
					{
						var val:Number = ((lastPoint.y - prevLastPoint.y)/(lastPoint.x - prevLastPoint.x)); 
						var rads:Number = Math.atan(val);
						var rads = GraphicsUtil.toRadians(180 - GraphicsUtil.toDegrees(rads));
						GraphicsUtil.rotate(arrow,-rads,lastPoint.x,lastPoint.y);
					}
						
   				}
   				else
   				{
   					//clear the arrow
   					arrow.graphics.clear();
   				}
   			}
   			
		}
		
		public override function clear():void
		{
			//clear the line
			var g:Graphics = this.graphics;
			g.clear();
			//clear the array
			arrow.graphics.clear();
			
		}
	}
}