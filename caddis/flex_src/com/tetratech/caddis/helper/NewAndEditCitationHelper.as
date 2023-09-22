import com.adobe.utils.StringUtil;
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.drawing.CShape;
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.view.AddEditCitation;
import com.tetratech.caddis.view.AddEditEvidence;
import com.tetratech.caddis.view.SeachAndAddExternalCitations;
import com.tetratech.caddis.vo.Citation;
import com.tetratech.caddis.vo.LabelValue;
import com.tetratech.caddis.vo.LookupValue;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.collections.Grouping;
import mx.collections.GroupingCollection;
import mx.collections.GroupingField;
import mx.controls.Alert;
import mx.controls.ComboBox;
import mx.controls.LinkBar;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.ItemClickEvent;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.validators.Validator;

private var ppPanel:AddEditCitation = null;
private var mode:String = null;
private const MODE_EDIT:String = "edit";
private const MODE_NEW:String = "new";
private var pubTypes:ArrayCollection = null;
private var authors:ArrayCollection = null;
private var titles:ArrayCollection = null;
private var journals:ArrayCollection = null;
private var c:Citation = null;
private var ippPanel:SeachAndAddExternalCitations = null;
private var displayList:Object = null;
private var labelText:String = "";
private var list:ArrayCollection ;
private function addCitation():void
{
	mode=MODE_NEW;
	//create pop up panel
	ppPanel = new AddEditCitation();
	ppPanel.title = "Add New Citation";
	ppPanel.addEventListener(FlexEvent.INITIALIZE,handleInitCitationPopup)
	ppPanel.addEventListener(CloseEvent.CLOSE, closeAddAndEditDialog);
	//add to manager
	PopUpManager.addPopUp(ppPanel, this.parent, true);
	PopUpManager.centerPopUp(ppPanel);
	ppPanel.y = 100;
}

private function editCitation(editCitation:Citation):void
{
	mode=MODE_EDIT;
	//selectedCitation = editCitation;
	c = editCitation;
	//create pop up panel
	ppPanel = new AddEditCitation();
	ppPanel.title = "Edit Citation";
	ppPanel.addEventListener(FlexEvent.INITIALIZE,handleInitCitationPopup)
	ppPanel.addEventListener(CloseEvent.CLOSE, closeAddAndEditDialog);
	//add to manager
	PopUpManager.addPopUp(ppPanel, this.parent, true);
	PopUpManager.centerPopUp(ppPanel);
	ppPanel.y = 20;
}

private function handleInitCitationPopup(event:FlexEvent):void
{
	
	ppPanel.saveb.addEventListener(MouseEvent.CLICK,saveCitation);
	ppPanel.cancelb.addEventListener(MouseEvent.CLICK,cancelCitation);
	ppPanel.cpubType.addEventListener(CloseEvent.CLOSE,tooglePubType);
	var s1:Service = new Service();
	s1.serviceHandler = handleGetPubTypes;
	s1.getLookupByType(Constants.LOOKUP_PUBLICATION_TYPE);
	
	disablePPPanelFields();
	CursorManager.setBusyCursor();
	
}

private function handleGetPubTypes(event:ResultEvent):void
{
	pubTypes = event.result as ArrayCollection;
	var s2:Service = new Service();
	s2.serviceHandler = handleGetAllAuthors;
	s2.getAllAuthors();
}

private function handleGetAllAuthors(event:ResultEvent):void
{
	authors = event.result as ArrayCollection;
	var s3:Service = new Service();
	s3.serviceHandler = handleGetAllTitles;
	s3.getAllTitles();
}

private function handleGetAllTitles(event:ResultEvent):void
{
	titles = event.result as ArrayCollection;
	var s4:Service = new Service();
	s4.serviceHandler = handelGetJounal;
	s4.getLookupByType(Constants.LOOKUP_JOURNAL);	
}

private function handelGetJounal(event:ResultEvent):void
{
	journals = event.result as ArrayCollection;
	populateLookups();
}

