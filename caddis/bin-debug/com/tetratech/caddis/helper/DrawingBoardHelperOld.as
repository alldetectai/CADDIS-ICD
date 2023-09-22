// ActionScript file
import com.adobe.images.PNGEncoder;
import com.tetratech.caddis.common.ArrayCollectionUtil;
import com.tetratech.caddis.common.ArrayUtil;
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.common.GraphicsUtil;
import com.tetratech.caddis.common.ShapeCollection;
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
import com.tetratech.caddis.event.DiagramFilterEvent;
import com.tetratech.caddis.event.InsetPanEvent;
import com.tetratech.caddis.event.InsetToggleEvent;
import com.tetratech.caddis.event.InsetZoomEvent;
import com.tetratech.caddis.event.MenuItemClickEvent;
import com.tetratech.caddis.event.ModeSwitchEvent;
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.session.SessionManager;
import com.tetratech.caddis.view.Menu;
import com.tetratech.caddis.view.NewLinkagePopUp;
import com.tetratech.caddis.view.ShapePopUp;
import com.tetratech.caddis.view.TabNavigator;
import com.tetratech.caddis.vo.Linkage;
import com.tetratech.caddis.vo.ShapeAttribute;

import flash.display.Graphics;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.UIComponent;
import mx.effects.WipeDown;
import mx.effects.WipeLeft;
import mx.effects.WipeRight;
import mx.effects.WipeUp;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
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
//2. VIEW MODE
//private var filteringDiagram:Boolean = false;
private var viewingLinkages:Boolean = false; //highlighting linkages by clicking on shapes
//END OF BOARD STATE

//MOUSE MODES on SHAPES or LINES (EDIT MODE ONLY)
private var dragging:Boolean = false;
private var resizing:Boolean = false;

//shape type to be drawn
private var shapeType:String;
private var legendType:Number;
private var shapeColor:Number;

//diagram modes (VIEW MODE ONLY)
private var diagramCollapsed:Boolean = false; //static flag that is reset by the menu
private var diagramShrinked:Boolean = false; //static flag that is reset by the menu
  
//shapes
private var shape:CShape=null; //current selected shape
private var shapes:ShapeCollection=null; //list of shapes on the board
private var dragShape:CShape=null; //shape that is dragged ONLY when users clicks on a create shape item on the menu

//lines
private var line:CLine=null;  //curent selected line
private var lines:ArrayCollection=null; //list of lines on the board

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
private var diagramFilterShown:Boolean = false;

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

//collection of shapes for new linkage (EDIT MODE)
private var newLinkageShapes:ArrayCollection=null;

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

//store creation point for shapes
private var newShapeLocation:CPoint = null;

//shapes for parent drop down
private var mostRecentlySelectedShape:CShape = null;
private var mostRecentlyAddedShape:CShape = null;

//pointer to dashed lines comoponent
private var dashedLines:UIComponent = null;

//pointer to square component
private var selectionSquare:UIComponent = null;
//coordiantes for selection square
private var startPoint:Point;
private var endPoint:Point;

//handle to session manager
private var sessionManager:SessionManager = null;


/* START OF INIT FUNCTIONS */
/* This function is used to initialize the board components */
private function init():void
{
	//bind to tab navigator(tab navigator is the wrapper now)
	tabNav = this.parent.parent.getChildByName("tabNav") as TabNavigator;
	//bind to menu (menu is in the wrapper now)
	menu = this.parent.parent.getChildByName("menu") as Menu;
	
	
	//initialize components
	board.parent.setChildIndex(board,0);
	board.parent.setChildIndex(boardControl,1);
	board.parent.setChildIndex(inset,2);
	board.parent.setChildIndex(accordion,3);
	board.parent.setChildIndex(diagramFilter,4);
	
	//setup event handlers
	board.doubleClickEnabled = true;
	
	//add mouse events
	board.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
	board.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
	board.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
	board.addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler);
	
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
	//this is need for the pre-load from the introduction (optinal)
	//Model.menu = menu;
	//menu.addEventListener(IntroductionLoadEvent.LOAD_DIAGRAM,menu.loadDiagramIntroListener);

	//add event listener for diagram filter
	diagramFilter.addEventListener(DiagramFilterEvent.DIAGRAM_FILTER_ALL,diagramFilterAllHandler);
	diagramFilter.addEventListener(DiagramFilterEvent.DIAGRAM_FILTER_SOME,diagramFilterSomeHandler);
	
	//disable board
	enableBoard(false);
	
	//start the introduction
	/*GET RID OF THE INTO 
	startIntroduction(this);
	*/
	
	//start login
	//startLogin(this);
	

}

/* END OF INIT FUNCTIONS */

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
	else if(event.operation == "chooseDiagram")
		chooseDiagramToggleHandler(true);
    else if(event.operation == "unchooseDiagram")
		chooseDiagramToggleHandler(false); 
	else if(event.operation == "downloadDiagram")
		saveDiagramAsImage();
	else if(event.operation == "collapse")
		collapseDiagram();
	else if(event.operation == "uncollapse")
		uncollapseDiagram();
	else if(event.operation == "shrink")
		shrinkDiagram();
	else if(event.operation == "expand")
		expandDiagram();
	else if(event.operation == "reset")
		resetDiagram();
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

