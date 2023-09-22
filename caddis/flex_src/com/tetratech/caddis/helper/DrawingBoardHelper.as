import com.adobe.images.PNGEncoder;
import com.adobe.utils.StringUtil;
import com.as3xls.xls.ExcelFile;
import com.as3xls.xls.Sheet;
import com.tetratech.caddis.common.ArrayUtil;
import com.tetratech.caddis.common.CSV;
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.common.ExcelExporterUtil;
import com.tetratech.caddis.common.GraphicsUtil;
import com.tetratech.caddis.drawing.CArrowLine;
import com.tetratech.caddis.drawing.CConnector;
import com.tetratech.caddis.drawing.CEllipse;
import com.tetratech.caddis.drawing.CHexagon;
import com.tetratech.caddis.drawing.CLine;
import com.tetratech.caddis.drawing.COctagon;
import com.tetratech.caddis.drawing.CPentagon;
import com.tetratech.caddis.drawing.CPoint;
import com.tetratech.caddis.drawing.CRectangle;
import com.tetratech.caddis.drawing.CRoundRectangle;
import com.tetratech.caddis.drawing.CShape;
import com.tetratech.caddis.event.AccordionToggleEvent;
import com.tetratech.caddis.event.BoardControlPanEvent;
import com.tetratech.caddis.event.BoardControlZoomEvent;
import com.tetratech.caddis.event.InsetPanEvent;
import com.tetratech.caddis.event.InsetToggleEvent;
import com.tetratech.caddis.event.InsetZoomEvent;
import com.tetratech.caddis.event.MenuItemClickEvent;
import com.tetratech.caddis.event.ModeSwitchEvent;
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.view.Menu;
import com.tetratech.caddis.view.NewLinkagePopUp;
import com.tetratech.caddis.view.ShapePopUp;
import com.tetratech.caddis.view.TabNavigator;
import com.tetratech.caddis.vo.Citation;
import com.tetratech.caddis.vo.Linkage;
import com.tetratech.caddis.vo.LookupValue;
import com.tetratech.caddis.vo.Term;
import com.tetratech.caddis.vo.User;

import flash.display.Graphics;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.net.FileReference;
import flash.utils.ByteArray;

import mx.charts.series.items.AreaSeriesItem;
import mx.collections.ArrayCollection;
import mx.containers.VBox;
import mx.controls.Alert;
import mx.controls.Label;
import mx.controls.scrollClasses.ScrollBar;
import mx.core.UIComponent;
import mx.effects.WipeDown;
import mx.effects.WipeLeft;
import mx.effects.WipeRight;
import mx.effects.WipeUp;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.ItemClickEvent;
import mx.events.ScrollEvent;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.validators.Validator;

//APP MODE (VIEW OR EDIT)
private var mode:String = Constants.MODE_VIEW;
private var oldMode:String = Constants.MODE_NONE;

//START OF BOARD STATE (what the user is doing on the board)
//1. EDIT MODE
/* a. Drawing State flags */
private var drawingLine:Boolean = false; //drawing a line on the board
private var drawingShape:Boolean = false; //drawing a shape on the board
private var drawingSquare:Boolean = false; //drawing a square when selecting shapes
/* b. Menu state flags */
private var addingLinkage:Boolean = false; //adding a linkage to the board
private var copyingShape:Boolean = false; //copying a shape on the board
private var aligningShapes:Boolean = false; //align shapes vertically
private var selectingShapes:Boolean = false; //select shapes

private var viewingLinkages:Boolean = false; //highlighting linkages by clicking on shapes
//END OF BOARD STATE

//MOUSE MODES on SHAPES or LINES (EDIT MODE ONLY)
private var dragging:Boolean = false;
private var resizing:Boolean = false;

//shape type to be drawn
private var shapeType:String;
private var legendType:Number;
private var shapeColor:Number;
//line type to be drawn
private var lineType:String;

  
//shapes
private var shape:CShape=null; //current selected shape
private var shapes:ArrayCollection=null; //list of shapes on the board
private var dragShape:CShape=null; //shape that is dragged ONLY when users clicks on a create shape item on the menu

//lines
private var line:CLine=null;  //curent selected line
private var lines:ArrayCollection=null; //list of lines on the board
private var diagramEvidenceList:ArrayCollection = null;
//old mouse coordinates
private var oldX:Number = 0;
private var oldY:Number = 0;

//connector index
private var cIndex:int = 0;

//zoom level
private var zoomLevel:int = Constants.ZOOM_LEVEL_MIN;
private var initalZoomScale:Number = Model.INITIAL_ZOOM_SCALE;

//zoom origin
private var zoomOriginX:Number=Constants.ZOOM_ORIGIN_X;
private var zoomOriginY:Number=Constants.ZOOM_ORIGIN_Y;

//toggler states
private var insetShown:Boolean = false;
private var menuShown:Boolean = false;
private var accordionShown:Boolean = false;
private var legendShown:Boolean = false;
private var legendShownLink:Boolean = false;
//effects
private var wipeRight:WipeRight = null;
private	var wipeLeft:WipeLeft = null;
private	var wipeUp:WipeUp = null;
private	var wipeDown:WipeDown = null;

//fields for shape pop up
private var shapePopUpPanel=null;
private var newShape:Boolean;

//fields for new linkage pop up
private var newLnkPopUpPanel=null;
private var reviewLnkPopUpPanel = null;
private var addLnkPopUpPanel=null;
private var causeShapeAdd:CShape = null;
private var shapesAdd:ArrayCollection=null;
private var selCits:ArrayCollection = new ArrayCollection(); 
//collection of shapes for new linkage (EDIT MODE)
private var newLinkageShapes:ArrayCollection=null;
private var causeShape:CShape = null;

//collection of shapes for highlighting linkages (VIEW MODE)
private var clickedShapes:ArrayCollection=null;

//collection of shapes used for alignment (EDIT MODE)
private var shapesToAlign:ArrayCollection=null;

//collection for shape selection (EDIT MODE)
private var selectedShapes:ArrayCollection=null;

//pointer to tab navigator
private var tabNav:TabNavigator = null;
//pointer to menu
private var menu:Menu = null;

private var homePage:VBox = null;
private var drawPage:VBox = null;
private var searchPage:VBox = null;

//store creation point for shapes
private var newShapeLocation:CPoint = null;

//pointer to dashed lines comoponent
private var dashedLines:UIComponent = null;

//pointer to square component
private var selectionSquare:UIComponent = null;
//coordiantes for selection square
private var startPoint:Point;
private var endPoint:Point;

private var canAddTerm:Boolean = false;
private var displayList:Object = null;
private var contentHeight; 

private var displayArray:ArrayCollection = new ArrayCollection();
/* START OF INIT FUNCTIONS */
/* This function is used to initialize the board components */
private function init():void
{
	//bind to tab navigator(tab navigator is the wrapper now)
	tabNav = this.parent.parent.getChildByName("tabNav") as TabNavigator;
	//bind to menu (menu is in the wrapper now)
	menu = this.parent.parent.getChildByName("menu") as Menu;
	homePage = this.parent.parent.getChildByName("hometextarea") as VBox;
	drawPage = this.parent.parent.getChildByName("drawingBoardP") as VBox;
    searchPage = this.parent.parent.getChildByName("searchArea") as VBox;
	contentHeight = homePage.height; 
	
	//initialize components
	board.parent.setChildIndex(board,0);
	board.parent.setChildIndex(boardControl,1);
	board.parent.setChildIndex(inset,2);
	board.parent.setChildIndex(accordion,3);
	board.parent.setChildIndex(legend,4);
	
	//setup event handlers
	board.doubleClickEnabled = true;
	
	//add mouse events
	board.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
	board.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
	board.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
	//removed mousewheel for zooming on the board
	//board.addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler);
	
	//add mouse click events
	board.addEventListener(MouseEvent.CLICK,clickHandler);
	board.addEventListener(MouseEvent.DOUBLE_CLICK,dblClickHandler);
	//*** add key events - this doesn't work ***
	//board.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyHandler);
	//***
	
	//add event listeners for board control
	boardControl.addEventListener(BoardControlZoomEvent.ZOOM_LEVEL_CHANGE,boardControlZoomLevelChangeHandler);
	boardControl.addEventListener(BoardControlPanEvent.ORIGIN_CHANGE,originChangeHandler);
	boardControl.addEventListener(BoardControlPanEvent.ORIGIN_CENTERED,originCenteredHandler);

	//add event listener for inset
	inset.addEventListener(InsetPanEvent.ORIGIN_MOVE,originMoveHandler);
	inset.addEventListener(InsetZoomEvent.ZOOM_LEVEL_CHANGE,insetZoomLevelChangeHandler);
	//wire inset to monitor drawing area
	inset.monitor(board);
	
	//add event listeners for tab navigator
	tabNav.addEventListener(ModeSwitchEvent.MODE_SWITCH,modeSwitchHandler);
	
	//add event listeners for menu
	menu.addEventListener(MenuItemClickEvent.MENU_ITEM_CLICK,menuItemHandler);
	menu.addEventListener(InsetToggleEvent.INSET_TOGGLE,insetToggleHandler);
	menu.addEventListener(AccordionToggleEvent.ACCORDION_TOGGLE,accordionToggleHandler);

	//disable board
	enableBoard(false);
	
	//set user to guest
	var guestUser:User = new User();
	guestUser.roleId = Constants.LL_EPA_USER; //Constants.LL_PUBLIC_USER;
	guestUser.userName = "Guest";
	guestUser.userId = 0;
	Model.user = guestUser;
	
	//set the boardsize and scrolls
	var screenRect:Rectangle = systemManager.screen; 
	resizeDrawingBoard(screenRect.width, screenRect.height);
}
/* END OF INIT FUNCTIONS */

private function resizeDrawingBoard(width:Number,height:Number):void
{
	var wrapper:VBox = board.parent.parent as VBox;
	if(height < Constants.DEFAULT_BOARD_HEIGHT + 42)
	{
		wrapper.verticalScrollBar.addEventListener(ScrollEvent.SCROLL, handleScroll);

		board.parent.parent.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandlerVScroll);
		board.parent.parent.height = height - 60;
		//to have scroll outside the board
		board.parent.parent.width = Constants.DEFAULT_BOARD_WIDTH + 40 ;
		var app:Canvas = board.parent.parent.parent.parent as Canvas;
		app.horizontalScrollPolicy = "on";
	}
	else
	{
		wrapper.height = Constants.DEFAULT_BOARD_HEIGHT;
		wrapper.verticalScrollPolicy = "off";
	}
}

/**
 * called when vertical scroll is moved on drawing board
 * */
private function handleScroll(event:ScrollEvent):void
{
	var ss:ScrollBar = event.target as ScrollBar;

	var pos:int = event.position ;
	inset.y = 20 + pos;
	boardControl.y = 20 + pos;
	legend.y=pos;
}

/**
 *mouseWheelHandler for mouse wheel wihtin gray area of VBox
 * */
private function mouseWheelHandlerVScroll(event:MouseEvent):void
{
	event.stopImmediatePropagation();
 	event.stopPropagation();
	
	var wrapper:VBox = board.parent.parent as VBox;
	var maxPos:int = wrapper.verticalScrollBar.maxScrollPosition;

	var currPos2:int = wrapper.verticalScrollPosition;
	
 	var num:int = event.delta / Math.abs(event.delta);  


	var pos:int = 0;
	if(currPos2 <= 0) {
		inset.y = 20 ;
		boardControl.y = 20;
		legend.y = 0;
	} else if( currPos2 >=  maxPos){
		inset.y = 20 + maxPos ;
		boardControl.y = 20 + maxPos;
		legend.y = maxPos;

	} else {
		inset.y = 20 + currPos2;
		boardControl.y = 20 + currPos2;
		legend.y = currPos2;
	}
}


/* START OF MENU EVENT HANDLERS */
private function menuItemHandler(event:MenuItemClickEvent):void
{
	if(event.operation == "new")
		newDiagram();
	else if(event.operation == "loadWithMsg")
		loadDiagram(true);
	else if(event.operation == "loadWithoutMsg")
		loadDiagram(false);
	else if(event.operation == "close")
		closeDiagram();
	else if(event.operation == "clear")
		clearDiagram();
	else if(event.operation == "stressor")
		newStressor();
	else if(event.operation == "addstep")
		newAddStep();	 
	else if(event.operation == "modfactor")
		newModFactor();
	else if(event.operation == "modaction")
		newModAction();
	else if(event.operation == "source")
		newSource();
	else if(event.operation == "bioresp")
		newBioResp();
	else if(event.operation == "humact")
		newHumanAct();
	else if(event.operation == "line")
		newLine();
	else if(event.operation == "arrowline")
		newArrowLine();
	else if(event.operation == "startSelection")
		startSelection();
	else if(event.operation == "endSelection")
		endSelection();
	else if(event.operation == "startCopying")
		startCopying();
	else if(event.operation == "endCopying")
		endCopying();
	else if(event.operation == "startAlignment")
		startAligning();
	else if(event.operation == "endAlignment")
		endAligning();
	else if(event.operation == "startNewLinkage")
		startNewLinkage();
	else if(event.operation == "endNewLinkage")
		endNewLinkage();
	else if(event.operation == "startReviewLinkage")
		startReviewLinkage();
	else if(event.operation == "endReviewLinkage")
		endReviewLinkage();
	else if(event.operation == "showLegend")
		legendToggleHandler();
	else if(event.operation == "showEditLegend")
		legendToggleHandler();
	else if(event.operation == "showLinkLegend")
		legendToggleHandler();
	else if(event.operation == "downloadDiagram")
		saveDiagramAsImage();
	else if(event.operation == "reset")
		resetDiagram();
	else if(event.operation == "hideLines")
		showDiagramWithoutLines();
	else if(event.operation == "showLines")
		showDiagramWithLines();
	else if (event.operation == "reviewLinkage")
		showDiragramEvidences();
}
/* END OF MENU EVENT HANDLERS */