private function populateLookups():void
{
	ppPanel.cpubType.dataProvider = pubTypes;
	ppPanel.cpubType.labelField = "code";
	ppPanel.cpubType.data = "id";
	ppPanel.cauthor.dataProvider = authors;
	ppPanel.ctitle.dataProvider = titles;
	ppPanel.cjournal.dataProvider = journals;
	ppPanel.cjournal.labelField = "desc";
	ppPanel.cjournal.data = "id";
	ppPanel.cpubType.selectedIndex = 0;
	ppPanel.cauthor.selectedIndex = -1;
	ppPanel.ctitle.selectedIndex = -1;
	ppPanel.cjournal.selectedIndex = -1;
	ppPanel.cexitDisclaimer.selected = false;
	if(mode == MODE_NEW){
		CursorManager.removeBusyCursor();
		enablePPPanelFields();
		releaseLocalVariables();
	} 
	else if(mode==MODE_EDIT)
	{
		handlePopulateFields();
	}
}


private function closeAddAndEditDialog(event:CloseEvent):void
{
	removePopUp();
}


private function cancelCitation(event:MouseEvent):void
{
	removePopUp();
}

private function saveCitation(event:MouseEvent):void
{
	var valArray:Array = new Array();
	valArray.push(ppPanel.valAuthor);
	valArray.push(ppPanel.valKeyword);
	valArray.push(ppPanel.valCURL);
	var selectedPubType:int = ppPanel.cpubType.selectedItem.id;
	switch (selectedPubType) {
		case Constants.PUBLICATION_TYPE_JOURNAL_ARTICLE:
			valArray.push(ppPanel.valYear);
			valArray.push(ppPanel.valTitle);
			valArray.push(ppPanel.valJournal);
			valArray.push(ppPanel.valVolume);
			valArray.push(ppPanel.valIssue);
			valArray.push(ppPanel.valStartpage);
			valArray.push(ppPanel.valEndpage);
			break ;
		case Constants.PUBLICATION_TYPE_BOOK_CHAPTER:
			valArray.push(ppPanel.valYear);
			valArray.push(ppPanel.valTitle);
			valArray.push(ppPanel.valBook);
			valArray.push(ppPanel.valBookChapterEditor);
			valArray.push(ppPanel.valBookChapterPublisher);
			valArray.push(ppPanel.valBCStartpage);
			valArray.push(ppPanel.valBCEndpage);
			break ;
		case Constants.PUBLICATION_TYPE_BOOK:
			valArray.push(ppPanel.valBookEditor);
			valArray.push(ppPanel.valYear);
			valArray.push(ppPanel.valTitle);
			valArray.push(ppPanel.valBookPublisher);
			valArray.push(ppPanel.valBookPages);
			break ;
		case Constants.PUBLICATION_TYPE_REPORT:
			valArray.push(ppPanel.valYear);
			valArray.push(ppPanel.valTitle);
			valArray.push(ppPanel.valReportPublisher);
			valArray.push(ppPanel.valReportNum);
			valArray.push(ppPanel.valReportPages);
			break ;
		case Constants.PUBLICATION_TYPE_OTHER:
			valArray.push(ppPanel.valYear);
			valArray.push(ppPanel.valTitle);
			valArray.push(ppPanel.valOtherSource);
			valArray.push(ppPanel.valOtherType);
			valArray.push(ppPanel.valOtherPage);
			break ;
	}
	
	var validatorErrorArray:Array = Validator.validateAll(valArray);
	if(validatorErrorArray.length == 0){
		//get edit  citation id
		var citationId:Number = 0;
		if(c != null)
			citationId = c.id;
		c = new Citation();
		if(mode==MODE_NEW)
		{
			c.createdBy = Model.user.userId;
		}
		else if(mode==MODE_EDIT)
		{
			c.lastUpdateBy = Model.user.userId;
			c.id = citationId;
		}
		c.pubTypeId = ppPanel.cpubType.selectedItem.id;
		c.author = StringUtil.trim(ppPanel.cauthor.text);
		c.keyword = StringUtil.trim(ppPanel.ckeyword.text);
		c.doi = StringUtil.trim(ppPanel.cdoi.text);
		c.citationAbstract = StringUtil.trim(ppPanel.cabstract.text);
		c.citationAnnotation = StringUtil.trim(ppPanel.cannotation.text);
		c.citationUrl = StringUtil.trim(ppPanel.curl.text);
		c.approved = ppPanel.approved.selected;
		c.exitDisclaimer = ppPanel.cexitDisclaimer.selected;
		
		switch (selectedPubType) {
			case Constants.PUBLICATION_TYPE_JOURNAL_ARTICLE:
				c.year = StringUtil.trim(ppPanel.cyear.text);
				c.title = StringUtil.trim(ppPanel.ctitle.text);
				c.journal = StringUtil.trim(ppPanel.cjournal.text);
				c.volume = parseInt(ppPanel.cvolume.text);
				c.issue = StringUtil.trim(ppPanel.cissue.text);
				c.startPage = ppPanel.cstartpage.text;
				c.endPage = ppPanel.cendpage.text;
				break ;
			case Constants.PUBLICATION_TYPE_BOOK_CHAPTER:
				c.year = StringUtil.trim(ppPanel.cyear.text);
				c.title = StringUtil.trim(ppPanel.ctitle.text);
				c.book = StringUtil.trim(ppPanel.cbook.text);
				c.editors = StringUtil.trim(ppPanel.cbookchaptereditor.text);
				c.publishers = StringUtil.trim(ppPanel.cbookchapterpublisher.text);
				c.startPage = ppPanel.cbcstartpage.text;
				c.endPage = ppPanel.cbcendpage.text;
				break ;
			case Constants.PUBLICATION_TYPE_BOOK:
				c.year = StringUtil.trim(ppPanel.cyear.text);
				c.title = StringUtil.trim(ppPanel.ctitle.text);
				c.editors = StringUtil.trim(ppPanel.cbookeditor.text);
				c.publishers = StringUtil.trim(ppPanel.cbookpublisher.text);
				c.pages = parseInt(ppPanel.cbpages.text);
				break ;
			case Constants.PUBLICATION_TYPE_REPORT:
				c.year = StringUtil.trim(ppPanel.cyear.text);
				c.title = StringUtil.trim(ppPanel.ctitle.text);
				c.publishers = StringUtil.trim(ppPanel.creportpublisher.text);
				c.reportNum = StringUtil.trim(ppPanel.creportnum.text);
				c.pages = parseInt(ppPanel.creportpages.text);
				break ;
			case Constants.PUBLICATION_TYPE_OTHER:
				c.year = StringUtil.trim(ppPanel.cyear.text);
				c.title = StringUtil.trim(ppPanel.ctitle.text);
				c.source = StringUtil.trim(ppPanel.cothersource.text);
				c.type = StringUtil.trim(ppPanel.cothertype.text);
				c.pages = parseInt(ppPanel.cotherpages.text);
				break ;
		}
		
		var s:Service = new Service();
		s.serviceHandler = handleNoDuplicateCitations;
		s.getDuplicateCitations(c);
	}
	else
	{
		ppPanel.error.visible = true;
	}
	
}


