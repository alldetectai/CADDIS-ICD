// ActionScript file
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.view.CitationAbstractPopUp;
import com.tetratech.caddis.view.CitationsByAuthorPopUp;
import com.tetratech.caddis.view.LinkagesByCitationIDPopUp;
import com.tetratech.caddis.view.ViewCitationEvidences;
import com.tetratech.caddis.vo.Citation;
import com.tetratech.caddis.vo.DownloadData;
import com.tetratech.caddis.vo.LabelValue;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.LinkBar;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;
import mx.events.ItemClickEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.states.RemoveChild;

private var cpPanel;
////TODO: Need to format authorsearch string to get correct results for author search
private var authorSearch:String = "";
//private var citationId:Number;
private var downloadLinkages:ArrayCollection = new ArrayCollection();
private var citationIds:ArrayCollection = null;
private var citation:Citation;

//Creates different popup based on index on linkbar
private function handleLinkBarPopUpCreation(event:ItemClickEvent):void
{
	if (event.index == 0)	{
	    handleAbstractPopUpCreation(event);
	} else if (event.index == 1) {
		handleEvidenceByCitationIdPopUpCreation(event);//handleLinkagesByCitationIdPopUpCreation(event);
	} else if (event.index == 2){
		var linkBar:LinkBar = event.target as LinkBar;
		var text:String = "This Reference is "+ (linkBar.dataProvider[2] as LabelValue).label;
		Alert.show(text, "INFORMATION", Alert.OK, null, null, null, Alert.OK);
	}
}

/* Cancel button on the pop ups */
private function closeDialogPopUp(event:MouseEvent):void
{
	//remove pop up
	PopUpManager.removePopUp(cpPanel);
	cpPanel = null;
	//citationId = 0;
	authorSearch = "";
	downloadLinkages = null;
	citationIds = null;
	//set focus 
	this.setFocus();
}

private function closeDialog(event:CloseEvent):void
{
	//remove pop up
	PopUpManager.removePopUp(cpPanel);
	cpPanel = null;
	//citationId = 0;
	authorSearch = "";
	downloadLinkages = null;
	citationIds = null;
	citation = null;
	//set focus 
	this.setFocus();
}

private function handleAbstractPopUpCreation(event:ItemClickEvent):void
{
	//Alert.show(event.currentTarget.toString() + event.target.toString() + "  " + event.item.toString());
	var item:LabelValue = (event.item 	as LabelValue);
	//Alert.show("value " + item.label + " " + item.value);
	//citationId = item.value as Number;
	citation = item.value as Citation;
	//	create pop up panel
	cpPanel = new CitationAbstractPopUp();
	cpPanel.addEventListener(FlexEvent.INITIALIZE, handleAbstractPopUpInit);
	cpPanel.addEventListener(CloseEvent.CLOSE, closeDialog);
	//add to manager
	PopUpManager.addPopUp(cpPanel, this.parent, true);
	PopUpManager.centerPopUp(cpPanel);
	cpPanel.y = 100;

}

private function handleEvidenceByCitationIdPopUpCreation(event:ItemClickEvent):void
{
	var item:LabelValue = (event.item 	as LabelValue);
	//Alert.show("value " + item.label + " " + item.value);
	citation = item.value as Citation;
	cpPanel =  new ViewCitationEvidences();
	cpPanel.addEventListener(FlexEvent.INITIALIZE, handleCitationEvidenceCreation);
	
	//add to manager
	PopUpManager.addPopUp(cpPanel, this.parent, true);
	PopUpManager.centerPopUp(cpPanel);
	cpPanel.y = 100;
}

private function handleCitationEvidenceCreation(event:FlexEvent) : void
{
	
	cpPanel.addEventListener(CloseEvent.CLOSE, closeDialog);
	cpPanel.closeb.addEventListener(MouseEvent.CLICK,closeDialog);
	
	cpPanel.cinfo.text = citation.author  + " (" + citation.year + ") " + citation.title;	
	getAllByCitationId(citation.id);
}


private function getAllByCitationId(citationId:Number) : void
{
	var s:Service = new Service();
	s.serviceHandler = handleGetAllEvidenesById;
	
	s.getEvidencesForAllDiagramByCitationId(citationId);
}

private function handleGetAllEvidenesById(event:ResultEvent):void
{
	//update citations
	var rc:ArrayCollection = event.result as ArrayCollection;
	
	cpPanel.citations.dataProvider = rc;
}
/*
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
	PopUpManager.removePopUp(citationSpecificPanel);
	citationSpecificPanel = null;
	//set focus 
	this.setFocus();
}
*/
private function handleCitationsByAuthorPopUpCreation(event:ItemClickEvent):void
{
	var item:LabelValue = (event.item 	as LabelValue);
	//Alert.show("value " + item.label + " " + item.value);	
	authorSearch = item.value as String;
	//	create pop up panel
	cpPanel = new CitationsByAuthorPopUp();
	cpPanel.addEventListener(FlexEvent.INITIALIZE, handleCitationsByAuthorPopUpInit);
	cpPanel.addEventListener(CloseEvent.CLOSE, closeDialog);
	//add to manager
	PopUpManager.addPopUp(cpPanel, this.parent, true);
	PopUpManager.centerPopUp(cpPanel);
	cpPanel.y = 100;
}

