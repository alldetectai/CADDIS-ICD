// ActionScript file
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.event.InsetPanEvent;
import com.tetratech.caddis.event.InsetZoomEvent;
import com.tetratech.caddis.model.Model;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.controls.Alert;
import mx.events.CloseEvent;

//center of the inset
private var centerX:Number=Constants.INSET_WIDTH/2;
private var centerY:Number=Constants.INSET_HEIGHT/2;
//width and height of the inset
private var sw:Number=Constants.INSET_WIDTH;
private var sh:Number=Constants.INSET_HEIGHT;
//current position of the viewing square(rect)
private var squareX:Number=centerX;
private var squareY:Number=centerY;
//old position of the square
private var oldSquareX:Number=centerX;
private var oldSquareY:Number=centerY;
//dragging state
private var draggingSquare:Boolean = false;
//old position of the mouse
private var oldMouseX:Number;
private var oldMouseY:Number;
//display object to draw - (drawing board)
private var displayObject:DisplayObject = null; 
//cached board data pixels
private var boardData:BitmapData = null;
//internal zoom level (should equal the board's zoom level)
private var zoomLevel:int=Constants.ZOOM_LEVEL_MIN;
//state var for panning and zooming errors
private var diplayedWarningMessage:Boolean = false;

private function init():void
{
	//add event listeners
	insetBoard.addEventListener(MouseEvent.MOUSE_DOWN,handleMouseDown);
	insetBoard.addEventListener(MouseEvent.MOUSE_UP,handleMouseUp);
	insetBoard.addEventListener(MouseEvent.MOUSE_MOVE,handleMouseMove);
	insetBoard.addEventListener(MouseEvent.MOUSE_OUT,handleMouseOut);
	//insetBoard.addEventListener(MouseEvent.MOUSE_WHEEL,handleMouseWheel);
}

/* This methods sets the drawing component 
from which the inset is supposed to be drawn from */
public function monitor(displayObject:DisplayObject):void
{
	this.displayObject = displayObject;
}

private function handleMouseDown(event:MouseEvent):void
{
	var x:Number = event.localX;
	var y:Number = event.localY;
	//check if the mouse is over the square
	if(x>=(squareX-sw/2)&&y>=(squareY-sh/2)&&x<=(squareX+sw/2)&&y<=(squareY+sh/2))
		grabSquare(event);
}

private function handleMouseUp(event:MouseEvent):void
{
	if(draggingSquare)
		releaseSquare();
}

private function handleMouseMove(event:MouseEvent):void
{
	if(draggingSquare)
		dragSquare(event);
}


private function handleMouseOut(event:MouseEvent):void
{
	if(draggingSquare)
		releaseSquare();
}

private function handleMouseWheel(event:MouseEvent):void
{
	if(event.delta > 0)
	{
		//broadcast increase zoom level
		broadcastZoomLevelChange(zoomLevel + 1);
	}else if(event.delta < 0)
	{
		//boardcast decrease zoom level
		broadcastZoomLevelChange(zoomLevel - 1);
	}
}

private function grabSquare(event:MouseEvent):void
{
		draggingSquare = true;
		oldMouseX = event.localX;
		oldMouseY = event.localY;
}

private function dragSquare(event:MouseEvent):void
{
	var newSquareX:Number = squareX + event.localX - oldMouseX;
	var newSquareY:Number = squareY + event.localY - oldMouseY;
	//check whether the square is inside the inset
	//before moving it around (change this so that the view rect
	//cannot move outside of the inset)
	if((newSquareX-sw/2)>=0&&(newSquareY-sh/2)>=0
	&&(newSquareX+sw/2)<=Constants.INSET_WIDTH
	&&(newSquareY+sh/2)<=Constants.INSET_HEIGHT)
	{
		//update inset
		squareX = newSquareX;
		squareY = newSquareY;
		draw(false,zoomLevel);
	}
	//update old mouse position
	oldMouseX = event.localX;
	oldMouseY = event.localY;
}