private function tooglePubType(evt:Event):void
{
	trace( ComboBox(evt.target).selectedItem.id);
	var selectedPubType:int = ComboBox(evt.target).selectedItem.id;
	
	switch (selectedPubType) {
		case Constants.PUBLICATION_TYPE_JOURNAL_ARTICLE:
			ppPanel.currentState = '';
			break ;
		case Constants.PUBLICATION_TYPE_BOOK_CHAPTER:
			ppPanel.currentState = 'bc';
			break ;
		case Constants.PUBLICATION_TYPE_BOOK:
			ppPanel.currentState = 'b';
			break ;
		case Constants.PUBLICATION_TYPE_REPORT:
			ppPanel.currentState = 'r';
			break ;
		case Constants.PUBLICATION_TYPE_OTHER:
			ppPanel.currentState = 'o';
			ppPanel.valTitle.validate();
			ppPanel.valYear.validate();
			break ;
	} 
}

private function removePopUp():void
{
	releaseLocalVariables();
	if(ppPanel != null) {
		PopUpManager.removePopUp(ppPanel);
		ppPanel = null;
	}
	if(ippPanel != null) {
		PopUpManager.removePopUp(ippPanel);
		ippPanel = null;
	}
	//set focus 
	this.setFocus();
}

private function handleNoDuplicateCitations(event:ResultEvent):void
{
	var msg:String = event.result as String;
	
	if(msg.length>0){
		msg = "The citation you try to save duplicates with following citation(s) and cannot be saved!\n\n" + msg;
		Alert.show(msg, "WARNING", Alert.OK, null, null, null, Alert.OK);
	}else{
		var s:Service = new Service();
		s.serviceHandler = handleSaveCitation;
		if(mode==MODE_NEW){
			Model.addedNewCitation = true;
			s.insertCitation(c);
		}else if(mode==MODE_EDIT){
			s.updateCitation(c);
		}
	}
}