/* START OF TOGGLERS EVENT HANDLERS */
private function accordionToggleHandler(event:AccordionToggleEvent):void
{
	if(!accordionShown)
	{
		accordion.visible = true;
		accordionShown = true;
	}
	else
	{
		accordion.visible = false;
		accordionShown = false;
	}
}

private function insetToggleHandler(event:InsetToggleEvent):void
{
	if(!insetShown)
	{
		inset.visible = true;
		insetShown = true;
		/* REMEMBER TO SYNCHRONIZE INSET */
		inset.draw(true,zoomLevel);
	}
	else
	{
		inset.visible = false;
		insetShown = false;
	}
}

private function legendToggleHandler():void
{
	if(!legendShown)
	{
		legend.visible = true;
		legendShown = true;
	}
	else
	{
		legend.visible = false;
		legendShown = false;
	}
	
}
/*
private function legendLinkToggleHandler():void
{
	if(!legendShownLink)
	{Alert.show("legendShownLink true" );
		legend.visible = true;
		legendShownLink = true;
	}
	else
	{Alert.show("legendShownLink false" );
		legend.visible = false;
		legendShownLink = false;
	}

}*/

private function modeSwitchHandler(event:ModeSwitchEvent):void
{
	
	menu.changeTab(event.newMode);
	
	if(event.newMode == Constants.MODE_VIEW)
	{

		//hide accordion
		accordion.visible = accordionShown;
		homePage.height = 0;
		homePage.visible = false;
		drawPage.visible = true;
		searchPage.visible = false;

		//set fields
		oldMode = mode;
		mode = Constants.MODE_VIEW;
		//show diagram
		showDiagramInViewMode(false,null);
		
	}
	else if(event.newMode == Constants.MODE_EDIT)
	{
		//reset menu state
		menu.resetEditState();
		//hide accordion
		accordion.visible = false;
		homePage.height = 0;
		homePage.visible = false;
		drawPage.visible = true;
		searchPage.visible = false;
		if(legendShown)
			legendToggleHandler();
		//set fields
		oldMode = mode;
		mode = Constants.MODE_EDIT;
		//show diagram
		showDiagramInEditMode(true);
	}
	else if(event.newMode == Constants.MODE_LINK)
	{ 	

		//hide accordion
		accordion.visible = false;
		homePage.height = 0;
		homePage.visible = false;
		drawPage.visible = true;
		searchPage.visible = false;
		
		//set fields
		oldMode = mode;
		mode = Constants.MODE_LINK;
		
	}
	else if(event.newMode == Constants.MODE_HOME)
	{
		//hide accordion
		accordion.visible = false;
		homePage.height = contentHeight;
		homePage.visible = true;
		drawPage.visible = false;
		searchPage.visible = false;
		if(legendShown)
			legendToggleHandler();
		//set fields
		oldMode = mode;
		mode = Constants.MODE_HOME;
		//show diagram
		//showDiagramInEditMode(true);
	}
	else if(event.newMode == Constants.MODE_SEARCH)
	{
		//hide accordion
		accordion.visible = false;
		homePage.height = 0;
	//	drawPage = 0;
		searchPage.height = contentHeight;
		homePage.visible = false;
		drawPage.visible = false;
		searchPage.visible = true;
		
		//set fields
		oldMode = mode;
		mode = Constants.MODE_SEARCH;

	}
}

/* END OF TOGGLERS EVENT HANDLERS */

/* START OF CONTROLS EVENT HANDLERS */
private function boardControlZoomLevelChangeHandler(event:BoardControlZoomEvent):void
{	
	zoomLevelChangeHandler(event.zoomLevel);
}

private function insetZoomLevelChangeHandler(event:InsetZoomEvent):void
{	
	zoomLevelChangeHandler(event.zoomLevel);
}


private function zoomLevelChangeHandler(newZoomLevel:int):void
{
	var scalingFactor:Number = 1;
	if(newZoomLevel > zoomLevel && newZoomLevel<=Constants.ZOOM_LEVEL_MAX)
	{
			if(inset.canZoom(newZoomLevel))
			{
				//calculate scaling factor
				scalingFactor = Math.pow(Constants.ZOOM_SCALE_INC,newZoomLevel-zoomLevel);
				//set zoom level
				zoomLevel = newZoomLevel;
				//update zoom level of the board control
				boardControl.setZoomLevel(zoomLevel);
				//scale board
				GraphicsUtil.scale(board,scalingFactor,zoomOriginX,zoomOriginY);
				 /* DRAW INSET */
				inset.draw(false,zoomLevel);
			}
	}
	else if(newZoomLevel < zoomLevel && newZoomLevel>=Constants.ZOOM_LEVEL_MIN)
	{
			if(inset.canZoom(newZoomLevel))
			{
				//calculate scaling factor
				scalingFactor = Math.pow(Constants.ZOOM_SCALE_DEC,zoomLevel-newZoomLevel);
				//set zoom level
				zoomLevel = newZoomLevel;
				//update zoom level of the board control
				boardControl.setZoomLevel(zoomLevel);
				//scale board
				GraphicsUtil.scale(board,scalingFactor,zoomOriginX,zoomOriginY);
				/* DRAW INSET */
				inset.draw(false,zoomLevel);
			}
	}
}

private function originChangeHandler(event:BoardControlPanEvent):void
{
	//add delta values to the origin
	//IMPORTANT: Multiply by the powered zoom level to make out
	//for the zooming factor
	var scale:Number = Math.pow(Constants.ZOOM_SCALE_INC,zoomLevel);
	
	var newX:Number = board.x + event.deltaX*scale;
	var newY:Number = board.y + event.deltaY*scale;
	if(inset.canPosition(newX,newY))
	{
		board.x = newX;
		board.y = newY;
		//UPDATE INSET
		inset.setPosition(board.x,board.y);
		//DRAW INSET
		inset.draw(false,zoomLevel);
	}
} 

private function originCenteredHandler(event:BoardControlPanEvent):void
{
	//undo scaling - scale back
	undoBoardZooming(false);
	//update board position
	board.x = 0;
	board.y = 0;	
	//RESTORE INSET
	inset.reset();
	//DRAW INSET
	inset.draw(false,zoomLevel);	
} 


private function originMoveHandler(event:InsetPanEvent):void
{
	//Update the board position
	board.x += event.deltaX;
	board.y += event.deltaY;
}


/* END OF CONTROLS EVENT HANDLERS */

/* START OF MOUSE MOVE HANDLERS */
private function mouseMoveHandler(event:MouseEvent):void
{
	
	if(mode == Constants.MODE_VIEW)
	{
	}	
	else if(mode == Constants.MODE_EDIT)
	{
		if(addingLinkage)
		{
			//dont do anything
		}
		else if(copyingShape)
		{
			//check if you have selected a shape for copying
			if(shape!=null)
			{
				//if you haven't created a drag shape do so
				//the drag shape is just a clone of the selected
				//shape in this case
				if(dragShape == null)
				{
					dragShape = shape.cloneDrawing();
					//dragShape.initNew();
					//add to board
					board.addChild(dragShape);
				}
				//position the drag shape
				dragShape.origin.x = event.localX-dragShape.cwidth/2;
				dragShape.origin.y = event.localY-dragShape.cheight/2;
				//draw shape
				dragShape.drawForEdit(false);
			}
		}
		else if(aligningShapes)
		{
			//dont do anything
		}
		else if(selectingShapes)
		{
			
			//check if you are drawing a square 
			//to select shapes
			if(drawingSquare)
			{
				//update end point
				endPoint.x = event.localX;
				endPoint.y = event.localY;
				//draw square
				drawSelectionSquare();
			}
			//check if you are dragging the square
			else if(dragging)
			{
				//calculate the deltas
				var deltaX:Number = event.localX - oldX;
				var deltaY:Number = event.localY - oldY;
				//drag selected shapes
				for(var i:int=0;i<selectedShapes.length;i++)
				{ 
					var s:CShape = selectedShapes.getItemAt(i) as CShape;
					//move shape
					s.move(deltaX,deltaY);
					//draw shape
					s.drawForEdit(true);
					//move the lines connected to the shape around
					moveShapeLines(s);
				}
				//move the drawing square
				moveSelectionSquare(deltaX,deltaY);
				//draw the square
				drawSelectionSquare();
				//update old coordinates
				oldX = event.localX;
				oldY = event.localY;
			}
		}
		else if(drawingLine)
		{
			if(line!=null)
			{
				//modify the coordinates of the last point
				var p:CPoint = line.getLastPoint();
				p.x = event.localX;
				p.y = event.localY;
				//draw line as selected
				line.draw(true);
			}
		}
		else if(drawingShape)
		{
			//init the drag shape if it doesn't exist
			if(dragShape == null) 
			{//Alert.show("mouseMoveHandler drawingShape -- dragShape" );
				var o:CPoint = new CPoint();
				o.x = event.localX-CShape.MIN_WIDTH/2;
				o.y = event.localY-CShape.MIN_HEIGHT/2;
				dragShape = createDefaultShape(o,shapeType,"", 0);
				//add to board
				board.addChild(dragShape);
				//draw it
				dragShape.drawForEdit(false);
			}
			//reposition drag shape
			else
			{//Alert.show("mouseMoveHandler drawingShape -- " );
				//position it
				dragShape.origin.x = event.localX-dragShape.cwidth/2;
				dragShape.origin.y = event.localY-dragShape.cheight/2;
				//draw shape
				dragShape.drawForEdit(false);
			}
			
		}
		else
		{
			//check if things have been init
			if(lines==null||shapes==null)
				return;
			
			var resetMouseState:Boolean = true;
			var mouseOverConnectorIndex:int = 0;
			var mouseOver:Boolean = false;
			//if you are not resizing or dragging
			//show selected item or otherwise drag or 
			//resize the current shape or line
			/* HANDLE SELECTION ON SHAPES AND LINES */
			if(!dragging&&!resizing)
			{
				for(var i:int=0;i<lines.length;i++)
				{
					var l:CLine = lines[i];
					mouseOverConnectorIndex = l.isMouseOverConnector(event);
					if(mouseOverConnectorIndex == 0)
						mouseOver = l.isMouseOver(event);
					
					if(mouseOverConnectorIndex>0)
					{
						if(!l.mouseOverConnector)
						{
							line = l;
							l.mouseOver = false;
							l.mouseOverConnector = true;
							l.draw(true);			
						}
						cIndex = mouseOverConnectorIndex;
						resetMouseState = false;
					}
					else if(mouseOver)
					{
						if(!l.mouseOver)
						{
							line = l;
							l.mouseOver = true;
							l.mouseOverConnector = false;
							l.draw(true);
						}
						resetMouseState = false;
					}
					else
					{
						if(l.mouseOver||l.mouseOverConnector)
						{
							l.mouseOver = false;
							l.mouseOverConnector = false;
							l.draw(false);
						}
					
					}
				}
				
				//reset temp vars
				mouseOverConnectorIndex = 0;
				mouseOver=false;
		  
				//skip this step if a line has been already selected
				//do not want to select both lines and shapes
				if(line==null)
				{
					for (var i:int=0;i<shapes.length;i++)
					{
						var s:CShape = shapes.getItemAt(i) as CShape;
						mouseOverConnectorIndex = s.isMouseOverConnector(event);
						if(mouseOverConnectorIndex == 0)
							mouseOver = s.isMouseOver(event);
						//check if mouse is over connector or over shape
						if(mouseOverConnectorIndex>0)
						{	
							//re-select shape if necessary
							if(!s.mouseOverConnector)
							{
								shape = s;
								s.mouseOverConnector = true;
								s.mouseOver = false;
								s.drawForEdit(true);
							}
							cIndex = mouseOverConnectorIndex;
							resetMouseState = false;
						}	
						else if(mouseOver)
						{
							//re-select shape if necessary
							if(!s.mouseOver){
								shape = s;
								s.mouseOverConnector = false;
								s.mouseOver = true;				
								s.drawForEdit(true);
							}
							resetMouseState = false; 
						}else{
							//clear state if necessary
							//de-select shape
							if(s.mouseOver||s.mouseOverConnector){
								s.mouseOver = false;
								s.mouseOverConnector = false;
								s.drawForEdit(false);
							}
						}
						
					}
				}
				//reset mouse state if necessary
				if(resetMouseState)
				{
					//if a shape or line has not been selected
					//clear selected objects and and reset mouse cursor
					shape = null;
					line = null;
				}
			}
			/* HANDLE RESIZING OR DRAGGING ON SHAPES AND LINES */
			else
			{
				 //handle line draggings or resizing
				 if(line!=null)
				 {
					if(resizing)
					{
						//update selected point's coordinates
						var p:CPoint = line.getPoint(cIndex);
						p.x = event.localX;
						p.y = event.localY;
				
						//check if the updated point has been placed over
						//neighboring connector
						if(line.points.length > 2 )
						{ 
							var cIndexN:int = line.isConnectorOverConnector(cIndex);
							//remove one of the line points if it is a neighbor
							if(cIndex-cIndexN == 1)
							{
								line.removePoint(cIndexN);
								cIndex -= 1;		
							}
							else if(cIndexN - cIndex == 1)
							{
								line.removePoint(cIndexN);
							}
						}
						//draw selected line
						line.draw(true);
					}
					else if(dragging)
					{
						//move line
						line.move(event.localX - oldX, event.localY - oldY);
						//update coordinates
						oldX = event.localX;
						oldY = event.localY;
						//draw line
						line.draw(true);
					}
				}
				//handle shape resizing or dragging
				else if(shape!=null)
				{
					if(resizing)
					{
						//resize shape based
						//on connectors index
						var cp:CPoint = shape.getConnectorPoint(cIndex);
						if(cIndex == 1 || cIndex == 3)
						{
							shape.resize(cIndex,event.localY - cp.y);
							shape.drawForEdit(true);
						}
						else if(cIndex == 2 || cIndex == 4)
						{
							shape.resize(cIndex,event.localX - cp.x);
							shape.drawForEdit(true);
						}
						//move the lines connected to the shape around
						moveShapeLines(shape);
	
						
					}
					else if(dragging)
					{
						//move shape
						shape.move(event.localX - oldX,event.localY-oldY);
						//update coordinates
						oldX = event.localX;
						oldY = event.localY;
						//draw shape
						shape.drawForEdit(true);
						//move the lines connected to the shape around
						moveShapeLines(shape);
	
					}
				 }
			}
		}
	
	}
}

