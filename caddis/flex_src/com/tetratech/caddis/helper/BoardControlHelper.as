// ActionScript file
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.event.BoardControlPanEvent;
import com.tetratech.caddis.event.BoardControlZoomEvent;

import flash.events.MouseEvent;
import flash.utils.Timer;

import mx.events.SliderEvent;

private var zoomLevel:int = 0;
private var slideTimer:Timer = null;
private const SLIDE_TIME_INTERVAL:int = 50;

private function init():void
{
   //add move (up,down,left,center,right) event handlers
   up.addEventListener(MouseEvent.MOUSE_DOWN,panUpStart);
   up.addEventListener(MouseEvent.MOUSE_UP,panEnd);
   left.addEventListener(MouseEvent.MOUSE_DOWN,panLeftStart);
   left.addEventListener(MouseEvent.MOUSE_UP,panEnd);
   right.addEventListener(MouseEvent.MOUSE_DOWN,panRightStart);
   right.addEventListener(MouseEvent.MOUSE_UP,panEnd);
   down.addEventListener(MouseEvent.MOUSE_DOWN,panDownStart);
   down.addEventListener(MouseEvent.MOUSE_UP,panEnd);
   center.addEventListener(MouseEvent.CLICK,panCenter);
   //add + and - zoom event handlers
   incZoom.addEventListener(MouseEvent.CLICK,increaseZoom);
   decZoom.addEventListener(MouseEvent.CLICK,decreaseZoom);
   //add event handler for slider
   //zoomLevel.addEventListener(SliderEvent.CHANGE,zoomLevelChanged);
}

//pan up
private function panUp(event:TimerEvent):void
{
	broadcastOriginChange(0,Constants.PAN_DELTA_VALUE);
}

private function panUpStart(event:MouseEvent):void
{
	slideTimer = new Timer(SLIDE_TIME_INTERVAL)
	slideTimer.addEventListener(TimerEvent.TIMER, panUp);
	slideTimer.start();
}
//end

//pan left
private function panLeft(event:TimerEvent):void
{
	broadcastOriginChange(Constants.PAN_DELTA_VALUE,0);
}

private function panLeftStart(event:MouseEvent):void
{
	slideTimer = new Timer(SLIDE_TIME_INTERVAL)
	slideTimer.addEventListener(TimerEvent.TIMER, panLeft);
	slideTimer.start();
}
//end

//pan right
private function panRight(event:TimerEvent):void
{
	broadcastOriginChange(-Constants.PAN_DELTA_VALUE,0);
}

private function panRightStart(event:MouseEvent):void
{
	slideTimer = new Timer(SLIDE_TIME_INTERVAL)
	slideTimer.addEventListener(TimerEvent.TIMER, panRight);
	slideTimer.start();
}
//end

//pan down
private function panDown(event:TimerEvent):void
{
	broadcastOriginChange(0,-Constants.PAN_DELTA_VALUE);
}

private function panDownStart(event:MouseEvent):void
{
	slideTimer = new Timer(SLIDE_TIME_INTERVAL)
	slideTimer.addEventListener(TimerEvent.TIMER, panDown);
	slideTimer.start();
}
//end

//center diagram
private function panCenter(event:MouseEvent):void
{
	broadcastOriginCentered();
}

//end

//end panning
private function panEnd(event:MouseEvent):void
{
	slideTimer.stop();
	slideTimer = null;
}
//end

private function increaseZoom(event:MouseEvent):void
{
//   if(zoomLevel.value < Constants.SLIDER_MAX_VALUE)
//   {
//		var newZoomLevel:int = zoomLevel.value+Constants.SLIDER_INTERVAL_VALUE;;
//		zoomLevel.value = newZoomLevel;
//		broadcastZoomLevelChange(newZoomLevel);
//   }
	
	if(zoomLevel < Constants.ZOOM_LEVEL_MAX)
	{
		broadcastZoomLevelChange(zoomLevel+1);
	}
}

private function decreaseZoom(event:MouseEvent):void
{
//   if(zoomLevel.value > Constants.SLIDER_MIN_VALUE)
//   {
//		var newZoomLevel:int = zoomLevel.value-Constants.SLIDER_INTERVAL_VALUE;
//		zoomLevel.value = newZoomLevel;
//		broadcastZoomLevelChange(newZoomLevel);
//   }

	if(zoomLevel > Constants.ZOOM_LEVEL_MIN)
	{
		broadcastZoomLevelChange(zoomLevel-1);
	}
}

private function zoomLevelChanged(event:SliderEvent):void
{
	broadcastZoomLevelChange(event.value);
}

/* This method can be used from outside to change the value of the slider */
public function setZoomLevel(level:int):void
{
//	zoomLevel.value = level*Constants.SLIDER_INTERVAL_VALUE;
	zoomLevel = level;
}

/* This method broadcast a origin changed event */
private function broadcastOriginChange(deltaX:Number,deltaY:Number):void
{
   var bcpe:BoardControlPanEvent = new BoardControlPanEvent(BoardControlPanEvent.ORIGIN_CHANGE);
   bcpe.deltaX = deltaX;
   bcpe.deltaY = deltaY;	
   this.dispatchEvent(bcpe);
}

/* This method broadcast a origin centered event */
private function broadcastOriginCentered():void
{
   var bcpe:BoardControlPanEvent = new BoardControlPanEvent(BoardControlPanEvent.ORIGIN_CENTERED);
   bcpe.deltaX = 0;
   bcpe.deltaY = 0;	
   this.dispatchEvent(bcpe);
}

/* This method broadcasts a zoom level change event */
private function broadcastZoomLevelChange(zoomLevel:int):void
{
   //create a new board control event
   var bce:BoardControlZoomEvent = new BoardControlZoomEvent(BoardControlZoomEvent.ZOOM_LEVEL_CHANGE);
   //scale zoom level by 10
//   bce.zoomLevel = zoomLevel/Constants.SLIDER_INTERVAL_VALUE;
	bce.zoomLevel = zoomLevel;
   //dispatch this event
   this.dispatchEvent(bce);
}
