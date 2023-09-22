// ActionScript file
import com.tetratech.caddis.drawing.CDiagram;
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.view.ReviewDiagramHistory;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.DateField;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;


private var rdhPanel:ReviewDiagramHistory = null;


/*start Search References*/
private function handleReviewDiagramHistory(event:MouseEvent):void
{
//create pop up panel
	rdhPanel = new ReviewDiagramHistory();
	rdhPanel.addEventListener(FlexEvent.INITIALIZE, handleReviewDiagamHistoryInit);
	rdhPanel.addEventListener(CloseEvent.CLOSE, closeReviewDiagamHistoryCloseEvent);

	//add to manager
	PopUpManager.addPopUp(rdhPanel, this.parent.parent, true);
	PopUpManager.centerPopUp(rdhPanel);
	rdhPanel.y = 20;
}

private function handleReviewDiagamHistoryInit(event:FlexEvent):void
{
	//search
	Model.selectedDiagram = ppPanel.diagrams.selectedItem as CDiagram;
	rdhPanel.dname.text = Model.selectedDiagram.name;
	rdhPanel.closeb.addEventListener(MouseEvent.CLICK, closeReviewDiagamHistoryMouseEvent);
	
	var s:Service = new Service();
	s.serviceHandler = handlePopulateRevisionList;
	s.getRevisionDiagrams(Model.selectedDiagram.id);
	
	var s2:Service = new Service();
	s2.serviceHandler = handlePopulateCommentList;
	s2.getCommentsByDiagramId(Model.selectedDiagram.id, true);
}

private function handlePopulateCommentList(event:ResultEvent):void
{
	var list:ArrayCollection = event.result as ArrayCollection;
	rdhPanel.comments.dataProvider = list;
}

private function handlePopulateRevisionList(event:ResultEvent):void
{
	var list:ArrayCollection = event.result as ArrayCollection;
	rdhPanel.diagramList.dataProvider = list;
	rdhPanel.updatedUser.labelFunction = formatUserInfo;
	
	rdhPanel.diagramList.addEventListener(ListEvent.ITEM_CLICK, handleDeleteRevisionDiagram);
	rdhPanel.diagramList.addEventListener(MouseEvent.DOUBLE_CLICK, handleOpenRevisionDiagram);

}

//used in datagrid
private function formatUserInfo(item:Object, col:DataGridColumn):String
{
     return item.updatedUser.firstName + " " + item.updatedUser.lastName;
}

private function formatDate(item:Object, col:DataGridColumn):String
{
	return DateField.dateToString(item.updatedDate, "MM/DD/YYYY");
}

////click="outerDocument.removeDiagramItem(data as CDiagram);"
//public function removeDiagramItem(data:CDiagram):void
//{
//	Alert.show("delete revision diagram" + data.name + " " + data.id );
//}

private function handleDeleteRevisionDiagram(event:ListEvent):void
{
	//trace(event.rowIndex + event.columnIndex);
	if(event.columnIndex == 4) {
		var msg:String = "Do you want to delete selected revision diagram? Click \"Yes\" to proceed with deleting the diagram; click \"No\" to abort the deleting diagram." ;
		Alert.show(msg,"WARNING",(Alert.YES | Alert.NO),null,handleRevDeleteDiagramWarnResponse,null,Alert.YES);
	}
}

private function handleRevDeleteDiagramWarnResponse(event:CloseEvent):void
{
	if(event.detail == Alert.YES)
	{
		var s:Service = new Service();
		s.serviceHandler = handleRevDeleteDiagramResponse;
		var diagram:CDiagram = rdhPanel.diagramList.selectedItem as CDiagram;
		s.deleteRevisionDiagram(diagram.id);
	}
	//else do nothing
}

private function handleRevDeleteDiagramResponse(event:ResultEvent):void
{
	var result:Boolean = event.result as Boolean;
	//if locked
	if(!result)
	{
		Alert.show("Revison Diagram could not be deleted.", "INFORMATION", Alert.OK);
	}
	else 
	{
		var s:Service = new Service();
		s.serviceHandler = handlePopulateRevisionList;
		s.getRevisionDiagrams(Model.selectedDiagram.id);
		Alert.show("Revision Diagram was successfully deleted.", "INFORMATION", Alert.OK);
	}
}

private function handleOpenRevisionDiagram(event:MouseEvent):void
{
	
	var diagram:CDiagram = rdhPanel.diagramList.selectedItem as CDiagram;
	if(diagram != null) {
		loadRevisionDiagramById(diagram.id);
		closeReviewDiagamHistory();
		//close the editHomePopUp
		//closePopUp();
	}
}

private function loadRevisionDiagramById(id:Number):void
{
	//make call to retrieve the diagram
	var s:Service = new Service();
	s.serviceHandler = handleLoadDiagram;
	s.loadRevisionDiagramById(id);

}

private function closeReviewDiagamHistoryCloseEvent(event:CloseEvent):void
{
	closeReviewDiagamHistory();
}

private function closeReviewDiagamHistoryMouseEvent(event:MouseEvent):void
{
	closeReviewDiagamHistory();
}

private function closeReviewDiagamHistory():void
{
	PopUpManager.removePopUp(rdhPanel);
	rdhPanel = null;
	//set focus 
	this.setFocus();
}
