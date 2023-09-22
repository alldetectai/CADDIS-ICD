// ActionScript file
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.view.AdminPopUp;

import flash.events.MouseEvent;

import mx.events.FlexEvent;

private var adminPopUp:AdminPopUp=null;
private var diagramStatusId:Number = Constants.LL_IN_REVIEW_STATUS;

private function handleAdmin(event:MouseEvent):void
{
	//create pop up panel
	adminPopUp = new AdminPopUp();
	adminPopUp.addEventListener(FlexEvent.INITIALIZE, handleAdminPopUpInit);
	adminPopUp.addEventListener(CloseEvent.CLOSE, closeAdminPopUpCloseEvent);

	//add to manager
	PopUpManager.addPopUp(adminPopUp, this.parent.parent, true);
	PopUpManager.centerPopUp(adminPopUp);
	adminPopUp.y = 100;	
}

private function handleAdminPopUpInit(event:FlexEvent):void
{
	//note: only review/published/archived diagrams can be opened to change the status
	adminPopUp.saveb.addEventListener(MouseEvent.CLICK, handleAdminSave);
	adminPopUp.closeb.addEventListener(MouseEvent.CLICK, closeAdminPopUpMouseEvent);
	adminPopUp.reviewCLink.addEventListener(MouseEvent.CLICK, handleReviewCitations);
	
	//adminPopUp.archiveCB.selected = Model.diagram.diagramStatusId == Constants.LL_ARCHIVED_STATUS;
	adminPopUp.publishCB.selected = Model.diagram.diagramStatusId == Constants.LL_PUBLISHED_STATUS;
	//adminPopUp.draftCB.selected = Model.diagram.diagramStatusId == Constants.LL_DRAFT_STATUS;
	//12/24/2009
	//adminPopUp.goldSealCB.selected = Model.diagram.goldSeal;
	adminPopUp.lockCB.selected = Model.diagram.locked;
	//if locked by other user disable the checkbox 
	if(Model.diagram.locked && Model.diagram.lockedUser.userId != Model.user.userId) {
	//	adminPopUp.draftCB.enabled = false;
		adminPopUp.lockCB.enabled = false;
		adminPopUp.lockCB.label = "Lock this Diagram (Locked by " + Model.diagram.lockedUser.firstName + " " + Model.diagram.lockedUser.lastName + ")";
		
	}
	//adminPopUp.archiveCB.addEventListener(MouseEvent.CLICK,handleArchiveClick);
	//adminPopUp.publishCB.addEventListener(MouseEvent.CLICK,handlePublishClick);
	//adminPopUp.draftCB.addEventListener(MouseEvent.CLICK,handleDraftClick);
	//adminPopUp.lockCB.addEventListener(MouseEvent.CLICK,handleLockDiagramClick);
}
/*
private function handleArchiveClick(event:MouseEvent):void
{
	adminPopUp.publishCB.selected = false;
	adminPopUp.draftCB.selected = false;
}

private function handleDraftClick(event:MouseEvent):void
{
	adminPopUp.publishCB.selected = false;
	adminPopUp.archiveCB.selected = false;
	adminPopUp.lockCB.selected = false;
}

private function handlePublishClick(event:MouseEvent):void
{
	adminPopUp.archiveCB.selected = false;
	adminPopUp.draftCB.selected = false;
}

private function handleLockDiagramClick(event:MouseEvent):void
{
	adminPopUp.draftCB.selected = false;
}
*/
private function handleAdminSave(event:MouseEvent):void
{
	//ADMIN BUTTON ENBALED ONLY FOR EPA USER AND STATUS IN-Review or higher

	diagramStatusId = Constants.LL_IN_REVIEW_STATUS;
	if(adminPopUp.publishCB.selected)
		diagramStatusId = Constants.LL_PUBLISHED_STATUS;
		/*
	else if(adminPopUp.archiveCB.selected)
		diagramStatusId = Constants.LL_ARCHIVED_STATUS;
	else if(adminPopUp.draftCB.selected) {
		diagramStatusId = Constants.LL_DRAFT_STATUS;
		lockedUserId = 0;
		adminPopUp.lockCB.selected = false;
	}
*/
	var lockedUserId:Number = 0;
	
	if(Model.diagram.locked) {
		//if diagram locked by other user do not override lockeduser id
		lockedUserId = Model.diagram.lockedUser.userId;
	}
	else if(adminPopUp.lockCB.selected)
	{
		//if locked by current user
		lockedUserId = Model.user.userId;
	}
		
	if(!adminPopUp.lockCB.selected)
		lockedUserId = 0;	//if unlocked remove lockeduserid
		
	var s:Service = new Service();
	s.serviceHandler = handleSaveDiagramStatusResponse;
		
	s.updateDiagramStatus(Model.diagram.id, diagramStatusId,
		//adminPopUp.goldSealCB.selected, //12/24/2009
		false,
		adminPopUp.lockCB.selected, lockedUserId);
}

private function handleSaveDiagramStatusResponse(event:ResultEvent):void
{
	var result:Boolean = event.result as Boolean;
	//if locked
	if(!result)
	{
		closeAdminPopUp();
		Alert.show("Status changes for this diagram was unsuccessful in saving as its been locked by other user.  Please re-open the diagram to see last updates.", "INFORMATION", Alert.OK);
	}
	else 
	{
		//update diagram 
		//Model.diagram.diagramStatusId = diagramStatusId;
		//if locked or unlocked by current user
		/*if((!Model.diagram.locked && adminPopUp.lockCB.selected) ||
		(!adminPopUp.lockCB.selected && Model.diagram.user.userId == Model.user.userId)) {
			//Model.diagram.user = Model.user;
			//Model.diagram.locked = true;
			loadDiagramByIdFunc(Model.diagram.id);
		} */
		//if(diagramStatusId != Constants.LL_DRAFT_STATUS)
			loadDiagramByIdFunc(Model.diagram.id);
		//else
		//	handleCloseFnc();
		//Model.diagram.goldSeal = adminPopUp.goldSealCB.selected;
		closeAdminPopUp();
		Alert.show("Status changes for this diagram was successfully saved.", "INFORMATION", Alert.OK);
	}
}

private function closeAdminPopUp():void
{
	PopUpManager.removePopUp(adminPopUp);
	adminPopUp = null;
	//set focus 
	this.setFocus();
}

private function closeAdminPopUpCloseEvent(event:CloseEvent):void
{
	closeAdminPopUp();
}

private function closeAdminPopUpMouseEvent(event:MouseEvent):void
{
	closeAdminPopUp();
}
