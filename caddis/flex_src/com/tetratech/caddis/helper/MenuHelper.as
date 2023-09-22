import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.drawing.CDiagram;
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
import com.tetratech.caddis.event.InsetToggleEvent;
import com.tetratech.caddis.event.MenuItemClickEvent;
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.view.DrawingBoard;
import com.tetratech.caddis.view.LoadDiagramPopUp;
import com.tetratech.caddis.view.Menu;
import com.tetratech.caddis.view.NewDiagramPopUp;
import com.tetratech.caddis.view.SaveDiagramAsPopUp;
import com.tetratech.caddis.vo.LookupValue;
import com.tetratech.caddis.vo.Term;
import com.tetratech.caddis.vo.User;

import flash.display.Shape;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.containers.Box;
import mx.containers.VBox;
import mx.controls.Alert;
import mx.controls.ComboBox;
import mx.controls.Label;
import mx.controls.List;
import mx.controls.Menu;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.core.Application;
import mx.events.CloseEvent;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.ItemClickEvent;
import mx.events.ListEvent;
import mx.events.MenuEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.utils.StringUtil;
import mx.validators.Validator;

//pop up pointer to panel
private var ppPanel;
private var editActionOptionPanel;
private var legendType:Number;
private var shapeColor:Number;
//state for selecting shapes (EDIT MODE)
private var selectingShapes:Boolean = false;
//state for copying (EDIT MODE)
private var startedCopying:Boolean = false;
//state for new linkage (EDIT MODE)
private var startNewLinkage:Boolean = true;
//state for alignment (EDIT MODE)
private var startedAligningShapes:Boolean = false;
//flag for whether or not you have loaded
//a new or existing diagram
private var newOrExistingDiagramLoaded:Boolean = false;
//function pointer
private var currentAction:Function = null;
private var visitedEditMode:Boolean = false;
//last label mouse over
private var lastLabelMouseOver:Label = null;
//flag for warning msg displayed
private var warningDisplayed:Boolean = false;
//flag for save as (this is need to display a message)
private var displayLoadMessage:Boolean = true;
//pointer to tab navigator
private var tabNav:TabNavigator = null;
//pointer to board
private var board:DrawingBoard = null;

//for hide/show lines in editMode
private var hideLines:Boolean = false;

//Enabled only when locked or in draft status
private var enableSave:Boolean = false;

//all users in the system
private var allUsers:ArrayCollection;
private var allStdTerms:ArrayCollection;
private var showLogin:Boolean = true;
private var selectedTerms:ArrayCollection;

private function init():void
{
	//bind to tab navigator(tab navigator is the wrapper now)
	tabNav = this.parent.getChildByName("tabNav") as TabNavigator;
	//menu = this.parent.parent.getChildByName("menu") as Menu;
	checkRequestOrigin();
	getConfiguration();
	stack.selectedChild = homeMode;
}

private function checkRequestOrigin():void
{
	var sessionID:String;
	var params:Dictionary = new Dictionary();
	params = getUrlParamaters();
	if(params != null)
	{
		for(var i:int=0; i<params.length; i++)
			{
				trace(params[i]);
			}
	}
	if(params != null && params[String("sessionID")] != null)
		sessionID = params[String("sessionID")];
	if(sessionID != null) {
		var s:Service = new Service();
		s.serviceHandler = handleCheckIfAuthenticatedResponse;
		s.checkIfAuthenticated(sessionID);
	}
}

private function handleCheckIfAuthenticatedResponse(event:ResultEvent):void
{
	var user:User = event.result as User;
	if(user != null) {
		Model.user = user;
	//	resetLoginButton();
	} 
}

/**
 * This method retrieves the URL parameters from the request.
 **/
private function getUrlParamaters():Dictionary
{
	var urlParams:Dictionary = new Dictionary();

	if (ExternalInterface.available)
	{
		var fullUrl:String = ExternalInterface.call('eval', 'document.location.href');
		var paramStr:String = fullUrl.split('?')[1];
		if (paramStr != null)
		{
			var params:Array = paramStr.split('&');
			for (var i:int=0; i < params.length; i++)
			{
				var kv:Array = params[i].split('=');
				urlParams[String(kv[0])] = kv[1];
			}
		}
	}
	else
	{
		urlParams = Application.application.parameters;
	}
	return urlParams;
}

private function getConfiguration():void
{
	var s:Service = new Service();
	s.serviceHandler = handleGetConfigurationResponse;
	s.getConfiguration();
}

private function handleGetConfigurationResponse(event:ResultEvent):void
{
	var config:ArrayCollection = event.result as ArrayCollection;
	for(var i:int = 0; i < config.length; i++)
	{
		var lk:LookupValue = config.getItemAt(i) as LookupValue;
		if(lk.code == Constants.ICD_USER_GUIDE)
			Model.icdUserGuideUrl = lk.desc;
	}
}
/*
private function initHomeHandlers():void
{
	loginb.addEventListener(MouseEvent.CLICK, handleLoginPopUpCreation);
	loginb.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	loginb.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
} */
private function initViewHandlers():void
{
	//bind to tab navigator(tab navigator is the wrapper now)
	var wrapper:VBox = this.parent.getChildByName("drawingBoardP") as VBox;
	//var wrapper:VBox = this.parent.getChildAt(2) as VBox;
	board = wrapper.getChildByName("drawingBoard") as DrawingBoard;
	
	//register event handlers
	inset.addEventListener(MouseEvent.CLICK,handleInsetToggle);
	accordion.addEventListener(MouseEvent.CLICK,handleAccordionToggle);
	vinfo.addEventListener(MouseEvent.CLICK, displayViewHelp);
	//load.addEventListener(MouseEvent.CLICK,handleLoad);
//	download.addEventListener(MouseEvent.CLICK,handleDownload);
	resetb.addEventListener(MouseEvent.CLICK, handleReset);
	searchrefs.addEventListener(MouseEvent.CLICK, handleSearchCitations);
//	loginb.addEventListener(MouseEvent.CLICK, handleLoginPopUpCreation);
	legend.addEventListener(MouseEvent.CLICK, handleLegendCreation);

//	load.addEventListener(MouseEvent.MOUSE_OVER,handleLabelMouseOver);
	//download.addEventListener(MouseEvent.MOUSE_OVER,handleLabelMouseOver);
	resetb.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	//register.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	//loginb.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	legend.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);

//	load.addEventListener(MouseEvent.MOUSE_OUT,handleLabelMouseOut);
	//download.addEventListener(MouseEvent.MOUSE_OUT,handleLabelMouseOut);
	resetb.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
	//register.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
	//loginb.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
	legend.addEventListener(MouseEvent.MOUSE_OUT,handleLabelMouseOut);
	
	reviewLink.addEventListener(MouseEvent.CLICK, handleDownloadReviewLinkage);
	reviewLink.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	reviewLink.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
	
	enableViewControls(newOrExistingDiagramLoaded);
}

private function initEditHandlers():void
{ 
	//bind to tab navigator(tab navigator is the wrapper now)
	var wrapper:VBox = this.parent.getChildByName("drawingBoardP") as VBox;
	//var wrapper:VBox = this.parent.getChildAt(2) as VBox;
	board = wrapper.getChildByName("drawingBoard") as DrawingBoard;
	//register event handlers
	
	selectedTerm.addEventListener(MouseEvent.CLICK,handleStandarditemsWithSelected);
	//inset2.addEventListener(MouseEvent.CLICK,handleInsetToggle);
	//einfo.addEventListener(MouseEvent.CLICK, displayEditHelp);
	
	//new menu
	//diagramMenu.visible = false;
	//diagramAction.addEventListener(MouseEvent.CLICK, displaySubMenu);
	
	//uploadRefs.addEventListener(MouseEvent.CLICK,handleUploadReferences);
	/*
	humact.addEventListener(MouseEvent.CLICK,handleHumAct);
	stressor.addEventListener(MouseEvent.CLICK,handleStressor);
	addstep.addEventListener(MouseEvent.CLICK,handleAddStep);
	modfactor.addEventListener(MouseEvent.CLICK,handleModFactor);
	modeaction.addEventListener(MouseEvent.CLICK,handleModAction);
	source.addEventListener(MouseEvent.CLICK,handleSource);
	bioresp.addEventListener(MouseEvent.CLICK,handleBioResp);
    aline.addEventListener(MouseEvent.CLICK,handleArrowLine);
    line.addEventListener(MouseEvent.CLICK,handleLine);
    hlines.addEventListener(MouseEvent.CLICK, handleHideLines);
    */
    //register event handlers
    select.addEventListener(MouseEvent.CLICK,handleSelect);
    clone.addEventListener(MouseEvent.CLICK,handleClone);
/*    addlinkage.addEventListener(MouseEvent.CLICK,handleAddLinkage);*/
	editIcon.addEventListener(MouseEvent.CLICK, handleReviewLinkage);
    align.addEventListener(MouseEvent.CLICK, handleAlignShapes);
    viewComments.addEventListener(MouseEvent.CLICK, handleViewInternalComments);
//	save.addEventListener(MouseEvent.CLICK,handleSave);
//	saveas.addEventListener(MouseEvent.CLICK,handleSaveAs);
//	load2.addEventListener(MouseEvent.CLICK, handleEditHome);
//	close.addEventListener(MouseEvent.CLICK,handleClose);
//	saveAsImage.addEventListener(MouseEvent.CLICK,handleSaveAsImage);
	
selectedTerm.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
//	saveas.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
//	saveAsImage.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
//	load2.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
//	close.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	select.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	clone.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
//	addlinkage.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
//	reviewlinkage.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	align.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	//hlines.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	

selectedTerm.addEventListener(MouseEvent.MOUSE_OUT,handleLabelMouseOut);
//	saveas.addEventListener(MouseEvent.MOUSE_OUT,handleLabelMouseOut);
//	saveAsImage.addEventListener(MouseEvent.MOUSE_OUT,handleLabelMouseOut);
//	load2.addEventListener(MouseEvent.MOUSE_OUT,handleLabelMouseOut);
//	close.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
	select.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
	clone.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
//	addlinkage.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
//	reviewlinkage.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
	align.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
	//hlines.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);

	legendEdit.addEventListener(MouseEvent.CLICK, handleLegendEditCreation);
    legendEdit.addEventListener(MouseEvent.MOUSE_OVER,handleLabelMouseOver); 
	legendEdit.addEventListener(MouseEvent.MOUSE_OUT,handleLabelMouseOut);
	//set the inset state
	//inset2.source = inset.source;

    enableEditControls(newOrExistingDiagramLoaded);   
}