private function handleSaveCitation(event:ResultEvent):void
{
	var newCitationId:Number = event.result as Number;
	Alert.show("Your changes have been successfully saved.", "INFORMATION", Alert.OK, null, handelSaveConfirmation, null, Alert.OK);
	//store the citation id if you added a new one
	if(Model.addedNewCitation)
		Model.newCitations.addItem(newCitationId);
	//get all citations
	//getAllCitations(null);
	searchCitations(null);
}

private function handelSaveConfirmation(event:Event):void
{
	removePopUp();
}

private function enablePPPanelFields():void
{
	//	ppPanel.showCloseButton = true;
	//	var btn:Button = ppPanel.mx_internal::closeButton;
	//	btn.enabled = true;
	ppPanel.cpubType.enabled = true;
	ppPanel.cauthor.enabled = true;
	ppPanel.cyear.enabled = true;
	ppPanel.ctitle.enabled = true;
	ppPanel.ckeyword.enabled = true;
	ppPanel.cabstract.enabled = true;
	ppPanel.cdoi.enabled = true;
	ppPanel.approved.enabled = true;
	ppPanel.cjournal.enabled = true;
	ppPanel.cvolume.enabled = true;
	ppPanel.cissue.enabled = true;
	ppPanel.cstartpage.enabled = true;
	ppPanel.cendpage.enabled = true;
	ppPanel.cbook.enabled = true;
	ppPanel.cbpages.enabled = true;
	ppPanel.cbookchaptereditor.enabled = true;
	ppPanel.cbookchapterpublisher.enabled = true;
	ppPanel.cbcstartpage.enabled = true;
	ppPanel.cbcendpage.enabled = true;
	ppPanel.cbookeditor.enabled = true;
	ppPanel.cbookpublisher.enabled = true;
	ppPanel.creportpublisher.enabled = true;
	ppPanel.creportnum.enabled = true;
	ppPanel.creportpages.enabled = true;
	ppPanel.cothersource.enabled = true;
	ppPanel.cothertype.enabled = true;
	ppPanel.cotherpages.enabled = true;
	ppPanel.saveb.enabled = true;
	ppPanel.cancelb.enabled = true;
	ppPanel.curl.enabled = true;
	ppPanel.cannotation.enabled = true;
	//ppPanel.coyear.enabled = true;
	//ppPanel.cotitle.enabled = true;
	ppPanel.cexitDisclaimer.enabled = true;
	if(Model.user.roleId == Constants.LL_REGISTERED_USER)
	{
		ppPanel.approved.selected = false;
		ppPanel.approved.enabled = false;
	}
}

