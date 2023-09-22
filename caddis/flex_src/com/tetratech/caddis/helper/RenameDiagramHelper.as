// ActionScript file
import com.tetratech.caddis.drawing.CDiagram;
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.view.RenameDiagram;

import flash.events.MouseEvent;

import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;


private var dpPanel;


/* RENAME DIAGRAM */
private function handleRenameDiagram(event:MouseEvent):void
{	
	Model.selectedDiagram = ppPanel.diagrams.selectedItem as CDiagram;
//	var index:Number = Model.selectedDiagram.name.lastIndexOf(' - ');
//	
//	Model.selectedDiagramStatus = Model.selectedDiagram.name.substring(index);
//	Model.selectedDiagram.name = Model.selectedDiagram.name.substring(0, index);
	//create pop up panel
	dpPanel = new RenameDiagram();
	dpPanel.addEventListener(FlexEvent.INITIALIZE,handleRenameDiagramPopUpCreation)
	//add to manager
	PopUpManager.addPopUp(dpPanel, this.parent, true);
	PopUpManager.centerPopUp(dpPanel);
	dpPanel.y = 100;
}

private function handleRenameDiagramPopUpCreation(event:FlexEvent):void
{
	//add listeners
	dpPanel.saveb.addEventListener(MouseEvent.CLICK, existsDiagramWithSameName4);
	dpPanel.cancelb.addEventListener(MouseEvent.CLICK, cancelRenamePopUp);
	dpPanel.addEventListener(CloseEvent.CLOSE,closeRenamePopUp );
	Model.selectedDiagram = ppPanel.diagrams.selectedItem as CDiagram;
	dpPanel.dname.text = Model.selectedDiagram.name;
	dpPanel.dloc.text = Model.selectedDiagram.location;
	dpPanel.dkeywords.text = Model.selectedDiagram.keywords;
	dpPanel.ddesc.text = Model.selectedDiagram.description;
}


private function existsDiagramWithSameName4(event:MouseEvent):void
{
	var valArray:Array = new Array();
	valArray.push(dpPanel.valDName);
	valArray.push(dpPanel.valDDesc);
	valArray.push(dpPanel.valDKeywords);
	valArray.push(dpPanel.valDLoc);
	var validatorErrorArray:Array = Validator.validateAll(valArray);
	if(validatorErrorArray.length == 0)
	{
		var s:Service = new Service();
		s.serviceHandler = handleDiagramNameCheck4;
		s.checkDiagram(dpPanel.dname.text);
	}
	else
	{
		dpPanel.error.visible = true;
	}

}


private function handleDiagramNameCheck4(event:ResultEvent):void
{
	
	var diagramId:Number = event.result as Number;
	if(diagramId > 0 && diagramId != Model.selectedDiagram.id)
	{
		var msg:String = "A diagram with the same name already exists. Please choose another diagram name.";
		Alert.show(msg,"INFORMATION",Alert.OK,null,null,null,Alert.OK);
	}
	else
	{
		 renameDiagram();
	}	

}

private function renameDiagram():void
{
	var valArray:Array = new Array();
	valArray.push(dpPanel.valDName);
	valArray.push(dpPanel.valDDesc);
	valArray.push(dpPanel.valDKeywords);
	valArray.push(dpPanel.valDLoc);
	var validatorErrorArray:Array = Validator.validateAll(valArray);
	if(validatorErrorArray.length == 0)
	{
		var s:Service = new Service();
		s.serviceHandler = handleRenameDiagramResponse;
		var diagram:CDiagram = new CDiagram();
		diagram.name = dpPanel.dname.text;
		diagram.location = dpPanel.dloc.text;
		diagram.keywords = dpPanel.dkeywords.text;
		diagram.description = dpPanel.ddesc.text;
		s.updateDiagramDetails(diagram, Model.user.userId, Model.selectedDiagram.id);
	}
	else
	{
		dpPanel.error.visible = true;
	}

}

private function handleRenameDiagramResponse(event:ResultEvent):void
{
	var result:Boolean = event.result as Boolean;
	//if locked
	if(!result)
	{
		Alert.show("Diagram could not be saved", "INFORMATION", Alert.OK);
	}
	else 
	{

		if(Model.diagram != null && Model.diagram.id == Model.selectedDiagram.id)
			handleCloseFnc();
		Model.selectedDiagram = null;
		//Model.selectedDiagramStatus = "";
		closeRenameDiagram();
		closePopUp();
		Alert.show("Diagram was successfully saved.", "INFORMATION", Alert.OK);
		
	}
}

private function closeRenamePopUp(event:CloseEvent):void
{
	closeRenameDiagram();
}

private function cancelRenamePopUp(event:MouseEvent):void
{
	closeRenameDiagram()
}

private function closeRenameDiagram():void
{
//	if(Model.selectedDiagram != null)
//		Model.selectedDiagram.name = Model.selectedDiagram.name + Model.selectedDiagramStatus;
	//remove pop up
	PopUpManager.removePopUp(dpPanel);
	dpPanel = null;
	
	//set focus 
	this.setFocus();
}
