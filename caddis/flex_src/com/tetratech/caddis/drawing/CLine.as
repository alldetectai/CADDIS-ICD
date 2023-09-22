package com.tetratech.caddis.drawing
{
	import com.tetratech.caddis.common.GraphicsUtil;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.Line")]
	public class CLine extends UIComponent
	{
		/* START OF DATABASE FEILDS */
		//attribute of line
		//public var id:Number;
		public var color:Number;
		public var thickness:int;
		public var points:ArrayCollection;
		public var firstConnector:CConnector;
		public var lastConnector:CConnector;
		/* END OF DATABASE FEILDS */
		
		//flags
		public var mouseOver:Boolean = false;	
		public var mouseOverConnector:Boolean = false;
		

		
		public function CLine()
		{
			this.points = new ArrayCollection();	
		}
		
		public function init(color:Number,thickness:Number):void
		{
			this.color = color;
			this.thickness = thickness;
		}
		
		public function draw(selected:Boolean):void
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
   			}
   			
		}
		
		public function clear():void
		{
			//clear the line
			var g:Graphics = this.graphics;
			g.clear();
		}		
		
		public function destroy():void
		{
			//clear line
			clear();
			//destroy points
			for(var i:int=0;i<points.length;i++)
				points[i]=null;
			points = null;
			//destroy connectors
			if(firstConnector!=null)
			{
				firstConnector.destroy();
				firstConnector = null;
			}
			if(lastConnector!=null)
			{
				lastConnector.destroy();
				lastConnector = null;
			}
		}
		
		
		public function isMouseOver(event:MouseEvent):Boolean
		{
			var mx:Number = event.localX;
			var my:Number = event.localY;
			var p:CPoint = new  CPoint();
			
			for(var i:int=0;i<points.length-1;i++)
			{
				var p1:CPoint = points[i];
				var p2:CPoint = points[i+1];
				
				p.x = (p1.x+p2.x)/2;
				p.y = (p1.y+p2.y)/2;
				
				if((p.x -5) <= mx && (p.y-5) <= my && mx <= (p.x + 5) && my <= (p.y + 5))
					return true;
			}
			
			return false;	
		}
		
		public function isMouseOverConnector(event:MouseEvent):int
		{
			var mx:Number = event.localX;
			var my:Number = event.localY;
			
			
			for(var i:int=0;i<points.length;i++)
			{
				var p:CPoint = points[i];
				if((p.x -5) <= mx && (p.y-5) <= my && mx <= (p.x + 5) && my <= (p.y + 5))
					return i+1;
			}
			
			return 0;
		}
				
		public function isConnectorOverConnector(index:int):int
		{
			//current connector
			var cindex:int = index -1 ;
			var p:CPoint = points[cindex];
			//check if current connector is over any of the other connectors
			for(var i:int=0;i<points.length;i++)
			{
				if(cindex!=i)
				{
					var po:CPoint = points[i];
					if((p.x -5) <= po.x && (p.y-5) <= po.y && po.x <= (p.x + 5) && po.y <= (p.y + 5))
						return i+1;
				}
			}
			
			return -2;
		}		
				
		public override function move(deltaX:Number,deltaY:Number):void
		{
			for(var i:int=0;i<points.length;i++)
			{
				var p:CPoint = points[i];
				p.x += deltaX;
				p.y += deltaY;
			}
		}
				
		public function addPoint(point:CPoint):void
		{
			points.addItem(point);
		}
		
		public function removePoint(index:int):void
		{
			points.removeItemAt(index-1);
		}
		
		public function getPoint(index:int):CPoint
		{
			return points[index-1];
		}
		
		public function getLastPoint():CPoint
		{
			return points[points.length-1];
		}
		
		public function getFirstPoint():CPoint
		{
			return points[0];
		}
		
		public function removeLastPoint():void
		{
			points.removeItemAt(points.length-1);
		}
		
		public function removeFirstPoint():void
		{
			points.removeItemAt(0);
		}
		
	}
}