private function disablePPPanelFields():void
{
	//	ppPanel.showCloseButton = false;
	//	var btn:Button = ppPanel.mx_internal::closeButton;
	//	btn.enabled = false;
	ppPanel.cpubType.enabled = false;
	ppPanel.cauthor.enabled = false;
	ppPanel.cyear.enabled = false;
	ppPanel.ctitle.enabled = false;
	ppPanel.ckeyword.enabled = false;
	ppPanel.cabstract.enabled = false;
	ppPanel.cdoi.enabled = false;
	ppPanel.approved.enabled = false;
	ppPanel.cjournal.enabled = false;
	ppPanel.cvolume.enabled = false;
	ppPanel.cissue.enabled = false;
	ppPanel.cstartpage.enabled = false;
	ppPanel.cendpage.enabled = false;
	ppPanel.cbook.enabled = false;
	ppPanel.cbpages.enabled = false;
	ppPanel.cbookchaptereditor.enabled = false;
	ppPanel.cbookchapterpublisher.enabled = false;
	ppPanel.cbookeditor.enabled = false;
	ppPanel.cbookpublisher.enabled = false;
	ppPanel.cbcstartpage.enabled = false;
	ppPanel.cbcendpage.enabled = false;
	ppPanel.creportpublisher.enabled = false;
	ppPanel.creportnum.enabled = false;
	ppPanel.creportpages.enabled = false;
	ppPanel.cothersource.enabled = false;
	ppPanel.cothertype.enabled = false;
	ppPanel.cotherpages.enabled = false;
	ppPanel.saveb.enabled = false;
	ppPanel.cancelb.enabled = false;
	ppPanel.curl.enabled = false;
	ppPanel.cannotation.enabled = false;
	//ppPanel.coyear.enabled = false;
	//ppPanel.cotitle.enabled = false;
	ppPanel.cexitDisclaimer.enabled = false;
}


private function handlePopulateFields():void
{
	var selectedPubType:Number = c.pubTypeId;
	var lu:LookupValue = null;
	var item:String = null;
	var i:Number;
	var titleIndex:Number = -1;
	// populate selected publication type
	for(i=0;i<pubTypes.length;i++){
		lu = pubTypes.getItemAt(i) as LookupValue;
		if(lu.id == selectedPubType){
			ppPanel.cpubType.selectedIndex = i;
			break;
		}
	}
	
	ppPanel.ckeyword.text = c.keyword;
	ppPanel.cdoi.text = c.doi;
	ppPanel.cabstract.text = c.citationAbstract;
	ppPanel.approved.selected = c.approved;	
	ppPanel.curl.text = c.citationUrl;
	ppPanel.cannotation.text = c.citationAnnotation;
	ppPanel.cexitDisclaimer.selected = c.exitDisclaimer;
	
	switch (selectedPubType) {
		case Constants.PUBLICATION_TYPE_JOURNAL_ARTICLE:
			ppPanel.currentState = '';
			// populate selected publication type
			for(i=0;i<journals.length;i++){
				lu = journals.getItemAt(i) as LookupValue;
				if(lu.id == c.pubId){
					ppPanel.cjournal.selectedIndex = i;
					break;
				}
			}
			ppPanel.cyear.text = c.year;
			if(c.volume > 0)
				ppPanel.cvolume.text = String(c.volume);
			ppPanel.cissue.text = c.issue;
			if(c.startPage != '0')
				ppPanel.cstartpage.text = c.startPage;
			if(c.endPage != '0')
				ppPanel.cendpage.text = c.endPage;		
			break ;
		case Constants.PUBLICATION_TYPE_BOOK_CHAPTER:
			ppPanel.currentState = 'bc';
			ppPanel.cyear.text = c.year;
			ppPanel.cbook.text = c.book;
			ppPanel.cbookchaptereditor.text = c.editors;
			ppPanel.cbookchapterpublisher.text =  c.publishers;
			if(c.startPage != '0')
				ppPanel.cbcstartpage.text = c.startPage;
			if(c.endPage != '0')
				ppPanel.cbcendpage.text = c.endPage;
			break ;
		case Constants.PUBLICATION_TYPE_BOOK:
			ppPanel.currentState = 'b';
			ppPanel.cyear.text = c.year;
			ppPanel.cbookeditor.text = c.editors;
			ppPanel.cbookpublisher.text = c.publishers;
			if(c.pages > 0)
				ppPanel.cbpages.text = String(c.pages);
			break ;
		case Constants.PUBLICATION_TYPE_REPORT:
			ppPanel.currentState = 'r';
			ppPanel.cyear.text = c.year;
			ppPanel.creportpublisher.text = c.publishers;
			ppPanel.creportnum.text = c.reportNum;
			if(c.pages > 0)
				ppPanel.creportpages.text = String(c.pages);
			break ;
		case Constants.PUBLICATION_TYPE_OTHER:
			ppPanel.currentState = 'o';
			ppPanel.cyear.text = c.year;
			ppPanel.cothersource.text = c.source;
			ppPanel.cothertype.text = c.type;
			if(c.pages > 0)
				ppPanel.cotherpages.text = String(c.pages);
			//ppPanel.cotitle.selectedIndex = titleIndex;
			break ;
	}
	
	// populate selected author
	for(i=0;i<authors.length;i++){
		item = authors.getItemAt(i) as String
		if(StringUtil.stringsAreEqual(item, c.author, false)){
			ppPanel.cauthor.selectedIndex = i;
			break;
		}
	}
	// populate selected title
	if(c.title != null )
	{
		for(i=0;i<titles.length;i++){
			item = titles.getItemAt(i) as String
			if(StringUtil.stringsAreEqual(item, c.title, false)){
				titleIndex = i;
				break;
			}
		}	
	}
	ppPanel.ctitle.selectedIndex = titleIndex;
	CursorManager.removeBusyCursor();
	enablePPPanelFields();
	//releaseLocalVariables();
}