private function releaseSquare():void
{
	//***
	//IMPORTANT: CALCULATE THE NEW POSITION AND DIVIDE BY THE INSET SCALE
	//TO FIGURE OUT THE POSITION IN THE MAIN BOARD. THE INSET SCALE IS (1/a)
	//***
	var deltaX:Number = (squareX-oldSquareX)/Model.INSET_TO_BOARD_RATIO;
	var deltaY:Number = (squareY-oldSquareY)/Model.INSET_TO_BOARD_RATIO;
	//***
	//IMPORTANT: MULTIPLY BY THE POWERED ZOOM SCALE TO MAKE UP FOR THE
	//INCREASE IN PIXEL POSITION ON THE BOARD DUE TO ZOOMING
	//FORMULA: (X,Y)*(ZOOM_INC_LEVEL)^(ZOOM_SCALE)
	//***
	var scale:Number = Math.pow(Constants.ZOOM_SCALE_INC,zoomLevel);
	deltaX = deltaX*scale*Model.INITIAL_ZOOM_SCALE;
	deltaY = deltaY*scale*Model.INITIAL_ZOOM_SCALE;
	//broadcast an event to singal the movement of origin
	// - is to change direction
	broadcastOriginMove(-deltaX,-deltaY);
	//reset fields and state
	draggingSquare = false;
	oldMouseX = 0;
	oldMouseY = 0;
	oldSquareX = squareX;
	oldSquareY = squareY;
	//draw 
	draw(false,zoomLevel);	
}

public function draw(boardHasChanged:Boolean,zoomLevel:int):void
{
	
	//*** DRAW BOARD CONTEND ***//
	//cache previous pixels of the board if it has not changed
	//to improve performance (however, must check if you have
	//cached the bitmap data array)
	if(boardHasChanged||boardData==null)
	{
		//create a bitmap data array with the pixels of the main board
		boardData = new BitmapData(Model.BOARD_WIDTH,Model.BOARD_HEIGHT);
		boardData.draw(displayObject);
	}
	
	//scale the bitmap data for the inset
	var m:Matrix = new Matrix();
	m.scale(Model.INSET_TO_BOARD_RATIO,Model.INSET_TO_BOARD_RATIO);
	
	//draw bitmap data on the inset
	insetBoard.graphics.clear();		
	insetBoard.graphics.beginBitmapFill(boardData,m,false,true);
	insetBoard.graphics.lineStyle(1,0x666666);
	insetBoard.graphics.drawRect(0, 0, Constants.INSET_WIDTH, Constants.INSET_HEIGHT);
	//***********************//
	
	//*** DRAW RECTANGLE ***//
	//set the local zoom level
	setZoomLevel(zoomLevel);
	
	//draw a blue square centered according to the square x and square y (REMEMBER TO CLIP THE RECTANGLE)
	var p1:Point = getTopLeftCorner();
	var p2:Point = getTopRightCorner();
	var p3:Point = getBottomRightCorner();
	var p4:Point = getBottomLeftCorner();
	
	insetBoard.graphics.beginFill(0x6699FF,0.2);
	insetBoard.graphics.lineStyle(1,0x6699FF,1);
	insetBoard.graphics.drawRect(p1.x,p1.y,p2.x-p1.x,p4.y-p1.y);
	//**********************//
}

