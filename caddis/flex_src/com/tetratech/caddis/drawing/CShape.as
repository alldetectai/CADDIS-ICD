package com.tetratech.caddis.drawing
{
	import com.tetratech.caddis.common.ArrayCollectionUtil;
	import com.tetratech.caddis.common.Constants;
	import com.tetratech.caddis.vo.Linkage;
	import com.tetratech.caddis.vo.ShapeAttribute;
	
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextLineMetrics;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.core.Container;
	import mx.core.UIComponent;
	

	[Bindable]
	[RemoteClass(alias="com.tetratech.caddis.model.Shape")]
	public class CShape extends UIComponent
	{	
	
		/* START OF DATABASE FEILDS */
			
		//attributes of all rectangular shapes

		public var origin:CPoint;
		public var color:Number;
		public var cwidth:int;
		public var cheight:int;
		public var thickness:int=1;
		public var label:String;
		public var binIndex:int;
		public var termId:Number;
		//connectors
		public var connectors:ArrayCollection;

		//linkages
		public var linkages:ArrayCollection;
		//legend type
		public var legendType:int;
		//label symbol type
		public var labelSymbolType:int;
		//attributes
		public var attributes:ArrayCollection;
		/* END OF DATABASE FEILDS */
		
		//reference to board
		public var board:Container;
			
		//connectors
		public var c1:CPoint;
		public var c2:CPoint;
		public var c3:CPoint;
		public var c4:CPoint;
		
		//field label object
		protected var l:Text
		
		//flags
		public var mouseOver:Boolean = false;	
		public var mouseOverConnector:Boolean = false;
		
		//static fields constants
		protected static const EDGE_COLOR:Number = 0x000000;
		//12/24/2009
		public static const HIDDEN_EDGE_COLOR:Number = 0xDD6909;//0xFF0033;
		protected static const  HIDDEN_EDGE_THICKNESS:int = 3;
		
		protected static const  SELECTION_COLOR:Number = 0x668CFF;
		
		public static const MIN_HEIGHT:int = 30;
		public static const MIN_WIDTH:int = 40;
		protected static const DELTA_WIDTH:int = 30; //this represents the delta width on both sides
		//of the label (need to divide by 2 to find the delta width(white space) on each side
		
		//temporary experimental other fields	
		public var oldOrigin:CPoint;
		public var oldColor:Number;
		
		//highlighted flag for view mode
		public var highlighted:Boolean=false;
		
		//clicked flag for view mode
		public var clicked:Boolean=false;
		
		public var highlightBorder:Boolean=false;
		
		public function CShape()
		{				
			origin = new CPoint();
			oldOrigin = new CPoint();
			
			connectors = new ArrayCollection();
						
			c1 = new CPoint();
			c2 = new CPoint();
			c3 = new CPoint();
			c4 = new CPoint();
			
			l = new Text();
			//IMPORTANT: TURN OFF THIS OR OTHERWISE THE APP FLICKERS LIKE CRAZY
			l.mouseEnabled = false;
			l.mouseFocusEnabled = false;
			l.mouseChildren = false;
			
			//childShapes = new ArrayCollection();
			linkages = new ArrayCollection();
			attributes = new ArrayCollection();
		}
		
		public function initExisting():void
		{
			//create a label component
	        l.text = label;
	        l.setStyle("textAlign","center");
	        l.setStyle("fontAntiAliasType",flash.text.AntiAliasType.ADVANCED);
	        l.setStyle("fontGridFitType",flash.text.GridFitType.SUBPIXEL); 
	        l.setStyle("fontFamily","myArialFont");
	     
	        //resize label
	        resizeLabel();
	        //move shape with no deltas
	        move(0,0);
		}
		
		public function initNew():void
		{
			//create a label component
	        l.text = label;
	        l.setStyle("textAlign","center");
	        l.setStyle("fontAntiAliasType",flash.text.AntiAliasType.ADVANCED);
	        l.setStyle("fontGridFitType",flash.text.GridFitType.SUBPIXEL); 
	        l.setStyle("fontFamily","myArialFont");
			//set the label width
			var tw:int = getLabelTextWidth();
			if(tw + DELTA_WIDTH <= MIN_WIDTH)
			{
				cwidth = MIN_WIDTH;
				cheight = MIN_HEIGHT;
				l.width = undefined;
			}else
			{
				cwidth = tw + DELTA_WIDTH;
				cheight = MIN_HEIGHT;
				l.width = tw;
			}
	        //move shape with no deltas
	        move(0,0);
		}
		
		public function drawForEdit(selected:Boolean):void
		{
		    var g:Graphics = this.graphics;

		    if(selected)
        	{
        		g.beginFill(SELECTION_COLOR);
        		g.lineStyle(1,SELECTION_COLOR);
        		g.drawCircle(c1.x,c1.y,4);
        		g.drawCircle(c2.x,c2.y,4);
        		g.drawCircle(c3.x,c3.y,4);
        		g.drawCircle(c4.x,c4.y,4);
        		g.endFill();
        		
        	}
        	
        	drawSymbol(g);
        	
			addLabel();
		}
		
		
		public function drawForView():void
		{
			var g:Graphics = this.graphics;

			drawSymbol(g);
			
    		addLabel();
		}
		
		
		private function drawSymbol(g:Graphics):void
		{
			//SYMBOL DRAWING
        	var delta:int = 10;
        	if(labelSymbolType == Constants.SYMBOL_ARROW_UP)
        	{
				g.beginFill(EDGE_COLOR);
	        	g.lineStyle(thickness, EDGE_COLOR);
				g.moveTo(c4.x+delta,c4.y-6);
	    		g.lineTo(c4.x+delta+3,c4.y);
				g.lineTo(c4.x+delta-3,c4.y);
				g.lineTo(c4.x+delta,c4.y-6);
				g.endFill();
				
				g.lineStyle(thickness, EDGE_COLOR);
				g.moveTo(c4.x+delta,c4.y+6);
	    		g.lineTo(c4.x+delta,c4.y-6);
				g.endFill();
        	}
        	else if(labelSymbolType == Constants.SYMBOL_ARROW_DOWN)
        	{
				g.beginFill(EDGE_COLOR);
	        	g.lineStyle(thickness, EDGE_COLOR);
				g.moveTo(c4.x+delta,c4.y+6);
	    		g.lineTo(c4.x+delta+3,c4.y);
				g.lineTo(c4.x+delta-3,c4.y);
				g.lineTo(c4.x+delta,c4.y+6);
				g.endFill();
				
				g.lineStyle(thickness, EDGE_COLOR);
				g.moveTo(c4.x+delta,c4.y+6);
	    		g.lineTo(c4.x+delta,c4.y-6);
				g.endFill();
        	}
        	else if(labelSymbolType == Constants.SYMBOL_DELTA)
        	{
        		//g.beginFill(EDGE_COLOR);
	        	g.lineStyle(thickness, EDGE_COLOR);
				g.moveTo(c4.x+delta,c4.y-6);
	    		g.lineTo(c4.x+delta+4,c4.y+2);
				g.lineTo(c4.x+delta-4,c4.y+2);
				g.lineTo(c4.x+delta,c4.y-6);
				//g.endFill();
        	}
        	//END OF SYMBOL DRAWING
		}
		
		public override function move(deltaX:Number,deltaY:Number):void
		{		
			origin.x += deltaX;
			origin.y += deltaY;
			
			var w2:Number = cwidth/2;
			var h2:Number = cheight/2;
		
			c1.x = origin.x + w2;
			c1.y = origin.y;
			
			c2.x = origin.x + cwidth;
			c2.y = origin.y + h2;
			
			c3.x = origin.x + w2;
			c3.y = origin.y + cheight;
			
			c4.x = origin.x;
			c4.y = origin.y + h2;
			
			l.x = origin.x + (cwidth-l.width)/2;
		    l.y = origin.y + (cheight-l.height)/2;
		    
		    //binIndex = int(origin.y / (Model.BOARD_HEIGHT/(Constants.NUMBER_OF_SUB_TIERS*Constants.NUMBER_OF_TIERS)));
			 binIndex = int(origin.y / Constants.TIER_HEIGHT);
		}
		
		public function resize(cIndex:int,delta:Number):void
		{			
			
			if(cIndex == 1)
			{
				if(cheight - delta >= MIN_HEIGHT)
				{
					cheight -= delta;
					move(0,delta);
				}
			}
			else if(cIndex == 2)
			{
				if(cwidth + delta >= MIN_WIDTH)
				{
					cwidth += delta;
					resizeLabel();
					move(0,0);
				}
			}
			else if(cIndex == 3)
			{
				if(cheight + delta >= MIN_HEIGHT)
				{
					cheight += delta;
					move(0,0);
				}
			
			}
			else if(cIndex == 4)
			{
				if(cwidth - delta >= MIN_WIDTH)
				{
					cwidth -= delta;
					resizeLabel();
					move(delta,0);
				}
			}
		}
			
		public function clear():void
		{
			var g:Graphics = this.graphics;
			g.clear();
			
			removeLabel();
		}
		
		public function destroy():void
		{
			//clear shape
			clear();
			
			//clear collections and objects
			origin = null;
			
			
			clearConnectors();
			clearLinkages();
			clearAttributes();

			connectors = null;
			linkages = null;
			attributes = null;
			
			label = null;
			l = null;
			
			board = null;
			
			c1 = null;
			c2 = null;
			c3 = null;
			c4 = null;
		}
		
		public function isMouseOver(event:MouseEvent):Boolean
		{
			var x:Number = origin.x;
			var y:Number = origin.y;
			var mx:Number = event.localX;
			var my:Number = event.localY;
			
			if(x <= mx && y <= my && mx <= (x + cwidth) && my <= (y + cheight))
				return true;
			else
				return false;
		}
		
		public function isMouseOverConnector(event:MouseEvent):int
		{
			var mx:Number = event.localX;
			var my:Number = event.localY;
			
			if((c1.x -5) <= mx && (c1.y-5) <= my && mx <= (c1.x + 5) && my <= (c1.y + 5))
				return 1;
			
			if((c2.x -5) <= mx && (c2.y-5) <= my && mx <= (c2.x + 5) && my <= (c2.y + 5))
				return 2;
			
			if((c3.x -5) <= mx && (c3.y-5) <= my && mx <= (c3.x + 5) && my <= (c3.y + 5))
				return 3;
			
			if((c4.x -5) <= mx && (c4.y-5) <= my && mx <= (c4.x + 5) && my <= (c4.y + 5))
				return 4;		
			
			return 0;
		}
		
//		public function isMouseOverTriangle(event:MouseEvent):Boolean
//		{
//			var mx:Number = event.localX;
//			var my:Number = event.localY;
//			trace(c3.x + " " + mx + " " + c3.y + " " + my);
//			if((c3.x-8) <= mx && (c3.y-2) <= my && mx <= (c3.x + 8) && my <= (c3.y + 12))
//				return true;
//			else
//				return false;
//		}
		
		public function updateAttributes(label:String, termId:Number):void
		{
			//update fields
			this.label = label;
			//this.parentShape = parentShape;
			//update label
			l.text = label;
			this.termId = termId;
			//resize label if necessary
			resizeLabel();
		}
		
		private function addLabel():void
		{
			//add label if it is not there
        	if(!board.contains(l)){
	       		board.addChild(l);
        		var i:int = board.getChildIndex(this);
        		//swap the index to place the shape
        		//over the label
	       		board.setChildIndex(l,i);
	        	board.setChildIndex(this,i+1);
	        	//IMPORTANT
	        	//blend the label with the shape together
				blendMode =  BlendMode.MULTIPLY; 
        	}
		}
		
		private function removeLabel():void
		{
			//remove label if it is there
        	if(board.contains(l)){
	       		board.removeChild(l);
        	}
		}
		
		
		/* this function set the width of the Text component to undefined if
		the length of the text is smaller than the shape's width (this streches 
		the Text component horizontally) and equal to the shape's width if the length of
		the text is greater than the width of the shape (this streches the
		Text component vertically) */
		private function resizeLabel():void
		{
			var lw:int = getLabelTextWidth();
			if(lw > cwidth - DELTA_WIDTH)
			{
				l.width = cwidth - DELTA_WIDTH;
			}
			else
			{
				l.width = undefined;
			}
		}
		
		private function getLabelTextWidth():int
		{
			//IMPORTANT: Call this function because in some instance
			//for performance issues, Flash doesn't add the Text to the
			//parent until later and you won't get an accurate measure
			//for the text width
			l.regenerateStyleCache(false);
			//measure the text length
			var m:TextLineMetrics = l.measureText(label);	
			return m.width;
		}
			
	
		public function getConnectorPoint(cIndex:int):CPoint
		{
			if(cIndex == 1)
			{
				return c1;
			}
			else if(cIndex == 2)
			{
				return c2;
			}
			else if(cIndex == 3)
			{
				return c3;
			}
			else if(cIndex == 4)
			{
				return c4;
			}
		
			return null;
		}
			
		
		public function addConnector(c:CConnector):void
		{
			if(!connectors.contains(c))
				connectors.addItem(c);
		}
		
		public function removeConnector(c:CConnector):void
		{
			if(connectors.contains(c))
				connectors.removeItemAt(connectors.getItemIndex(c));
	
		}	
		
		public function clearConnectors():void
		{
			connectors.removeAll();
		}
		
		public function addLinkage(shape:CShape,citations:ArrayCollection, effectRelationship:Boolean):void
		{
			
			var linkage:Linkage=findOrCreateLinkage(true,shape);
			for(var i:int=0;i<citations.length;i++)
			{
				if(!linkage.causeEffectIds.contains(citations[i].causeEffectId))
				{
					linkage.causeEffectIds.addItem(citations[i].causeEffectId);
					linkage.citationIds.addItem(citations[i].citationId);
				}
					linkage.effectRelationship = effectRelationship;
			}
		}
		
		public function removeLinkageWithCauseEffect(shape:CShape, causeEffectId:Number):void
		{
			var linkage:Linkage=findOrCreateLinkageWithCauseEffect(false,shape, causeEffectId);
			if(linkage!=null)
			{
				//Alert.show("You are about to delete evidence " + shape.label + " causeEffectIds = " + linkages.length);
				linkage.causeEffectIds.removeItemAt(linkage.causeEffectIds.getItemIndex(causeEffectId));
				if (linkage.causeEffectIds.length == 0)
					linkages.removeItemAt(linkages.getItemIndex(linkage));
			}
		}
		
		public function removeLinkage(shape:CShape):void
		{
			var linkage:Linkage=findOrCreateLinkage(false,shape);
			if(linkage!=null)
				linkages.removeItemAt(linkages.getItemIndex(linkage));
		}
		
		public function printLinkages():void
		{
			for(var i:int=0;i<linkages.length;i++)
			{
				var s:String = "";
				var l:Linkage = linkages[i];
				s += l.shape.label+" [ ";
				for(var m:int=0;m<l.citationIds.length;m++)	
					s += l.citationIds[m]+" ";
				s += "]";
				trace(s);
			}
		}
		
		public  function findOrCreateLinkage(createNew:Boolean,shape:CShape):Linkage
		{
			//search for linkage
			for(var i:int=0;i<linkages.length;i++)
			{
				var l:Linkage = linkages[i];
				if(l.shape == shape)
				{
					return l;
				}
			}
			//create a new one if needed
			if(createNew)
			{
				var linkage:Linkage = new Linkage();
				linkage.shape = shape;
				linkages.addItem(linkage);
				return linkage;
			}
			else
				return null;
		}
		
		public  function findOrCreateLinkageWithCauseEffect(createNew:Boolean,shape:CShape, causeEffectId:Number):Linkage
		{
			//search for linkage
			for(var i:int=0;i<linkages.length;i++)
			{
				var l:Linkage = linkages[i];
				//Alert.show("You are about to delete evidence " + shape.label + " linkages = " + l.causeEffectIds.length);
				if(l.shape == shape && l.causeEffectIds.contains(causeEffectId))
				{
					return l;
				}
			}
			
			return null;
		}
		
		public function clearLinkages():void
		{
			linkages.removeAll();
		}
		
		public function getAttribute(type:Number):ShapeAttribute
		{
			return findOrCreateAttribute(type,true);
		}
		
		public function addAttribute(type:Number,valueId:Number):void
		{
			var a:ShapeAttribute = findOrCreateAttribute(type,true);
			if(!a.values.contains(valueId))
					a.values.addItem(valueId);
		}
		
		public function removeAttribute(type:Number,valueId:Number):void
		{

			var a:ShapeAttribute = findOrCreateAttribute(type,false);
			if(a!=null&&a.values.contains(valueId))
					a.values.removeItemAt(a.values.getItemIndex((valueId)));

		}
		
		public function clearAttributes():void
		{
			attributes.removeAll();
		}
		
		private function findOrCreateAttribute(type:Number,createNew:Boolean):ShapeAttribute
		{
			//find an attribute if it exists
			for(var i:int=0;i<attributes.length;i++)
			{
				var a:ShapeAttribute = attributes[i];
				if(a.type == type)
					return a;
			}
			//if you cannot find the type create a new one if necessary
			if(createNew)
			{
				var na:ShapeAttribute = new ShapeAttribute();
				na.type = type;	
				attributes.addItem(na);
				return na;
			}
			else
				return null;
		}
		
		//this function clones the drawing
		//and the attributes of the shape
		public function clone():CShape
		{
			var s:CShape = new CShape();
			return this.createClone(s,false);
		}
		
		//this function clones the drawing of a shape
		public function cloneDrawing():CShape
		{
			var s:CShape = new CShape();
			return this.createClone(s,true);
		}
		
		protected function createClone(s:CShape,drawingOnly:Boolean):CShape
		{
			s.color = this.color;
			s.cwidth = this.cwidth;
			s.cheight = this.cheight;
			s.thickness = this.thickness;
			s.legendType = this.legendType;
			if(!drawingOnly)
			{
				s.label = this.label;
				s.labelSymbolType = this.labelSymbolType;
				s.attributes = ArrayCollectionUtil.copyArrayCollection(this.attributes);
			}
			else
				s.label = "";
			
			s.board = board;
			return s;
		}
	}
}