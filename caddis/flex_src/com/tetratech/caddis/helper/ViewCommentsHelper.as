// ActionScript file
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.view.ViewComments;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;
import mx.rpc.events.ResultEvent;

private var viewCommentsPopUp:ViewComments = null;
//flage to get internal comments for edit view
private var isInternalComments:Boolean = false;

private function handleViewComments(event:MouseEvent):void
{
	isInternalComments = false;
	//create pop up panel
	viewCommentsPopUp = new ViewComments();
	viewCommentsPopUp.addEventListener(FlexEvent.INITIALIZE, handleViewCommentsPopUpInit);
	viewCommentsPopUp.addEventListener(CloseEvent.CLOSE, closeViewCommentsPopUpCloseEvent);
	

	//add to manager
	PopUpManager.addPopUp(viewCommentsPopUp, this.parent.parent, true);
	PopUpManager.centerPopUp(viewCommentsPopUp);
	viewCommentsPopUp.y = 100;	
}

private function handleViewInternalComments(event:MouseEvent):void
{
	isInternalComments = true;
	//create pop up panel
	viewCommentsPopUp = new ViewComments();
	viewCommentsPopUp.addEventListener(FlexEvent.INITIALIZE, handleViewCommentsPopUpInit);
	viewCommentsPopUp.addEventListener(CloseEvent.CLOSE, closeViewCommentsPopUpCloseEvent);
	

	//add to manager
	PopUpManager.addPopUp(viewCommentsPopUp, this.parent.parent, true);
	PopUpManager.centerPopUp(viewCommentsPopUp);
	viewCommentsPopUp.y = 100;	
}

private function handleViewCommentsPopUpInit(event:FlexEvent):void
{
	//viewCommentsPopUp.closeb.addEventListener(MouseEvent.CLICK, closeViewCommentsPopUpMouseEvent);
	if(isInternalComments)
		viewCommentsPopUp.enterCommentB.addEventListener(MouseEvent.CLICK, handleInternalComment);
	else
		viewCommentsPopUp.enterCommentB.addEventListener(MouseEvent.CLICK, handleComment);
	var s:Service = new Service();
	s.serviceHandler = handlePopulateComments;
	s.getCommentsByDiagramId(Model.diagram.id, isInternalComments);
}

private function refreshViewComments():void
{
	var s:Service = new Service();
	s.serviceHandler = handlePopulateComments;
	s.getCommentsByDiagramId(Model.diagram.id, isInternalComments);
}

private function handlePopulateComments(event:ResultEvent):void
{
	var list:ArrayCollection = event.result as ArrayCollection;
	if(list.length  > 0) {
		if(list.length == 1)
				viewCommentsPopUp.resultsMessage.text = "Found " + list.length + " comment.";
			else
				viewCommentsPopUp.resultsMessage.text = "Found " + list.length + " comments.";
				viewCommentsPopUp.displayComments.dataProvider = list;
				
	} else {
		viewCommentsPopUp.resultsMessage.text = "No comments found.";
	}
		
}

private function closeViewCommentsPopUp():void
{
	PopUpManager.removePopUp(viewCommentsPopUp);
	viewCommentsPopUp = null;
	//set focus 
	this.setFocus();
}

private function closeViewCommentsPopUpCloseEvent(event:CloseEvent):void
{
	closeViewCommentsPopUp()
}

private function closeViewCommentsPopUpMouseEvent(event:MouseEvent):void
{
	closeViewCommentsPopUp();
}