public function setPosition(x:Number,y:Number):void
{
	//***
	//IMPORTANT: DIVIDE BY THE POWERED ZOOM SCALE TO SCALE BACK FROM THE
	//INCREASE IN PIXEL POSITION ON THE BOARD DUE TO ZOOMING
	//FORMULA: (X,Y)*(ZOOM_INC_LEVEL)^(ZOOM_SCALE)
	//***
	var scale:Number = Math.pow(Constants.ZOOM_SCALE_INC,zoomLevel);
	x = x/(scale*Model.INITIAL_ZOOM_SCALE);
	y = y/(scale*Model.INITIAL_ZOOM_SCALE);
	//***
	//IMPORTANT: CALCULATE THE NEW POSITION AND MULTIPLY BY THE INSET SCALE
	//TO FIGURE OUT THE POSITION IN THE INSET. THE INSET SCALE IS (1/a)
	//***
	x = x*Model.INSET_TO_BOARD_RATIO;
	y = y*Model.INSET_TO_BOARD_RATIO;
	//calculate orgin
	// - is to change direction
	x = -x + sw/2;
	y = -y + sh/2;
	//update fields
	squareX=x;
	squareY=y;
	oldSquareX=x;
	oldSquareY=y;
}

/* this function determines whether you can move
	without going to gray area */
public function canPosition(x:Number,y:Number):Boolean
{
	//***
	//IMPORTANT: DIVIDE BY THE POWERED ZOOM SCALE TO SCALE BACK FROM THE
	//INCREASE IN PIXEL POSITION ON THE BOARD DUE TO ZOOMING
	//FORMULA: (X,Y)*(ZOOM_INC_LEVEL)^(ZOOM_SCALE)
	//***
	var scale:Number = Math.pow(Constants.ZOOM_SCALE_INC,zoomLevel);
	x = x/(scale*Model.INITIAL_ZOOM_SCALE);
	y = y/(scale*Model.INITIAL_ZOOM_SCALE);
	//***
	//IMPORTANT: CALCULATE THE NEW POSITION AND MULTIPLY BY THE INSET SCALE
	//TO FIGURE OUT THE POSITION IN THE INSET. THE INSET SCALE IS (1/a)
	//***
	x = x*Model.INSET_TO_BOARD_RATIO;
	y = y*Model.INSET_TO_BOARD_RATIO;
	//calculate orgin
	// - is to change direction
	x = -x + sw/2;
	y = -y + sh/2;

	//check if it is inside square
	if((x-sw/2)>=-Constants.DELTA_ZERO
	&&(y-sh/2)>=-Constants.DELTA_ZERO
	&&(x+sw/2)<=(Constants.INSET_WIDTH+Constants.DELTA_ZERO)
	&&(y+sh/2)<=(Constants.INSET_HEIGHT+Constants.DELTA_ZERO))
		return true;
	else
	{
//		//avoid displaying the warning message multiple times
//		if(!diplayedWarningMessage)
//		{
//			diplayedWarningMessage = true;
//			Alert.show("You cannot pan anymore. Please reposition the inset", "Information", Alert.OK, null, alertOKHandler, null, Alert.OK);
//		}
		return false;
	}
}

public function reset():void
{
	squareX=centerX;
	squareY=centerY;
	oldSquareX=centerX;
	oldSquareY=centerY;
}

private function setZoomLevel(zoomLevel:int):void
{
	//*** check if you need to scale
	//the width and height of the viewing 
	//rectangle ***
	var d:int = 0;
	if(this.zoomLevel>zoomLevel)
	{
		d = this.zoomLevel - zoomLevel;
		sw = sw*Math.pow(Constants.ZOOM_SCALE_INC,d);
		sh = sh*Math.pow(Constants.ZOOM_SCALE_INC,d);
		this.zoomLevel = zoomLevel;
	}
	else(this.zoomLevel<zoomLevel)
	{
		d = zoomLevel - this.zoomLevel;
		sw = sw*Math.pow(Constants.ZOOM_SCALE_DEC,d);
		sh = sh*Math.pow(Constants.ZOOM_SCALE_DEC,d);
		this.zoomLevel = zoomLevel;
	}
}

/* this function determines whether you can zoom
	without going to gray area */