private function mouseDownHandler(event:MouseEvent):void
{
	
	if(mode == Constants.MODE_VIEW)
	{
		//DON'T DO ANYTHING IN VIEW MODE
	}
	else if(mode == Constants.MODE_EDIT)
	{
		
		if(addingLinkage)
		{
			//dont do anything
		}
		else if(copyingShape)
		{
			//dont do anything
		}
		else if(aligningShapes)
		{
			//dont do anything
		}
		else if(selectingShapes)
		{
			//start selecting shapes
			//draw a square if haven't already done so
			//or the previous square didn't select any shapes
			if(selectedShapes==null||selectedShapes.length==0)
			{
				//set the start point
				startPoint = new Point();
				startPoint.x = event.localX;
				startPoint.y = event.localY;
				//set the end point
				endPoint = new Point();
				endPoint.x = event.localX;
				endPoint.y = event.localY;
				//set the state to drawing square
				drawingSquare = true;
			}
			//if you have selected shapes start dragging them around
			else
			{
				//set the old x and y coordinates
				oldX = event.localX;
				oldY = event.localY;
				//set dragging to true
				dragging = true;
			}
		
		}
		//unless you are drawing a shape or line
		//set the mouse move state to resizing, dragging, or none
		//based on the selected shape status
		//NOTE: (mouse down is fired after mouse move)
		else if(!drawingLine&&!drawingShape)
		{ 	    		
			if(line!=null)
			{
				if(line.mouseOverConnector)
				{
					//enable resizing
					dragging = false;
					resizing = true;
					oldX = 0;
					oldY = 0;
					//check if you need to disconnect connectors
					var p:CPoint = line.getPoint(cIndex);
					//clear either the first or last connector from the line
					if(line.firstConnector!=null && p == line.getFirstPoint())
					{
						removeLineFirstConnector(line);
					}
					else if(line.lastConnector!=null && p == line.getLastPoint())
					{
						removeLineLastConnector(line);
					}
					//select all shapes when moving the first or last point of the line
					if(p == line.getFirstPoint() || p == line.getLastPoint())
					{
						selectAllShapes(true);	
					}
				}
				else if(line.mouseOver)
				{
					//enable dragging
					dragging = true;
					resizing = false;
					oldX = event.localX;
					oldY = event.localY;
					//if you are dragging the line
					//clear all connectors from the line
					removeLineConnectors(line);
				}
				else
				{
					//reset state
					resetBoardState();
				}
			}	
			else if(shape!=null)
			{
				if(!dragging && shape.mouseOverConnector)
				{
					//enable resizing
					resizing = true;
					dragging = false;
					oldX = event.localX;
					oldY = event.localY;
				}
				else if(!dragging && shape.mouseOver)
				{
					//enable dragging
					dragging = true;
					resizing = false;
					oldX = event.localX;
					oldY = event.localY;
				}
				else
				{
					//reset state
					resetBoardState();
				}
			}
		}
	}

}

private function mouseUpHandler(event:MouseEvent):void
{
	
	if(mode == Constants.MODE_VIEW)
	{
		//DON'T DO ANYTHING IN VIEW MODE
	}
	else if(mode == Constants.MODE_EDIT)
	{
		if(addingLinkage)
		{
			//dont do anything
		}
		else if(copyingShape)
		{
			//dont do anything
		}
		else if(aligningShapes)
		{
			//dont do anything
		}
		else if(selectingShapes)
		{
			//if you were drawing a square
			//select potential shapes
			if(drawingSquare)
			{
				//update end point
				endPoint.x = event.localX;
				endPoint.y = event.localY;
				//draw square
				drawSelectionSquare();
				//change state
				drawingSquare = false;
				//select shapes
				selectShapes();
				//draw inset
				inset.draw(true,zoomLevel);
			}
			//if you were dragging the selected shapes
			//stop dragging them
			else if(dragging)
			{
				//unselect all the shapes
				selectAllShapes(false);
				//remove the square
				removeSelectionSquare();
				//clear the selection shapes list
				selectedShapes = null;
				//set dragging to false
				dragging = false;
			}
		}
		//unless you are drawing a shape or line
		//if the mouse is up release selected
		//shape or line if and reset state
		else if(!drawingLine&&!drawingShape)
		{	
			if(resizing)
			{
				//if the line was being resized (drop the line 
				//and check whether it is being placed over another connector)
				if(line!=null)
				{
					//connect a line to a shape (if possible)
					var p:CPoint = line.getPoint(cIndex);
					if(p == line.getFirstPoint())
					{
						connectLineToShapes(event,line,true);
					}
					else if(p == line.getLastPoint())
					{
						connectLineToShapes(event,line,false);
					}
					//de-select all shapes selection
					selectAllShapes(false);
				}
				
				if(shape!=null)
				{
					//CHECK AGAIN
					//shapes.addItem(shape);
				}
				
				//reset state
				resetBoardState();
			}
			else if(dragging)
			{
				if(shape!=null)
				{
					//CHECK AGAIN
					//shapes.addItem(shape);
					//draw as unselected
					shape.drawForEdit(false);
				}
				
				//reset state
				resetBoardState();
			}
		}
	}
}

private function clickHandler(event:MouseEvent):void
{
	if(mode == Constants.MODE_VIEW)
	{
		//loop through the shapes
		for(var i:int=0;i<shapes.length;i++)
		{
			var s:CShape = shapes.getItemAt(i) as CShape;

			if(s.isMouseOver(event))
			{
				CursorManager.setBusyCursor();
				//if you were not viewing linkages - set state to view linkages
				if(!viewingLinkages)
				{
					viewingLinkages = true;
					//init collections
					clickedShapes = new ArrayCollection();
					//add this to clicked shapes
					addToClickedShapes(s);
					//hightling linked shapes;
					highlightLinkedShapes(s);
					
					//IMPORTANT: update accordion
					accordion.setSelectedShapes(clickedShapes);
					accordion.setSelectedLinkages(clickedShapes);
					//break from loop
					break;	
				}
				else
				{
					if(s.clicked)
					{
						//remove the current clicked shape
						//if the user is clicking on it again
						removeFromClickedShapes(s);
						//if there are still linked shapes grab the last
						//shape in the path; otherwise reset all
						if(clickedShapes.length > 0)
						{
							var st:CShape = clickedShapes.getItemAt(clickedShapes.length-1) as CShape;
							//reset linked shapes
							resetHighlightedAndClickedShapes(true);
							//hightling linked shapes;
							highlightLinkedShapes(st);
						}
						else
						{
							//reset linked shapes including clicked
							resetHighlightedAndClickedShapes(false);
							//turn off viewing linkages
							viewingLinkages = false;
						}
						
						//IMPORTANT: update accordion
						accordion.setSelectedShapes(clickedShapes);
						accordion.setSelectedLinkages(clickedShapes);
					}
					//highlighted shapes are the only ones
					//who can be clicked
					else if(s.highlighted)
					{
						//add this to clicked shapes
						addToClickedShapes(s);
						//reset linked shapes
						resetHighlightedAndClickedShapes(true);
						//hightling linked shapes;
						highlightLinkedShapes(s);
					
						//IMPORTANT: update accordion
						accordion.setSelectedShapes(clickedShapes);
						accordion.setSelectedLinkages(clickedShapes);
					}
					else
					{
						CursorManager.removeBusyCursor();
						//don't do anything
						//only clicked and highlighted 
						//shapes can be process after viewing linkages has begun
					}	
					
					//break from loop
					break;				
				}
			}

		}
	}
	else if(mode == Constants.MODE_EDIT)
	{ 
		
		//for now this event is used to create
		//shapes or lines and it might be changed
		//in the future					
		if(drawingLine)
		{					
			//create a new point			
			var p:CPoint = new CPoint();
			p.x = event.localX;
			p.y = event.localY;
			
			if(line==null)
			{
				//create a default line
				var cl:CLine = createDefaultLine(p, lineType);
				//add line to shapes
				lines.addItem(cl);
				//select current line
				line = cl;
				//add to drawing area
				board.addChild(cl);
				//connect a line to a shape (if possible)
				if(connectLineToShapes(event,cl,true))
				{
					//draw line
					cl.draw(false);
				}
				else
				{
					//draw line as selected
					cl.draw(true);
				}
			}
			else
			{
				//keep on drawing line
				if(!connectLineToShapes(event,line,false))
				{
					//add point to current line
					line.addPoint(p);
					//draw line as selected
					line.draw(true);
				}
				//line is done
				else
				{
					//modify the coordinates of the last point
					var p:CPoint = line.getLastPoint();
					p.x = event.localX;
					p.y = event.localY;					
					//draw line
					line.draw(false);
					//reset state
					resetBoardState();
					//clear all shape selections
					selectAllShapes(false);
					//VERY IMPORTANT:
					menu.enableControls(true);
				}
			}
		}
		else if (drawingShape)
		{ 
			//create a new shape Li Li
			if(shape==null)
			{
				//get rid of the dragShape
			    board.removeChild(dragShape);
				dragShape = null;
				//VERY IMPORTANT: enable menu controls
				//menu.enableControls(true);
				//create a new point			
				var p:CPoint = new CPoint();
				p.x = event.localX;
				p.y = event.localY;
				//set the new shape location
				newShapeLocation = p;
				//create shape
				createPopUpForShape(true);
			}
	
		}
		else if(addingLinkage)
		{
			//see if you clicked on a shape
			for(var i:int=0;i<shapes.length;i++)
			{
				var s:CShape = shapes.getItemAt(i) as CShape;
				if(s.isMouseOver(event))
				{
					//add the item if it has not already been added
					//to create a linkage
					if(!newLinkageShapes.contains(s))
					{
						newLinkageShapes.addItem(s);
						s.drawForEdit(true);
					}
					//if the user clicks on a selected shape
					//remove shape from list of linked shapes
					else
					{
						newLinkageShapes.removeItemAt(newLinkageShapes.getItemIndex(s));
						s.drawForEdit(false);
					}
					break;
				}
			}
		}
		else if(copyingShape)
		{
			//no shape selected for copying
			if(shape==null)
			{
				//see if you clicked on a shape 
				//if this is the case this is the shape you
				//are supposed to copy
				for(var i:int=0;i<shapes.length;i++)
				{
					var s:CShape = shapes.getItemAt(i) as CShape;
					if(s.isMouseOver(event))
					{
						s.drawForEdit(true);
						shape = s;
						break;
					}
				}
			}
			//copy shape
			else
			{
				//remove the drag shape
				board.removeChild(dragShape);
				dragShape = null;
				
				//create a new point			
				var p:CPoint = new CPoint();
				p.x = event.localX;
				p.y = event.localY;
				
				//clone shape
				var s:CShape = shape.clone();
				var oldWidth:Number = s.cwidth;
				var oldHeight:Number = s.cheight;
				//set the origin
				p.x -= s.cwidth/2;
				p.y -= s.cheight/2;
				s.origin = p;
				//init shape
				s.initNew();
				//save the old dimensions
				s.cwidth = oldWidth;
				s.cheight = oldHeight;
				//make a dunny call to update attributes to resize the label
				s.updateAttributes(s.label, s.termId);
								
				//add shape to shapes
				shapes.addItem(s);
				//add shape to drawing board
				board.addChild(s);

				//draw shape
				s.drawForEdit(false);
				
				//import: reset the current shape so that you can copy others
				shape.drawForEdit(false);
				shape = null;
			}
		}
		else if(aligningShapes)
		{
			//see if you clicked on a shape
			for(var i:int=0;i<shapes.length;i++)
			{
				var s:CShape = shapes.getItemAt(i) as CShape;
				if(s.isMouseOver(event))
				{
					//add the item if it has not already been added
					if(!shapesToAlign.contains(s))
					{
						shapesToAlign.addItem(s);
						s.drawForEdit(true);
					}
					//if the user clicks on a selected shape
					//remove shape from list
					else
					{
						shapesToAlign.removeItemAt(shapesToAlign.getItemIndex(s));
						s.drawForEdit(false);
					}
					break;
				}
			}
		}
		else if(selectingShapes)
		{
			//don't do anything on clicks
		}
	}
	else if(mode == Constants.MODE_LINK)
	{ 

		//see if you clicked on a shape
			for(var i:int=0;i<shapes.length;i++)
			{
				var s:CShape = shapes.getItemAt(i) as CShape;
				if(s.isMouseOver(event))
				{
					//add the item if it has not already been added
					//to create a linkage
					if(!newLinkageShapes.contains(s))
					{
						newLinkageShapes.addItem(s);
						s.drawForEdit(true);
					}
						//if the user clicks on a selected shape
						//remove shape from list of linked shapes
					else
					{
						newLinkageShapes.removeItemAt(newLinkageShapes.getItemIndex(s));
						s.drawForEdit(false);
					}
					break;
				}
			}
		
		
	}
	/*  
		every time the users clicks remember to synchronized the drawing board 
		with the inset (user should be finished doing stuff)
	*/ 
	/* REMEMBER TO SYNCHRONIZE INSET */
	inset.draw(true,zoomLevel);
	
	
}


