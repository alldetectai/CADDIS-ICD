import com.adobe.utils.StringUtil;
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.drawing.CShape;
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.view.NewLinkageHelp;
import com.tetratech.caddis.vo.Citation;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.CheckBox;
import mx.events.CloseEvent;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.ItemClickEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

private var evidenceCitation:Citation 
private var citationList:ArrayCollection=null; 
private var addEditPanel = null;

public function init():void
{
	//Jan 15 2010
	if(Model.user.roleId == Constants.LL_REGISTERED_USER)
	{
//		editcitationb.visible = false;
	}
	this.addEventListener(CloseEvent.CLOSE, closeAddAndEditDialog);
	//filter event listener
	filterc.addEventListener(KeyboardEvent.KEY_UP,filterCitationsHandler);
//	searchb.addEventListener(MouseEvent.CLICK, searchCitations);
//	newcitationb.addEventListener(MouseEvent.CLICK, initNewCitation);
//	editcitationb.addEventListener(MouseEvent.CLICK, initEditCitation);
	searchExternalSourceb.addEventListener(MouseEvent.CLICK, initSearchExternalCitation);
	//add event listeners
//	citations.addEventListener(MouseEvent.DOUBLE_CLICK,doubleClickHandler);
	selectedCitation.addEventListener(ItemClickEvent.ITEM_CLICK, handleSelectedCitation);
	//selcitations.addEventListener(KeyboardEvent.KEY_UP,keyHandler);
	//selcitations.addEventListener(DragEvent.DRAG_DROP,dropHandler);
	//help.addEventListener(MouseEvent.CLICK,handleHelp);
	//get all citations
	getAllCitations(null);
}

private function searchCitations(event:MouseEvent):void
{
	if(filterc.text!=null && StringUtil.trim(filterc.text).length > 0)
		getAllCitations(filterc.text);
	else
		getAllCitations(null);
}

private function filterCitationsHandler(event:KeyboardEvent):void
{
	if(filterc.text!=null && StringUtil.trim(filterc.text).length > 0)
		getAllCitations(filterc.text);
	else
		getAllCitations(null);
}

private function getAllCitations(filter:String):void
{
	trace("filtering citations: "+filter);
	var s:Service = new Service();
	s.serviceHandler = handleGetAllCitations;
	//if the user specifices a filter get filtered citations
	//otherwise get the entire list
	if(filter==null||filter.length==0)
		s.getAllCitations();
	else
		s.searchCitations(filter);
}

private function handleGetAllCitations(event:ResultEvent):void
{
	//update citations
	var rc:ArrayCollection = event.result as ArrayCollection;
	trace("filtering: "+rc.length);
	//move the new citations on top of the list
	moveNewCitationsOnTop(rc);
	citationList = rc;
	//assign data provider
	citations.dataProvider = rc;
	citations.labelField = "displayTitle";
	//update selected citations
	//selcitations.labelField = "displayTitle"
	//select the first item of the list if necessary
	if(Model.addedNewCitation)
	{
		citations.selectedIndex = 0;
		Model.addedNewCitation = false;
	}
}

//this method returns true you move the new citations to the top
private function moveNewCitationsOnTop(citations:ArrayCollection):void
{
	if(Model.newCitations!=null && Model.newCitations.length > 0)
	{
		//loop through the new citations
		for(var i:int=0;i<Model.newCitations.length;i++)
		{
			var cId:Number = Model.newCitations[i];
			var index:Number = findCitationIndexById(citations,cId);
			//if you can find the new citation
			//move the item on the top
			if(index != -1)
			{
				var ec:Citation = citations.removeItemAt(index) as Citation;
				citations.addItemAt(ec,0);
			}
		}
		
	}
}

private function findCitationIndexById(citations:ArrayCollection,id:Number):Number
{
	for(var i:int=0;i<citations.length;i++)
	{
		var c:Citation = citations[i];
		if(c.id == id)
			return i;
	}
	return -1;
}

//this function is used to delete items from the list of selected citations
private function keyHandler(event:KeyboardEvent):void
{
	//try to delete items from the list if necessary
	if(event.keyCode == Constants.KEYCODE_DELETE)
	{
		//if(selcitations.selectedItem!=null)
		//{
		//	selcitations.dataProvider.removeItemAt(selcitations.dataProvider.getItemIndex(selcitations.selectedItem));
		//}
	}
}

//this function is used to remove duplicates from the list of selected citations
private function dropHandler(event:DragEvent):void
{
	//get the first citation (there is only one the whole time)
	var c:Citation = event.dragSource.dataForFormat("items")[0] as Citation;
	//remove duplicate if necessary
	//var index:int = findCitationIndex(selcitations.dataProvider as ArrayCollection,c);
	//if(index>=0)
		//selcitations.dataProvider.removeItemAt(index);
}

//double click to move items from one list to the other
private function doubleClickHandler(event:MouseEvent):void
{
	//get the current selected citation
	var c:Citation = citations.selectedItem as Citation;
	if(c!=null)
	{
		//check if the citation has been already added
		//if(findCitationIndex(selcitations.dataProvider as ArrayCollection,c)<0)
		//{
			//add to the selected citations and remove from the existing citations
		//	selcitations.dataProvider.addItem(c);
		//	citations.dataProvider.removeItemAt(citations.dataProvider.getItemIndex(c));
		//}
	}
	
}

