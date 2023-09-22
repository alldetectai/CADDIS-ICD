import flash.events.MouseEvent;

//pop up pointer to panel
private var pprPanel;

public function initUploadCitations():void
{
	//uploadcitations.addEventListener(MouseEvent.CLICK,handleUploadReferences);
}

/* HANDLE UPLOAD REFERENCES */
private function handleUploadReferences(event:MouseEvent):void
{
	//create pop up panel
	pprPanel = new UploadReferences();
	pprPanel.addEventListener(FlexEvent.INITIALIZE,handleUploadCreation);
	//add to manager
	PopUpManager.addPopUp(pprPanel, this.parent, true);
	PopUpManager.centerPopUp(pprPanel);
	pprPanel.y = 100;
}


private function handleUploadCreation(event:FlexEvent):void
{
	//add listeners
	pprPanel.cancelb.addEventListener(MouseEvent.CLICK,cancel);
	pprPanel.addEventListener(CloseEvent.CLOSE,closePanel);
}

private function cancel(event:MouseEvent):void
{
	closeUploadRefsPopUp();
}

private function closePanel(event:CloseEvent):void
{
	closeUploadRefsPopUp();
}

private function closeUploadRefsPopUp():void
{
	//remove pop up
	PopUpManager.removePopUp(pprPanel);
	pprPanel = null;
	//set focus 
	this.setFocus();
}