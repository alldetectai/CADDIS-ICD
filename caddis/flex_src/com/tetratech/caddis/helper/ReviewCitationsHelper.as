// ActionScript file
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.view.ReviewCitations;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;


private var rcPanel:ReviewCitations;
//NOTES: BUTTON TO VIEW CITATIONN DETAILS?
//QUERY TO UPDATE THE CITATIONS FLAGS.
//NEW BUTTON FOR REVIEW CITATIONS??
//view comments changes for edit tab

/*start ReviewCitations*/
private function handleReviewCitations(event:MouseEvent):void
{
	//create pop up panel
	rcPanel = new ReviewCitations();
	rcPanel.addEventListener(FlexEvent.INITIALIZE, handleReviewCitationsPopUpInit);
	rcPanel.addEventListener(CloseEvent.CLOSE, closeReviewCitationsPopUpDialog);

	//add to manager
	PopUpManager.addPopUp(rcPanel, this.parent.parent, true);
	PopUpManager.centerPopUp(rcPanel);
	rcPanel.y = 100;	
}

//Initializing Review Citations PopUp
private function handleReviewCitationsPopUpInit(event:FlexEvent):void
{
	//add listeners
	rcPanel.saveb.addEventListener(MouseEvent.CLICK, handleSaveCitations);
	rcPanel.closeb.addEventListener(MouseEvent.CLICK, closeReviewCitationsPopUp);

	//getCitations which are in review
	var s:Service = new Service();
	s.serviceHandler = handlePopulateReviewCitationsPopUp;
	s.getCitationsInReview();
}

//populate search results
private function handlePopulateReviewCitationsPopUp(event:ResultEvent):void
{
	var list:ArrayCollection = event.result as ArrayCollection;
	if(list != null && list.length > 0) {

		rcPanel.displayCitations.dataProvider = list;
		if(list.length == 1)
			rcPanel.resultsMessage.text = "Found " + list.length + " reference to review.";
		else
			rcPanel.resultsMessage.text = "Found " + list.length + " references to review.";
			for(var i:int = 0; i < list.length ; i++) {
	    	//Alert.show("handlePopulateCitationSearchPopUp " + i);
	    	var c:Citation = (list[i]) as Citation;
			var tabList:ArrayCollection = new ArrayCollection();
			//tabList.addItem(new LabelValue("Author", c.author));
//			tabList.addItem(new LabelValue("Abstract", c.id));
//			tabList.addItem(new LabelValue("Linkages", c.id));
			tabList.addItem(new LabelValue("Abstract", c));
			tabList.addItem(new LabelValue("Citation-Specific Evidence", c));
			//LiLi
	//		if(c.inCADLIT)
	//			rcPanel.inCadlit[i].text = "In CADLit";
	//		else 
	//			rcPanel.inCadlit[i].text = "Not In CADLit";

//			add to link bark		
//			if(c.cadlitSource)
//				tabList.addItem(new LabelValue("In CADLit",0));
//			else 
//				tabList.addItem(new LabelValue("Not In CADLit",0));	
			
			(rcPanel.linkbar[i] as LinkBar).dataProvider = tabList;
			rcPanel.linkbar[i].addEventListener(ItemClickEvent.ITEM_CLICK, handleLinkBarPopUpCreation);
	    }
	}
	else {
		rcPanel.resultsMessage.text = "No References found to review.";
	}
}

private function closeReviewCitationsPopUpDialog(event:CloseEvent):void
{
	closeRCitationsPopUp();
}

private function closeReviewCitationsPopUp(event:MouseEvent):void
{
	closeRCitationsPopUp();
}

private function closeRCitationsPopUp():void 
{
	PopUpManager.removePopUp(rcPanel);
	rcPanel = null;
	//set focus 
	this.setFocus();
}

private function handleSaveCitations(event:MouseEvent):void
{
	var citationIds:ArrayCollection = new ArrayCollection();
	if(rcPanel.citationCB != null) {
		var len:uint = rcPanel.citationCB.length;
		for (var i:uint = 0; i < len; i++)
	    {
	        // Reference the current checkBox instance
	        var currentItem:CheckBox = rcPanel.citationCB[i];
	        if(currentItem.selected) {
	 			citationIds.addItem(currentItem.data);
	        }
	    }
		if(citationIds.length == 0) {
			Alert.show("Please select references to approve.","INFORMATION");
		}
		else {
			//save citation
			var s:Service = new Service();
			s.serviceHandler = handleSaveResultReturn;
			
			s.approveCitations(citationIds)	
		}
	}

}

private function handleSaveResultReturn(event:ResultEvent):void
{
	//show msg and remove pop up
	Alert.show("Your approved citations were successfully saved.", "INFORMATION", Alert.OK, null, null, null, Alert.OK);

	//save checked citations
	closeRCitationsPopUp();
}