private function dblClickHandler(event:MouseEvent):void
{
	
	if(mode == Constants.MODE_VIEW)
	{
	
	}
	else if(mode == Constants.MODE_EDIT)
	{
		if(addingLinkage)
		{
			//don't do anything
		}
		else if(copyingShape)
		{
			//dont do anything
		}
		else if(aligningShapes)
		{
			//dont do anything
		}
		else if(selectingShapes)
		{
			//don't do anything on clicks
		}
		//show attributes pop up if necessary
		else if(!drawingLine && !drawingShape)
		{	
			for(var i:int=0;i<shapes.length;i++)
			{
				var s:CShape = shapes.getItemAt(i) as CShape;
				if(s.isMouseOver(event))
				{	
					//draw shape
					s.drawForEdit(false);
					//reset state
					resetBoardState();
					//select current shape
					shape = s;
					//bring popup on
					createPopUpForShape(false);
					break;
				}
			}
		}
		//if drawing line stop
		else if(drawingLine)
		{
			//remove the last point added twice because of the click
			line.removeLastPoint();
			//modify the coordinates of the last point
			var p:CPoint = line.getLastPoint();
			p.x = event.localX;
			p.y = event.localY;					
			//draw line
			line.draw(false);
			//reset state
			resetBoardState();
			//clear all shape selections
			selectAllShapes(false);
			//VERY IMPORTANT:
			menu.enableControls(true);
		}
	}
	
}

/*
* mouse wheel handler on the board. 	
 * */
private function mouseWheelHandler(event:MouseEvent):void
{
	
	//check if board is disabled
	if(board.enabled==false)
		return;
	
	if(event.delta > 0 && zoomLevel+1<=Constants.ZOOM_LEVEL_MAX)
	{
		if(inset.canZoom(zoomLevel + 1))
		{
			//increase zoom level
			zoomLevel = zoomLevel + 1;
			//scale board
			GraphicsUtil.scale(board,Constants.ZOOM_SCALE_INC,zoomOriginX,zoomOriginY);
			//update zoom level of the board control
			boardControl.setZoomLevel(zoomLevel);
			/* DRAW INSET */
			inset.draw(false,zoomLevel);
		}
	} else if(event.delta < 0 && zoomLevel-1>=Constants.ZOOM_LEVEL_MIN){
		if(inset.canZoom(zoomLevel - 1))
		{
			//decrease zoom level
			zoomLevel = zoomLevel - 1;
			//scale board
			GraphicsUtil.scale(board,Constants.ZOOM_SCALE_DEC,zoomOriginX,zoomOriginY);
			//update zoom level of the board control
			boardControl.setZoomLevel(zoomLevel);
			/* DRAW INSET */
			inset.draw(false,zoomLevel);
		}
	}
}
/* END OF MOUSE MOVE HANDLERS */

/* START OF KEY HANDLERS */
public function keyHandler(event:KeyboardEvent):void 
{
	if(mode == Constants.MODE_VIEW)
	{
		if(event.keyCode == Constants.KEYCODE_ESCAPE)
		{
			//toggle a fake space bar click
			insetToggleHandler(null);
		}
	}
	else if(mode == Constants.MODE_EDIT)
	{	
		if(event.keyCode == Constants.KEYCODE_DELETE)
		{	
			if(selectingShapes)
			{
				selectShapes();
				for(var i:int=0;i<selectedShapes.length;i++)
				{
					var s:CShape = selectedShapes.getItemAt(i) as CShape;
				    //clear connectors connecting to shape
					removeShapeConnectors(s);
					//clear linkages to this shape
					removeShapeLinkages(s);
					//remove the shape from the board
					s.clear();
					shapes.removeItemAt(shapes.getItemIndex(s));
				}
				resetBoardState();
				//remove selection square
				removeSelectionSquare();
				//DRAW INSET
				inset.draw(true,zoomLevel);	
				//dispatch endSelect mouse event to automatically end the select menu
				var endSelectEvent:MouseEvent =  new MouseEvent(MouseEvent.CLICK);
				menu.select.dispatchEvent(endSelectEvent);
			} 
			else if(!addingLinkage&&!copyingShape&&!aligningShapes)
			{
				//delete line
				if(line!=null)
				{
				    removeLineConnectors(line);
					line.clear();
					lines.removeItemAt(lines.getItemIndex(line));
					resetBoardState();
					//DRAW INSET
					inset.draw(true,zoomLevel);	
				}
				//delete shape
				else if(shape!=null)
				{
					//clear connectors connecting to shape
					removeShapeConnectors(shape);
					//clear linkages to this shape
					removeShapeLinkages(shape);
					//remove the shape from the board
					shape.clear();
					shapes.removeItemAt(shapes.getItemIndex(shape));
					resetBoardState();
					//DRAW INSET
					inset.draw(true,zoomLevel);	
				}
			}
		}
		else if(event.keyCode == Constants.KEYCODE_ESCAPE)
		{
			//toggle a fake space bar click
			insetToggleHandler(null);
		}
	}
}
/* END OF KEY HANDLERS */

private function newDiagram():void
{
	mode = Model.mode ;
	loadNewOrExistingDiagram();
	Alert.show("A new diagram was successfully created.", "INFORMATION", Alert.OK, null, alertOKHandler, null, Alert.OK);
		
	//drawingShape = true;
	//update the diagram name
	tabNav.diagramName.text = Model.diagram.name;
	tabNav.diagramNameLabel.visible = true;
	//set the focus to the board
	this.setFocus();
} 

private function loadDiagram(displayMessage:Boolean):void
{
	loadNewOrExistingDiagram();
	if(displayMessage)
		Alert.show("Diagram was successfully opened.", "INFORMATION", Alert.OK, null, alertOKHandler, null, Alert.OK);
	else
		alertOKHandler(null);

	tabNav.diagramName.text = Model.diagram.name;
	tabNav.diagramNameLabel.visible = true;
	//set the focus to the board
	this.setFocus();
}

private function loadDiagramFromSaveAs():void
{
	loadNewOrExistingDiagram();
	//update the diagram name
	tabNav.diagramName.text = Model.diagram.name;
	tabNav.diagramNameLabel.visible = true;
}
//this is needed to fix an issue with Flex
//the board display object doesn't refresh its bitmap data
//until the 2 methods above are finished executing
private function alertOKHandler(event:CloseEvent):void
{
	//RESTORE INSET
	inset.reset();
	//DRAW INSET
	inset.draw(true,zoomLevel);	
}

private function resetDiagram():void
{
	//if you were viewing linkages
	//reset the highlighted and clicked shapes
	if(viewingLinkages)
	{
		//reset linked shapes including clicked
		resetHighlightedAndClickedShapes(false);
		//reset board state
		resetBoardState();
		//IMPORTANT: update accordion
		accordion.clearAll();
		//DRAW INSET
		inset.draw(true,zoomLevel);	
	}
}

private function closeDiagram():void
{
	shapes = Model.diagram.shapes;
	shapes.refresh();
	//clear the diagram
	clearBoardDrawings();
	//disable board
	enableBoard(false);
	//undo previous user zooming and inital zooming
	undoBoardZooming(false);
	//re-position board
	board.x = 0;
	board.y = 0;
	//set background color
	board.setStyle("backgroundColor","white");
	//RESET THE INSET
	//inset.reset();
	/* REMEMBER TO SYNCHRONIZE INSET */
	//inset.draw(true,zoomLevel);
	//disable menu items
	//menu.enableControls(false);
	Alert.show("Model.diagram = null");
	//set the models diagram to nothing
	Model.diagram = null;
	//clear the diagram name
	tabNav.diagramName.text = "";
	tabNav.diagramNameLabel.visible = false;
		
}

private function clearDiagram():void
{
	//clear the board
	clearBoardDrawings();

	//init collections of diagram
	Model.diagram.lines = new ArrayCollection();
	Model.diagram.shapes = new ArrayCollection();
	//bind collections
	lines = Model.diagram.lines;

	shapes = Model.diagram.shapes;
	/* REMEMBER TO SYNCHRONIZE INSET */
	inset.draw(true,zoomLevel);
}

private function loadNewOrExistingDiagram():void
{
	//clear diagram
	clearBoardDrawings();
	//enable board
	enableBoard(true);
	//bind collections
	lines = Model.diagram.lines;
	//shapes = new ArrayCollection();
	
	//shapes.addCollection(Model.diagram.shapes);
	shapes = Model.diagram.shapes;
	//set height and width
	board.width = Model.BOARD_WIDTH;
	board.height = Model.BOARD_HEIGHT;
	//undo previous user zooming and inital zooming
	undoBoardZooming(true);
	//scale new board accordingly
	GraphicsUtil.scale(board,Model.INITIAL_ZOOM_SCALE,zoomOriginX,zoomOriginY);
	//store inital zoom scale for later
	initalZoomScale = Model.INITIAL_ZOOM_SCALE;
	//re-position board
	board.x = 0;
	board.y = 0;
	//set background color
	board.setStyle("backgroundColor",Model.diagram.color);
		
	//create shapes and lines on the board if there are any
	var i:int = 0;
	for(i=0;i<lines.length;i++)
	{
		var l:CLine = lines[i];
		//add line to drawing board
		board.addChild(l);
	}
	for(i=0;i<shapes.length;i++)
	{
		var s:CShape = shapes.getItemAt(i) as CShape;
		//set the board - init shape
		s.board = board;
		s.initExisting();
		//add shape to drawing board
		board.addChild(s);
	}
	
	if(mode == Constants.MODE_VIEW)
	{
		//clear accordion
		accordion.clearAll();

		//show diagram
		showDiagramInViewMode(false,null);
	}
	else if(mode == Constants.MODE_EDIT)
	{
		//reset menu state
		menu.resetEditState();
		//show diagram
		showDiagramInEditMode(false);
	}
	else if(mode == Constants.MODE_LINK)
	{
		//reset menu state
		//menu.resetEditState();
		//show diagram
		showDiagramInEditMode(false);
	}
}

/* END OF DIAGRAM FUNCTIONS */

/* START OF CREATING SHAPES AND LINES */
/*
	Human activity -  round rect - ffe497
	source - octagon - f3e895
	stressor - rect - c6dde8
	bio resp - oval - e2edf2
	mod fac - round rect - edcbaf
	add step - round rect - f9f4cf
	mod act	- hexagon - f6f7f8
*/
		
private function newStressor():void
{
	resetBoardState();
	drawingShape = true;
	shapeType = "rectangle";
	shapeColor = 0xc6dde8;
	legendType = Constants.STRESSOR;
}

private function newAddStep():void
{
	resetBoardState();
	drawingShape = true;
	shapeType = "roundrectangle";
	shapeColor = 0xf9f4cf;
	legendType = Constants.ADDITIONAL_STEP;
} 

private function newModFactor():void
{
	resetBoardState();
	drawingShape = true;
	shapeType = "roundrectangle";
	shapeColor = 0xedcbaf;
	legendType = Constants.MODIFIYING_FACTOR;
}