private function chooseDiagramToggleHandler(show:Boolean):void
{
	if(show)
	{
		diagramFilter.visible = true;
		diagramFilterShown = true;
	}
	else
	{
		diagramFilter.visible = false;
		diagramFilterShown = false;
	}

}

private function modeSwitchHandler(event:ModeSwitchEvent):void
{
	if(event.newMode == Constants.MODE_VIEW)
	{
		//change menu tab
		menu.changeTab();
		//reset menu state
		menu.resetViewState();
		//clear accordion
		accordion.clearAll();
		//show accordion if necessary
		accordion.visible = accordionShown;
		//set fields
		oldMode = mode;
		mode = Constants.MODE_VIEW;
		//show diagram in view mode
		showDiagramInViewMode(false,null);
	}
	else if(event.newMode == Constants.MODE_EDIT)
	{
		//change menu tab
		menu.changeTab();
		//reset menu state
		menu.resetEditState();
		//reset the organism filter on the accordion
		/* COMMENT OUT ORGANISMS
		accordion.organismFilter.reset();
		*/
		//hide accordion
		accordion.visible = false;
		//reset the diagram filters
		diagramFilter.reset();
		//hide diagram filter if necessary
		if(diagramFilterShown)
			chooseDiagramToggleHandler(false);
		//set fields
		oldMode = mode;
		mode = Constants.MODE_EDIT;
		//show diagram
		showDiagramInEditMode(true);

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


private function diagramFilterAllHandler(event:DiagramFilterEvent):void
{
	//reset the diagram every time you filter
	resetDiagram();
	//show diagram
	showDiagramInViewMode(true,null);
}

private function diagramFilterSomeHandler(event:DiagramFilterEvent):void
{
	//reset the daigram every time you filter
	resetDiagram();
	//show diagram
	showDiagramInViewMode(true,event.filters);
}


/* END OF CONTROLS EVENT HANDLERS */

/* START OF MOUSE MOVE HANDLERS */
private function mouseMoveHandler(event:MouseEvent):void
{
	if(mode == Constants.MODE_VIEW)
	{
		//hide the diagram filter
		//if it is shown 
		if(diagramFilterShown)
		{
			chooseDiagramToggleHandler(false);
		}
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
			{
				var o:CPoint = new CPoint();
				o.x = event.localX-CShape.MIN_WIDTH/2;
				o.y = event.localY-CShape.MIN_HEIGHT/2;
				dragShape = createDefaultShape(o,shapeType,"");
				//add to board
				board.addChild(dragShape);
				//draw it
				dragShape.drawForEdit(false);
			}
			//reposition drag shape
			else
			{
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
					for (var i:int=0;i<shapes.length();i++)
					{
						var s:CShape = shapes.getItemAt(i);
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
					//re-insert shape into the list to update the
					//list position if necessary
					shapes.reAddItem(shape);
				}
				
				//reset state
				resetBoardState();
			}
			else if(dragging)
			{
				if(shape!=null)
				{
					//re-insert shape into the list to update the
					//list position if necessary
					shapes.reAddItem(shape);
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
		for(var i:int=0;i<shapes.length();i++)
		{
			var s:CShape = shapes.getItemAt(i);
			//check only filtered shapes (ignore non-filtered shapes)
			//ignore hidden shapes too
			if(s.filtered&&!s.hidden)
			{
				//check if you need to collapse or un-collapse the child shapes of a shape
				if(s.childShapes.length > 0 && s.isMouseOverTriangle(event))
				{
									
					//show children when collapsed and user
					//clicks to uncollapse
					if(s.collapsed)
					{
						showChildShapes(s);
					}
					else
					{
						hideChildShapes(s);
					}
									
					//toggle triangle and draw shape
					s.drawForView(!s.collapsed);
					
					/* IMPORTANT: highlight shapes if you were in view linkage mode */
					if(viewingLinkages)
					{
						//highlight linkages for the last shape in the clicked shapes
						var st:CShape = clickedShapes.getItemAt(clickedShapes.length-1) as CShape;
						//reset linked shapes
						resetHighlightedAndClickedShapes(true);
						//hightling linked shapes;
						highlightLinkedShapes(st);
					}
					
					//break from loop
					break;
				}
				//check if you clicked on a shape
				else if(s.isMouseOver(event))
				{
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
				var cl:CLine = createDefaultLine(p);
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
			//create a new shape
			if(shape==null)
			{
				//get rid of the dragShape
				board.removeChild(dragShape);
				dragShape = null;
				//VERY IMPORTANT: enable menu controls
				menu.enableControls(true);
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
			for(var i:int=0;i<shapes.length();i++)
			{
				var s:CShape = shapes.getItemAt(i);
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
				for(var i:int=0;i<shapes.length();i++)
				{
					var s:CShape = shapes.getItemAt(i);
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
				s.updateAttributes(s.label,s.parentShape);
								
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
			for(var i:int=0;i<shapes.length();i++)
			{
				var s:CShape = shapes.getItemAt(i);
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
		else if(!drawingLine&&!drawingShape)
		{		
			for(var i:int=0;i<shapes.length();i++)
			{
				var s:CShape = shapes.getItemAt(i);
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
	}else if(event.delta < 0 && zoomLevel-1>=Constants.ZOOM_LEVEL_MIN){
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
			if(!addingLinkage&&!copyingShape&&!aligningShapes)
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


/* START OF DIAGRAM FUNCTIONS */
private function newDiagram():void
{
	loadNewOrExistingDiagram();
	Alert.show("A new diagram was successfully created.", "INFORMATION", Alert.OK, null, alertOKHandler, null, Alert.OK);
	//update the diagram name
	tabNav.diagramName.text = Model.diagram.name;
	//set the focus to the board
	this.setFocus();
} 

private function loadDiagram(displayMessage:Boolean):void
{
	trace("disaply " + displayMessage);
	diagramFilter.reset();
	loadNewOrExistingDiagram();
	if(displayMessage)
		Alert.show("Diagram was successfully loaded.", "INFORMATION", Alert.OK, null, alertOKHandler, null, Alert.OK);
	else
		alertOKHandler(null);
	//update the diagram name
	tabNav.diagramName.text = Model.diagram.name;
	//set the focus to the board
	this.setFocus();
}

private function loadDiagramFromSaveAs():void
{
	diagramFilter.reset();
	loadNewOrExistingDiagram();
	//update the diagram name
	tabNav.diagramName.text = Model.diagram.name;
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
	inset.reset();
	/* REMEMBER TO SYNCHRONIZE INSET */
	inset.draw(true,zoomLevel);
	//disable menu items
	menu.enableControls(false);
	//clear the diagram name
	tabNav.diagramName.text = "";
	//set the models diagram to nothing
	Model.diagram = null;
}

private function clearDiagram():void
{
	//clear the board
	clearBoardDrawings();
	//draw or remove dashed lines
//	if(mode == Constants.MODE_VIEW)
//		removeDashedLines();
//	else if(mode == Constants.MODE_EDIT)
//		addDashedLinesToBoard();
	//init collections of diagram
	Model.diagram.lines = new ArrayCollection();
	Model.diagram.shapes = new ArrayCollection();
	//bind collections
	lines = Model.diagram.lines;
	shapes = new ShapeCollection();
	shapes.addCollection(Model.diagram.shapes);
	/* REMEMBER TO SYNCHRONIZE INSET */
	inset.draw(true,zoomLevel);
}

private function loadNewOrExistingDiagram():void
{
	//clear diagram
	clearBoardDrawings();
	//draw or remove dashed lines
//	if(mode == Constants.MODE_VIEW)
//		removeDashedLines();
//	else if(mode == Constants.MODE_EDIT)
//		addDashedLinesToBoard();
	//enable board
	enableBoard(true);
	//bind collections
	lines = Model.diagram.lines;
	shapes = new ShapeCollection();
	shapes.addCollection(Model.diagram.shapes);
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
	for(i=0;i<shapes.length();i++)
	{
		var s:CShape = shapes.getItemAt(i);
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
		//reset menu state
		menu.resetViewState();
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

}

private function collapseDiagram():void
{
	//set flag
	diagramCollapsed = true;
	//get current filters returns null for all or collection (can be empty) for some
	showDiagramInViewMode(true,diagramFilter.getCurrentFilters());
}

private function uncollapseDiagram():void
{
	//set flag
	diagramCollapsed = false;
	//get current filters returns null for all or collection (can be empty) for some
	showDiagramInViewMode(true,diagramFilter.getCurrentFilters());
}

private function shrinkDiagram():void
{
	//set flag
	diagramShrinked = true;
	//get current filters returns null for all or collection (can be empty) for some
	showDiagramInViewMode(true,diagramFilter.getCurrentFilters());
}

private function expandDiagram():void
{
	//set flag
	diagramShrinked = false;
	//get current filters returns null for all or collection (can be empty) for some
	showDiagramInViewMode(true,diagramFilter.getCurrentFilters());
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
	//fields 
	var needsSeparator:Boolean = false;
	
	
	//POPULATE PARENT'S LIST//
	//create lists for parents
	var ls:ArrayCollection = ArrayCollectionUtil.copyArrayCollection(Model.diagram.shapes);
	var mls:ArrayCollection = new ArrayCollection();
	
	//remove the current shape from the list
	if(!newShape)
		ls.removeItemAt(ls.getItemIndex(shape));
	//add most recently added shape to the list head	
	if(mostRecentlyAddedShape!=null&&mostRecentlyAddedShape!=shape)
	{
		if(ls.contains(mostRecentlyAddedShape))
		{
			ls.removeItemAt(ls.getItemIndex(mostRecentlyAddedShape));
			mls.addItemAt(mostRecentlyAddedShape,0);
			needsSeparator = true;
		}
	}
	//add most recently selected shape to the list head	
	if(mostRecentlySelectedShape!=null&&mostRecentlySelectedShape!=shape)
	{ 
	    if(ls.contains(mostRecentlySelectedShape))
	    {
		    ls.removeItemAt(ls.getItemIndex(mostRecentlySelectedShape));
			mls.addItemAt(mostRecentlySelectedShape,0);
			needsSeparator = true;
	    }
	}
	
	//add an empty record for the first shape and prepend to list and a separator
	var ns:CShape = new CShape();
	ns.label = "";
	mls.addItemAt(ns,0);
	
	if(needsSeparator&&ls.length>0)
	{
		var ns2:CShape = new CShape();
		ns2.label = "--------------";
		mls.addItem(ns2);
	}
	
	//sort the other part of list and copy to the modified list
	var sls:Array = ls.toArray().sortOn("label");
	for(var i:int=0;i<sls.length;i++)
		mls.addItem(sls[i]);
	
	//assign data provider
	shapePopUpPanel.sparent2.dataProvider = mls;
	//END OF POPULATE PARENT'S LIST//
	
	//populate lists
	shapePopUpPanel.sdiagram.dataProvider = Model.diagramFilters;
	shapePopUpPanel.sdiagram.labelField = "code";

	shapePopUpPanel.ssymbol.dataProvider = Constants.SYMBOLS;
	
	//set label, parent, diagram filters, symbol
	if(!newShape){
		shapePopUpPanel.slabel.text = shape.label;
		shapePopUpPanel.sparent2.selectedItem = shape.parentShape;
		shapePopUpPanel.sdiagram.selectedItems = selectDiagramFilters(shape);
		shapePopUpPanel.ssymbol.selectedItem = selectSymbol(shape);
	}
	
	//add event listener's for buttons	
	shapePopUpPanel.save.addEventListener(MouseEvent.CLICK,saveAttributes);
	shapePopUpPanel.cancel.addEventListener(MouseEvent.CLICK,cancelAttributes);
	shapePopUpPanel.addEventListener(CloseEvent.CLOSE,handleCloseAttributes);
	if(!newShape)
		shapePopUpPanel.viewlnk.addEventListener(MouseEvent.CLICK,viewLinkagesForShape);
	
	//disable view linkages button on new shapes
	//shapePopUpPanel.cancel.visible = !newShape;
	shapePopUpPanel.viewlnk.visible = !newShape;
	
	//save most recently selected shape
//	if(!newShape)
//		mostRecentlySelectedShape = shape;
}




private function selectDiagramFilters(shape:CShape):Array
{
	var selFilters:ArrayCollection = new ArrayCollection();
	var shapeAttr:ShapeAttribute = shape.getAttribute(Constants.SHAPE_ATTR_TYPE_DIAGRAM);
	for(var i:int=0;i<shapeAttr.values.length;i++)	
	{
		for(var j:int=0;j<Model.diagramFilters.length;j++)
		{
			if(shapeAttr.values[i] == Model.diagramFilters[j].id)
			{
				selFilters.addItem(Model.diagramFilters[j]);
			
			}
		}
	}
	return selFilters.toArray();
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

private function saveAttributes(evt:MouseEvent):void
{
	//validate errors 
	var valArray:Array = new Array();
	valArray.push(shapePopUpPanel.valSLabel);
	var validatorErrorArray:Array = Validator.validateAll(valArray);
	//don't update shape if there are errors
	if(validatorErrorArray.length == 0)
	{
		//if there is a new shape
		//then create one and add it 
		//to the board
		if(newShape)
		{
				//create shape
				var s:CShape = createDefaultShape(newShapeLocation,shapeType,shapePopUpPanel.slabel.text);
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
				//save most recently added shape
				mostRecentlyAddedShape = s;
		}
		
		/* UPDATE THE PARENT */
		//get the parent shape
		var pshape:CShape = shapePopUpPanel.sparent2.selectedItem as CShape;
		//if the user chooses the blank entry
		//set the parent shape to null
		if(pshape!=null && (pshape.label == ""||pshape.label=="--------------"))
			pshape = null;
		//update the old parent's children (if there was one)
		if(shape.parentShape != null && shape.parentShape != pshape)
			shape.parentShape.removeChildShape(shape);
		//update the current parent's children (if it is different from the last selection)
		if(pshape != null && shape.parentShape != pshape)
			pshape.addChildShape(shape);
		
		//save the most recently selected shape
		if(pshape != null)
			mostRecentlySelectedShape = pshape;
			
		/* UPDATE SYMBOL */
		shape.labelSymbolType = (shapePopUpPanel.ssymbol.selectedItem!=null&&shapePopUpPanel.ssymbol.selectedItem.value!=0)?shapePopUpPanel.ssymbol.selectedItem.value:undefined;
		
		/* UPDATE ATTRIBUTES - parent and label */
		//update the shapes attributes
		shape.updateAttributes(shapePopUpPanel.slabel.text,pshape);
		
		/* UPDATE THE DIAGRAM FILTERS */
		shape.clearAttributes();
		for(var i:int=0;i<shapePopUpPanel.sdiagram.selectedItems.length;i++)
		{
			var value:Number = shapePopUpPanel.sdiagram.selectedItems[i].id;
			shape.addAttribute(Constants.SHAPE_ATTR_TYPE_DIAGRAM, value);
		}
		
		//remove pop up
		removePopUp();
	}
   			
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
		for(i=0;i<shapes.length();i++)
		{
			var s:CShape = shapes.getItemAt(i);
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
private function enableBoard(enable:Boolean):void
{
	//enable or disable controls
	board.enabled = enable;
	boardControl.enabled = enable;
    inset.enabled = enable;
	accordion.enabled = enable;
}

/* This function clears the state of board (whatever you were doing on the board) */
private function resetBoardState():void
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
	
	diagramCollapsed = false;
	diagramShrinked = false;
		
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
   	var length = Model.BOARD_HEIGHT/Constants.TIER_HEIGHT;
   	for(var i:int=1;i<length;i++)
   	{
//   		if(i%Constants.NUMBER_OF_SUB_TIERS!=0)
//   		{
//   			//set the line style
   			g.lineStyle(1,0x787878,0.9);
//   		}
//   		else
//   		{
   			//set the line style
//   			g.lineStyle(1,0x000000,1);
//   		}
   		
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
	for(var i:int=0;i<shapes.length();i++)
	{
		var s:CShape = shapes.getItemAt(i);
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
	for(var i:int=0;i<shapes.length();i++)
	{
		var s:CShape = shapes.getItemAt(i);
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

private function createDefaultShape(origin:CPoint,shapeType:String,label:String):CShape
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
		s.initNew();
		//center origin
		origin.x -= s.cwidth/2;
		origin.y -= s.cheight/2;
		//return shape
		return s;
}

private function createDefaultLine(startPoint:CPoint):CLine
{
		//create a new line
		var cl:CLine = new CLine();
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
		for(var i:int=0;i<shapes.length();i++)
		{
			var s:CShape = shapes.getItemAt(i);
			//IMPORTANT: COPY THE OLD VALUES BACK IF THIS IS
			//A PREVIOUS DIAGRAM THAT WAS LOADED IN VIEW MODE
			if(previousDiagram)
			{
				//copy old values back
				s.origin.x = s.oldOrigin.x;
				s.origin.y = s.oldOrigin.y;
				s.color = s.oldColor;
				//reset state
				s.filtered = false;
				s.hidden = false;
				s.collapsed = false;
				s.highlighted = false;
				s.clicked = false;
			}
			//move to old position
			s.move(0,0);
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
		//STEP 1 - uncollapse diagram (if it was collapsed)
		//this method checks for shapes that were collapsed
		undoCollapseDiagram();
		
		//STEP 2 - set flags for shapes and store the old values
		for(var i:int=0;i<shapes.length();i++)
		{
			var s:CShape = shapes.getItemAt(i);
			//IMPORTANT: DO NOT UPDATE THE OLD VALUES UNLESS THIS IS NOT THE
			//PREVIOUS DIAGRAM THAT WAS LOADED IN VIEW MODE
			if(!previousDiagram)
			{
				//save the old values back
				s.oldOrigin.x = s.origin.x;
				s.oldOrigin.y = s.origin.y;
				s.oldColor = s.color;
			}
			//set the filtered flag
			//NOTE: if filters == null every shape is part of the diagram (filtered = true)
			//otherwise check whether the shape is part of the diagram filters
			if(filters==null)
			{
				s.filtered = true;
			}
			else
			{
				s.filtered = isShapeFiltered(s,filters);
			}
			
			//if a shape has been FILTERED display it 
			//otherwise clear it from the board
			//NOTE: if the you are loading a new diagram
			//you need to set the flags accordintly. If it is 
			//a previous diagram DON'T do anything 
			//in order to preserve state
			if(s.filtered&&!previousDiagram)
			{
				//check whether or not the shape is a child 
				//if so set the hidden flag to true
				if(s.parentShape==null)
				{
					//set the collapsed flag
					s.collapsed = true;
					//set hidden to false
					s.hidden = false;
				}
				else
				{
					//set the collapsed flag
					s.collapsed = true;
					//set hidden to false
					s.hidden = true;
				}
			}
		}
	
		//STEP 3 - collapse diagram
		if(diagramShrinked)
			collapseDiagramHorizontally();
		if(diagramCollapsed)
			collapseDiagramVertically();

		//STEP 4 - draw lines
		if(diagramShrinked||diagramCollapsed)
			hideLinesInViewMode();
		else	
			showLinesInViewMode();
		
		//STEP 5 - draw the shapes in view
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
/* END OF UI (MODE SWITCH) UTILITY FUNCTIONS */


/* START OF UI (VIEW MODE) UTILITY FUNCTIONS */
//utility method to draw in view mode
private function drawShapesInViewMode():void
{
	for(var i:int=0;i<shapes.length();i++)
	{
		var s:CShape = shapes.getItemAt(i);
		//process only filtered shapes and non-hidden shapes
		if(s.filtered&&!s.hidden)
			s.drawForView(s.collapsed);

		else
			s.clear();
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
			var l:CLine = lines[i];
			var fc:CConnector = l.firstConnector;
			var lc:CConnector = l.lastConnector;
			//depending on the case do something
			if(fc!=null&&lc!=null)
			{
				var fs:CShape = fc.shape;
				var ls:CShape = lc.shape;
				//draw the line if both the shapes
				//have been filtered and are not hidden
				if(fs.filtered&&!fs.hidden&&ls.filtered&&!ls.hidden)
					l.draw(false);
				else
					l.clear();
			}
			else if(fc!=null)
			{
				var fs:CShape = fc.shape;
				//draw the line if the first shape
				//is filtered and are not hidden
				if(fs.filtered&&!fs.hidden)
					l.draw(false);
				else
					l.clear();
			}
			else if(lc!=null)
			{
				var ls:CShape = lc.shape;
				//draw the line if the last shape
				//is filtered and are not hidden
				if(ls.filtered&&!ls.hidden)
					l.draw(false);
				else
					l.clear();
			}
			else
			{
				//otherwise don't draw the line
				l.draw(false);
			}
		}
	}
}

//utility method to determine whether a shape has been filtered or not
//if a shape has been filtered, it means that its attributes are not
private function isShapeFiltered(s:CShape,filters:ArrayCollection):Boolean
{
	var sa:ShapeAttribute = s.getAttribute(Constants.SHAPE_ATTR_TYPE_DIAGRAM);
	for(var i:int=0;i<sa.values.length;i++)
	{
		for(var j:int=0;j<filters.length;j++)
		{
			//compare the attribute's value of the shape ( value = diagram filter id [Number]) 
			//with the filters' id ( filters = Model's diagram filters [LookupValue])
			if(sa.values[i] == filters[j].id)
				return true;
		}
	}
	return false;
}

//utility function to collapse the diagram horizontally
private function collapseDiagramHorizontally():void
{

	//init horizontal offset and empty bins
	var hrzOffset:Array = new Array();
	//var numOfBins:int = Constants.NUMBER_OF_SUB_TIERS*Constants.NUMBER_OF_TIERS;
	var numOfBins:int = Model.BOARD_HEIGHT/Constants.TIER_HEIGHT;
	for(var i:int=0;i<numOfBins;i++)
	{
		hrzOffset[i]=0;
	}
	
	/* STEP 1 - calculate the horizontal offset (collapsed on the left) */
	//loop through the shapes
	for(var i:int=0;i<shapes.length();i++)
	{
		var s:CShape = shapes.getItemAt(i);
		//ignore non-filtered shapes
		if(s.filtered)
		{
			//reposition shape by stacking together shapes
			s.origin.x = hrzOffset[s.binIndex];
			//update offset
			hrzOffset[s.binIndex]+=s.cwidth+Constants.COLLAPSE_HORIZONTAL_GAP;
		}
		
	}
	
	/* STEP 2 - find deltaX to center collapsed diagram  */
	//get the max hrz offset
	var maxValue:int = ArrayUtil.findMaxValue(hrzOffset);
	//calculate the delta x to move the shapes hrz
	var deltaX:int = int((board.width-maxValue)/2);
	
	/* STEP 3 - center shapes */
	//relocate shapes after calculating the delta
	for(var i:int=0;i<shapes.length();i++)
	{
		var s:CShape = shapes.getItemAt(i);
		//ignore non-filtered shapes
		if(s.filtered)
		{
			//shift shapes horizontally
			s.origin.x += deltaX;
			s.move(0,0);
		}
	}
	
	//OTHER
	//clear fields
	hrzOffset = null;

}

//utility function to collapse the diagram vertically
private function collapseDiagramVertically():void
{
	//init empty bins
	var emptyBins:Array = new Array();
	//var numOfBins:int = Constants.NUMBER_OF_SUB_TIERS*Constants.NUMBER_OF_TIERS;
	var numOfBins:int = Model.BOARD_HEIGHT/Constants.TIER_HEIGHT;
	for(var i:int=0;i<numOfBins;i++)
	{
		emptyBins[i]=true;
	}
	
	/* STEP 1 - check for empty bins */
	//loop through the shapes
	for(var i:int=0;i<shapes.length();i++)
	{
		var s:CShape = shapes.getItemAt(i);
		//ignore non-filtered shapes
		if(s.filtered)
		{
			//update the empty bins if shape is not hidden
			if(!s.hidden)
			{
				emptyBins[s.binIndex]=false;
			}
		}
		
	}
	
	/* STEP 2 - collapse empty bins */
	//relocate shapes after calculating the delta
	var prevBinIndex:int = -1;
	var deltaY:int = 0;
	var verGap:int = Model.BOARD_HEIGHT / numOfBins;
	for(var i:int=0;i<shapes.length();i++)
	{
		var s:CShape = shapes.getItemAt(i);
		//ignore non-filtered shapes
		if(s.filtered)
		{
			//if you are moving to a new bin
			//calculate the new deltaY
			if(prevBinIndex != s.binIndex)
			{
				//add to the deltaY every time
				//you find an empty bin
				deltaY = 0;
				var startIndex:int = prevBinIndex!=-1?0:prevBinIndex+1;
				for(var m:int=startIndex;m<s.binIndex;m++)
				{
					if(emptyBins[m]==true)
						deltaY -= verGap;
				}
				//update prev bin
				prevBinIndex = s.binIndex;
			}
			//shift shapes vertically
			s.origin.y += deltaY;
			s.move(0,0);
		}
	}
	
	//OTHER
	//clear fields
	emptyBins = null;

}
//utility method to undo collapse (horizontal and vertical on a diagram)
private function undoCollapseDiagram():void
{
	//loop through the shapes
	for(var i:int=0;i<shapes.length();i++)
	{
		var s:CShape = shapes.getItemAt(i);
		//reposition filtered shapes
		if(s.filtered)
		{
			s.origin.x = s.oldOrigin.x;
			s.origin.y = s.oldOrigin.y;
			s.move(0,0);
		}	
	}
}

private function showChildShapes(s:CShape):void
{
	//uncollapse diagram
	undoCollapseDiagram();
	//show children - set hidden to false for all children recursively
	showChildren(s);
	//collapse diagram
	if(diagramShrinked)
		collapseDiagramHorizontally();
	if(diagramCollapsed)
		collapseDiagramVertically();
	// draw lines
	if(diagramShrinked||diagramCollapsed)
		hideLinesInViewMode();
	else	
		showLinesInViewMode();
	//draw all shapes in view mode
	drawShapesInViewMode();
}

private function showChildren(s:CShape):void
{      		
	//show children
	for(var i:int=0;i<s.childShapes.length;i++)
	{
		var cs:CShape = s.childShapes[i];
		//set hidden to false
		cs.hidden = false;
		//check if you need to draw
		//children (shape is un-collapsed)
		if(!cs.collapsed)
			showChildren(cs);
	}
}

private function hideChildShapes(s:CShape):void
{
	//uncollapse diagram
	undoCollapseDiagram();
	//show children - set hidden to false for all children recursively
	hideChildren(s);
	//collapse diagram
	if(diagramShrinked)
		collapseDiagramHorizontally();
	if(diagramCollapsed)
		collapseDiagramVertically();
	// draw lines
	if(diagramShrinked||diagramCollapsed)
		hideLinesInViewMode();
	else	
		showLinesInViewMode();
	//draw all shapes in view mode
	drawShapesInViewMode();
}

private function hideChildren(s:CShape):void
{
	//hide children
	for(var i:int=0;i<s.childShapes.length;i++)
	{
		var cs:CShape = s.childShapes[i];
		//set hidden to true
		cs.hidden = true;
		//hide children recursively
		hideChildren(cs);
	}
}

//this function adds a shape to clicked shapes
private function addToClickedShapes(s:CShape):void
{
	s.clicked = true;
	s.highlighted = false;
	s.color = Constants.VIEW_CLICK_COLOR;
	s.drawForView(s.collapsed);
	clickedShapes.addItem(s);
}

//this function removes a clicked shape from the list
private function removeFromClickedShapes(s:CShape):void
{
	if(clickedShapes.contains(s))
	{
		clickedShapes.removeItemAt(clickedShapes.getItemIndex(s));
		s.highlighted = false;
		s.clicked = false;
		s.color = s.oldColor;
		s.drawForView(s.collapsed);
	}
}

//this function highlights linked shapes
private function highlightLinkedShapes(s:CShape):void
{
	var linkages:ArrayCollection = s.linkages;
	for(var i:int=0;i<linkages.length;i++)
	{
		var l:Linkage = linkages[i];
		//consider only filtered shapes
		//do not highlight shapes that have been clicked
		if(l.shape.filtered && !l.shape.clicked)
		{
			//if a shape is hidden highlight the shape
			//otherwise highlight the parent
			if(!l.shape.hidden)
			{
				l.shape.clicked = false;
				l.shape.highlighted = true;
				l.shape.color = Constants.VIEW_HIGHLIGHT_COLOR;
				l.shape.drawForView(l.shape.collapsed);
			}
			else
			{
				//highlight parent if child is hidden
				var parent:CShape = l.shape.parentShape;
				if(parent!=null)
				{
					parent.clicked = false;
					parent.highlighted = true;
					parent.color = Constants.VIEW_HIGHLIGHT_COLOR;
					parent.drawForView(parent.collapsed);
				}
			}
		}
	}
}


//this function resets highlighted shapes and clicked shapes (if excludeClicked == false)
private function resetHighlightedAndClickedShapes(excludeClicked:Boolean):void
{
	for(var i:int=0;i<shapes.length();i++)
	{
		var s:CShape = shapes.getItemAt(i);
		//consider only filtered shapes
		//restore flags and color
		if(s.filtered)
		{
			if(s.highlighted)
			{
				s.highlighted = false;
				s.clicked = false;
				s.color = s.oldColor;
				if(!s.hidden)
					s.drawForView(s.collapsed);
			
			}
			else if(s.clicked&&!excludeClicked)
			{
				s.highlighted = false;
				s.clicked = false;
				s.color = s.oldColor;
				if(!s.hidden)
					s.drawForView(s.collapsed);
			}
		}
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
	for(var i:int=0;i<shapes.length();i++)
	{
		var s:CShape = shapes.getItemAt(i);
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
	newLnkPopUpPanel = new  NewLinkagePopUp();
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
	//add listeners
	newLnkPopUpPanel.saveb.addEventListener(MouseEvent.CLICK,saveNewLinkage);
	newLnkPopUpPanel.cancelb.addEventListener(MouseEvent.CLICK,cancelNewLinkage);
	newLnkPopUpPanel.addEventListener(CloseEvent.CLOSE,closeNewLinkage);
	//set value for shapes
	newLnkPopUpPanel.shapes.dataProvider = newLinkageShapes;
	//modify the label of the primary option
	newLnkPopUpPanel.primary.label += " ("+newLinkageShapes[0].label+") pairs";
}

private function saveNewLinkage(event:MouseEvent):void
{
	//get the linkage type
	var type:String = newLnkPopUpPanel.type.selection;
	
	//find the selected references
	var selCits:ArrayCollection = newLnkPopUpPanel.selcitations.dataProvider;
	
	//check if the user has selected a type
	if(type == null)
	{
		//show error message
		Alert.show("Please select a linkage type.", "INFORMATION", Alert.OK, null, null, null, Alert.OK);
		return;
	}
	
	//check if the user has selected any citations at all
	if(selCits.length == 0)
	{
		//show error message
		Alert.show("Please select at least one reference when creating a linkage.", "INFORMATION", Alert.OK, null, null, null, Alert.OK);
		return;
	}
	
	if(type == newLnkPopUpPanel.pairwise)
		createPairwiseLinkages(selCits);
	else if(type == newLnkPopUpPanel.primary)
		createPrimaryLinkages(selCits);
	
	removeNewLnkPopUp();
}

private function createPairwiseLinkages(selCits:ArrayCollection):void
{
	//update linkages for the shape
	//IMPORTANT: avoid adding a linkage to itself
	for(var i:int=0;i<newLinkageShapes.length;i++)
	{
		var s:CShape = newLinkageShapes[i];
		//link the shape to other shapes
		for(var m:int=0;m<newLinkageShapes.length;m++)
		{
			if(i!=m)
			{
				s.addLinkage(newLinkageShapes[m],selCits);
			}
		}
//		//link the parent of the shape to the other shapes
//		//recursing upwards
//		var parent:CShape = s.parentShape
//		while(parent!=null)
//		{
//			for(var n:int=0;n<newLinkageShapes.length;n++)
//			{
//				if(i!=n)
//				{
//					parent.addLinkage(newLinkageShapes[n],selCits);
//					newLinkageShapes[n].addLinkage(parent,selCits);
//				}
//			}
//			parent = parent.parentShape;
//		}
	}
}

private function createPrimaryLinkages(selCits:ArrayCollection):void
{
	//get the primary shape
	var pShape:CShape = newLinkageShapes[0];
	//create linkages
	for(var m:int=1;m<newLinkageShapes.length;m++)
	{
		var s:CShape = newLinkageShapes[m];
		//link the primary shape to other shape
		pShape.addLinkage(s,selCits);
		//link the other shape to the primary shape
		s.addLinkage(pShape,selCits);
		
//		//link to the parents of the primary shape
//		var parent:CShape = pShape.parentShape;
//	    Code for linking parents recursively upwards
//		while(parent!=null)
//		{
//			parent.addLinkage(s,selCits);
//			s.addLinkage(parent,selCits);
//			//get the next parent
//			parent = parent.parentShape;
//		}
//		//link to the parents of the other shape
//		parent = s.parentShape;
//	    Code for linking parents recursively upwards
//		while(parent!=null)
//		{
//			parent.addLinkage(pShape,selCits);
//			pShape.addLinkage(parent,selCits);
//			//get the next parent
//			parent = parent.parentShape;
//		}
	}

}

private function cancelNewLinkage(event:MouseEvent):void
{
	removeNewLnkPopUp();
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
	resetBoardState();
	//clear shape selection
	selectAllShapes(false);
	//hide pop up
	PopUpManager.removePopUp(newLnkPopUpPanel);
	newLnkPopUpPanel = null;
	//set focus to the main board
	this.setFocus();
}
/* END OF CREATING A NEW LINKAGE */