private function diagramMenuHandler(event:MenuEvent):void  {
	
	
	if (event.item.@data == "save")
	{
		handleSave();
	}
	else if ( event.item.@data == "saveas")
	{
		handleSaveAs();
	}
	else if ( event.item.@data == "printAsImage")
	{
		handleSaveAsImage();
	}
	else if ( event.item.@data == "close")
	{
		handleClose();
	}
	else if ( event.item.@data == "open")
	{
		handleNewDiagramHome(null);
	}
	
}

private function viewDiagramMenuHandler(event:MenuEvent):void  {
	if ( event.item.@data == "open")
		{
			handleNewDiagramHome(null);
		}
	else if (Model.diagram != null )
	{
		if (event.item.@data == "save")
		{ 
				handleSave();
		}
		else if ( event.item.@data == "saveas")
		{
			handleSaveAs();
		}
		else if ( event.item.@data == "printAsImage")
		{
			handleSaveAsImage();
		}
		else if ( event.item.@data == "close")
		{
			Model.mode = Model.MODE_NONE;
			newOrExistingDiagramLoaded = false;
			broadcastMenuItemClick("close");
		}
		
	}
	
}

private function linkDiagramMenuHandler(event:MenuEvent):void  {
	
	
	if (event.item.@data == "save")
	{
		handleSave();
	}
	else if ( event.item.@data == "saveas")
	{
		handleSaveAs();
	}
	else if ( event.item.@data == "printAsImage")
	{
		handleSaveAsImage();
	}
	else if ( event.item.@data == "close")
	{
		handleClose();
	}
	else if ( event.item.@data == "open")
	{
		handleNewDiagramHome(null);
	}
	
}
private function diagramShapeMenuHandler(event:MenuEvent):void  {
	/*
	<menuitem label="Human Activity" icon="humanAct" data="humanAct"/>
	<menuitem label="Source" icon="source" data="source"/>
	<menuitem label="Stressor" icon="stressor" data="stressor"/>
	<menuitem label="Response" icon="resp" data="bioresp"/>
	<menuitem label="Modifying Factor" icon="modFac" data="modfactor"/>
	<menuitem label="Mode of Action" icon="modeAct" data="modeaction"/>
	<menuitem label="Additional Steps" icon="addStep" data="addstep"/>
	<menuitem label="Line" icon="line" data="line"/>
	<menuitem label="Arrow Line" icon="arrowline" data="aline"/>
	*/
	
	if (event.item.@data == "humanAct") 
	{
		handleHumAct(null);
	}  
	else if ( event.item.@data == "source")
	{
		handleSource(null);
	}
	else if ( event.item.@data == "stressor")
	{
		handleStressor(null);
	}
	else if ( event.item.@data == "bioresp")
	{
		handleBioResp(null);
	}
	else if ( event.item.@data == "modfactor")
	{
		handleModFactor(null);
	}
	else if ( event.item.@data == "modeaction")
	{
		handleModAction(null);
	}
	else if ( event.item.@data == "addstep")
	{
		handleAddStep(null);
	}
	else if ( event.item.@data == "line")
	{
		handleLine(null);
	}
	else if ( event.item.@data == "aline")
	{
		handleArrowLine(null);
	}
	
}

private function initLinkHandlers():void
{
	//bind to tab navigator(tab navigator is the wrapper now)
	var wrapper:VBox = this.parent.getChildByName("drawingBoardP") as VBox;
	//var wrapper:VBox = this.parent.getChildAt(2) as VBox;
	board = wrapper.getChildByName("drawingBoard") as DrawingBoard;
	addLink.text = "Add/Edit Evidence";
	addLink.toolTip = "Add/Edit Evidence";
	addLink.enabled = true;	
	//register event handlers
	//openLink.addEventListener(MouseEvent.CLICK,handleLoad);
	//closeLink.addEventListener(MouseEvent.CLICK,handleClose);
	legendLink.addEventListener(MouseEvent.CLICK, handleLegendLinkCreation);
	addLink.addEventListener(MouseEvent.CLICK,handleAddLinkage);
	//reviewLink.addEventListener(MouseEvent.CLICK, handleReviewLinkage);
	viewCommentsLink.addEventListener(MouseEvent.CLICK, handleViewInternalComments);
	
	//openLink.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	//closeLink.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	addLink.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	//reviewLink.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	legendLink.addEventListener(MouseEvent.MOUSE_OVER,handleLabelMouseOver);
	
	//openLink.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
	//closeLink.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
	addLink.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
	//reviewLink.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
	legendLink.addEventListener(MouseEvent.MOUSE_OUT,handleLabelMouseOut);
	
	enableLinkageControls(newOrExistingDiagramLoaded); 
}

private function initSearchHandlers():void
{
	
}
/* Utility function to change tab in the menu */
public function changeTab(selectedMode:String):void
{
	if(selectedMode == Constants.MODE_HOME)
	{
		stack.selectedChild = homeMode;
		
	}
	else if(selectedMode == Constants.MODE_VIEW)
	{
		stack.selectedChild = viewMode;
	}
	else if(selectedMode == Constants.MODE_EDIT)
	{
		stack.selectedChild = editMode;
		visitedEditMode = true;
	}
	else if(selectedMode ==Constants.MODE_LINK)
	{
		stack.selectedChild = linkMode;
	}
	else if(selectedMode ==Constants.MODE_SEARCH)
	{
		stack.selectedChild = searchMode;
	}


}

private function enableLinkageControls(enabled:Boolean):void
{
	
	//if (closeLink != null  ) 
	//{closeLink.enabled = = closeLink.mouseEnabled
	//	reviewLink.enabled  =
	viewCommentsLink.enabled = addLink.enabled =  enabled;
		
		//reviewLink.mouseEnabled = 
	viewCommentsLink.mouseEnabled = addLink.mouseEnabled = enabled;
	//}
}

/* ENABLE DISABLE CONTROLS */
private function enableViewControls(enabled:Boolean):void
{ 
	if(resetb!=null)
	{
		resetb.enabled =  enabled;
	
		resetb.mouseEnabled = enabled;
	
	/*var alpha:Number;download.enabled = download.mouseEnabled =
	if(enabled)
		alpha = 1;
	else
		alpha = 0.2;*/
	}
}

private function enableEditControls(enabled:Boolean):void
{
	//check if the buttons have been initialized
	/*
	if(save!=null)
	{	
		humact.enabled = stressor.enabled = addstep.enabled = modfactor.enabled = 
		modeaction.enabled =source.enabled = bioresp.enabled = line.enabled = aline.enabled
	    clone.enabled = close.enabled = save.enabled = saveAsImage.enabled =
	    saveas.enabled = align.enabled = select.enabled =  
	    viewComments.enabled = hlines.enabled = enabled;
		//addlinkage.mouseEnabled =  = addlinkage.enabled
		viewComments.mouseEnabled = select.mouseEnabled = clone.mouseEnabled = 
		close.mouseEnabled = save.mouseEnabled = saveas.mouseEnabled  = align.mouseEnabled =
		humact.mouseEnabled = stressor.mouseEnabled = addstep.mouseEnabled = modfactor.mouseEnabled = 
		modeaction.mouseEnabled =source.mouseEnabled = bioresp.mouseEnabled 
		= line.mouseEnabled = aline.mouseEnabled = hlines.mouseEnabled = enabled;

		
		//viewComments.visible = enabled;
		if(!enableSave) {
			save.enabled = false;
			save.mouseEnabled = false;
		}
		
		var alpha:Number;
		if(enabled)
			alpha = 1;
		else
			alpha = 0.2;
		
		humact.alpha = stressor.alpha = addstep.alpha = modfactor.alpha = 
		modeaction.alpha =source.alpha = bioresp.alpha = line.alpha =  aline.alpha = viewComments.alpha = alpha;
	}
	*/
	
}

public function enableControls(enabled:Boolean):void
{
	
	enableViewControls(enabled);
	enableEditControls(enabled);
	enableLinkageControls(enabled);
}

/* END */

/* RESET STATE */
/* utility function to reset the state of the menu */
public function resetEditState():void
{
	if(startedCopying)
	{
		clone.text = "Copy";
		clone.toolTip ="Copy Shape"
		startedCopying = false;
	}
	if(selectingShapes)
	{
		select.text = "Select";
		select.toolTip = "Select Shapes";
		selectingShapes = false;
	}
	if(startedAligningShapes)
	{
		align.text = "Align";
		align.toolTip = "Align Shapes";
		startedAligningShapes = false;
	}
	
	if(hideLines)
	{
		align.text = "Hide";
		align.toolTip = "Hide Lines";
		hideLines = false;
	}
	
	if(Model.diagram != null && 
	  ((Model.diagram.locked && Model.diagram.lockedUser.userId == Model.user.userId) 
		|| Model.diagram.id == 0))
		enableSave = true;
	else
		enableSave = false;
/*		
	if(save != null) {
		save.enabled = enableSave;
		save.mouseEnabled = enableSave;	
	}
*/
	if(Model.diagram == null)
		//handleEditHomeFnc();
		openEditActionOptionPopUp();
		
}

/* END */

