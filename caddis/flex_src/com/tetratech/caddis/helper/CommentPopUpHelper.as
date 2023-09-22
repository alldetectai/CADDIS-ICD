// ActionScript file

import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.view.CommentPopUp;
import com.tetratech.caddis.view.InternalCommentPopUp;
import com.tetratech.caddis.vo.Comment;

import flash.events.MouseEvent;

import mx.events.FlexEvent;

private var commentPopUp=null;

private function handleComment(event:MouseEvent):void
{
	viewCommentsPopUp.enterCommentB.enabled = false;
	//create pop up panel
	commentPopUp = new CommentPopUp();
	commentPopUp.addEventListener(FlexEvent.INITIALIZE, handleCommentPopUpInit);
	commentPopUp.addEventListener(CloseEvent.CLOSE, closeCommentPopUpCloseEvent);

	//add to manager
	PopUpManager.addPopUp(commentPopUp, this.parent.parent, true);
	PopUpManager.centerPopUp(commentPopUp);
	commentPopUp.y = 100;	
}

private function handleCommentPopUpInit(event:FlexEvent):void
{
	commentPopUp.saveb.addEventListener(MouseEvent.CLICK, handleCommentSave);
	commentPopUp.cancelb.addEventListener(MouseEvent.CLICK, closeCommentPopUpMouseEvent);
}

private function handleCommentSave(event:MouseEvent):void
{
	//validate errors 
	var valArray:Array = new Array();
	valArray.push(commentPopUp.valName);
	valArray.push(commentPopUp.valComment);
	var validatorErrorArray:Array = Validator.validateAll(valArray);
	//close the pop up
	if(validatorErrorArray.length == 0)
	{
		var comment:Comment = new Comment();
		if(Model.diagram.orginialId != 0)
			comment.diagramId = Model.diagram.orginialId;
		else
			comment.diagramId = Model.diagram.id;
		comment.commentor = commentPopUp.commentor.text;
		comment.commentText =  commentPopUp.commentText.text;
		comment.email = commentPopUp.email.text;
		comment.userId = 0;
		
		var s:Service = new Service();
		s.serviceHandler = handleSaveCommentResponse;
		s.saveDiagramComment(comment);
	}
	else
	{
		commentPopUp.error.visible = true;
	}

}
private function handleInternalComment(event:MouseEvent):void
{
	viewCommentsPopUp.enterCommentB.enabled = false;
	//create pop up panel
	commentPopUp = new InternalCommentPopUp();
	commentPopUp.addEventListener(FlexEvent.INITIALIZE, handleInternalCommentPopUpInit);
	commentPopUp.addEventListener(CloseEvent.CLOSE, closeCommentPopUpCloseEvent);

	//add to manager
	PopUpManager.addPopUp(commentPopUp, this.parent.parent, true);
	PopUpManager.centerPopUp(commentPopUp);
	commentPopUp.y = 100;	
}

private function handleInternalCommentPopUpInit(event:FlexEvent):void
{
	commentPopUp.ctitle.text = "Enter your comment for " + Model.diagram.name + " diagram.";
	commentPopUp.saveb.addEventListener(MouseEvent.CLICK, handleInternalCommentSave);
	commentPopUp.cancelb.addEventListener(MouseEvent.CLICK, closeCommentPopUpMouseEvent);
}

private function handleInternalCommentSave(event:MouseEvent):void
{
	//validate errors 
	var valArray:Array = new Array();
	valArray.push(commentPopUp.valComment);
	var validatorErrorArray:Array = Validator.validateAll(valArray);
	//close the pop up 
	if(validatorErrorArray.length == 0)
	{
		var comment:Comment = new Comment();
		if(Model.diagram.orginialId != 0)
			comment.diagramId = Model.diagram.orginialId;
		else
			comment.diagramId = Model.diagram.id;
		comment.commentor = Model.user.firstName + " " + Model.user.lastName;
		comment.commentText =  commentPopUp.commentText.text;
		comment.email = Model.user.email;
		comment.userId = Model.user.userId;
		
		var s:Service = new Service();
		s.serviceHandler = handleSaveCommentResponse;
		s.saveDiagramComment(comment);
	}
	else
	{
		commentPopUp.error.visible = true;
	}

}


private function handleSaveCommentResponse(event:ResultEvent):void
{
	closeCommentPopUp();
	refreshViewComments();
	Alert.show("Comment for this diagram was successfully saved.", "INFORMATION", Alert.OK);
}

private function closeCommentPopUp():void
{
	viewCommentsPopUp.enterCommentB.enabled = true;
	PopUpManager.removePopUp(commentPopUp);
	commentPopUp = null;
	//set focus 
	this.setFocus();
}

private function closeCommentPopUpCloseEvent(event:CloseEvent):void
{
	closeCommentPopUp();
}

private function closeCommentPopUpMouseEvent(event:MouseEvent):void
{
	closeCommentPopUp();
}