private function handleLinkagesByCitationIdPopUpCreation(event:ItemClickEvent):void
{
	var item:LabelValue = (event.item 	as LabelValue);
	//Alert.show("value " + item.label + " " + item.value);	
	//citationId = item.value as Number;
	citation = item.value as Citation;
	//	create pop up panel
	cpPanel = new LinkagesByCitationIDPopUp();
	cpPanel.addEventListener(FlexEvent.INITIALIZE, handleLinkagesByCitationIdPopUpInit);
	cpPanel.addEventListener(CloseEvent.CLOSE, closeDialog);
	//add to manager
	PopUpManager.addPopUp(cpPanel, this.parent, true);
	PopUpManager.centerPopUp(cpPanel);
	cpPanel.y = 100;
}

////Initializing handleAbstractPopUpInit
private function handleAbstractPopUpInit(event:FlexEvent):void
{
	//add listeners
	cpPanel.closeb.addEventListener(MouseEvent.CLICK, closeDialogPopUp);
	if(Model.selectedSourceDB == Constants.SEARCH_OTHER_SOURCE)
		populateAbstractPopup(citation);
	else {
		//get abstract data
		var s:Service = new Service();
		s.serviceHandler =  handlePopulateAbstractPopUp;
		s.getCitation(citation.id);
	}
}

////Initializing handleOtherCitationsByAuthorPopUpInit
private function handleCitationsByAuthorPopUpInit(event:FlexEvent):void
{
	//add listeners
	cpPanel.closeb.addEventListener(MouseEvent.CLICK, closeDialogPopUp);
	//get abstract data
	var s:Service = new Service();
	s.serviceHandler = handlePopulateCitationsByAuthorPopUp;
	s.searchCitations(authorSearch);
}

////Initializing handleLinakgePopUpInit
private function handleLinkagesByCitationIdPopUpInit(event:FlexEvent):void
{
	//add listeners
	cpPanel.tabNav.addEventListener(IndexChangedEvent.CHANGE, handleTabNavChangeEvent);
	if(Model.selectedSourceDB == Constants.SEARCH_OTHER_SOURCE)
		cpPanel.addEventListener(FlexEvent.CREATION_COMPLETE, handleLinkagesByCitationIdPopUpComp);
	else {

		var s:Service = new Service();
		s.serviceHandler = handlePopulateLinkageCauseEffectPopUp;
		s.getCauseEffectByCitationID(citation.id);
	}
}

private function handleLinkagesByCitationIdPopUpComp(event:FlexEvent):void{
	cpPanel.tabNav.getTabAt(1).visible = false;
	cpPanel.tabNav.getTabAt(1).includeInLayout = false; 
	cpPanel.tabNav.getTabAt(2).visible = false;
	cpPanel.tabNav.getTabAt(2).includeInLayout = false; 

	cpPanel.causeEffectList.dataProvider = citation.causeEffectLinkage;
}

private function handlePopulateAbstractPopUp(event:ResultEvent):void {
	var c:Citation = event.result as Citation;
	populateAbstractPopup(c);
}

private function populateAbstractPopup(c:Citation):void {
	if(c != null && c.citationAbstract != null) {
		cpPanel.resultsMessage.text = "Abstract for Reference: ";
		cpPanel.abstractText.htmlText = c.citationAbstract;
	}
	else 
		cpPanel.resultsMessage.htmlText = "No Abstract Found for reference: ";
	cpPanel.ref.htmlText = citation.displayTitle;
}

private function handlePopulateCitationsByAuthorPopUp(event:ResultEvent):void {
	var list:ArrayCollection = event.result as ArrayCollection;
	if(list != null && list.length > 0) {
		cpPanel.displayCitations.dataProvider = list;
		if(list.length == 1)
			cpPanel.resultsMessage.text = "Found " + list.length + " reference.";
		else
			cpPanel.resultsMessage.text = "Found " + list.length + " references.";
	}
	else 
		cpPanel.resultsMessage.text  = "No References Found.";
}
 		