private function newModAction():void
{
	resetBoardState();
	drawingShape = true;
	shapeType = "hexagon";
	shapeColor = 0xf6f7f8;
	legendType = Constants.MODE_OF_ACTION;
}

private function newSource():void
{
	resetBoardState();
	drawingShape = true;
	shapeType = "octagon";
	shapeColor = 0xf3e895;
	legendType = Constants.SOURCE;
}

private function newBioResp():void
{
	resetBoardState();
	drawingShape = true;
	shapeType = "ellipse";
	shapeColor = 0xe2edf2;
	legendType = Constants.BIOLOGICAL_RESPONSE;
}

private function newHumanAct():void
{
	resetBoardState();
	drawingShape = true;
	shapeType = "roundrectangle";
	shapeColor = 0xffe497;
	legendType = Constants.HUMAN_ACTIVITY;
}

private function newLine():void
{
	resetBoardState();
	drawingLine = true;
	lineType = Constants.LINE_TYPE;
	//select all shapes 
	//when adding a new line
	selectAllShapes(true);	
}

private function newArrowLine():void
{
	resetBoardState();
	drawingLine = true;
	lineType = Constants.SINGLEARROWLINE_TYPE;
	//select all shapes 
	//when adding a new line
	selectAllShapes(true);	
}
/* END OF CREATING SHAPES AND LINES */

/* START OF SHAPE ATTRIBUTES */
private function createPopUpForShape(newShape:Boolean):void
{
	//create pop up panel
	shapePopUpPanel = new ShapePopUp();
	//add init event handler for pop up
	shapePopUpPanel.addEventListener(FlexEvent.INITIALIZE,handleShapePopUpCreation)
	//set flags
	this.newShape = newShape;
	//show pop up
	PopUpManager.addPopUp(shapePopUpPanel, this, true);
	PopUpManager.centerPopUp(shapePopUpPanel);
	shapePopUpPanel.y = 20;
}

private function handleShapePopUpCreation(event:FlexEvent):void
{
	//Alert.show("Create new shapePopUpHandler");
	
	shapePopUpPanel.ssymbol.dataProvider = Constants.SYMBOLS;
	shapePopUpPanel.stype.dataProvider = Constants.SHAPE_SYMBOLS;
	//set label, parent, diagram filters, symbol
	if(!newShape){
		shapePopUpPanel.slabel.text = shape.label;
		shapePopUpPanel.ssymbol.selectedItem = selectSymbol(shape);
		shapePopUpPanel.stype.selectedItem = selectShape(shape);
	
		shapePopUpPanel.termId.text = shape.termId;
	}
	else
	{
		shapePopUpPanel.stype.selectedItem = selectShapeNew(legendType);
	}
	
	//add event listener's for buttons	
	shapePopUpPanel.save.addEventListener(MouseEvent.CLICK,saveAttributes);
	shapePopUpPanel.cancel.addEventListener(MouseEvent.CLICK,cancelAttributes);
	shapePopUpPanel.addEventListener(CloseEvent.CLOSE,handleCloseAttributes);
	if(!newShape)
		shapePopUpPanel.viewlnk.addEventListener(MouseEvent.CLICK,viewLinkagesForShape);
	
	//disable view linkages button on new shapes
	shapePopUpPanel.viewlnk.visible = !newShape;
	
}

private function selectShapeNew(selectedlegendType:int):Object
{
	var dp:ArrayCollection = Constants.SHAPE_SYMBOLS;
	for(var i:int=0;i<dp.length;i++){
		if(selectedlegendType == dp[i].value)
			return dp[i];
	}
	return null;
}

private function selectSymbol(shape:CShape):Object
{
	var dp:ArrayCollection = Constants.SYMBOLS;
	for(var i:int=0;i<dp.length;i++){
		if(shape.labelSymbolType == dp[i].value)
			return dp[i];
	}
	return null;
}

private function selectShape(shape:CShape):Object
{
	var dp:ArrayCollection = Constants.SHAPE_SYMBOLS;
	for(var i:int=0;i<dp.length;i++){
		if(shape.legendType == dp[i].value)
			return dp[i];
	}
	return null;
}

//User can change shape type
private function saveAttributes(evt:MouseEvent):void
{
	//validate errors 
	var valArray:Array = new Array();
	valArray.push(shapePopUpPanel.valSLabel);
	var validatorErrorArray:Array = Validator.validateAll(valArray);
	//don't update shape if there are errors
	if(validatorErrorArray.length == 0)
	{
		//Li Li 0008379
		if (addTerm())
		{
		
			//if there is a new shape
			//then create one and add it 
			//to the board
			//if(newShape)
			//var obj:Array = shapePopUpPanel.stype.selectedItem;
			if(newShape)
			{	
				//create shape
				var s:CShape = createDefaultShape(newShapeLocation,shapeType,shapePopUpPanel.slabel.text, shapePopUpPanel.termId.text);
				//add shape to shapes
				shapes.addItem(s);
				//add shape to drawing board
				board.addChild(s);
				//draw shape
				s.drawForEdit(false);
				//reset state
				resetBoardState();
				//create a pop up to populate shape
				shape = s;
				
			}
			else if ( shapePopUpPanel.stype.selectedItem!=null && shapePopUpPanel.stype.selectedItem.value != 0 )
			{
			
				var p:CPoint = new CPoint();
				p.x = shape.origin.x + shape.cwidth/2;
				p.y = shape.origin.y + shape.cheight/2;
	
				board.removeChild(shape);
				
				shapes.removeItemAt(shapes.getItemIndex(shape));
				shape.destroy();
				shape = null;
				//resetBoardState();
				drawingShape = true;
	
				
				//create shape
				var s:CShape = createDefaultShapeLegenType(p,shapePopUpPanel.stype.selectedItem.value ,shapePopUpPanel.slabel.text, shapePopUpPanel.termId.text);
			
					//add shape to shapes
				shapes.addItem(s);
				
					//add shape to drawing board
				board.addChild(s);
					//draw shape
				s.drawForEdit(false);
			
					//reset state
				resetBoardState();
					//create a pop up to populate shape
				shape = s;	
				
			}
			
				
			/* UPDATE SYMBOL */
			shape.labelSymbolType = (shapePopUpPanel.ssymbol.selectedItem!=null&&shapePopUpPanel.ssymbol.selectedItem.value!=0)?shapePopUpPanel.ssymbol.selectedItem.value:undefined;
		
			/* UPDATE ATTRIBUTES - parent and label */
			//update the shapes attributes
			shape.updateAttributes(shapePopUpPanel.slabel.text,shapePopUpPanel.termId.text );
			
			/* UPDATE THE DIAGRAM FILTERS */
			shape.clearAttributes();
	
			//remove pop up
			removePopUp();
		}
	}
	else
	{  
		shapePopUpPanel.error.visible = true;
	}
   			
}

private function addTerm():Boolean
{
	var t:Term = shapePopUpPanel.terms.selectedItem as Term;
	//shapePopUpPanel.termId.text == "" || shapePopUpPanel.termId.text == null 
	if ( t == null  ||(t != null && shapePopUpPanel.slabel.text != t.term ))
	{
		if (Model.user == null || Model.user.userId == 0)
		{
			Alert.show("Can not save the term to database. You must register and login first. ", "INFORMATION", Alert.OK, null,null, null, Alert.OK);
			
		}
		else
		{
			var s:Service = new Service();
			s.serviceHandler = handleNoDuplicateNewTerm;
				//check if term exists using exact match
			s.searchTerms(StringUtil.trim(shapePopUpPanel.slabel.text), true, true);
			canAddTerm = true;	
		}
	}
	
	return canAddTerm;
}

private function handleNoDuplicateNewTerm(evt:ResultEvent):void
{
	var result:ArrayCollection = evt.result as ArrayCollection;
	
	if(result.length > 0)
		Alert.show("Term exists in the system. Please add another new term");
	else {
		
		var term:Term = new Term();
		term.isEELTerm = false;
		term.term = StringUtil.trim(shapePopUpPanel.slabel.text);
		term.desc = "";//StringUtil.trim(apPanel.desc.text);
		if ( shapePopUpPanel.stype.selectedItem != null && shapePopUpPanel.stype.selectedItem.value != 0)
			term.legendType = shapePopUpPanel.stype.selectedItem.value;
	
		var s:Service = new Service();
		s.serviceHandler = handleAddNewTerm;
		s.saveTerm(term, Model.user.userId); 
	}
}

private function handleAddNewTerm(evt:ResultEvent):void
{
	var result:Number = evt.result as Number;
	shapePopUpPanel.termId.text = result as String;
	canAddTerm = true;	
}

private function cancelAttributes(evt:MouseEvent):void
{
	removePopUp();
}

private function handleCloseAttributes(evt:CloseEvent):void
{
	removePopUp();
}

private function viewLinkagesForShape(event:MouseEvent):void
{
	//CODE FROM EXTERNAL AS FILE
	//code from ManageLinkagesHelper.as
	selectedShape = shape;
	createManageLinkagesPopUp();
	//CODE FROM EXTERNAL AS FILE
}

private function removePopUp():void
{
	//remove pop up
	PopUpManager.removePopUp(shapePopUpPanel);
	shapePopUpPanel = null;
	//reset state
	resetBoardState();
	/* REMEMBER TO SYNCHRONIZE INSET */
	inset.draw(true,zoomLevel);
	//set focus to the main board
	this.setFocus();
}

/* END OF SHAPE ATTRIBUTES */

/* BOARD UTILITY FUNCTIONS */
/* This function undoes the zooming on a board  */
private function undoBoardZooming(includeInitZoomScale:Boolean):void
{
	//undo scaling - scale back
	if(zoomLevel > 0)
	{
		var scalingFactor:Number = Math.pow(Constants.ZOOM_SCALE_DEC,zoomLevel);
		//reset scale
		zoomLevel = Constants.ZOOM_LEVEL_MIN;
		//update board control
		boardControl.setZoomLevel(zoomLevel);
		//scale back
		GraphicsUtil.scale(board,scalingFactor,zoomOriginX,zoomOriginY);
		
	}
	//don't scale by the Model.INTIAL_ZOOM_SCALE because it has been already
	//updated at this point
	if(includeInitZoomScale)
		GraphicsUtil.scale(board,1/initalZoomScale,zoomOriginX,zoomOriginY);
}

/* This fuction clears the board drawings and clears the dashed lines as well */
public function clearBoardDrawings():void
{
	//clear state
	resetBoardState();

	//destroy lines and shapes
	//to avoid memory leaks
	var i:int = 0;
	if(lines!=null)
	{
		for(i=0;i<lines.length;i++)
		{
			var l:CLine = lines[i];
			board.removeChild(l);
			l.destroy();
			l = null;
		}
	}
	if(shapes!=null)
	{
		for(i=0;i<shapes.length;i++)
		{
			var s:CShape = shapes.getItemAt(i) as CShape;
			board.removeChild(s);
			s.destroy();
			s = null;
		}
	}
	//create new lists
	lines = null;
	shapes = null;
	//remove all children from board to avoid memory leaks
	board.removeAllChildren();
}

/* This function enables or disables board controls */
public function enableBoard(enable:Boolean):void
{
	//enable or disable controls
	board.enabled = enable;
	boardControl.enabled = enable;
    inset.enabled = enable;
	accordion.enabled = enable;
}

/* This function clears the state of board (whatever you were doing on the board) */
public function resetBoardState():void
{
	//EDIT MODE
	drawingLine = false;
	drawingShape = false;
	drawingSquare = false;
	
	addingLinkage = false;
	copyingShape = false;
	aligningShapes = false;
	selectingShapes = false;
	
	resizing = false;
	dragging = false;	
		
	line = null;
	shape = null;
	
	if(dragShape!=null)
		board.removeChild(dragShape);
	dragShape = null;
	
	shapeType = null;
	shapeColor = undefined;
	legendType = undefined;
		
	oldX = 0;
	oldY = 0;
	
	//clear collections
	newLinkageShapes = null;
	clickedShapes = null;
	shapesToAlign = null;
	selectedShapes = null;
	
	newShape = undefined;
	newShapeLocation = null;	
	
	endPoint=null;
	startPoint=null;
	//END OF EDIT MODE 
	
	//VIEW MODE	      
	viewingLinkages = false;
	
	clickedShapes = null;

	//END OF VIEW MODE
}

/* This method can be used to add dashed lines to the board */
public function addDashedLinesToBoard():void
{
	//remove dashed lines
	removeDashedLines()
	//create an overlay for the dashed lines
	dashedLines = new UIComponent();
	var g:Graphics = dashedLines.graphics;	
	//number of dashes
	var dashes:int = Model.BOARD_WIDTH/4;
   	//create the dashed lines
   	var length:int = Model.BOARD_HEIGHT/Constants.TIER_HEIGHT;
   	for(var i:int=1;i<length;i++)
   	{
   		g.lineStyle(1,0x787878,0.9);

   		var y:int = i*Model.DASHED_LINES_VERTICAL_GAP;
   		var x:int = 0;
   		for(var j:int=0;j<dashes;j++)
   		{
   			g.moveTo(x,i*Model.DASHED_LINES_VERTICAL_GAP);
   			g.lineTo(x+1,i*Model.DASHED_LINES_VERTICAL_GAP);
   			x+=4;
   		}
   	}
   	//add to board
	board.addChild(dashedLines);
	board.setChildIndex(dashedLines,0);
}

