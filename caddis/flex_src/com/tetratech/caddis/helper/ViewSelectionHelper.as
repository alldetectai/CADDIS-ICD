// ActionScript file
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.vo.Citation;
import com.tetratech.caddis.vo.LabelValue;
import com.tetratech.caddis.vo.SelectedLinkage;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.LinkBar;
import mx.events.ItemClickEvent;
import mx.managers.CursorManager;
import mx.rpc.events.ResultEvent;

private var clickedShapes:ArrayCollection = null;
private var linkages:ArrayCollection = null;
private var savedlinkagesList:ArrayCollection = new ArrayCollection();

public function setSelectedShapes(clickedShapes:ArrayCollection):void
{
	selectedShapes.dataProvider = clickedShapes;
}

public function clearSelectedShapes():void
{
	selectedShapes.dataProvider = null;
}

//NOTE: THIS FUNCTION IS CALLED FROM DrawingBoardHelper.as
public function setSelectedLinkages(clickedShapes:ArrayCollection):void
{
	if(clickedShapes.length > 1) 
	{
		//IMPORTANT: set the clicked shapes in case you need to filter from the organism filter
		//see function below for more information
		this.clickedShapes = clickedShapes;
		//get Selected Linkages
		var s:Service = new Service();
		s.serviceHandler = handlePopulatingSelectedLinkages;
		//IMPORTANT: PASS the organism filters and the selected shapes to get the selected linkages
		/* COMMENT OUT ORGANISMS
		var filters:ArrayCollection = organismFilter.getCurrentFilters();
		var filterIds:ArrayCollection = new ArrayCollection();
		for(var i:int=0;filters!=null&&i<filters.length;i++)
				filterIds.addItem(filters[i].id);
		s.getSelectedLinkages(filterIds, clickedShapes);
		*/
		s.getSelectedLinkages(new ArrayCollection(), clickedShapes);
	}
	else
	{
		selectedLinkages.dataProvider = null;
		selectedLinkagesHB.visible = false;
		linkages = null;
		this.clickedShapes = null;
		CursorManager.removeBusyCursor();
	}
}

//NOTE: THIS FUNCTION IS CALLED FROM AccordionHelper.as
public function setSelectedLinkagesForExistingShapes(filters:ArrayCollection):void
{
	if(this.clickedShapes!=null&&this.clickedShapes.length > 1) 
	{
		var s:Service = new Service();
		//get Selected Linkages
		s.serviceHandler = handlePopulatingSelectedLinkages;
		//IMPORTANT: PASS the organism filters and the selected shapes to get the selected linkages
		var filterIds:ArrayCollection = new ArrayCollection();
		for(var i:int=0;filters!=null&&i<filters.length;i++)
				filterIds.addItem(filters[i].id);
		s.getSelectedLinkages(filterIds, clickedShapes);
	}
	else
	{
		selectedLinkages.dataProvider = null;
		selectedLinkagesHB.visible = false;
		linkages = null;
		this.clickedShapes = null;
	}
}

public function handlePopulatingSelectedLinkages(event:ResultEvent):void 
{
	linkages = event.result as ArrayCollection;
	if( linkages != null &&  linkages.length > 0) 
	{
		selectedLinkages.dataProvider =  linkages;
		//var len:int = linkbar.length;

		for(var i:int = 0; i < linkages.length ; i++) {
	    	//Alert.show("handlePopulateCitationSearchPopUp " + i);
	    	var l:SelectedLinkage = (linkages[i]) as SelectedLinkage;
	    	var list:ArrayCollection = l.citations;
	    	for(var j:int = 0; j < list.length; j++) {
	    		var c:Citation = (list[j]) as Citation;
	    		if(c.id != 0) {
	    			selectedLinkagesHB.visible = true;
					var tabList:ArrayCollection = new ArrayCollection();
					//tabList.addItem(new LabelValue("Author", c.author));
//					tabList.addItem(new LabelValue("Abstract", c.id));
//					tabList.addItem(new LabelValue("Linkages", c.id));
					tabList.addItem(new LabelValue("Abstract", c));
					tabList.addItem(new LabelValue("Citation-Specific Evidence", c));
					//if(c.inCADLIT)
					//	inCadlit[i][j].text = "In CADLit";
					//else 
					//	inCadlit[i][j].text = "Not In CADLit";
					
//put it on the link bar
//					if(c.cadlitSource)
//						tabList.addItem(new LabelValue("In CADLit",0));
//					else 
//						tabList.addItem(new LabelValue("Not In CADLit",0));
					
					(linkbar[i][j] as LinkBar).dataProvider = tabList;
					linkbar[i][j].addEventListener(ItemClickEvent.ITEM_CLICK, handleLinkBarPopUpCreation);
	    		}

	    	}
	    }
	}
	else
	{
		selectedLinkages.dataProvider = null;
		selectedLinkagesHB.visible = false;
	}
	CursorManager.removeBusyCursor();
}