public function canZoom(zoomLevel:int):Boolean
{
	var d:int = 0;
	var tsw:Number = 0;
	var tsh:Number = 0;
	if(this.zoomLevel>zoomLevel)
	{
		d = this.zoomLevel - zoomLevel;
		tsw = sw*Math.pow(Constants.ZOOM_SCALE_INC,d);
		tsh = sh*Math.pow(Constants.ZOOM_SCALE_INC,d);
	}
	else(this.zoomLevel<zoomLevel)
	{
		d = zoomLevel - this.zoomLevel;
		tsw = sw*Math.pow(Constants.ZOOM_SCALE_DEC,d);
		tsh = sh*Math.pow(Constants.ZOOM_SCALE_DEC,d);
	}
	
	//check if it is inside sqaure
	if((squareX-tsw/2)>=-Constants.DELTA_ZERO
	&&(squareY-tsh/2)>=-Constants.DELTA_ZERO
	&&(squareX+tsw/2)<=(Constants.INSET_WIDTH+Constants.DELTA_ZERO)
	&&(squareY+tsh/2)<=(Constants.INSET_HEIGHT+Constants.DELTA_ZERO))
		return true;
	else
	{
		//avoid displaying the warning message multiple times
		if(!diplayedWarningMessage)
		{
			var msg:String = null;
			diplayedWarningMessage = true;
			
			if(this.zoomLevel>zoomLevel)
				msg = "You cannot zoom out anymore. Please reposition the inset, center the diagram, or pan around.";
			//this never really happens( you can always zoom in)
			else if(this.zoomLevel<zoomLevel)
				msg = "You cannot zoom in anymore. Please reposition the inset, center the diagram, or pan around.";
			
			Alert.show(msg, "INFORMATION", Alert.OK, null, alertOKHandler, null, Alert.OK);
		}
		return false;
	}

}

private function alertOKHandler(event:CloseEvent):void
{
	diplayedWarningMessage = false;
}

private function getTopLeftCorner():Point
{
	var p1x:Number = squareX-sw/2;
	var p1y:Number = squareY-sh/2;
	
	if(p1x<0)
		p1x=0;
	if(p1y<0)	
		p1y=0;
	
	var p:Point = new Point();
	p.x = p1x;
	p.y = p1y;	
	return p;
}

private function getTopRightCorner():Point
{
	var p1x:Number = squareX+sw/2;
	var p1y:Number = squareY-sh/2;
	
	if(p1x>Constants.INSET_WIDTH)
		p1x=Constants.INSET_WIDTH;
	if(p1y<0)
		p1y=0;
		
	var p:Point = new Point();
	p.x = p1x;
	p.y = p1y;	
	return p;
}

private function getBottomRightCorner():Point
{
	var p1x:Number = squareX+sw/2;
	var p1y:Number = squareY+sh/2;
	
	if(p1x>Constants.INSET_WIDTH)
		p1x=Constants.INSET_WIDTH;
	if(p1y>Constants.INSET_HEIGHT)
		p1y=Constants.INSET_HEIGHT;
	
	var p:Point = new Point();
	p.x = p1x;
	p.y = p1y;	
	return p;
}

private function getBottomLeftCorner():Point
{
	var p1x:Number = squareX-sw/2;
	var p1y:Number = squareY+sh/2;
	
	if(p1x<0)
		p1x=0;
	if(p1y>Constants.INSET_HEIGHT)
		p1y=Constants.INSET_HEIGHT;
	
	var p:Point = new Point();
	p.x = p1x;
	p.y = p1y;	
	return p;
}


/* This method broadcast a origin move event */
private function broadcastOriginMove(deltaX:Number,deltaY:Number):void
{
   var e:InsetPanEvent = new InsetPanEvent(InsetPanEvent.ORIGIN_MOVE);
   e.deltaX = deltaX;
   e.deltaY = deltaY;	
   this.dispatchEvent(e);
}

/* This method broadcast a zoom level event */
private function broadcastZoomLevelChange(zoomLevel:Number):void
{
   var e:InsetZoomEvent = new InsetZoomEvent(InsetZoomEvent.ZOOM_LEVEL_CHANGE);
   e.zoomLevel = zoomLevel;
   this.dispatchEvent(e);
}