/* NEW DIAGRAM */
private function handleNew(event:MouseEvent):void
{	
	//close Edithome/collobrate popup and then open new popup
	//PopUpManager.removePopUp(editActionOptionPanel);
	//editActionOptionPanel = null;
	//create pop up panel
	ppPanel = new NewDiagramPopUp();
	ppPanel.addEventListener(FlexEvent.INITIALIZE,handleNewDiagramPopUpCreation)
	//add to manager
	PopUpManager.addPopUp(ppPanel, this.parent, true);
	PopUpManager.centerPopUp(ppPanel);
	ppPanel.y = 100;
}

private function handleNewDiagramPopUpCreation(event:FlexEvent):void
{
	//add listeners
	ppPanel.createb.addEventListener(MouseEvent.CLICK,existsDiagramWithSameName);
	ppPanel.cancelb.addEventListener(MouseEvent.CLICK,cancel);
	ppPanel.addEventListener(CloseEvent.CLOSE,closePanel);
}


private function existsDiagramWithSameName(event:MouseEvent):void
{
	PopUpManager.removePopUp(editActionOptionPanel);
	editActionOptionPanel = null;
	this.setFocus();
	var s:Service = new Service();
	s.serviceHandler = handleDiagramNameCheck;
	s.existsDiagramWithName(ppPanel.dname.text);
	
}

private function handleDiagramNameCheck(event:ResultEvent):void
{
	var exists:Boolean = event.result as Boolean;
	if(exists)
	{
		var msg:String = "A diagram with the same name already exists. Please choose another diagram name.";
		Alert.show(msg,"INFORMATION",Alert.OK,null,null,null,Alert.OK);
	}
	else
	{
		board.clearBoardDrawings();
		var shapes:ArrayCollection = new ArrayCollection();
		
		if (selectedTerms != null &&  selectedTerms.length > 0 )
		{
			//TODO: lili;
			var i:int;
			var x:Number = 150;
			var y:Number = 30;
			var swidth:Number= 10;
			var oldLegendType:Number = 0;
			
			for(i= 0; i < selectedTerms.length; i++)
			{
				var obj:Term = selectedTerms.getItemAt(i) as Term;
				
				var ns:CShape = new CShape();
				
				var o:CPoint = new CPoint();
				o.x = x+CShape.MIN_WIDTH/2;
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
				
				o.y = y+CShape.MIN_HEIGHT/2;
				
				
				ns = createDefaultShape(o,obj.legendType,obj.term, obj.id);
				
				//add to board
				board.addChild(ns);
				//draw it
				ns.drawForEdit(false);
		
				y = y +   ns.height; //50 +
				x = x + ns.width;
				
				shapes.addItem(ns);
				oldLegendType = obj.legendType ;
			}
		
		}
		
		createNewDiagram(shapes);

	}	

}
/*Human activity -  round rect - ffe497
source - octagon - f3e895
stressor - rect - c6dde8
bio resp - oval - e2edf2
mod fac - round rect - edcbaf
add step - round rect - f9f4cf
mod act	- hexagon - f6f7f8*/

public function createDefaultShape(origin:CPoint,legendType:Number,label:String, termId:Number):CShape
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

private function createNewDiagram(shapes:ArrayCollection):void
{
	var valArray:Array = new Array();
	valArray.push(ppPanel.valDName);
	valArray.push(ppPanel.valDDesc);
	valArray.push(ppPanel.valDLoc);
	valArray.push(ppPanel.valDKeywords);
	var validatorErrorArray:Array = Validator.validateAll(valArray);
	if(validatorErrorArray.length == 0)
	{
		//update model
		Model.mode = Constants.MODE_EDIT;
		Model.BOARD_WIDTH = ppPanel.ddim.selectedItem.width;
		Model.BOARD_HEIGHT = ppPanel.ddim.selectedItem.height;
		Model.INITIAL_ZOOM_SCALE = Constants.DEFAULT_BOARD_WIDTH/Model.BOARD_WIDTH;
		Model.INSET_TO_BOARD_RATIO = Constants.INSET_WIDTH/Model.BOARD_WIDTH;
		//Model.DASHED_LINES_VERTICAL_GAP = Model.BOARD_HEIGHT / (Constants.NUMBER_OF_TIERS*Constants.NUMBER_OF_SUB_TIERS);
		Model.DASHED_LINES_VERTICAL_GAP = Constants.TIER_HEIGHT;
		//update the diagram
		Model.diagram = new CDiagram();
		Model.diagram.id = 0;
		Model.diagram.diagramStatusId = Constants.LL_DRAFT_STATUS;
		Model.diagram.name = ppPanel.dname.text;
		Model.diagram.description = ppPanel.ddesc.text;
		Model.diagram.location = ppPanel.dloc.text;
		Model.diagram.keywords = ppPanel.dkeywords.text;
		Model.diagram.color = 0xFFFFFF;
		Model.diagram.width = Model.BOARD_WIDTH;
		Model.diagram.height = Model.BOARD_HEIGHT;
		
		Model.diagram.diagramStatusId = Constants.LL_DRAFT_STATUS;
		Model.diagram.createdBy = Model.user.userId;
		Model.diagram.updatedBy = Model.user.userId;
		Model.diagram.createdDate = null;
		Model.diagram.goldSeal = false;
		Model.diagram.locked = false;
		Model.diagram.lockedUser = new User();
		Model.diagram.lockedUser.userId = Model.user.userId;
		Model.diagram.openToPublic = true;
		Model.diagram.shapes = shapes;
		enableSave=true;
		//broadcast message
		broadcastMenuItemClick("new");	
		PopUpManager.removePopUp(ppPanel);
		//enable controls
		enableControls(true);
		newOrExistingDiagramLoaded = true;
		//set focus 
		this.setFocus();
	}
	else
	{
		ppPanel.error.visible = true;
	}
}

/* END */
private function enableAll():void {
	//load2.enabled = true;
	//load2.mouseEnabled = true;
	tabNav.enabled=true;
	tabNav.mouseEnabled = true;
	
	enableEditControls(true);
	board.enableBoard(true);
}

private function disableAll():void {
	//load2.enabled = false;
	//load2.mouseEnabled = false;
	tabNav.enabled=false;
	tabNav.mouseEnabled = false;
	board.enableBoard(false);
	enableEditControls(false);
}

/* SAVE DIAGRAM */
private function handleSave():void
{
	var s:Service = new Service();
	s.serviceHandler = handleSaveDiagram;
	
	if (Model.user == null || Model.user.userId == 0)
	{
		Alert.show(" Can not save the Diagram to database. You must register and login first.", "INFORMATION", Alert.OK, null, handleSaveResponse, null, Alert.OK);
	}
	else {
		
	
		if(Model.diagram.id == 0)
		{
			Model.diagram.openToPublic = true;
			Model.diagram.createdBy = Model.user.userId;
			//lock the diagram as user may keeping saving the diagram once created. 
			Model.diagram.lockedUser =  new User();
			Model.diagram.lockedUser.userId = Model.user.userId;
		}
		else
			Model.diagram.updatedBy = Model.user.userId;
		s.saveDiagram(Model.diagram);
	
		disableAll();
		
		//change the mouse to a busy cursor
		CursorManager.setBusyCursor();
	}
}

private function handleSaveDiagram(event:ResultEvent):void
{
	Model.diagram.id = event.result as Number;
	//reset the orginialId in case revision diagram was saved to overwrite the existing diagram
	Model.diagram.orginialId = 0;

	//remove busy cursor
	CursorManager.removeBusyCursor();
	Alert.show("Diagram was successfully saved.", "INFORMATION", Alert.OK, null, handleSaveResponse, null, Alert.OK);
	enableAll();
}

private function handleSaveResponse(event:CloseEvent):void
{
	//check if a warning message was displayed
	if(warningDisplayed==true)
	{
		currentAction();
		warningDisplayed = false;		
	}
}
/* END */

/* SAVE DIAGRAM AS */
private function handleSaveAs():void
{
	if (Model.user == null || Model.user.userId == 0)
	{
		Alert.show("Can not save the Diagram to database. You must register and login first. ", "INFORMATION", Alert.OK, null, handleSaveResponse, null, Alert.OK);
	}
	else
		handleAction(handleSaveAsFnc);
}

private function handleSaveAsImage():void
{
	broadcastMenuItemClick("downloadDiagram");
}

private function handleSaveAsFnc():void
{
	//create pop up panel
	ppPanel = new SaveDiagramAsPopUp();
	ppPanel.addEventListener(FlexEvent.INITIALIZE,handleSaveDiagramAsPopUpCreation)
	//add to manager
	PopUpManager.addPopUp(ppPanel, this.parent, true);
	PopUpManager.centerPopUp(ppPanel);
	ppPanel.y = 100;
}

private function handleSaveDiagramAsPopUpCreation(event:FlexEvent):void
{
	//add listeners
	ppPanel.createb.addEventListener(MouseEvent.CLICK, existsDiagramWithSameName2);
	ppPanel.cancelb.addEventListener(MouseEvent.CLICK,cancel);
	ppPanel.addEventListener(CloseEvent.CLOSE,closePanel);
	ppPanel.dname.text = Model.diagram.name;
}

private function existsDiagramWithSameName2(event:MouseEvent):void
{
	var s:Service = new Service();
	s.serviceHandler = handleDiagramNameCheck2;
	s.existsDiagramWithName(ppPanel.dname.text);
}

private function handleDiagramNameCheck2(event:ResultEvent):void
{
	var exists:Boolean = event.result as Boolean;
	if(exists)
	{
		var msg:String = "A diagram with the same name already exists. Please choose another diagram name.";
		Alert.show(msg,"Information",Alert.OK,null,null,null,Alert.OK);
	}
	else
	{
		saveDiagramAs();
	}	

}