private function handleClearAllCitations(event:MouseEvent):void {
	
	for(var i:int = 0; i < linkages.length ; i++) {
    	var l:SelectedLinkage = (linkages[i]) as SelectedLinkage;
    	var list:ArrayCollection = l.citations;
    	for(var j:int = 0; j < list.length; j++) {
    		var c:Citation = (list[j]) as Citation;
    		if(c.id != 0) {
				citationCB[i][j].selected = false;
    		}
    	}
	}
}

private function handleRemoveSavedLinkages(event:MouseEvent):void {
	var msg:String = "Are you sure you want to remove the selected reference(s) from the Saved References panel?";
	Alert.show(msg,"WARNING",(Alert.YES | Alert.NO),null,handleRemoveWarnResponse,null,Alert.YES);
}

private function handleRemoveWarnResponse(event:CloseEvent):void
{
	if(event.detail == Alert.YES) {	
		var len:int = savedlinkagesList.length;
		var newList:ArrayCollection = new ArrayCollection();
		
		for(var i:int = 0; i < len ; i++) {
	    	var l:SelectedLinkage = (savedlinkagesList[i]) as SelectedLinkage;
	    	var list:ArrayCollection = l.citations;
	    	
	    	var newl:SelectedLinkage = new SelectedLinkage();
	    	newl.label = l.label;
	    	newl.shape1 = l.shape1;
	    	newl.shape2 = l.shape2;
	
	    	for(var j:int = 0; j < l.citations.length; j++) {
	    		var c:Citation = (list[j]) as Citation;
					if(!savedCitationCB[i][j].selected) {
						newl.citations.addItem(c);
					}
	    	}
	    	if(newl.citations.length > 0) {
	    		newList.addItem(newl);
			}
		}
		savedlinkagesList = null;
		savedlinkagesList = newList;
		savedLinkages.dataProvider = savedlinkagesList;
		if(savedlinkagesList.length == 0)
			savedLinkagesHB.visible = false;
	}

}

private function handleSelectAllSavedCitations(event:MouseEvent):void {
	for(var i:int = 0; i < savedlinkagesList.length ; i++) {
    	var l:SelectedLinkage = (savedlinkagesList[i]) as SelectedLinkage;
    	var list:ArrayCollection = l.citations;
    	for(var j:int = 0; j < list.length; j++) {
    		var c:Citation = (list[j]) as Citation;
    		if(c.id != 0) {
				savedCitationCB[i][j].selected = true;
    		}
    	}
	}
}

private function handleRemoveAllLinkages(event:MouseEvent):void {
	clearSavedLinkages();
}

private function handleDownloadLinkages(event:MouseEvent):void {
	downloadLinkages = null;
	downloadLinkages = new ArrayCollection();
	
	for(var i:int = 0; i < savedlinkagesList.length ; i++) {
    	var l:SelectedLinkage = (savedlinkagesList[i]) as SelectedLinkage;
    	var list:ArrayCollection = l.citations;
    	
    	var newl:SelectedLinkage = new SelectedLinkage();
    	newl.label = l.label;
    	
    	for(var j:int = 0; j < list.length; j++) {
    		var c:Citation = (list[j]) as Citation;
    		if(savedCitationCB[i][j].selected) {
    			 newl.citations.addItem(c);
    		}
    	}
    	if(newl.citations.length > 0) {
    		downloadLinkages.addItem(newl);
    	}
	}
	if(downloadLinkages.length == 0) {
		Alert.show("Please select references to download.","INFORMATION");
		return;
	}
	handleDownloadPopUpCreation(event);
}