public function removeDashedLines():void
{
	if(dashedLines!=null&&board.contains(dashedLines))
	{
		//board.removeChildAt(board.getChildIndex(dashedLines));
		board.removeChild(dashedLines);
		dashedLines = null;
	}

}

/* END OF BOARD UTILITY FUNCTIONS */


/* START OF UI (EDIT MODE) UTILITY FUNCTIONS */

private function selectAllShapes(selected:Boolean):void
{
	//draw shapes as selected
	for(var i:int=0;i<shapes.length;i++)
	{
		var s:CShape = shapes.getItemAt(i) as CShape;
		s.drawForEdit(selected);
	}

}

/* This function is used to move the lines of a shape */
private function moveShapeLines(s:CShape):void
{
	//loop through the shape's connectors 
	//and reposition the lines
	for(var i:int=0;i<s.connectors.length;i++)
	{
		var c:CConnector = s.connectors[i];
		var lp:CPoint = null;
		if(c.start)
			lp = c.line.getFirstPoint();
		else
			lp = c.line.getLastPoint();
		var cp:CPoint = s.getConnectorPoint(c.index);
		lp.x = cp.x;
		lp.y = cp.y;
		//draw line unselected
		c.line.draw(false);
	}
}

/* This function tries to connect a line to one of the shapes on the board
If the connection is successful it creates a  new connector and return true
otherwise it returns false */
private function connectLineToShapes(event:MouseEvent,l:CLine,first:Boolean):Boolean
{
	var connected:Boolean = false;
	for(var i:int=0;i<shapes.length;i++)
	{
		var s:CShape = shapes.getItemAt(i) as CShape;
		var ci:int = s.isMouseOverConnector(event);
		if(ci > 0)
		{
			if(first)
			{
				//create a connector
				var c:CConnector = new CConnector();
				c.init(l,s,ci,true);
				//add connector last to both shape and line
				s.addConnector(c);
				line.firstConnector = c;
				//reposition line's first point coordinates
				var lp:CPoint = l.getFirstPoint();
				var cp:CPoint = s.getConnectorPoint(ci);
				lp.x = cp.x;
				lp.y = cp.y;
			}
			else
			{
				//create a connector
				var c:CConnector = new CConnector();
				c.init(l,s,ci,false);
				//add connector last to both shape and line
				s.addConnector(c);
				line.lastConnector = c;
				//reposition line's last point coordinates
				var lp:CPoint = l.getLastPoint();
				var cp:CPoint = s.getConnectorPoint(ci);
				lp.x = cp.x;
				lp.y = cp.y;
			}
			connected = true;
			break;
		}
	}
		
	return connected;
}

private function removeLineConnectors(l:CLine):void
{
	if(l.firstConnector!=null)
	{
		removeLineFirstConnector(l);
	}
	if(l.lastConnector!=null)
	{
		removeLineLastConnector(l);
	}
}

private function removeLineFirstConnector(l:CLine):void
{
	//remove connector from shape
	l.firstConnector.shape.removeConnector(l.firstConnector);
	//set to null
	l.firstConnector = null;
}

private function removeLineLastConnector(l:CLine):void
{
	//remove connector from shape
	l.lastConnector.shape.removeConnector(l.lastConnector);
	//set to null
	l.lastConnector = null;
}

private function removeShapeConnectors(s:CShape):void
{
	//clear connectors connecting to shape
	for(var j:int=0;j<s.connectors.length;j++)
	{
		var c:CConnector = s.connectors[j];
		if(c.line.firstConnector == c )
			c.line.firstConnector = null;
		else if(c.line.lastConnector == c)
			c.line.lastConnector = null;
	}
}

private function removeShapeLinkages(s:CShape):void
{
	//remove linkages to other shapes
	for(var i:int=0;i<s.linkages.length;i++)
	{
		var l:Linkage = s.linkages[i];
		l.shape.removeLinkage(s);
	}
}

private function createDefaultShapeLegenType(origin:CPoint,legendType:Number,label:String, termId:Number):CShape
{
	//create shape
	var s:CShape = null;
	if(legendType == Constants.HUMAN_ACTIVITY)
	{
		s = new CRoundRectangle();
		s.color = 0xffe497;
	}
	else if(legendType == Constants.SOURCE)
	{
		s = new  COctagon();
		s.color = 0xf3e895;
	}
	else if(legendType == Constants.MODIFIYING_FACTOR)
	{
		s = new CRoundRectangle();
		s.color = 0xedcbaf;
	}
	else if(legendType == Constants.MODE_OF_ACTION)
	{
		s = new  CHexagon();
		s.color = 0xf6f7f8;
	}
	else if(legendType == Constants.ADDITIONAL_STEP)
	{
		s = new CRoundRectangle();
		s.color = 0xf9f4cf;
	}
	else if(legendType == Constants.STRESSOR)
	{
		s = new CRectangle();
		s.color = 0xc6dde8;
	}
	else if(legendType == Constants.BIOLOGICAL_RESPONSE)
	{
		s = new CEllipse();	
		s.color = 0xe2edf2;
	}
	else
	{
		s = new CEllipse();	//throw new Error("Unknown Shape Type");
		s.color = 0xffe497;
	}
	
	//create shape - set fields
	s.board = board;
	s.origin = origin;
	//s.color = shapeColor;
	s.label = label;
	s.legendType = legendType;
	s.termId = termId;
	s.initNew();
	//center origin
	origin.x -= s.cwidth/2;
	origin.y -= s.cheight/2;
	//return shape
	return s;
}

private function createDefaultShape(origin:CPoint,shapeType:String,label:String, termId:Number):CShape
{
		//create shape
		var s:CShape = null;
		if(shapeType == "rectangle")
			s = new CRectangle();
		else if(shapeType == "roundrectangle")
			s = new CRoundRectangle();
		else if(shapeType == "pentagon")
			s = new  CPentagon();
		else if(shapeType == "hexagon")
			s = new  CHexagon();
		else if(shapeType == "octagon")
			s = new  COctagon();
		else if(shapeType == "ellipse")
			s = new CEllipse();	
		else
			throw new Error("Unknown Shape Type");
		//create shape - set fields
		s.board = board;
		s.origin = origin;
		s.color = shapeColor;
		s.label = label;
		s.legendType = legendType;
		s.termId = termId;
		s.initNew();
		//center origin
		origin.x -= s.cwidth/2;
		origin.y -= s.cheight/2;
		//return shape
		return s;
}

private function createDefaultLine(startPoint:CPoint, lineType:String):CLine
{
		var cl:CLine = null;
		//create a new line
		if(lineType == Constants.LINE_TYPE)
			cl = new CLine();
		else
			cl = new CArrowLine();
		
		cl.init(0x808080,1);
		//add two points
		//since an line needs at least two
		cl.addPoint(startPoint);
		cl.addPoint(startPoint.getClone());
		//return line		
		return cl;
}

/* END OF UI (EDIT MODE) UTILITY FUNCTIONS */

/* START OF UI (MODE SWITCH) UTILITY FUNCTIONS */
//This method is used to show the diagram in edit mode
//so that the user can modify the diagram accordingly
private function showDiagramInEditMode(previousDiagram:Boolean):void
{
	//re-draw shapes and lines
	//in the original position
	if(shapes!=null)
	{
		
		for(var i:int=0;i<shapes.length;i++)
		{
			var s:CShape = shapes.getItemAt(i) as CShape;
			//IMPORTANT: COPY THE OLD VALUES BACK IF THIS IS
			//A PREVIOUS DIAGRAM THAT WAS LOADED IN VIEW MODE
			if(previousDiagram && (s.oldOrigin.x > 0 && s.oldOrigin.y > 0))
			{
				//copy old values back
				s.origin.x = s.oldOrigin.x;
				s.origin.y = s.oldOrigin.y;
				s.color = s.oldColor;
				//reset state

				s.highlighted = false;
				s.clicked = false;
			}
			//move to old position
			//s.move(0,0);
			//draw
			s.drawForEdit(false);
		}
	}
	if(lines!=null)
	{
		for(var j:int=0;j<lines.length;j++)
		{
			var l:CLine = lines[j];
			l.draw(false);
		}
	}
	
	//clear state
	resetBoardState();
	
	//draw dashed lines
	addDashedLinesToBoard();

	//reset selection square
	removeSelectionSquare();
	
	//restore inset
	inset.draw(true,zoomLevel);

}
//This method is used to show the diagram in view mode
//1) if filters == null it shows the master diagram in an uncollapsed form
//2) if filters !=null it shows the collapsed version of the filtered master diagram 
//based on the fitlers
private function showDiagramInViewMode(previousDiagram:Boolean,filters:ArrayCollection):void
{
	
	if(shapes!=null)
	{
		
		for(var i:int=0;i<shapes.length;i++)
		{
			var s:CShape = shapes.getItemAt(i) as CShape;
			//IMPORTANT: DO NOT UPDATE THE OLD VALUES UNLESS THIS IS NOT THE
			//PREVIOUS DIAGRAM THAT WAS LOADED IN VIEW MODE
			if(!previousDiagram)
			{
				//save the old values back
				s.oldOrigin.x = s.origin.x;
				s.oldOrigin.y = s.origin.y;
				s.oldColor = s.color;
				s.highlightBorder = false;
			}

		}
	
		showLinesInViewMode();
		
		drawShapesInViewMode();

	}
	
	//clear state
	if(!previousDiagram)
		resetBoardState();
	
	//remove dashed lines
	removeDashedLines();
	
	//reset selection square
	removeSelectionSquare();
	
	//restore inset
	inset.draw(true,zoomLevel);
}

//show diagram without lines for edit mode
private function showDiagramWithoutLines():void
{
	if(lines!=null)
	{
		for(var j:int=0;j<lines.length;j++)
		{
			var l:CLine = lines[j];
			board.removeChild(l);
		}
	}
	//restore inset
	inset.draw(true,zoomLevel);
}

//show diagram with lines for edit mode
private function showDiagramWithLines():void
{
	if(lines!=null)
	{
		for(var j:int=0;j<lines.length;j++)
		{
			var l:CLine = lines[j];
			board.addChild(l);
			l.draw(false);
		}
	}
	//restore inset
	inset.draw(true,zoomLevel);
}


/* START OF UI (VIEW MODE) UTILITY FUNCTIONS */
//utility method to draw in view mode
private function drawShapesInViewMode():void
{
	for(var i:int=0;i<shapes.length;i++)
	{
		var s:CShape = shapes.getItemAt(i) as CShape;
		s.highlightBorder=false;
		s.drawForView();
	}
}

private function hideLinesInViewMode():void
{
	if(lines!=null)
	{
		for(var i:int=0;i<lines.length;i++)
		{
			var l:CLine = lines[i];
			l.clear();
		}
	}
}

private function showLinesInViewMode():void
{
	if(lines!=null)
	{
		for(var i:int=0;i<lines.length;i++)
		{
			var l:CLine = lines.getItemAt(i) as CLine;
			l.draw(false);
		}
	}
}

//this function adds a shape to clicked shapes
private function addToClickedShapes(s:CShape):void
{
	s.clicked = true;
	s.highlighted = false;
	s.color = Constants.VIEW_CLICK_COLOR;
	s.drawForView();
	clickedShapes.addItem(s);
}

//this function removes a clicked shape from the list
private function removeFromClickedShapes(s:CShape):void
{
	if(clickedShapes.contains(s))
	{
		clickedShapes.removeItemAt(clickedShapes.getItemIndex(s));
		s.highlightBorder = false;
		s.highlighted = false;
		s.clicked = false;
		s.color = s.oldColor;
		s.drawForView();
	}
}

//this function highlights linked shapes
private function highlightLinkedShapes(s:CShape):void
{
	var linkages:ArrayCollection = s.linkages;
	for(var i:int=0;i<linkages.length;i++)
	{
		var l:Linkage = linkages[i];
		if(!l.shape.clicked)
		{
			l.shape.clicked = false;
			l.shape.highlighted = true;
			l.shape.color = Constants.VIEW_HIGHLIGHT_COLOR;
			l.shape.drawForView();
		}
	}
}


//this function resets highlighted shapes and clicked shapes (if excludeClicked == false)
private function resetHighlightedAndClickedShapes(excludeClicked:Boolean):void
{
	for(var i:int=0;i<shapes.length;i++)
	{
	var s:CShape = shapes.getItemAt(i) as CShape;
		//if(s.filtered)
		{
			if(s.highlighted)
			{
				s.highlighted = false;
				s.clicked = false;
				s.color = s.oldColor;
			
			}
			else if(s.clicked&&!excludeClicked)
			{
				s.highlighted = false;
				s.clicked = false;
				s.color = s.oldColor;
				
			}
			else if(s.clicked && excludeClicked) {

			}
		}
		
//		s.highlightBorder = false;
//		s.clicked = false;
//		s.color = s.oldColor;
		s.drawForView();
	}
}
	