private function saveDiagramAs():void
{
	var valArray:Array = new Array();
	valArray.push(ppPanel.valDName);
	valArray.push(ppPanel.valDDesc);
	valArray.push(ppPanel.valDLoc);
	valArray.push(ppPanel.valDKeywords);
	var validatorErrorArray:Array = Validator.validateAll(valArray);
	if(validatorErrorArray.length == 0)
	{	
		//UPDATE THE MODEL
		//update diagram's name
		Model.diagram.name = ppPanel.dname.text;
		Model.diagram.description = ppPanel.ddesc.text;
		Model.diagram.location = ppPanel.dloc.text;
		Model.diagram.keywords = ppPanel.dkeywords.text;
		//update the diagram size
		if(Model.diagram.width>ppPanel.ddim.selectedItem.width
		&&Model.diagram.height>ppPanel.ddim.selectedItem.height)
		{
			var msg:String = "You have chosen a lower diagram resolution, which may result in loss of diagram content. Do you want to proceed?";
			Alert.show(msg,"WARNING",(Alert.YES | Alert.NO),null,handleResolutionWarnResponse,null,Alert.YES);
		}
		else
		{
			saveDiagramAsAnother();
		}
	}
	else
	{
		ppPanel.error.visible = true;
	}
}

private function handleResolutionWarnResponse(event:CloseEvent):void
{
	if(event.detail == Alert.YES)	
		saveDiagramAsAnother();

}
//used in saveAS FUNCTION TO RESET STATUSES BEFORE SAVING
private function resetDiagramDefaults():void
{
	Model.diagram.diagramStatusId = Constants.LL_DRAFT_STATUS;
	Model.diagram.createdBy = Model.user.userId;
	Model.diagram.updatedBy = Model.user.userId;
	Model.diagram.createdDate = null;
	Model.diagram.goldSeal = false;
	Model.diagram.locked = true;
	Model.diagram.lockedUser = new User();
	Model.diagram.lockedUser.userId = Model.user.userId;
	Model.diagram.openToPublic = true;
	Model.diagram.userList..removeAll();
}

private function saveDiagramAsAnother():void
{
	Model.diagram.width = ppPanel.ddim.selectedItem.width;
	Model.diagram.height = ppPanel.ddim.selectedItem.height;
	
	ppPanel.createb.mouseEnabled = false;
	ppPanel.cancelb.mouseEnabled = false;
	ppPanel.createb.enabled = false;
	ppPanel.cancelb.enabled = false;
	
	//save diagram as
	var s:Service = new Service();
	s.serviceHandler = handleSaveDiagramAs;
	resetDiagramDefaults();
	s.saveDiagramAs(Model.diagram);
	//change the mouse to a busy cursor
	CursorManager.setBusyCursor();
}

private function handleSaveDiagramAs(event:ResultEvent):void
{
	//set the flat
	displayLoadMessage = false;
	//VERY IMPORTANT: LOAD THE DIAGRAM THAT SAVED AS ANOTHER DIAGRAM
	var id:Number = event.result as Number;
	//make call to retrieve the diagram
	var s:Service = new Service();
	s.serviceHandler = handleLoadDiagram;
	s.loadDiagram(id);
}

/* END */

/*load home/collobrate popup*/
private function handleNewDiagramHome(event:MouseEvent):void
{
	handleAction(handleEditHomeFnc);
}


/*load home/collobrate popup*/
private function handleEditHome(event:MouseEvent):void
{
	handleAction(openEditActionOptionPopUp);
}

private function openEditActionOptionPopUp():void
{
	//create pop up panel
	editActionOptionPanel = new EditOptionsPopUp();
	editActionOptionPanel.addEventListener(FlexEvent.INITIALIZE,handleEditOptionPopUpCreation);
	//add to manager
	PopUpManager.addPopUp(editActionOptionPanel, this.parent, true);
	PopUpManager.centerPopUp(editActionOptionPanel);
	editActionOptionPanel.y = 100;
}


private function handleEditOptionPopUpCreation(event:FlexEvent):void
{
	//add listeners
	editActionOptionPanel.addEventListener(CloseEvent.CLOSE, closeEditOptionPanel);
	//saves diagram status, lock, and user in the list
	editActionOptionPanel.createSTD.addEventListener(MouseEvent.CLICK, handleStandarditems);
	editActionOptionPanel.createManu.addEventListener(MouseEvent.CLICK, handleNew);
	editActionOptionPanel.openExist.addEventListener(MouseEvent.CLICK, handleNewDiagramHome);
	//should we lock before renaming or just enabled check is enough to rename?
}

private function handleEditDiagramSettingFnc():void
{
	//create pop up panel
	ppPanel = new EditDiagramSettingPopUp();
	
	ppPanel.addEventListener(FlexEvent.INITIALIZE,handleEditSettingPopUpCreation);
	
	//add to manager
	PopUpManager.addPopUp(ppPanel, this.parent, true);
	PopUpManager.centerPopUp(ppPanel);
	ppPanel.y = 100;
	
}

private function handleEditSettingPopUpCreation(event:FlexEvent):void
{
	ppPanel.addEventListener(CloseEvent.CLOSE, closePanel);
	//saves diagram status, lock, and user in the list
	ppPanel.checkoutb.addEventListener(MouseEvent.CLICK, handleSaveDiagramInfo);
	//should we lock before renaming or just enabled check is enough to rename?
	
	//if locked is enabled, then we can delete diagram
	ppPanel.deleteb.addEventListener(MouseEvent.CLICK, deleteDiagram);
	//ppPanel.hinfo.addEventListener(MouseEvent.CLICK, displayHomeHelp);
	ppPanel.reviewHb.addEventListener(MouseEvent.CLICK, handleReviewDiagramHistory);
	ppPanel.lockDb.addEventListener(MouseEvent.CLICK, handleCheckoutDiagram);
	ppPanel.allUsers.addEventListener(MouseEvent.DOUBLE_CLICK, userDoubleClickHandler);
	ppPanel.selectedUsers.addEventListener(KeyboardEvent.KEY_UP, userKeyHandler);
	ppPanel.selectedUsers.addEventListener(DragEvent.DRAG_DROP, userDropHandler);	
	
	var userservice:Service = new Service();
	userservice.getAllUsers();
	
	userservice.serviceHandler = handleGetAllSetting;
}

private function handleGetAllSetting(event:ResultEvent):void
{
	
	allUsers = event.result as ArrayCollection;
	var diagram:CDiagram = Model.selectedDiagram;

	ppPanel.dname.text =  diagram.name;
	ppPanel.ddesc.text =  diagram.description;
	ppPanel.dkeywords.text = diagram.keywords;
	ppPanel.dloc.text = diagram.location;
	ppPanel.publicCB.dataProvider = Constants.ACCESS_ARRAY;
	
	ppPanel.publicCB.selectedIndex = diagram.openToPublic ? 1 : 2;
	ppPanel.selectedUsers.dataProvider = diagram.userList
	//add listeners
	
	var availableUsers:ArrayCollection = new ArrayCollection();
	var index:Number = 0;
	for(var i:int = 0; i < allUsers.length; i++)
	{
		if(allUsers[i].userId != diagram.creatorUser.userId) {
			index = findUserIndex(ppPanel.selectedUsers.dataProvider, allUsers[i]);
			if(index < 0)
				availableUsers.addItem(allUsers[i]);
		}
	}
	ppPanel.allUsers.dataProvider = availableUsers;
	ppPanel.allUsers.labelFunction=displayUserInfo;
}

private function handleCheckoutDiagram(event:MouseEvent):void
{
	var s:Service = new Service();
	s.serviceHandler = handleSaveDiagramLockResponse;
	var diagram:CDiagram = Model.selectedDiagram;

	diagram.updatedBy = Model.user.userId;
	diagram.locked = true;
	diagram.lockedUser = Model.user;
	diagram.lockedUser.userId = Model.user.userId;
	//Model.diagram = diagram;
	s.updateDiagramInfo(diagram); 
}

private function handleEditHomeFnc():void
{
	//create pop up panel
	ppPanel = new EditHomePopUp();
	
	ppPanel.addEventListener(FlexEvent.INITIALIZE,handleEditHomePopUpCreation);

	//add to manager
	PopUpManager.addPopUp(ppPanel, this.parent, true);
	PopUpManager.centerPopUp(ppPanel);
	ppPanel.y = 100;
	
	PopUpManager.removePopUp(editActionOptionPanel);
}

private function handleEditHomePopUpCreation(event:FlexEvent):void
{
	//add listeners
	ppPanel.loadb.addEventListener(MouseEvent.CLICK,loadDiagram);
	ppPanel.addEventListener(CloseEvent.CLOSE, closePanel);
	//saves diagram status, lock, and user in the list
	//ppPanel.saveb.addEventListener(MouseEvent.CLICK, handleSaveDiagramInfo);
	//should we lock before renaming or just enabled check is enough to rename?

	//if locked is enabled, then we can delete diagram
	//ppPanel.deleteb.addEventListener(MouseEvent.CLICK, deleteDiagram);
	//ppPanel.hinfo.addEventListener(MouseEvent.CLICK, displayHomeHelp);
	//ppPanel.reviewb.addEventListener(MouseEvent.CLICK, handleReviewDiagramHistory);
	
	if(Model.user.roleId == Constants.LL_EPA_USER)
	{
		//ppPanel.reviewCitationb.addEventListener(MouseEvent.CLICK, handleReviewCitations);
		//ppPanel.reviewCitationb.visible = true;
	}

	ppPanel.filterd.addEventListener(KeyboardEvent.KEY_UP,handleSearchDiagrams);
	//ppPanel.allUsers.addEventListener(MouseEvent.DOUBLE_CLICK, userDoubleClickHandler);
	//ppPanel.selectedUsers.addEventListener(KeyboardEvent.KEY_UP, userKeyHandler);
	//ppPanel.selectedUsers.addEventListener(DragEvent.DRAG_DROP, userDropHandler);
	ppPanel.sort.addEventListener(ItemClickEvent.ITEM_CLICK, handleDiagramSort);
	//get users
	
	var userservice:Service = new Service();
	userservice.getAllUsers();

	userservice.serviceHandler = handleGetAllUsers;
}
//handleCheckoutDiagram