private function handlePopulateLinakgesByCitationIdPopUp(event:ResultEvent):void {

	var selectedLinkages:ArrayCollection = event.result as ArrayCollection;
	if(selectedLinkages != null && selectedLinkages.length > 0 ) {
		if(selectedLinkages.length == 1)
			cpPanel.linkageResultsMessage.text = "Found " + selectedLinkages.length + " linkage for reference: ";
			
		else
			cpPanel.linkageResultsMessage.text = "Found " + selectedLinkages.length + " linkages for reference: ";
		cpPanel.displayLinkages.dataProvider = selectedLinkages;
	}
	else
		cpPanel.linkageResultsMessage.text = "No linkages found for reference: ";
	cpPanel.ref2.htmlText = citation.displayTitle;	
}

private function handleTabNavChangeEvent(event:IndexChangedEvent):void
{
	//first time diagram tab clicked; retreive diagrams from Database
	if(event.newIndex == 1 && cpPanel.diagramResultsMessage.text.length == 0) {
		
		var s:Service = new Service();
		s.serviceHandler = handlePopulateLinkageDiagramPopUp;
		if(Model.user.userId != 0)
			s.getDiagramNamesByCitationIdNUser(citation.id, Model.user.userId);
		else
			s.getDiagramNamesByCitationID(citation.id);
	} 
	//first time linkage tab clicked; retreive linkages from Database
	if(event.newIndex == 2 && cpPanel.linkageResultsMessage.text.length == 0) {
		
		if(Model.diagram != null)
		{
			var s:Service = new Service();
			s.serviceHandler =  handlePopulateLinakgesByCitationIdPopUp;
			s.getLinakgesByCitationIdNDiagramId(citation.id, Model.diagram.id);
			
		}
		else
			cpPanel.linkageResultsMessage.text = "Please open a diagram to view linkages.";
	}
}

private function handlePopulateLinkageDiagramPopUp(event:ResultEvent):void
{
	var names:ArrayCollection = event.result as ArrayCollection;
	if(names != null && names.length > 0 ) {
		if(names.length == 1)
			cpPanel.diagramResultsMessage.text  = "Found " + names.length + " diagram for reference: ";
		else
			cpPanel.diagramResultsMessage.text = "Found " + names.length + " diagrams for reference: ";
			cpPanel.diagramNames.dataProvider = names;
	}
	else
		cpPanel.diagramResultsMessage.text = "No diagrams found for reference: ";
	cpPanel.ref1.htmlText = citation.displayTitle;
}

private function handlePopulateLinkageCauseEffectPopUp(event:ResultEvent):void
{

	var evidence:ArrayCollection = event.result as ArrayCollection;
	if(evidence != null && evidence.length > 0 ) {
		if(evidence.length == 1)
			cpPanel.causeEffectListMessage.text  = "Found " + evidence.length + " cause and effect relationship for reference: ";
		else
			cpPanel.causeEffectListMessage.text = "Found " + evidence.length + " cause and effect relationship for reference: ";
			cpPanel.causeEffectList.dataProvider = evidence;
	}
	else
		cpPanel.causeEffectListMessage.text = "No cause and effect relation found for reference: ";
	cpPanel.ref.htmlText = citation.displayTitle;
}
//Both citation search panel and linkages panel use this download functions
public function handleDownloadPopUpCreation(event:MouseEvent):void
{
	//create pop up panel
	cpPanel = new DownloadCitationsPopup();
		
	cpPanel.addEventListener(FlexEvent.INITIALIZE, handleDownloadPopUpInit);
	cpPanel.addEventListener(CloseEvent.CLOSE, closeDialog);
	//add to manager
	PopUpManager.addPopUp(cpPanel, this.parent, true);
	PopUpManager.centerPopUp(cpPanel);
	cpPanel.y = 100;
	
}
//initialize 
private function handleDownloadPopUpInit(event:FlexEvent):void
{
	if(downloadLinkages != null && downloadLinkages.length != 0 )
		cpPanel.linkage.visible = true;
	//add listeners
	cpPanel.downloadb.addEventListener(MouseEvent.CLICK, handleSavingDownloadData);
	cpPanel.closeb.addEventListener(MouseEvent.CLICK, closeDialogPopUp);
}

private function handleSavingDownloadData(event:MouseEvent):void {
	var includeAbstract:Boolean = cpPanel.abstract.selected;
	var includeLinkage:Boolean = cpPanel.linkage.selected;
	var downloadInfo:DownloadData = new DownloadData();
	
	if(citationIds != null && citationIds.length != 0)
		downloadInfo.citationIds = citationIds;
	else
		downloadInfo.selectedLinakge = downloadLinkages;
	downloadInfo.format = cpPanel.format.selectedValue;
	downloadInfo.includeAbstract = includeAbstract;
	downloadInfo.includeLinkage = includeLinkage;
	
	var s:Service = new Service();
	s.serviceHandler = handleCitationDownload;
	s.saveDownloadData(downloadInfo);
}


private function handleCitationDownload(event:ResultEvent):void
{
	var url:URLRequest = new URLRequest("DownloadCitation");
	navigateToURL(url, "_blank");
}