/* END OF UI (VIEW MODE) UTILITY FUNCTIONS */


/* START OF DOWNLOADING DIAGRAM */
public function saveDiagramAsImage():void
{
	//create a bitmap array from the board's pixels
	var data:BitmapData = new BitmapData(board.width,board.height);
	data.draw(board);
	//encode bitmap 
	var encodedData:ByteArray = PNGEncoder.encode(data);
	//upload to server
	var s:Service = new Service();
	s.serviceHandler = saveAsPNGHandler;
	s.saveDiagramAsImage(encodedData);
}


private function saveAsPNGHandler(event:ResultEvent):void
{
	var u:URLRequest = new URLRequest("DownloadPNGImage");
	navigateToURL(u,"_blank");
}
/* END OF DOWNLOADING DIAGRAM */


/* START OF ALIGNING SHAPES */
private function startAligning():void
{
	//reset board state
	resetBoardState();
	//set edit state
	aligningShapes = true;
	//create a new collection
	shapesToAlign = new ArrayCollection();
}

private function endAligning():void
{
	//get the max yValue
	var length:int = shapesToAlign.length;
	var yValues:Array = new Array();
	for(var i:int=0;i<length;i++){
		var s:CShape = shapesToAlign[i];
		yValues[i] = s.origin.y;
	}
	//find the min value
	var minY:Number = ArrayUtil.findMinValue(yValues);
	//update the height of all selected shapes
	for(var m:int=0;m<length;m++){
		var s:CShape = shapesToAlign[m];
		s.move(0,minY-s.origin.y);
		s.drawForEdit(false);
		//move the connectors (move the first
		//and last point of the line if necessary)
		var cns:ArrayCollection = s.connectors;
		for(var n:int=0;n<cns.length;n++){
			var c:CConnector = cns[n];
			if(c.start)
			{
				var sp:CPoint = c.line.getFirstPoint();
				sp.y = s.getConnectorPoint(c.index).y;
			}
			else
			{
				var ep:CPoint = c.line.getLastPoint();
				ep.y = s.getConnectorPoint(c.index).y;
			}
			c.line.draw(false);
		}
	}
	//reset board state
	resetBoardState();
	//set edit state
	aligningShapes = false;
	//clear collection
	shapesToAlign = null;
}


/* END OF ALIGNING SHAPES */

/* START OF SELECTING SHAPES */
private function startSelection():void
{
	//reset board state
	resetBoardState();
	//set edit state
	selectingShapes = true;	
}

private function endSelection():void
{
	//reset board state
	resetBoardState();
	//remove selection square
	removeSelectionSquare();
	//unselect currently selected the shapes
	selectAllShapes(false);
	//set edit state
	selectingShapes = false;
}

private function selectShapes():void
{
	selectedShapes = new ArrayCollection();
	for(var i:int=0;i<shapes.length;i++)
	{
		var s:CShape = shapes.getItemAt(i) as CShape;
		var insideSquare:Boolean = isShapeInsideSquare(s);
		if(insideSquare)
		{
			//add to selected shapes
			selectedShapes.addItem(s);
			//draw as selected
			s.drawForEdit(true);
		}
		else
		{
			//draw as unselected
			s.drawForEdit(false);
		}
	}
	
}

private function isShapeInsideSquare(shape:CShape):Boolean
{
	//check in regards to center of the shape
	var cx:Number = shape.origin.x+shape.cwidth/2;
	var cy:Number = shape.origin.y+shape.cheight/2;
	//two cases: start point could be higher or lower than endpoint
	if(startPoint.x < endPoint.x && startPoint.y < endPoint.y)
	{
		if(cx >= startPoint.x && cx <= endPoint.x 
			&& cy >= startPoint.y && cy <= endPoint.y)
			return true;
		else
			return false;
	}
	else
	{
		if(cx >= endPoint.x && cx <= startPoint.x 
			&& cy >= endPoint.y && cy <= startPoint.y)
			return true;
		else
			return false;
	}
}

private function drawSelectionSquare():void
{
	//remove previous square
	removeSelectionSquare();
	//create a new square
	selectionSquare = new UIComponent();
	//get the graphics object
	var g:Graphics = selectionSquare.graphics;
	//calculate corners
	var x1:Number = startPoint.x;
	var y1:Number = startPoint.y;
	var x2:Number = endPoint.x;
	var y2:Number = endPoint.y;
	//set the line style
	g.lineStyle(2,0x668CFF,1);
	//draw the square
	g.moveTo(x1,y1);
	g.lineTo(x2,y1);
	g.lineTo(x2,y2);
	g.lineTo(x1,y2);
	g.lineTo(x1,y1);	
	//add square to board
	board.addChild(selectionSquare);
}

private function moveSelectionSquare(deltaX:Number,deltaY:Number):void
{
	//update start end end points
	startPoint.x += deltaX;
	startPoint.y += deltaY;
	endPoint.x += deltaX;
	endPoint.y += deltaY;
}

private function removeSelectionSquare():void
{
	if(selectionSquare!=null&&board.contains(selectionSquare))
	{
		board.removeChild(selectionSquare);
		selectionSquare = null;
	}
}


/* END OF SELECTING SHAPES */


/* START OF COPYING SHAPES */
private function startCopying():void
{
	//reset board state
	resetBoardState();
	//set edit state
	copyingShape = true;
}

private function endCopying():void
{
	//deselect current shape (if selected)
	if(shape!=null)
		shape.drawForEdit(false);
	//reset board state
	resetBoardState();
	//set edit state
	copyingShape = false;
}
/* END OF COPYING SHAPES */

private function showDiragramEvidences():void 
{
	newLinkageShapes = new ArrayCollection();
	//create pop up panel
	reviewLnkPopUpPanel = new  ViewDiagramEvidences();
	reviewLnkPopUpPanel.addEventListener(FlexEvent.INITIALIZE,handleReviewLnkPopUpCreation)
	reviewLnkPopUpPanel.addEventListener(CloseEvent.CLOSE,closeReviewEvidence);	
	//add to manager
	PopUpManager.addPopUp(reviewLnkPopUpPanel, this, true);
	PopUpManager.centerPopUp(reviewLnkPopUpPanel);
	reviewLnkPopUpPanel.y = 20;
}

private function handleReviewLnkPopUpCreation(event:FlexEvent):void
{

	reviewLnkPopUpPanel.closeb.addEventListener(MouseEvent.CLICK,cancelReviewEvidence);
//	reviewLnkPopUpPanel.citations.addEventListener(itemClickEvent,navigateToViewCitation);
	reviewLnkPopUpPanel.downloadAll.addEventListener(MouseEvent.CLICK,downloadAllCitations);
	//Alert.show("effect Shapes " + newLinkageShapes.length.toString());downloadAll
	reviewLnkPopUpPanel.dname.text = Model.diagram.name;
	
	var s:Service = new Service();
	s.serviceHandler = handleGetDiagramEvidences;
	
	s.getDiagramEvidences(Model.diagram.id);
	
	
	//change the mouse to a busy cursor
	CursorManager.setBusyCursor();
	busyCursor = true;
}

public function downloadAllCitations(diagramEvidenceList:ArrayCollection):void
{
	/*if (diagramEvidenceList .length > 0)
	{
		
		ExcelExporterUtil.dataGridExporter(reviewLnkPopUpPanel.displayDiagramCitations, "prueba_excel.xls");
		
		*/
		var csv : CSV = new CSV();
		csv.embededHeader = false
		csv.header =  ['CAUSE SHAPE', 'EFFECT SHAPE', 'AUTHOR', 'YEAR', 'TITLE', 'SOURCE DATA','STUDY TYPE', 'HABITAT', 'CREATE BY']
		
		for(var i:int = 0; i < diagramEvidenceList.length ; i++)
		{ 
			var c:Object = diagramEvidenceList.getItemAt(i) as Object;
				
			csv.addRecordSet( [c.shapeFromLabel + getTrajectory(c.shapeFromTrajectory), 
							   c.shapeToLabel + getTrajectory(c.shapeToTrajectory),
							   '"' + c.author + '"', c.year, c.title, c.sourceData, c.studyType, c.habitat, c.createUser] )
		}
		var bytes:ByteArray = new ByteArray();
		
		csv.encode();
		bytes.writeMultiByte(csv.data,"UTF-8"); 
		var s:Service = new Service();
		s.serviceHandler = saveAsCSVHandler;
		s.saveDiagramEvidencesAsCSV(bytes);
	
}

private function saveAsCSVHandler(event:ResultEvent):void
{
		var u:URLRequest = new URLRequest("DownloadCSV");
		navigateToURL(u,"_blank");
}

private function cancelReviewEvidence(event:MouseEvent):void
{
	removeReviewLnkPopUp();
}
private function closeReviewEvidence(event:CloseEvent):void
{
	//remove pop up
	removeReviewLnkPopUp();
}

private function removeReviewLnkPopUp():void
{	//hide pop up
	PopUpManager.removePopUp(reviewLnkPopUpPanel);
	reviewLnkPopUpPanel = null;
	//set focus to the main board
	this.setFocus();
}

private function handleGetDiagramEvidences(event:ResultEvent):void
{
	
	diagramEvidenceList = event.result as ArrayCollection;
	var filterList:ArrayCollection = new ArrayCollection();
	var displayList:Object = null;
	var displayArray:ArrayCollection = new ArrayCollection();
	
	for(var i:int = 0; i < diagramEvidenceList.length ; i++)
	{ 
		var c:Object = diagramEvidenceList.getItemAt(i) as Object;
		
		var text:String = c.shapeFromLabel + getTrajectory(c.shapeFromTrajectory) + " AND " + c.shapeToLabel + getTrajectory(c.shapeToTrajectory);	
		
		
		if(filterList.length ==  0 || filterContains(displayArray, text))
				filterList.addItem(c);
		else
		{
			var visibleMsg:Boolean = filterList.length > 0 ? false : true;
			displayList = {header: text, data:filterList, visibleMsg:visibleMsg, visibleGrid:!visibleMsg};
			displayArray.addItem(displayList);
			
			filterList = new ArrayCollection();
			filterList.addItem(c);
		}
		
	} 
	
	reviewLnkPopUpPanel.displayDiagramCitations.dataProvider=displayArray;
	
	CursorManager.removeBusyCursor();
	busyCursor = false; 
	
}

private function filterContains(filterList:ArrayCollection, text:String):Boolean
{
	for each(var item:Object in filterList)
	{	
		if ( StringUtil.stringsAreEqual( item.header, text, false) )
			return true;
		
	}
	return false;
}

private function getTrajectory (shapeSymbol:int):String
{
	var taj:String = " & " ;
	if(shapeSymbol == Constants.SYMBOL_ARROW_UP)
		taj += Constants.SYMBOL_INCREASING;
	else if(shapeSymbol == Constants.SYMBOL_DELTA)
		taj += Constants.SYMBOL_CHANGE;
	else if(shapeSymbol == Constants.SYMBOL_ARROW_DOWN)
		taj += Constants.SYMBOL_DECREASING;
	else
		taj = "";
	return taj;
}

private function startReviewLinkage():void
{
	//reset board state
	resetBoardState();
	//set state to adding lnkg
	addingLinkage = true;
	//init collection
	newLinkageShapes = new ArrayCollection();
}

private function endReviewLinkage():void
{
	//check if the user has selected any shapes at all
	if(newLinkageShapes.length < 2)
	{
		//reset board state
		resetBoardState();
		//clear shape selection
		selectAllShapes(false);
		//show error message
		Alert.show("Please select at least two shapes when creating a linkage.", "INFORMATION", Alert.OK, null, null, null, Alert.OK);
		return;
	}
	
	//create pop up panel
	newLnkPopUpPanel = new  NewLinkagePopUp();
	newLnkPopUpPanel.addEventListener(FlexEvent.INITIALIZE,handleNewLnkPopUpCreation)
	//add to manager
	PopUpManager.addPopUp(newLnkPopUpPanel, this, true);
	PopUpManager.centerPopUp(newLnkPopUpPanel);
	newLnkPopUpPanel.y = 20;
}

/* START OF CREATING A NEW LINKAGE */
private function startNewLinkage():void
{
	//reset board state
	resetBoardState();
	//set state to adding lnkg
	addingLinkage = true;
	
	//init collection
	newLinkageShapes = new ArrayCollection();
}

private function endNewLinkage():void
{
	//check if the user has selected any shapes at all
	if(newLinkageShapes.length < 2)
	{
		//reset board state
		resetBoardState();
		//clear shape selection
		selectAllShapes(false);
		//show error message
		Alert.show("Please select at least two shapes when creating a linkage.", "INFORMATION", Alert.OK, null, null, null, Alert.OK);
		return;
	}
	
	//create pop up panel
	addLnkPopUpPanel = new AddEditDiagramLinkage(); //NewLinkagePopUp();
	addLnkPopUpPanel.addEventListener(FlexEvent.INITIALIZE,handleAddEditLnkPopUpCreation)
	//add to manager
	PopUpManager.addPopUp(addLnkPopUpPanel, this, true);
	PopUpManager.centerPopUp(addLnkPopUpPanel);
	newLnkPopUpPanel.y = 20;
}