private function deleteDiagram(event:MouseEvent):void
{
	var msg:String = "Are you sure you want to delete this diagram?  Click \"Yes\" to proceed with deletion; click \"No\" to cancel deletion and return to the Open Existing Diagram screen." ;
	Alert.show(msg,"WARNING",(Alert.YES | Alert.NO),null,handleDeleteDiagramWarnResponse,null,Alert.YES);
}

private function handleDeleteDiagramWarnResponse(event:CloseEvent):void
{
	if(event.detail == Alert.YES)
	{
		var s:Service = new Service();
		s.serviceHandler = handleDeleteDiagramResponse;
		var diagram:CDiagram = Model.diagram; //ppPanel.diagrams.selectedItem as CDiagram;
		s.deleteDiagram(diagram.id);
	}
	//else do nothing
}

private function handleDeleteDiagramResponse(event:ResultEvent):void
{
	var result:Boolean = event.result as Boolean;
	//if locked
	if(!result)
	{
		closePopUp();
		Alert.show("Diagram could not be deleted.", "INFORMATION", Alert.OK);
	}
	else 
	{
		handleCloseFnc();
		closePopUp();
		Alert.show("Diagram was successfully deleted.", "INFORMATION", Alert.OK);
	}
}

private function handleSaveDiagramInfo(event:MouseEvent):void
{
	
	var valArray:Array = new Array();
	valArray.push(ppPanel.valDName);
	valArray.push(ppPanel.valDDesc);
	valArray.push(ppPanel.valDKeywords);
	valArray.push(ppPanel.valDLoc);
	var validatorErrorArray:Array = Validator.validateAll(valArray);
	if(validatorErrorArray.length == 0)
	{
		var s:Service = new Service();
		s.serviceHandler = handleDiagramNameCheck3;
		s.checkDiagram(ppPanel.dname.text);
	}
	else
	{
		Alert.show("Please correct error(s) indicated on the screen.", "INFORMATION" ,Alert.OK);
	}
}

private function handleDiagramNameCheck3(event:ResultEvent):void
{
	
	var diagramId:Number = event.result as Number;
	var diagram:CDiagram = Model.selectedDiagram;
	if(diagramId > 0 && diagramId != diagram.id)
	{
		var msg:String = "A diagram with the same name already exists. Please choose another diagram name.";
		Alert.show(msg,"INFORMATION",Alert.OK,null,null,null,Alert.OK);
	}
	else
	{
		 saveDiagramInfo();
	}	

}

private function saveDiagramInfo():void
{	
	var s:Service = new Service();
	s.serviceHandler = handleSaveDiagramInfoResponse;
	var diagram:CDiagram = Model.selectedDiagram; //ppPanel.diagrams.selectedItem as CDiagram;
	/*var lockedUserId:Number = 0;
	diagram.locked = ppPanel.lockCB.enabled;
	if(!ppPanel.lockCB.enabled)
		lockedUserId = diagram.lockedUser.userId;
	else if(ppPanel.lockCB.selected)
		lockedUserId = Model.user.userId;
	*/
	//var diagramStatusId:Number = Constants.LL_DRAFT_STATUS;
	//if(ppPanel.publishCB.selected)
	//	diagramStatusId = Constants.LL_PUBLISHED_STATUS;
	//CursorManager.setBusyCursor();
	diagram.name = ppPanel.dname.text;
	diagram.keywords = ppPanel.dkeywords.text;
	diagram.location = ppPanel.dloc.text;
	diagram.description = ppPanel.ddesc.text;
	diagram.userList = ppPanel.selectedUsers.dataProvider;
	
	//diagram.lockedUser = new User;
	//diagram.lockedUser.userId = lockedUserId;
	//diagram.diagramStatusId =  diagramStatusId;
	if (ppPanel.publicCB.selectedLabel == "Private" )
		diagram.openToPublic =  false;
	else 
		diagram.openToPublic = true;
	diagram.updatedBy = Model.user.userId;
	//Model.selectedDiagram = diagram;
	s.updateDiagramInfo(diagram);
}
private function handleSaveDiagramLockResponse(event:ResultEvent):void
{
	var result:Boolean = event.result as Boolean;
	//if locked
	if(!result)
	{
		closePopUp();
		Alert.show("Diagram settings were not saved as its been locked by other user.  Please re-open the Home:Diagram Settings screen to see last updates.", "INFORMATION", Alert.OK);
	}
	else 
	{
		var sdiagram:CDiagram = Model.selectedDiagram;// ppPanel.diagrams.selectedItem as CDiagram;
		if(Model.diagram != null && Model.diagram.id == sdiagram.id)
			handleCloseFnc();
		closePopUp();
		
		Alert.show("Diagram is successfully locked.", "INFORMATION", Alert.OK);
	}
}

private function handleSaveDiagramInfoResponse(event:ResultEvent):void
{
	var result:Boolean = event.result as Boolean;
	//if locked
	if(!result)
	{
		closePopUp();
		Alert.show("Diagram settings were not saved as its been locked by other user.  Please re-open the Home:Diagram Settings screen to see last updates.", "INFORMATION", Alert.OK);
	}
	else 
	{
		//should we always close teh diagram or only if saved diagram and open matches??
		var sdiagram:CDiagram = Model.selectedDiagram;// ppPanel.diagrams.selectedItem as CDiagram;
		if(Model.diagram != null && Model.diagram.id == sdiagram.id)
			handleCloseFnc();
		//else
		//	ppPanel.diagrams.selectedItem = Model.selectedDiagram;
		
		closePopUp();

		Alert.show("Diagram settings were successfully saved.", "INFORMATION", Alert.OK);
	}
}

private function handleGetAllUsers(event:ResultEvent):void
{
	//try to get all diagrams+  Model.user.userId
	var s:Service = new Service();
	var id:Number = 0;

	if ( Model.user != null ) id = Model.user.userId;
	
	s.getDiagramsByUser("", Constants.DIAGRAM_NAME, id);
	s.serviceHandler = handleGetDiagrams;
	//maintain this list when user login or whenever collobrate popups
	allUsers = event.result as ArrayCollection;
}
//used in datagrid
private function displayUserInfo(item:Object, col:DataGridColumn):String
{
     return item.firstName + " " + item.lastName;
}


//used in diagram drop-down
private function diagramComboBoxlabelFunc(item:Object):String {
	return StringUtil.substitute("{0} - {1}", item.name, item.diagramStatus);
}


private function handleGetDiagrams(event:ResultEvent):void
{
	var list:ArrayCollection = event.result as ArrayCollection;

	ppPanel.diagrams.dataProvider = list;
	ppPanel.diagrams.labelFunction = diagramComboBoxlabelFunc;
	
	if(list.length > 0) {
		enableEditHomeControls();
		ppPanel.diagrams.addEventListener(CloseEvent.CLOSE, diagramSelectionCloseHandler);
		ppPanel.diagrams.addEventListener(ListEvent.CHANGE, diagramSelectionCloseHandler);
		
		if(Model.diagram != null && Model.diagram.id != 0)
		{
			for( var i:int = 0; i < list.length; i++){
				 var diagram:CDiagram = list.getItemAt(i) as CDiagram;
				if(Model.diagram.id == diagram.id)
				{
					ppPanel.diagrams.selectedItem = list[i];
					updateEditHomePanel((list[i] as CDiagram));
					break;
				}
			}
		}
		else
		{
			ppPanel.diagrams.selectedItem = list[0];
			updateEditHomePanel((list[0] as CDiagram));
		}
		
	}
	else
		disableEditHomeControls();

}

//item click event on edit home popup
private function handleDiagramSort(event:ItemClickEvent):void {
	searchDiagrams();
}

private function handleStandarditemsWithSelected(event:MouseEvent):void
{
	if (Model.diagram != null )
	{
		ppPanel = new SearchStandardTermsModify();
		//ppPanel.newTermDiagram.text = "Modify Diagram";
		//ppPanel.newS.visible = false; //!ppPanel.newTermDiagram.visible; 
		//ppPanel.newS.includeInLayout= false;// !ppPanel.newTermDiagram.includeInLayout;
		//ppPanel.modifyS.visible = true; //!ppPanel.modifyTermDiagram.visible; 
		//ppPanel.modifyS.includeInLayout= true;//!ppPanel.modifyTermDiagram.includeInLayout;
		
		ppPanel.addEventListener(FlexEvent.INITIALIZE,searchStandardTermSelectedResult);
		
		PopUpManager.addPopUp(ppPanel, this.parent, true);
		PopUpManager.centerPopUp(ppPanel);
		ppPanel.y = 100;
	}
}
private function handleStandarditems(event:MouseEvent):void
{
	//closePopUp();
	ppPanel = new SearchStandardTerms();
	
	ppPanel.addEventListener(FlexEvent.INITIALIZE,searchStandardTermResult);
	PopUpManager.addPopUp(ppPanel, this.parent, true);
	PopUpManager.centerPopUp(ppPanel);
	ppPanel.y = 100;
	
}

private function searchStandardTermSelectedResult(event:FlexEvent):void
{
	
	var s:Service = new Service();
	s.getAllTerms(true);
	s.serviceHandler = handleSearchTermSelectResult;
}

private function searchStandardTermResult(event:FlexEvent):void
{
	
	var s:Service = new Service();
	s.getAllTerms(true);
	s.serviceHandler = handleSearchTermResult;
}


