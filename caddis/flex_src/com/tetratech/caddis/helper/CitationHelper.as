// ActionScript file
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.view.SearchCitationsPopUp;
import com.tetratech.caddis.vo.Citation;
import com.tetratech.caddis.vo.LabelValue;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.CheckBox;
import mx.controls.LinkBar;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.ItemClickEvent;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.states.AddChild;

private var ippPanel = null;
private var searchFunc:String = null;
//state of cursor
private var busyCursor:Boolean = false;

/*start Search References*/
private function handleSearchCitations(event:MouseEvent):void
{
	if(Model.sourceDB  == null) {
		Model.sourceDB = new ArrayCollection();
		Model.sourceDB.addItem(Constants.SEARCH_EPA_SOURCE);
		Model.sourceDB.addItem(Constants.SEARCH_OTHER_SOURCE);
	}
	//create pop up panel
	ippPanel = new SearchCitationsPopUp();
	ippPanel.addEventListener(FlexEvent.INITIALIZE, handleSearchCitationsPopUpInit);
	ippPanel.addEventListener(CloseEvent.CLOSE, closeSearchCitationsDialog);

	//add to manager
	PopUpManager.addPopUp(ippPanel, this.parent.parent, true);
	PopUpManager.centerPopUp(ippPanel);
	ippPanel.y = 100;	
}


private function handleSearchCitationsPopUpInit(event:FlexEvent):void
{
	ippPanel.searchrefs.addEventListener(MouseEvent.CLICK, searchCitations);
	ippPanel.searchTerms.addEventListener(MouseEvent.CLICK, searchCauseAndEffect);
	ippPanel.sourceDB.dataProvider = Model.sourceDB;
}

private function closeSearchCitationsDialog(event:CloseEvent):void
{
	PopUpManager.removePopUp(ippPanel);
	ippPanel = null;
	//set focus 
	this.setFocus();
}


private function searchCitations(event:MouseEvent):void
{
	if(ippPanel.keywords.text == "") {
		Alert.show("Please enter keyword to search References","INFORMATION");
		return ;
	} if(ippPanel.keywords.text.length < 4 || ippPanel.keywords.text.length > 100) {
		Alert.show("Please enter keyword between 4 and 100 in length.","INFORMATION");
		return ;
	} else	{
		searchFunc = "searchCitationAndShape";
		//create pop up panel
		ppPanel = new CitationSearchResultsPopUp();
		ppPanel.addEventListener(FlexEvent.INITIALIZE, handleCitationSearchPopUpInit);
		ppPanel.addEventListener(CloseEvent.CLOSE, closeCitationSearchResultDialog);

		//add to manager
		PopUpManager.addPopUp(ppPanel, this.parent.parent, true);
		PopUpManager.centerPopUp(ppPanel);
		ppPanel.y = 20;
	}
}


private function searchCauseAndEffect(event:MouseEvent):void
{
	var errorMsg:String = "";
	if(ippPanel.cause.text == "") {
		errorMsg = "Please enter cause term to search References";
		
	} else if(ippPanel.cause.text.length < 4 || ippPanel.cause.text.length > 100) {
		errorMsg = "Please enter cause term between 4 and 100 in length.";
		
	} 
	if(ippPanel.effect.text == "") {
		if(errorMsg.length > 0)
			errorMsg += "\n";
		errorMsg += "Please enter effect term to search References";
		
	} else if(ippPanel.effect.text.length < 4 || ippPanel.cause.text.length > 100) {
		if(errorMsg.length > 0)
			errorMsg += "\n";
		errorMsg += "Please enter effect term between 4 and 100 in length.";
	}
	if(errorMsg.length > 0) {
		Alert.show(errorMsg,"INFORMATION");
		return ;
	}
	else	
	{
		searchFunc = "CauseAndEffectTerm";
		//create pop up panel
		ppPanel = new CitationSearchResultsPopUp();
		ppPanel.addEventListener(FlexEvent.INITIALIZE, handleCitationSearchPopUpInit);
		ppPanel.addEventListener(CloseEvent.CLOSE, closeCitationSearchResultDialog);

		//add to manager
		PopUpManager.addPopUp(ppPanel, this.parent.parent, true);
		PopUpManager.centerPopUp(ppPanel);
		ppPanel.y = 20;
	}
}


//Initializing CitationSearchresultsPopUp
private function handleCitationSearchPopUpInit(event:FlexEvent):void
{
	//add listeners
	ppPanel.selectAllCitationsb.addEventListener(MouseEvent.CLICK, handleSelectAllCitations);
	ppPanel.downloadCitaionsb.addEventListener(MouseEvent.CLICK, prepareDownloadCitations);
	ppPanel.clearAllCitaionsb.addEventListener(MouseEvent.CLICK, handleClearAllCitations);
	ppPanel.closeb.addEventListener(MouseEvent.CLICK, closeCitationSearchResultPopUp);

	ppPanel.selectAllCitationsb.enabled = false;
	ppPanel.downloadCitaionsb.enabled = false;
	ppPanel.clearAllCitaionsb.enabled = false;
	ppPanel.closeb.enabled = false;

	ppPanel.selectAllCitationsb.mouseEnabled = false;
	ppPanel.downloadCitaionsb.mouseEnabled = false;
	ppPanel.clearAllCitaionsb.mouseEnabled = false;
	ppPanel.closeb.mouseEnabled = false;
	//search
	var s:Service = new Service();
	s.serviceHandler = handlePopulateCitationSearchPopUp;

	if(searchFunc == "searchCitationAndShape") 
		s.searchCitationsNShapes(null, ippPanel.keywords.text);
	else {
		Model.selectedSourceDB = ippPanel.sourceDB.selectedItem as String;
		s.searchCitationsByCauseNEffect (ippPanel.cause.text, ippPanel.effect.text, Model.selectedSourceDB);
	}
	
	//change the mouse to a busy cursor
	CursorManager.setBusyCursor();
	busyCursor = true;

}