private function handleAddEditLnkPopUpCreation(event:FlexEvent):void
{
	//*** init list for new Citations
	Model.newCitations = new ArrayCollection();
	var causeShapes:ArrayCollection = new ArrayCollection();
	//add listeners
	addLnkPopUpPanel.dEvidenceb.addEventListener(MouseEvent.CLICK,saveNewLinkage);
	addLnkPopUpPanel.cancelb.addEventListener(MouseEvent.CLICK,cancelAddLinkage);
	addLnkPopUpPanel.addEventListener(CloseEvent.CLOSE,closeAddLinkage);
	//addLnkPopUpPanel.eCADLinkb.addEventListener(MouseEvent.CLICK,goCADlinkEdit);
	addLnkPopUpPanel.addNewEvidence.addEventListener(MouseEvent.CLICK,newLinkagePopUp);
	
	causeShapeAdd = newLinkageShapes.removeItemAt(0) as CShape;
	//only one causeShape, this list is for store it 
	causeShapes.addItem(causeShapeAdd);
	//Alert.show("effect Shapes " + newLinkageShapes.length.toString());
	addLnkPopUpPanel.clabel.text = causeShapeAdd.label;
	addLnkPopUpPanel.causeShapes.dataProvider = causeShapes;
	//set value for shapes
	addLnkPopUpPanel.shapes.dataProvider = newLinkageShapes;
	
	var list:ArrayCollection = new ArrayCollection();
	for each(var obj:CShape in newLinkageShapes)
	{
		list.addItem(obj.label);
	}
	//search
	var s:Service = new Service();
	s.serviceHandler = handlePopulateCitationSearch;
	
	s.searchCitationsByCauseNEffects (causeShapeAdd.label, list);
	
	
	//change the mouse to a busy cursor
	CursorManager.setBusyCursor();
	busyCursor = true;
}

private function handlePopulateCitationSearch(event:ResultEvent):void
{
	var selectedlinkageShapes = addLnkPopUpPanel.shapes.dataProvider as ArrayCollection;
	
	var list = event.result as ArrayCollection;
	var citationList:ArrayCollection = list;
	
	displayList = null;
	displayArray = new ArrayCollection();
	for(var i:int = 0; i < selectedlinkageShapes.length ; i++)
	{ 
		var eshape = selectedlinkageShapes[i] as CShape;
		
		var text:String = addLnkPopUpPanel.clabel.text + " AND " + eshape.label ;	
		var filterList:ArrayCollection = new ArrayCollection();
		for(var o:int = 0; o < list.length; o++)
		{
			var c:Object = list.getItemAt(o) as Object;
			if(StringUtil.stringsAreEqual(c.shapeToLabel, eshape.label, false))
				filterList.addItem(c);
		}
		var visibleMsg:Boolean = filterList.length > 0 ? false : true;
		displayList = {header: text, data:filterList, visibleMsg:visibleMsg, visibleGrid:!visibleMsg, effectShape:eshape};
		displayArray.addItem(displayList);
	} 

	addLnkPopUpPanel.displayDiagramCitations.dataProvider=displayArray;
		
	CursorManager.removeBusyCursor();
	busyCursor = false; 
}


private function newLinkagePopUp(event:MouseEvent):void
{
	newLnkPopUpPanel = new NewLinkagePopUp();
	newLnkPopUpPanel.addEventListener(FlexEvent.INITIALIZE,handleNewLnkPopUpCreation)
	//add to manager
	PopUpManager.addPopUp(newLnkPopUpPanel, this, true);
	PopUpManager.centerPopUp(newLnkPopUpPanel);
	newLnkPopUpPanel.y = 20;
}

private function handleNewLnkPopUpCreation(event:FlexEvent):void
{
	//*** init list for new Citations
	Model.newCitations = new ArrayCollection();
	var causeShapes:ArrayCollection = new ArrayCollection();
	//add listeners
	//newLnkPopUpPanel.saveb.addEventListener(MouseEvent.CLICK,saveNewLinkage);
	newLnkPopUpPanel.cancelb.addEventListener(MouseEvent.CLICK,cancelNewLinkage);
	newLnkPopUpPanel.addEventListener(CloseEvent.CLOSE,closeNewLinkage);
	
 	causeShape = causeShapeAdd;// newLinkageShapes.removeItemAt(0) as CShape;
	//only one causeShape, this list is for store it 
	causeShapes.addItem(causeShape);
	//Alert.show("effect Shapes " + newLinkageShapes.length.toString());
	newLnkPopUpPanel.clabel.text = causeShape.label;
	newLnkPopUpPanel.causeShapes.dataProvider = causeShapes;
	//set value for shapes
	newLnkPopUpPanel.shapes.dataProvider = newLinkageShapes;
}

private function goCADlinkEdit(event:MouseEvent):void
{
	Alert.show("Go to CADLink login");
}

private function saveNewLinkage(event:MouseEvent):void
{

	//find the selected references

	var list = addLnkPopUpPanel.displayDiagramCitations.dataProvider as ArrayCollection;

	for(var i:int = 0; i < list.length ; i++)
	{ 
		for each(var o:Object in list[i].data)
		{
			if(o.selected)
			{
				selCits.addItem({effectShape: list[i].effectShape, item:o });	
			}
		}
		
	} 
	//check if the user has selected any citations at all
	if(selCits.length == 0)
	{
		//show error message
		Alert.show("Please select at least one evidence to delete", "INFORMATION", Alert.OK, null, null, null, Alert.OK);
		return;
	}
	else
	{
		Alert.show("You are about to delete evidence from your diagram. Do you wish to proceed?", "WARNING",(Alert.YES | Alert.NO),null,handleDeleteWarnResponse,null,Alert.YES);
	}
	
	
}

private function handleDeleteWarnResponse(event:CloseEvent):void
{
	if(event.detail == Alert.YES)	
	{
		
		var selectedlinkageShapes = addLnkPopUpPanel.shapes.dataProvider as ArrayCollection;
		var listEffects:ArrayCollection = new ArrayCollection();
		for each(var obj:CShape in selectedlinkageShapes)
		{
			listEffects.addItem(obj.label);
		}
		var s:Service = new Service();
		s.serviceHandler = handleGetEvidences;
		
		s.searchEvidenceByDaigramShapeFrom (addLnkPopUpPanel.clabel.text, listEffects, Model.diagram.id);
		
	}
	
}

private function handleGetEvidences(event:ResultEvent):void
{	
	var listEvidences = event.result as ArrayCollection;//This array has all of the evidences for the selected shape
	
	var selectedlinkageShapes = addLnkPopUpPanel.shapes.dataProvider as ArrayCollection; // all of the available effective shapes
	
	var citationList:ArrayCollection = new ArrayCollection();
	
	//Alert.show("You are about to delete evidence " + listEvidences.length.toString());
	//selCits: to be deleted (has datasetId)
	for(var i:int = 0; i < selCits.length ; i++)
	{ 
		var effectShape:CShape = selCits[i].effectShape as CShape;
		
		for each(var o:Object in listEvidences)
		{
			if (o.shapeFromLabel == causeShapeAdd.label && 
				o.shapeToLabel == effectShape.label && 
				o.dataSetId == selCits[i].item.dataSetId)
			{
				DeleteLinkage(causeShapeAdd, effectShape, o.causeEffectId);
			}
		}

	} 
	
	removeAddLnkPopUp();
}

private function DeleteLinkage(causeShape:CShape, effectShape:CShape, causeEffectId:Number) : void
{
	for each (var c:CShape in Model.diagram.shapes)
	{
		//l.linkages
		if(c == causeShape)
		{
			//delete linkage
			var l:Linkage = c.findOrCreateLinkage(false, effectShape);
			//Alert.show("You are about to delete evidence " + l.shape.label + " causeEffectIds = " + l.causeEffectIds.length);
			//remove linkage from selected shape
			c.removeLinkageWithCauseEffect(effectShape, causeEffectId);
			//remove linkage from the other shape of the linkage
			l.shape.removeLinkageWithCauseEffect(c, causeEffectId);
			//add to items to remove
			//c.printLinkages();
		}
	}
}
//private function createPairwiseLinkages(selCits:ArrayCollection):void
//{
//	//update linkages for the shape
//	
//	for(var i:int=0;i<newLinkageShapes.length;i++)
//	{
//		var s:CShape = newLinkageShapes[i];
//		//link the shape to other shapes
//		for(var m:int=0;m<newLinkageShapes.length;m++)
//		{
//			if(i!=m)//IMPORTANT: avoid adding a linkage to itself
//			{
//				s.addLinkage(newLinkageShapes[m],selCits);
//			}
//		}
//	}
//}

private function createPrimaryLinkages(selCits:ArrayCollection):void
{
	//get the primary shape
	//var pShape:CShape = newLinkageShapes[0];
	//create linkages
	for(var m:int=0;m<newLinkageShapes.length;m++)
	{
		var s:CShape = newLinkageShapes[m];
		//link the primary shape to other shape
		causeShape.addLinkage(s,selCits, false);//set before popup created
		//link the other shape to the primary shape
		s.addLinkage(causeShape,selCits, true);
		
	}

}

private function cancelNewLinkage(event:MouseEvent):void
{
	removeNewLnkPopUp();
}

private function cancelAddLinkage(event:MouseEvent):void
{
	removeAddLnkPopUp();
}
private function closeAddLinkage(event:CloseEvent):void
{
	//remove pop up
	removeAddLnkPopUp();
}

private function removeAddLnkPopUp():void
{
	//reset board state
	resetBoardState();
	//clear shape selection
	selectAllShapes(false);
	//hide pop up
	PopUpManager.removePopUp(addLnkPopUpPanel);
	addLnkPopUpPanel = null;
	//set focus to the main board
	this.setFocus();
}

private function closeNewLinkage(event:CloseEvent):void
{
	//reset value for new citations
	Model.newCitations = null;
	//remove pop up
	removeNewLnkPopUp();
}

private function removeNewLnkPopUp():void
{
	//reset board state
	//resetBoardState();
	//clear shape selection
	//selectAllShapes(false);
	//hide pop up
	PopUpManager.removePopUp(newLnkPopUpPanel);
	newLnkPopUpPanel = null;
	//set focus to the main board
	this.setFocus();
}
/* END OF CREATING A NEW LINKAGE */

public function ModifyDiagramShapes(selectedTerms:ArrayCollection):void
{
	var shapesList:ArrayCollection = new ArrayCollection();
	var newSelected:ArrayCollection = selectedTerms;
	
	if(Model.diagram.shapes!=null)
	{
		for(var i:int=0;i<Model.diagram.shapes.length;i++)
		{
			var s:CShape = Model.diagram.shapes.getItemAt(i) as CShape;
			var oldShape:Boolean = false;
			if ((s.termId != NaN && s.termId != 0)  && s.label != null )
			{
				
				for(var k:int= 0; k < selectedTerms.length; k++)
				{
					var obj:Term = selectedTerms.getItemAt(k) as Term;
					if (s.termId == obj.id || s.label == obj.term)
					{
						oldShape = true;
						newSelected.removeItemAt(newSelected.getItemIndex(obj));
						newSelected.refresh();
						shapesList.addItem(s);
						break;
					}
					
				}
				
				if (!oldShape)
				{	
					board.removeChild(s);
					s.destroy();
					s = null;
					for(var j:int=0; j< Model.diagram.lines.length; j++)
					{
						var l:CLine = Model.diagram.lines[j];
						//TODO: line??
					}
				}
				
			}
			else 
				shapesList.addItem(s);
			
		}
	}
	
	if (newSelected != null &&  newSelected.length > 0 )
	{
		//TODO: lili
		var i:int;
		var x:Number = 150;
		var y:Number = 30;
		var swidth:Number= 10;
		
		var oldLegendType:Number = 0;
		resetBoardState();
		for(i= 0; i < newSelected.length; i++)
		{
			var obj:Term = selectedTerms.getItemAt(i) as Term;
			
			var ns:CShape = new CShape();
			
			var o:CPoint = new CPoint();
			
			if ( oldLegendType != obj.legendType )
			{	
				if (oldLegendType != 0)
					y = y + 80;
				x = 150;
			}
			else
			{
				if (oldLegendType != 0)
					x = x + 130;
			}
			
			o.x = x+CShape.MIN_WIDTH/2;
			o.y = y+CShape.MIN_HEIGHT/2;
			
			
			ns = createDefaultShapeLegenType(o,obj.legendType,obj.term, obj.id);
			
			//add to board
			board.addChild(ns);
			shapesList.addItem(ns);
			
			//draw it
			ns.drawForEdit(false);
			
			
			
			y = y + ns.height; 
			x = x + ns.width;
			
			ns = null;
			oldLegendType = obj.legendType ;
		}
		
	}
	resetBoardState();

	Model.diagram.shapes = shapesList;
	Model.diagram.shapes.refresh();
	shapes = Model.diagram.shapes;
}