private function handleSearchTermSelectResult(event:ResultEvent):void
{
	var selectedTermsModify = new ArrayCollection();
	
	allStdTerms = event.result as ArrayCollection;
	
	if(Model.diagram.shapes != null )
	{
		for(var i:int=0;i<  Model.diagram.shapes.length;i++)
		{
			
			var s:CShape = Model.diagram.shapes.getItemAt(i) as CShape;
			
		
			for (var j:int=0;j< allStdTerms.length; j++)
			{
				
				var t:Object = allStdTerms.getItemAt(j);
				var temp:String = t.term.toString();
				var tempId:Number = t.id;
				
				if (s.label == temp || s.termId == tempId )
				{	
					
					selectedTermsModify.addItem(t);
					break;
				}  
			} 
			
		}
	}
	
	ppPanel.selectedTermsModify.dataProvider = selectedTermsModify;
	
	ppPanel.stdTerms.dataProvider = allStdTerms;
	ppPanel.filterdTerm.addEventListener(KeyboardEvent.KEY_UP, keyUpSearchTermHandler);
	ppPanel.searchCancel.addEventListener(MouseEvent.CLICK, cancel);
	ppPanel.modifyTermDiagram.addEventListener(MouseEvent.CLICK, handleModifyTermDiagram);
}


private function handleSearchTermResult(event:ResultEvent):void
{

	allStdTerms = event.result as ArrayCollection;

	ppPanel.stdTerms.dataProvider = allStdTerms;
 	ppPanel.filterdTerm.addEventListener(KeyboardEvent.KEY_UP, keyUpSearchTermHandler);
	ppPanel.searchCancel.addEventListener(MouseEvent.CLICK, cancel);

	ppPanel.newTermDiagram.addEventListener(MouseEvent.CLICK, handleNewTermDiagram);
	
}

private function keyUpSearchTermHandler(event:KeyboardEvent):void {
	//if (event.keyCode ==Keyboard.ENTER)
	//{
		var s:Service = new Service();
		
		s.searchTerms(ppPanel.filterdTerm.text, false, true);
		s.serviceHandler = handlefilterTermResult;
	//}
}

private function handlefilterTermResult(event:ResultEvent):void
{
	var list:ArrayCollection= event.result as ArrayCollection;

	ppPanel.stdTerms.dataProvider = list;
	
}

private function handleModifyTermDiagram(event:MouseEvent):void
{
	
	selectedTerms = ppPanel.selectedTermsModify.dataProvider ;

	closePopUp();
	//create pop up panel
	
	//LiLi Modify diagram??
	board.ModifyDiagramShapes(selectedTerms);
	ppPanel.selectedTermsModify.dataProvider = null;
}

private function handleNewTermDiagram(event:MouseEvent):void
{
	
	selectedTerms = ppPanel.selectedTerms.dataProvider ;
	
	//close Edithome/collobrate popup and then open new popup
	PopUpManager.removePopUp(editActionOptionPanel);
	editActionOptionPanel = null;
	
	closePopUp();
	//create pop up panel
	ppPanel = new NewDiagramPopUp();
	ppPanel.addEventListener(FlexEvent.INITIALIZE,handleNewDiagramPopUpCreation)
	//add to manager
	PopUpManager.addPopUp(ppPanel, this.parent, true);
	PopUpManager.centerPopUp(ppPanel);
	ppPanel.y = 100;
	
}


private function handleShapesResult(event:ResultEvent):void
{
	var list:ArrayCollection = event.result as ArrayCollection;
	ppPanel.shapes.dataProvider = list;
}

private function handleSearchDiagrams(event:KeyboardEvent):void
{
	searchDiagrams();
}

//used in edit home popup
private function searchDiagrams():void
{
	var s:Service = new Service();
	
	s.getDiagramsByUser(ppPanel.filterd.text, ppPanel.sort.selectedValue, Model.user == null ? 0 : Model.user.userId);
	s.serviceHandler = handleSearchDiagramsResult;
}

private function handleSearchDiagramsResult(event:ResultEvent):void
{
	var list:ArrayCollection = event.result as ArrayCollection;
	ppPanel.diagrams.dataProvider = list;
	ppPanel.diagrams.labelFunction = diagramComboBoxlabelFunc;

	if(list.length > 0) {
		enableEditHomeControls();
		ppPanel.diagrams.addEventListener(ListEvent.CHANGE, diagramSelectionCloseHandler);
		ppPanel.diagrams.selectedItem = list[0];
		updateEditHomePanel((list[0] as CDiagram));
		
	}
	if(list.length == 0)
	{
		var msg:String = "Search returned no diagrams. Please change your search criteria and search again.";
		Alert.show(msg,"INFORMATION",Alert.OK,null,null,null,Alert.OK);
		disableEditHomeControls();
	}
}
private function enableEditHomeControls():void 
{
	ppPanel.loadb.visible = true;
	//ppPanel.deleteb.visible = true;
	//ppPanel.reviewb.visible = true;
	//ppPanel.saveb.visible = true;
}

private function disableEditHomeControls():void 
{
	ppPanel.loadb.visible = false;
	//ppPanel.deleteb.visible = false;
	//ppPanel.reviewb.visible = false;
	//ppPanel.saveb.visible = false;
}

private function updateEditHomePanel(diagram:CDiagram):void
{
	if(diagram != null)
	{
		ppPanel.dname.text =  diagram.name;
		ppPanel.dname.toolTip = diagram.name;
		ppPanel.ddesc.text =  diagram.description;
		ppPanel.ddesc.toolTip = diagram.description;
		ppPanel.dkeywords.text = diagram.keywords;
		ppPanel.dkeywords.toolTip = diagram.keywords;
		ppPanel.dloc.text = diagram.location;
		ppPanel.dloc.toolTip = diagram.location;
		
		
		//group users
		ppPanel.selectedUsers.dataProvider = diagram.userList;
		ppPanel.selectedUsers.labelFunction=displayUserInfo; //use labelFunction
	
	//	if(Model.user.roleId != Constants.LL_EPA_USER)
			ppPanel.publishCB.enabled = false;
		ppPanel.publishCB.selected = diagram.diagramStatusId == Constants.LL_PUBLISHED_STATUS;
		var index:int = findUserIndex(ppPanel.selectedUsers.dataProvider, Model.user);
		//published diagrams are also public diagrams??
		//if(diagram.diagramStatusId == Constants.LL_PUBLISHED_STATUS ||
		if(index < 0 && diagram.creatorUser.userId != Model.user.userId)//) 
		{
			ppPanel.publicCB.enabled = false;
			//ppPanel.reviewb.visible = false;
		}
		else 
		{
			ppPanel.publicCB.enabled = false;
			//ppPanel.reviewb.visible = true;
		}
				
		ppPanel.publicCB.selected = diagram.openToPublic;
		ppPanel.creator.text = diagram.creatorUser.firstName + " " + diagram.creatorUser.lastName;
		ppPanel.lockCB.selected = diagram.locked;
		//if already locked then user cannot save
	 	if(diagram.locked && diagram.lockedUser.userId != Model.user.userId) 
		{
			ppPanel.lockCB.enabled = false;
			ppPanel.lockCB.label = "Checked out (by " + diagram.lockedUser.firstName + " " + diagram.lockedUser.lastName + ")";
		}
		else 
		{
			ppPanel.lockCB.label = "Check out diagram";
			//epauser can lock and edit published diagram
			if((Model.user.roleId != Constants.LL_EPA_USER && diagram.diagramStatusId == Constants.LL_PUBLISHED_STATUS)
				|| (index < 0 && diagram.creatorUser.userId != Model.user.userId))
			{
				ppPanel.lockCB.enabled = false;
			}
			else
			{
				ppPanel.lockCB.enabled = false;
			}
		}
		/*	
		if(ppPanel.lockCB.enabled)
		{
			ppPanel.deleteb.visible = true;
			ppPanel.rename.enabled = false; //0008389: Make all diagram settings information read-only in Diagram Settings pop-up
			ppPanel.saveb.visible = true;
		}
		else
		{
			ppPanel.deleteb.visible = false;
			ppPanel.rename.enabled = false;
			ppPanel.saveb.visible = false;
		}
			*/	
		var availableUsers:ArrayCollection = new ArrayCollection();
		for(var i:int = 0; i < allUsers.length; i++)
		{
			if(allUsers[i].userId != diagram.creatorUser.userId) {
				index = findUserIndex(ppPanel.selectedUsers.dataProvider, allUsers[i]);
				if(index < 0)
					availableUsers.addItem(allUsers[i]);
			}
		}
		ppPanel.allUsers.dataProvider = availableUsers;
		ppPanel.allUsers.labelFunction=displayUserInfo; //use labelFunction
		
		if(Model.user.userId != 0 && (diagram.creatorUser.userId == Model.user.userId || Model.user.roleId == Constants.LL_EPA_USER))
		{
			//ppPanel.userContainer.enabled = false;
			this.editIcon.visible = true;
			this.editIcon.enabled = true;
		}
		else
		{
			//ppPanel.userContainer.enabled = false;
			this.editIcon.visible = false;
			this.editIcon.enabled = false;
		}
	}
}

private function diagramSelectionCloseHandler(event:Event):void
{
	var diagram:CDiagram = CDiagram(List(event.target).selectedItem);
	updateEditHomePanel((diagram));
}


//this function is used to add user to the list of selected users
private function userDropHandler(event:DragEvent):void
{
	var user:User =  event.dragSource.dataForFormat("items")[0] as User;
	ppPanel.selectedUsers.dataProvider.addItem(user);
	ppPanel.allUsers.dataProvider.removeItemAt(ppPanel.allUsers.dataProvider.getItemIndex(user));

}