private function handleSelectedCitation(event:ItemClickEvent):void
{
	//create pop up panel
	addEditPanel = new AddEditEvidence();
	evidenceCitation = citationList.getItemAt( event.index) as Citation;
//	Alert.show("select citation: " + evidenceCitation.author);
	addEditPanel.addEventListener(FlexEvent.INITIALIZE,handleAddEditEvidenceCreation);
	
	
	//add to manager
	PopUpManager.addPopUp(addEditPanel, this.parent, true);
	PopUpManager.centerPopUp(addEditPanel);
	ppPanel.y = 100;
		
}

private function handleAddEditEvidenceCreation(event:FlexEvent) : void
{
	addEditPanel.cancelb.addEventListener(MouseEvent.CLICK,cancelAddEdit);
	addEditPanel.saveb.addEventListener(MouseEvent.CLICK,saveAddEditEvidence);
	//addEditPanel.addEditb.addEventListener(MouseEvent.CLICK,goCADLinkAddEditEvidence);
	addEditPanel.citationDesc.text = evidenceCitation.author + " (" + evidenceCitation.year + ") " + evidenceCitation.title;
	addEditPanel.addEventListener(CloseEvent.CLOSE,closeAddEditPanel);
	getEvidenceByCitationId(evidenceCitation.id);
}

private function getEvidenceByCitationId(citationId:Number) : void
{
	var s:Service = new Service();
	s.serviceHandler = handleGetAllEvidenes;
	
	s.getAllEvidenceForCitation(citationId);
}

private function handleGetAllEvidenes(event:ResultEvent):void
{
	//update citations
	var rc:ArrayCollection = event.result as ArrayCollection;

	addEditPanel.evidences.dataProvider = rc;
}


private function saveAddEditEvidence(event:MouseEvent):void
{
	var allEvidences:ArrayCollection = addEditPanel.evidences.dataProvider;
	var selectedEvidences:ArrayCollection = new ArrayCollection();
	
	for each (var currentItem:Object in allEvidences)
	{
		var cellValue:Boolean = currentItem.selected; 
		
		if(cellValue) {
			//Alert.show("Please " + currentItem.causeEffectId.toString() + " is selected");
				selectedEvidences.addItem(currentItem);
		}
		
	}
	if(selectedEvidences.length == 0) {
			Alert.show("Please select at least one reference when creating a linkage.","INFORMATION");
	}
	else {
		createPrimaryLinkages(selectedEvidences);
	}
	
	
}

private function createPrimaryLinkages(selCits:ArrayCollection):void
{
	var newLinkageShapes:ArrayCollection = this.shapes.dataProvider as ArrayCollection;
	var causeShapes:ArrayCollection = this.causeShapes.dataProvider as ArrayCollection;
	var causeShape:CShape = causeShapes.getItemAt(0) as CShape;
		//create linkages
		for(var m:int=0;m<newLinkageShapes.length;m++)
		{
			var s:CShape = newLinkageShapes[m];
			//link the primary shape to other shape
			causeShape.addLinkage(s,selCits, false);//set before popup created
			//link the other shape to the primary shape
			s.addLinkage(causeShape,selCits, true);
			
		}
		
	closeAddEditPopUp();
}


private function goCADLinkAddEditEvidence(event:MouseEvent):void
{
	Alert.show("Go to CADLink");
}
private function cancelAddEdit(event:MouseEvent):void
{	
	closeAddEditPopUp();
}

private function closeAddEditPanel(event:CloseEvent):void
{
	closeAddEditPopUp();
}

private function closeAddEditPopUp():void
{
	//remove pop up
	PopUpManager.removePopUp(addEditPanel);
	addEditPanel = null;
	//set focus 
	this.setFocus();
}
//utility function to find a citation in a list
private function findCitationIndex(cts:ArrayCollection,c:Citation):int
{
	for(var i:int=0;i<cts.length;i++)
	{
		var sc:Citation = cts.getItemAt(i) as Citation;
		//compare the citations ids
		if(sc.id == c.id)
		{
			return i;
		}
	}
	return -1;
}

private function initSearchExternalCitation(event:MouseEvent):void
{
	searchExternalCitations();
}

private function initNewCitation(event:MouseEvent):void
{
	addCitation();
}

private function initEditCitation(event:MouseEvent):void
{
	if(citations.selectedItem != null)
	{
		var c:Citation = citations.selectedItem as Citation;
		var s:Service = new Service();
		s.serviceHandler = prePopulateCitation;
		s.getCitation(c.id);
	}
}

private function prePopulateCitation(event:ResultEvent):void
{
	var c:Citation = event.result as Citation;
	editCitation(c);
}
/*
private function handleHelp(event:MouseEvent):void
{
	
	newLnkHelp = new NewLinkageHelp();
	newLnkHelp.addEventListener(CloseEvent.CLOSE, closeHelp);
	PopUpManager.addPopUp(newLnkHelp,this,true);
	PopUpManager.centerPopUp(newLnkHelp);
}

private function closeHelp(event:CloseEvent):void
{
	PopUpManager.removePopUp(newLnkHelp);
	newLnkHelp = null;
	//set focus 
	this.setFocus();
}
*/