//populate search results
private function handlePopulateCitationSearchPopUp(event:ResultEvent):void
{
	var list:ArrayCollection = event.result as ArrayCollection;
	if(list != null && list.length > 0) {

		ppPanel.displayCitations.dataProvider = list;
		if(list.length == 1)
			ppPanel.resultsMessage.text = "Found " + list.length + " reference.";
		else
			ppPanel.resultsMessage.text = "Found " + list.length + " references.";

	    for(var i:int = 0; i < list.length ; i++) {
	    	//Alert.show("handlePopulateCitationSearchPopUp " + i);
	    	var c:Citation = (list[i]) as Citation;
			var tabList:ArrayCollection = new ArrayCollection();
			//tabList.addItem(new LabelValue("Author", c.author));
//			tabList.addItem(new LabelValue("Abstract", c.id));
//			tabList.addItem(new LabelValue("Linkages", c.id));
			tabList.addItem(new LabelValue("Abstract", c));
			tabList.addItem(new LabelValue("Citation-Specific Evidence", c));
			//if(c.inCADLIT)
			//	ppPanel.inCadlit[i].text = "In CADLit";
			//else 
			//	ppPanel.inCadlit[i].text = "Not In CADLit";

//			add to link bark		
//			if(c.cadlitSource)
//				tabList.addItem(new LabelValue("In CADLit",0));
//			else 
//				tabList.addItem(new LabelValue("Not In CADLit",0));	
			
			(ppPanel.linkbar[i] as LinkBar).dataProvider = tabList;
			ppPanel.linkbar[i].addEventListener(ItemClickEvent.ITEM_CLICK, handleLinkBarPopUpCreation);
	    }
	}
	else {
		ppPanel.resultsMessage.text = "No References found.";
	}
	
	ppPanel.selectAllCitationsb.enabled = true;
	ppPanel.downloadCitaionsb.enabled = true;
	ppPanel.clearAllCitaionsb.enabled = true;
	ppPanel.closeb.enabled = true;

	ppPanel.selectAllCitationsb.mouseEnabled = true;
	ppPanel.downloadCitaionsb.mouseEnabled = true;
	ppPanel.clearAllCitaionsb.mouseEnabled = true;
	ppPanel.closeb.mouseEnabled = true;
	
	//remove busy cursor
	CursorManager.removeBusyCursor();
	busyCursor = false;

}

private function handleClearAllCitations(event:MouseEvent):void {
	//checkedCitationList = null;
	if(ppPanel.citationCB != null) {
		var len:uint = ppPanel.citationCB.length;
		for (var i:uint = 0; i < len; i++)
	    {
	        // Reference the current checkBox instance
	        ppPanel.citationCB[i].selected = false;
	    }
 	}
}

private function handleSelectAllCitations(event:MouseEvent):void {
	//checkedCitationList = null;
	if(ppPanel.citationCB != null) {
		var len:uint = ppPanel.citationCB.length;
		for (var i:uint = 0; i < len; i++)
	    {
	        // Reference the current checkBox instance
	        ppPanel.citationCB[i].selected = true;
	    }
 	}
}

//prepares to call download popup
private function prepareDownloadCitations(event:MouseEvent):void {

	citationIds = null;
	citationIds = new ArrayCollection();
	if(ppPanel.citationCB != null) {
		var len:uint = ppPanel.citationCB.length;
		for (var i:uint = 0; i < len; i++)
	    {
	        // Reference the current checkBox instance
	        var currentItem:CheckBox= ppPanel.citationCB[i];
	        if(currentItem.selected) {
	 			citationIds.addItem(currentItem.data);
	        }
	    }
		if(citationIds.length == 0) {
			Alert.show("Please select references to download.","INFORMATION");
		}
		else {
			handleDownloadPopUpCreation(event);
		}
	}
}

private function closeCitationSearchResultPopUp(event:MouseEvent):void
{
	PopUpManager.removePopUp(ppPanel);
	ppPanel = null;
	//set focus 
	this.setFocus();
}

private function closeCitationSearchResultDialog(event:CloseEvent):void
{
	//check if you are still trying to receive results
	//Note: if  you don't do this an exception will occur
	if(!busyCursor)
	{
		PopUpManager.removePopUp(ppPanel);
		ppPanel = null;
		//set focus 
		this.setFocus();
	}
}