//utility function to find a user in a list
private function findUserIndex(currUsers:ArrayCollection, u:User):int
{
	for(var i:int=0; i < currUsers.length; i++)
	{
		var iu:User = currUsers.getItemAt(i) as User;
		//compare the users ids
		if(iu.userId == u.userId)
		{
			return i;
		}
	}
	return -1;
}
//this function is used to delete users from the list of selected users
private function userKeyHandler(event:KeyboardEvent):void
{
	//try to delete items from the list if necessary
	if(event.keyCode == Constants.KEYCODE_DELETE)
	{
		var u:Object = ppPanel.selectedUsers.selectedItem as Object;
		var diagram:CDiagram = ppPanel.diagrams.selectedItem as CDiagram;
	
		if(u.userId == diagram.lockedUser.userId )
			Alert.show("You cannot delete this user until User unlocks the diagram.");
		if(u != null)
		{
			ppPanel.allUsers.dataProvider.addItem(u);
			ppPanel.selectedUsers.dataProvider.removeItemAt(ppPanel.selectedUsers.dataProvider.getItemIndex(ppPanel.selectedUsers.selectedItem));
			
		}
	}
}

//double click to move items from user list to the seelcted user list
private function userDoubleClickHandler(event:MouseEvent):void
{
	//get the current selected user
	var u:Object = ppPanel.allUsers.selectedItem as Object;
	if(u!=null)
	{
		//add to the selected user and remove from the existing users
		ppPanel.selectedUsers.dataProvider.addItem(u);
		ppPanel.allUsers.dataProvider.removeItemAt(ppPanel.allUsers.dataProvider.getItemIndex(u));

	//Alert.show(u.toString())
	}
	
}
/*END OF EDITHOME POPUP*/

/* LOAD DIAGRAM */
private function handleLoad(event:MouseEvent):void
{
	handleAction(handleLoadFnc);
}

private function handleLoadFnc():void
{
	//create pop up panel
	ppPanel = new LoadDiagramPopUp();
	ppPanel.addEventListener(FlexEvent.INITIALIZE,handleLoadDiagramPopUpCreation)
	//add to manager
	PopUpManager.addPopUp(ppPanel, this.parent, true);
	PopUpManager.centerPopUp(ppPanel);
	ppPanel.y = 100;
}

private function handleLoadDiagramPopUpCreation(event:FlexEvent):void
{
	//add listeners
	ppPanel.loadb.addEventListener(MouseEvent.CLICK,loadDiagram);
	ppPanel.cancelb.addEventListener(MouseEvent.CLICK,cancel);
	ppPanel.addEventListener(CloseEvent.CLOSE,closePanel);
	
	//try to get all diagrams
	var s:Service = new Service();
	if(Model.user.roleId == Constants.LL_PUBLIC_USER)
		s.getPublishedDiagrams();
	else
		s.getDiagramsByUser("", Constants.DIAGRAM_NAME, Model.user.userId);

	s.serviceHandler = getAllDiagrams;
	//s.getAllDiagrams();
}

private function getAllDiagrams(event:ResultEvent):void
{
	var list:ArrayCollection = event.result as ArrayCollection;
	for(var i:int; i < list.length; i++){
		var diagram:CDiagram = list.getItemAt(i) as CDiagram;
		diagram.name = diagram.name + ' - ' + diagram.diagramStatus; 
		trace("diagram " + diagram.name);
	}
	ppPanel.diagrams.dataProvider = list;
	ppPanel.diagrams.labelField = "name";
	
	if(list.length > 0) {
		ppPanel.diagrams.addEventListener(CloseEvent.CLOSE, loadDiagramSelectionCloseHandler);
		ppPanel.desc.text = (list[0] as CDiagram).description;
		ppPanel.dloc.text = (list[0] as CDiagram).location;
		ppPanel.dkeywords.text = (list[0] as CDiagram).keywords;
	}
}

private function loadDiagramSelectionCloseHandler(event:Event):void
{
	ppPanel.desc.text =  ComboBox(event.target).selectedItem.description;
	ppPanel.dloc.text =  ComboBox(event.target).selectedItem.location;
	ppPanel.dkeywords.text =  ComboBox(event.target).selectedItem.keywords;
}

private function loadDiagram(event:MouseEvent):void
{
	Model.selectedDiagram = ppPanel.diagrams.selectedItem as CDiagram;
	loadDiagramById(ppPanel.diagrams.selectedItem.id);
}


private function loadDiagramById(id:Number):void
{
	
	ppPanel.loadb.mouseEnabled = false;
	ppPanel.cancelb.mouseEnabled = false;
	ppPanel.loadb.enabled = false;
	ppPanel.cancelb.enabled = false;
	
	//make call to retrieve the diagram
	var s:Service = new Service();
	s.serviceHandler = handleLoadDiagram;
	s.loadDiagram(id);
	//change the mouse to a busy cursor
	CursorManager.setBusyCursor();
}


private function handleLoadDiagram(event:ResultEvent):void
{
	var d:CDiagram = event.result as CDiagram;
	//update model
	if(d!=null)
	{
		Model.mode = Model.MODE_EXISTING;
		Model.diagram = d;
		Model.BOARD_WIDTH = d.width;
		Model.BOARD_HEIGHT = d.height;
		Model.INITIAL_ZOOM_SCALE = Constants.DEFAULT_BOARD_WIDTH/Model.BOARD_WIDTH;
		Model.INSET_TO_BOARD_RATIO = Constants.INSET_WIDTH/Model.BOARD_WIDTH;

		Model.DASHED_LINES_VERTICAL_GAP = Constants.TIER_HEIGHT;
		//broadcast message
		if(displayLoadMessage)
		{//display info
			broadcastMenuItemClick("loadWithMsg");	
			CursorManager.removeBusyCursor();
		}
		else
		{
		
			//remove busy cursor
			CursorManager.removeBusyCursor();
			//display info
			Alert.show("Diagram was successfully saved as a new file.", "INFORMATION", Alert.OK, null, null, null, Alert.OK);

			displayLoadMessage = true;
			broadcastMenuItemClick("loadWithoutMsg");
		}

		PopUpManager.removePopUp(ppPanel);
		//enable controls
		enableControls(true);	
	
		newOrExistingDiagramLoaded = true;
		//set focus 
		this.setFocus();
	}
	else
	{
		var msg:String = "This diagram may have been deleted or saved by another user. Please click on \"Open Diagram\" again to get an updated list of diagrams.";
		Alert.show(msg,"WARNING",Alert.OK,null,null,null,Alert.OK);
	}
}
/* END */

/* EDIT HANDLERS */
private function handleClose():void
{
	handleAction(handleCloseFnc);
}

private function handleCloseFnc():void
{
	
	this.editIcon.visible = false;
	Model.mode = Model.MODE_NONE;
	newOrExistingDiagramLoaded = false;
	broadcastMenuItemClick("close");
}

private function handleClear(event:MouseEvent):void
{
	broadcastMenuItemClick("clear");
}

private function displaySubMenu(event:MouseEvent):void
{
	Alert.show("Sub menu");
	//diagramMenu.visible = true;
}

private function handleHumAct(event:MouseEvent):void
{
	//Alert.show("humact");
	//enableControls(false);
	broadcastMenuItemClick("humact");
}

private function handleStressor(event:MouseEvent):void
{
	//enableControls(false);
	broadcastMenuItemClick("stressor");
}

private function handleAddStep(event:MouseEvent):void
{
	//enableControls(false);
	broadcastMenuItemClick("addstep");
}

private function handleModFactor(event:MouseEvent):void
{
	//enableControls(false);
	broadcastMenuItemClick("modfactor");
}

private function handleModAction(event:MouseEvent):void
{
	//enableControls(false);
	broadcastMenuItemClick("modaction");
}

private function handleSource(event:MouseEvent):void
{
	//enableControls(false);
	broadcastMenuItemClick("source");
}

private function handleBioResp(event:MouseEvent):void
{
	//enableControls(false);
	broadcastMenuItemClick("bioresp");
}

private function handleArrowLine(event:MouseEvent):void
{
	//enableControls(false);
	broadcastMenuItemClick("arrowline");
}

private function handleLine(event:MouseEvent):void
{
	//enableControls(false);
	broadcastMenuItemClick("line");
}

private function handleAddLinkage(event:MouseEvent):void
{
	if(startNewLinkage)
	{
		//enableEditControls(false);
		addLink.text = "Save Evidence";
		addLink.toolTip = "Save Evidence";
		addLink.enabled = true;
		startNewLinkage = false;
		broadcastMenuItemClick("startNewLinkage");
	}
	else
	{
		//enableEditControls(true);
		addLink.text = "Add/Edit Evidence";
		addLink.toolTip = "Add/Edit Evidence";
		startNewLinkage = true;
		broadcastMenuItemClick("endNewLinkage");	
	}
}

private function handleReviewLinkage(event:MouseEvent):void
{
	handleEditDiagramSettingFnc();
}

private function handleDownloadReviewLinkage(event:MouseEvent):void
{
	var s:Service = new Service();
	s.serviceHandler = handleGetDiagramEvidences;
	if ( Model.diagram != null && Model.diagram.id != 0)
		s.getDiagramEvidences(Model.diagram.id);
}

private function handleGetDiagramEvidences(event:ResultEvent):void
{
	
	var diagramEvidenceList = event.result as ArrayCollection;
	board.downloadAllCitations(diagramEvidenceList);
}
private function handleAlignShapes(event:MouseEvent):void
{
	if(!startedAligningShapes)
	{
		enableEditControls(false);
		align.text = "End";
		align.toolTip = "End Align";
		align.enabled = true;
		startedAligningShapes = true;
		broadcastMenuItemClick("startAlignment");
	}
	else
	{
		enableEditControls(true);
		align.text = "Align";
		align.toolTip = "Align Shapes"
		startedAligningShapes = false;
		broadcastMenuItemClick("endAlignment");	
	}

}