private function releaseLocalVariables():void
{
	pubTypes = null;
	authors = null;
	titles = null;
	journals = null;
	c = null;
	
}

private function searchExternalCitations():void
{
	//create pop up panel
	ippPanel = new SeachAndAddExternalCitations();
	ippPanel.addEventListener(FlexEvent.INITIALIZE,handleInitSearchCitationPopup)
	ippPanel.addEventListener(CloseEvent.CLOSE, closeAddAndEditDialog);
	//add to manager
	PopUpManager.addPopUp(ippPanel, this.parent, true);
	PopUpManager.centerPopUp(ippPanel);
	ippPanel.y = 20;
}

private function handleInitSearchCitationPopup(event:FlexEvent):void
{
	ippPanel.searchTerms.addEventListener(MouseEvent.CLICK, searchCauseAndEffect);
	ippPanel.selectDatabase.dataProvider = Constants.DATABASE_SOURCES;
	ippPanel.selectDatabase.selectedIndex = 2;
	loadResults(Constants.SEARCH_EPA_SOURCE);
	
	/*ippPanel.selectAllCitationsb.addEventListener(MouseEvent.CLICK, handleSelectAllCitations);
	ippPanel.saveCitaionsb.addEventListener(MouseEvent.CLICK, saveExternalCitations);
	ippPanel.clearAllCitaionsb.addEventListener(MouseEvent.CLICK, handleClearAllCitations);
	//ippPanel.closeb.addEventListener(MouseEvent.CLICK, closeCitationSearchResultPopUp);
	
	ippPanel.selectAllCitationsb.enabled = false;
	ippPanel.saveCitaionsb.enabled = false;
	ippPanel.clearAllCitaionsb.enabled = false;
	ippPanel.closeb.enabled = false;
	
	ippPanel.selectAllCitationsb.mouseEnabled = false;
	ippPanel.saveCitaionsb.mouseEnabled = false;
	ippPanel.clearAllCitaionsb.mouseEnabled = false;
	ippPanel.closeb.mouseEnabled = false;
	*/
}

