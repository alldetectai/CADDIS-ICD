import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.event.ModeSwitchEvent;
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.vo.User;

import flash.events.MouseEvent;

import mx.containers.Box;
import mx.controls.Alert;
import mx.controls.Label;
import mx.events.CloseEvent;
import mx.managers.CursorManager;
import mx.rpc.events.ResultEvent;
import mx.managers.PopUpManager;
import mx.validators.Validator;

private var mode:String = Constants.MODE_HOME;
private var currentAction:Function = null;

private function init():void
{
	view.addEventListener(MouseEvent.CLICK,switchToView);
	edit.addEventListener(MouseEvent.CLICK,switchToEdit);
	home.addEventListener(MouseEvent.CLICK,switchToHome);
	link.addEventListener(MouseEvent.CLICK,switchToLink);
	//search.addEventListener(MouseEvent.CLICK,switchToSearch);
	broadcastModeSwitch(Constants.MODE_HOME);
	diagramNameLabel.visible = false;
}

private function switchToView(event:MouseEvent):void
{
	if(mode != Constants.MODE_VIEW)
	{
		view.styleName = "selectedTab";
		edit.styleName = "unselectedTab";
		home.styleName = "unselectedTab";
		link.styleName = "unselectedTab";
		//search.styleName = "unselectedTab";
		mode = Constants.MODE_VIEW;
		broadcastModeSwitch(Constants.MODE_VIEW);
	}
}

private function switchToEdit(event:MouseEvent):void
{

	if(mode != Constants.MODE_EDIT)
	{
		view.styleName = "unselectedTab";
		edit.styleName = "selectedTab";
		home.styleName = "unselectedTab";
		link.styleName = "unselectedTab";
		//search.styleName = "unselectedTab";

		mode = Constants.MODE_EDIT;
		broadcastModeSwitch(Constants.MODE_EDIT);
	}
}

private function switchToHome(event:MouseEvent):void
{
	if(mode != Constants.MODE_HOME)
	{
		view.styleName = "unselectedTab";
		edit.styleName = "unselectedTab";
		home.styleName = "selectedTab";
		link.styleName = "unselectedTab";
		//search.styleName = "unselectedTab";
		mode = Constants.MODE_HOME;
		broadcastModeSwitch(Constants.MODE_HOME);
	}
}

private function switchToLink(event:MouseEvent):void
{
	if(mode != Constants.MODE_LINK)
	{ 
		view.styleName = "unselectedTab";
		edit.styleName = "unselectedTab";
		home.styleName = "unselectedTab";
		link.styleName = "selectedTab";
	//	search.styleName = "unselectedTab";
		mode = Constants.MODE_LINK;
		broadcastModeSwitch(Constants.MODE_LINK);
	}
}

private function switchToSearch(event:MouseEvent):void
{ 
	if(mode != Constants.MODE_SEARCH)
	{
		view.styleName = "unselectedTab";
		edit.styleName = "unselectedTab";
		home.styleName = "unselectedTab";
		link.styleName = "unselectedTab";
		//search.styleName = "selectedTab";
		mode = Constants.MODE_SEARCH;
		broadcastModeSwitch(Constants.MODE_SEARCH);
	}
}


/* This method is used to broadcast a mode switch */
private function broadcastModeSwitch(mode:String):void
{
	var ms:ModeSwitchEvent = new ModeSwitchEvent(ModeSwitchEvent.MODE_SWITCH);
	ms.newMode = mode;
	this.dispatchEvent(ms);
}

private function initLoginHandlers():void
{
	loginb.addEventListener(MouseEvent.CLICK, handleLoginPopUpCreation);
	loginb.addEventListener(MouseEvent.MOUSE_OVER, handleLabelMouseOver);
	loginb.addEventListener(MouseEvent.MOUSE_OUT, handleLabelMouseOut);
}

/* MENU HANDLERS */
private function handleLabelMouseOver(event:MouseEvent):void
{
	var label:Label = event.target.parent as Label;
	var labelBox:Box = label.parent as Box;
	label.setStyle("color",0x000000);
	//labelBox.setStyle("backgroundColor",0xCCCC99);
	labelBox.setStyle("backgroundColor",0xD9B4B4);
	
	//lastLabelMouseOver = label;
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
	this.edit.visible = true;
}

private function resetLoginButton():void
{
	loginb.text = "Log Out";
	loginb.toolTip = "Log Out";
	loginb.removeEventListener(MouseEvent.CLICK, handleLoginPopUpCreation);
	loginb.addEventListener(MouseEvent.CLICK, handleLogOff);
	this.link.visible = true;
	this.link.includeInLayout = true;
}

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
	loginb.text = "Log In";
	loginb.toolTip = "Log in using your EPA LAN or EPA Portal username and password, after obtaining CADDIS community access.";
	loginb.removeEventListener(MouseEvent.CLICK, handleLogOff);
	loginb.addEventListener(MouseEvent.CLICK, handleLoginPopUpCreation);
	//close diagram when logged off except published diagrams or close all??
	if(Model.diagram != null && Model.diagram.diagramStatusId !=  Constants.LL_PUBLISHED_STATUS)
		handleCloseFnc();
	Model.user = null;
	resetUser();
	
	this.link.visible = false;
	this.link.includeInLayout = false;
}

private function handleCloseFnc():void
{
	Model.mode = Model.MODE_NONE;
	//TODO: close open diagram
	//broadcastMenuItemClick("close");
}

/* WARNING FUNCTIONS */
private function handleAction(actionFnc:Function):void
{
	//set current load
	handleLogOffFunc();
	warnUserAboutDiagram();
}

private function warnUserAboutDiagram():void
{
	//check if the user had loaded a diagram
	if(Model.mode != Model.MODE_NONE && Model.diagram != null)
	{
		var msg:String = " Do you want to save the current diagram before proceeding? Click \"Yes\" to automatically save and close the current diagram; click \"No\" to close it without saving any changes." ;
		Alert.show(msg,"WARNING",(Alert.YES | Alert.NO),null,handleUserWarnResponse,null,Alert.YES);
	}
	
}

private function handleUserWarnResponse(event:CloseEvent):void
{
	//Alert.show("CurrentAction in Tab " + event.detail);
	if(event.detail == Alert.YES)
	{
		handleSave(null);
	}
	
}
/* END OF WARNING FUNCTIONS */

private function handleSave(event:MouseEvent):void
{
	var s:Service = new Service();
	s.serviceHandler = handleSaveDiagram;
	

		
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
		
		
		//change the mouse to a busy cursor
		CursorManager.setBusyCursor();
	
}

private function handleSaveDiagram(event:ResultEvent):void
{
	Model.diagram.id = event.result as Number;
	//reset the orginialId in case revision diagram was saved to overwrite the existing diagram
	Model.diagram.orginialId = 0;
	
	//remove busy cursor
	CursorManager.removeBusyCursor();
	Alert.show("Diagram was successfully saved.", "INFORMATION", Alert.OK, null, handleSaveResponse, null, Alert.OK);
	
}

private function handleSaveResponse(event:CloseEvent):void
{
	//check if a warning message was displayed
/*	if(warningDisplayed==true)
	{
		currentAction();
		warningDisplayed = false;		 
	}*/
}