private function handleClone(event:MouseEvent):void
{
	if(!startedCopying)
	{
		enableEditControls(false);
		clone.text = "End";
		clone.toolTip = "End Copy";
		clone.enabled = true;
		startedCopying = true;
		broadcastMenuItemClick("startCopying");
	}
	else
	{
		enableEditControls(true);
		clone.text = "Copy";
		clone.toolTip = "Copy Shape";
		startedCopying = false;
		broadcastMenuItemClick("endCopying");	
	}
}

private function handleSelect(event:MouseEvent):void
{
	if(!selectingShapes)
	{
		enableEditControls(false);
		select.text = "End";
		select.toolTip = "End Select";
		select.enabled = true;
		selectingShapes = true;
		broadcastMenuItemClick("startSelection");
	}
	else
	{
		enableEditControls(true);
		select.text = "Select";
		select.toolTip = "Select Shapes";
		selectingShapes = false;
		broadcastMenuItemClick("endSelection");	
	}
}

private function handleHideLines(event:MouseEvent):void
{
	if(!hideLines)
	{
		enableEditControls(false);
	//	hlines.text = "Show";
	//	hlines.toolTip = "Show Lines";
	//	hlines.enabled = true;
		hideLines = true;
		broadcastMenuItemClick("hideLines");
	}
	else
	{
		enableEditControls(true);
	//	hlines.text = "Hide";
	//	hlines.toolTip = "Hide Lines";
		hideLines = false;
		broadcastMenuItemClick("showLines");	
	}
}
/* END */


private function handleReset(event:MouseEvent):void
{
	broadcastMenuItemClick("reset");
}

private function handleLegendCreation(event:MouseEvent):void
{
	
	if(legend.enabled)
	{
		broadcastMenuItemClick("showLegend");
	}
	
	handleLabelMouseOver(event);
}

private function handleLegendEditCreation(event:MouseEvent):void
{
	
	if(legendEdit.enabled)
	{
		broadcastMenuItemClick("showEditLegend");
	}
	
	handleLabelMouseOver(event);
}
private function handleLegendLinkCreation(event:MouseEvent):void
{
	
	broadcastMenuItemClick("showLinkLegend");
	
	handleLabelMouseOver(event);
}

private function handleDownload(event:MouseEvent):void
{
	broadcastMenuItemClick("downloadDiagram");
}
/* END */

/* POP UP UTILITY */
/* Cancel button on the pop ups */
private function cancel(event:MouseEvent):void
{
	closePopUp();
}

private function closeEditOptionPanel(event:CloseEvent):void
{
	PopUpManager.removePopUp(editActionOptionPanel);
	editActionOptionPanel = null;
	stack.selectedChild = homeMode;
	this.setFocus();
}

private function closePanel(event:CloseEvent):void
{
	closePopUp();
}

private function closePopUp():void
{
	//remove pop up
	PopUpManager.removePopUp(ppPanel);
	ppPanel = null;
	//set focus 
	this.setFocus();
}
/* END */

/* BROADCAST FUNCTIONALITY */

/* This method is used to broadcast a menu item click */
private function broadcastMenuItemClick(operation:String):void
{	//Alert.show(operation + "-- saving any changes.");
	var mice:MenuItemClickEvent = new MenuItemClickEvent(MenuItemClickEvent.MENU_ITEM_CLICK);
	mice.operation = operation;
	this.dispatchEvent(mice);
}
/* END OF BROADCAST FUNCTIONALITY */

/* WARNING FUNCTIONS */
private function handleAction(actionFnc:Function):void
{
	//set current load
	currentAction = actionFnc;
	warnUserAboutDiagram();
}

private function warnUserAboutDiagram():void
{
	//check if the user had loaded a diagram
	if(Model.mode != Model.MODE_NONE && visitedEditMode == true)// && save.enabled)
	{
		warningDisplayed = true;
		var msg:String = " Do you want to save the current diagram before proceeding? Click \"Yes\" to automatically save and close the current diagram; click \"No\" to close it without saving any changes." ;
		Alert.show(msg,"WARNING",(Alert.YES | Alert.NO),null,handleUserWarnResponse,null,Alert.YES);
	}
	else
	{
		//if the user hasn't loaded or created a new diagram just call the current action
		currentAction();
	}
	
	if(stack.selectedChild == editMode)	
		visitedEditMode = true;
	else if(stack.selectedChild == viewMode || stack.selectedChild == linkMode)
		visitedEditMode = false;
}

private function handleUserWarnResponse(event:CloseEvent):void
{
	if(event.detail == Alert.YES)
	{
		handleSave();
	}
	else
	{Alert.show("CurrentAction in Menu: ");
		//call the current action
		currentAction();
		warningDisplayed = false;
	}
}
/* END OF WARNING FUNCTIONS */



/* INSET HANDLER */
public function handleInsetToggle(event:MouseEvent):void
{
	//broadcast an event
	var it:InsetToggleEvent = new InsetToggleEvent(InsetToggleEvent.INSET_TOGGLE);
	this.dispatchEvent(it);
}

/* ACCORDION HANDLER */
private function handleAccordionToggle(event:MouseEvent):void
{
	//broadcast an event
	var at:AccordionToggleEvent = new AccordionToggleEvent(AccordionToggleEvent.ACCORDION_TOGGLE);
	this.dispatchEvent(at);
}

/* MENU HANDLERS */
private function handleLabelMouseOver(event:MouseEvent):void
{
	var label:Label = event.target.parent as Label;
	var labelBox:Box = label.parent as Box;
	label.setStyle("color",0x000000);
	//labelBox.setStyle("backgroundColor",0xCCCC99);
	labelBox.setStyle("backgroundColor",0xD9B4B4);
	
	lastLabelMouseOver = label;
}					

private function handleLabelMouseOut(event:MouseEvent):void
{
	var label:Label = event.target.parent as Label;
	var labelBox:Box = label.parent as Box;
	label.setStyle("color",0xFFFFFF);
	labelBox.setStyle("backgroundColor",0x446666);
}
/* END */

private function enableEditMenu():void
{
  this.tabNav.edit.visible = true;
}

/*
private function resetLoginButton():void
{
	loginb.text = "Log Out";
	loginb.toolTip = "Log Out";
	loginb.removeEventListener(MouseEvent.CLICK, handleLoginPopUpCreation);
	loginb.addEventListener(MouseEvent.CLICK, handleLogOff);
	this.tabNav.link.visible = true;
}
*/
private function resetUser():void 
{
	var guestUser:User = new User();
	guestUser.roleId = Constants.LL_PUBLIC_USER;
	guestUser.userName = "Guest";
	guestUser.userId = 0;
	Model.user = guestUser;
}

private function handleLogOff(event:MouseEvent):void
{
	//allows diagram to be saved if edited 
	handleAction(handleLogOffFunc);
}

private function handleLogOffFunc():void
{
	var s:Service = new Service();
	s.serviceHandler = handleLogOffResultEvent;
	s.updateUserLogOut(Model.user);
}

private function handleLogOffResultEvent(event:ResultEvent):void
{
	/*
	loginb.text = "Log In";
	loginb.toolTip = "Log in using your EPA LAN or EPA Portal username and password, after obtaining CADDIS community access.";
	loginb.removeEventListener(MouseEvent.CLICK, handleLogOff);
	loginb.addEventListener(MouseEvent.CLICK, handleLoginPopUpCreation);
	//close diagram when logged off except published diagrams or close all??
	if(Model.diagram != null && Model.diagram.diagramStatusId !=  Constants.LL_PUBLISHED_STATUS)
		handleCloseFnc();
	Model.user = null;
	resetUser();

	this.tabNav.link.visible = false;  */
}

private function handleSaveWithOutWarning():void
{
	var s:Service = new Service();
	if(Model.diagram.createdBy == 0)
		Model.diagram.createdBy = Model.user.userId;
	else
		Model.diagram.updatedBy = Model.user.userId;
	s.serviceHandler = handleSaveResponseWithOutWarning;
	s.saveDiagram(Model.diagram);
}

private function handleSaveResponseWithOutWarning(event:ResultEvent):void
{
	Model.diagram.id = event.result as Number;
	displayLoadMessage = false;
	loadDiagramByIdFunc(Model.diagram.id);
}

private function loadDiagramByIdFunc(id:Number):void
{
	//make call to retrieve the diagram
	var s:Service = new Service();
	s.serviceHandler = handleLoadDiagramFunc;
	s.loadDiagram(id);
}


private function handleLoadDiagramFunc(event:ResultEvent):void
{
	var d:CDiagram = event.result as CDiagram;
	//update model
	if(d!=null)
	{
		Model.mode = Model.MODE_EXISTING;
		Model.diagram = d;
		Model.BOARD_WIDTH = d.width;
		Model.BOARD_HEIGHT = d.height;
		Model.INITIAL_ZOOM_SCALE = Constants.DEFAULT_BOARD_WIDTH/Model.BOARD_WIDTH;
		Model.INSET_TO_BOARD_RATIO = Constants.INSET_WIDTH/Model.BOARD_WIDTH;

		Model.DASHED_LINES_VERTICAL_GAP = Constants.TIER_HEIGHT;
		CursorManager.removeBusyCursor();
		enableAll();
		broadcastMenuItemClick("loadWithoutMsg");
	}
	else
	{
		CursorManager.removeBusyCursor();
		enableAll();
		var msg:String = "This diagram may have been deleted or saved by another user. Please click on \"Open Diagram\" again to get an updated list of diagrams.";
		Alert.show(msg,"WARNING",Alert.OK,null,null,null,Alert.OK);
	}
}

private function displayViewHelp(event:MouseEvent):void
{
	navigateToURL(new URLRequest(Model.icdUserGuideUrl+"#page=26"), "_blank");
}

private function displayEditHelp(event:MouseEvent):void
{
	navigateToURL(new URLRequest(Model.icdUserGuideUrl+"#page=36"), "_blank");
}

private function displayHomeHelp(event:MouseEvent):void
{
	navigateToURL(new URLRequest(Model.icdUserGuideUrl+"#page=36"), "_blank");
}