private function loadResults(source:String):void
{
	var errorMsg:String = "";
	
	var casueText = this.clabel.text;
	var selectedlinkageShapes = this.shapes.dataProvider as ArrayCollection;
	var eterm:String = "";
	
		var s:Service = new Service();
		s.serviceHandler = handlePopulateCitationSearch;
		
		s.searchCitationsByCauseNEffect (casueText, "", source);

	CursorManager.setBusyCursor();
	busyCursor = true; 
}
private function searchCauseAndEffect(event:MouseEvent):void
{
	
	loadResults(ippPanel.selectDatabase.selectedLabel);
	//Alert.show(displayList.length.toString());
	
	/*
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
		
		ippPanel.selectAllCitationsb.enabled = false;
		ippPanel.saveCitaionsb.enabled = false;
		ippPanel.clearAllCitaionsb.enabled = false;
		ippPanel.closeb.enabled = false;
		
		ippPanel.selectAllCitationsb.mouseEnabled = false;
		ippPanel.saveCitaionsb.mouseEnabled = false;
		ippPanel.clearAllCitaionsb.mouseEnabled = false;
		ippPanel.closeb.mouseEnabled = false;
	
		var s:Service = new Service();
		s.serviceHandler = handlePopulateCitationSearch;
		
		s.searchCitationsByCauseNEffect (ippPanel.cause.text, ippPanel.effect.text, Constants.SEARCH_OTHER_SOURCE);
		
		//change the mouse to a busy cursor
		CursorManager.setBusyCursor();
		busyCursor = true; 
	}*/
}
//populate search results
private function handlePopulateCitationSearch(event:ResultEvent):void
{
	var selectedlinkageShapes = this.shapes.dataProvider as ArrayCollection;
	var displayArray:ArrayCollection = new ArrayCollection();
	list = event.result as ArrayCollection;
	citationList = list;
	for(var i:int = 0; i < selectedlinkageShapes.length ; i++)
	{ 
		var eshape = selectedlinkageShapes[i] as CShape;
		
		var text:String =  this.clabel.text + " And " + eshape.label ;	
		var filterList:ArrayCollection = new ArrayCollection();
		for(var o:int = 0; o < list.length; o++)
		{
			var c:Citation = list.getItemAt(o) as Citation;
			if(StringUtil.stringsAreEqual(c.effectTerm, eshape.label, false))
				filterList.addItem(c);
		}
		displayList = {header: text, data:filterList};
		displayArray.addItem(displayList);
	} 
	ippPanel.selectedCitation.addEventListener(ItemClickEvent.ITEM_CLICK, handleSelectedCitation);
	ippPanel.displayCitations.dataProvider=displayArray;
	 
	/*var myGColl:GroupingCollection = new GroupingCollection();new ArrayCollection(list.toArray())
	var myGrp:Grouping = new Grouping();Alert.show(c.effectTerm);
	
		myGColl.source = list;
		myGrp.fields = [new GroupingField("effectTerm")];
		myGColl.grouping = myGrp;
		ippPanel.displayCitations.dataProvider=myGColl;
		myGColl.refresh();
	*/	
	CursorManager.removeBusyCursor();
	busyCursor = false; 
}

/*
private function handleClearAllCitations(event:MouseEvent):void {
	//checkedCitationList = null;
	if(ippPanel.citationCB != null) {
		var len:uint = ippPanel.citationCB.length;
		for (var i:uint = 0; i < len; i++)
		{
			// Reference the current checkBox instance
			ippPanel.citationCB[i].selected = false;
		}
	}
}

private function handleSelectAllCitations(event:MouseEvent):void {
	//checkedCitationList = null;
	if(ippPanel.citationCB != null) {
		var len:uint = ippPanel.citationCB.length;
		for (var i:uint = 0; i < len; i++)
		{
			// Reference the current checkBox instance
			ippPanel.citationCB[i].selected = true;
		}
	}
}

//prepares to save external citations
private function saveExternalCitations(event:MouseEvent):void {
	
	var citationIds:ArrayCollection = null;
	citationIds = new ArrayCollection();
	if(ippPanel.citationCB != null) {
		var len:uint = ippPanel.citationCB.length;
		for (var i:uint = 0; i < len; i++)
		{
			// Reference the current checkBox instance
			var currentItem:CheckBox = ippPanel.citationCB[i];
			if(currentItem.selected) {
				citationIds.addItem(currentItem.data);
			}
		}
		if(citationIds.length == 0) {
			Alert.show("Please select references to save.","INFORMATION");
		}
		else {
			//savecitations selected
			//handleDownloadPopUpCreation(event);
		}
	}
}
*/