private function handleSelectAllCitations(event:MouseEvent):void {
	for(var i:int = 0; i < linkages.length ; i++) {
    	var l:SelectedLinkage = (linkages[i]) as SelectedLinkage;
    	var list:ArrayCollection = l.citations;
    	for(var j:int = 0; j < list.length; j++) {
    		var c:Citation = (list[j]) as Citation;
    		if(c.id != 0) {
				citationCB[i][j].selected = true;
    		}
    	}
	}
}

private function checkIfLinkageCheckBoxSelected():Boolean {
	
	for(var i:int = 0; i < linkages.length ; i++) {
    	var l:SelectedLinkage = (linkages[i]) as SelectedLinkage;
    	var list:ArrayCollection = l.citations;
    	for(var j:int = 0; j < list.length; j++) {
    		var c:Citation = (list[j]) as Citation;
    		if(c.id != 0) {
    			if(citationCB[i][j].selected) {
    				return true;
    			}
    		}
    	}
	}
	return false;
}

private function handleSaveSelectedLinkages(event:MouseEvent):void {

	if(!checkIfLinkageCheckBoxSelected()) {
		Alert.show("Please select Linkages to Save","INFORMATION");
		return;
	}
	for(var i:int = 0; i < linkages.length ; i++) {
		
    	var l:SelectedLinkage = (linkages[i]) as SelectedLinkage;
    	var list:ArrayCollection = l.citations;
    	for(var j:int = 0; j < list.length; j++) {
    		var foundLinkage:Boolean = false;
    		var foundC:Boolean = false;
    		var c:Citation = (list[j]) as Citation;
    		
    		if(c.id != 0) {
    			//if citation selected
    			if(citationCB[i][j].selected) {
    				var len:int = savedlinkagesList.length;
    				for(var k:int = 0; k < len; k++) {
    					var sl:SelectedLinkage = (savedlinkagesList[k]) as SelectedLinkage;
    					if(sl.label == l.label) {
    						foundLinkage = true;
    						for(var m:int = 0; m < sl.citations.length; m++) {
    							if(sl.citations[m].id == c.id) {
    								foundC = true;
    								break;//found citation break
    							}
    						}
    					}
    					if(foundLinkage == true || foundC == true) {
    						break;//found linkage break
    					}
	       			}//end of loop
	       			if(!foundLinkage) {//did not find linkage, add it to the end
	       				var newl:SelectedLinkage = new SelectedLinkage;
	    				newl.label = l.label;
	    				newl.shape1 = l.shape1;
	    				newl.shape2 = l.shape2;
		        		newl.citations.addItem(c);
		        		savedlinkagesList.addItem(newl);
		        	} else if(foundLinkage == true && foundC == false) {//foundlinkage but not citation
		        		(savedlinkagesList[k] as SelectedLinkage).citations.addItem(c);
		        	}
	        	}//end of if citation selected check
    		}//end of c.id == 0
    	}//end of loop for citations in selectedlinkage
    	
	}
	//Alert.show("savedLinkages" + savedlinkagesList.length);
	savedLinkages.dataProvider = savedlinkagesList;
	if(savedlinkagesList.length > 0)
		savedLinkagesHB.visible = true;
}

public function clearSelectedLinkages():void
{
	//clear data provider of repeaters
	selectedLinkages.dataProvider = null;
	selectedLinkagesHB.visible = false;
	linkages = null;
}

public function clearSavedLinkages():void
{
	//clear data provider of repeaters
	savedLinkages.dataProvider = null;
	savedLinkagesHB.visible = false;
	savedlinkagesList = null;
	savedlinkagesList = new ArrayCollection();
}

public function clearAll():void
{
	clearSelectedShapes();
	clearSelectedLinkages();
}

