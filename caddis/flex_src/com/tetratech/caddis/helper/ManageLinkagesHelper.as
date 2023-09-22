// ActionScript file
import com.tetratech.caddis.common.DictionaryUtil;
import com.tetratech.caddis.common.Set;
import com.tetratech.caddis.drawing.CShape;
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.view.ManageLinkages;
import com.tetratech.caddis.vo.Citation;
import com.tetratech.caddis.vo.Linkage;
import com.tetratech.caddis.vo.SelectedLinkage;

import flash.events.MouseEvent;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.controls.CheckBox;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

private var selectedShape:CShape;
private var sppPanel;
//private var infoPanel:InformationPopUp;
//state of cursor
private var busyCursor:Boolean = false;
/* THIS FUNCTION IS USED TO HANDLE THE CLICK EVENT ON A LIST OF 
SHAPES AND DISPLAY A POP UP WITH THE LINKAGES OF THE SHAPE */
private function shapeClickHandler(event:ListEvent):void
{
	if(event.target.selectedItem!=null)
	{
		selectedShape = event.target.selectedItem;
		createManageLinkagesPopUp();
	}
}

private function causeClickHandler(event:MouseEvent):void
{

//	if(event.target.selectedItem!=null)
//	{
//		selectedShape = event.target.data;
//		createManageLinkagesPopUp();
//	}
}

//utility method to create the pop up for adding a new citation
private function createManageLinkagesPopUp():void
{
	
	//create pop up panel
	sppPanel = new ManageLinkages();
	sppPanel.addEventListener(FlexEvent.INITIALIZE, handleManageLinkagesPopUpInit);
	
	//add to manager
	PopUpManager.addPopUp(sppPanel, this, true);
	PopUpManager.centerPopUp(sppPanel);	
	sppPanel.y = 100;
}

private function handleManageLinkagesPopUpInit(event:FlexEvent):void
{
	//add event listeners
	sppPanel.closeb.addEventListener(MouseEvent.CLICK,handleClose);
	sppPanel.deleteb.addEventListener(MouseEvent.CLICK,handleDelete);
	sppPanel.addEventListener(CloseEvent.CLOSE,handleClosePanel);
	sppPanel.rp.addEventListener(FlexEvent.REPEAT_END, handleRepeaterEnd);
	//IMPORTANT: map linkages to references
	//create a set of ref ids for the linkages of the shape 
	var ss:Set = new Set();
	var linkages:ArrayCollection = selectedShape.linkages;
	for(var i:int=0;i<linkages.length;i++)
	{
		var l:Linkage = linkages[i];
		ss.addItems(l.citationIds);
	}
	sppPanel.deleteb.enabled = false;
	sppPanel.closeb.enabled = false;

	sppPanel.deleteb.mouseEnabled = false;
	sppPanel.closeb.mouseEnabled = false;
	
	//call service to get references
	var s:Service = new Service();
	s.serviceHandler = getReferences;
	s.getCitationsByIDs(null, ss.toArrayCollection());
	trace("set busy");
//	infoPanel = new InformationPopUp();
	//	//add to manager
//	PopUpManager.addPopUp(infoPanel, this.parent, true);
//	PopUpManager.centerPopUp(infoPanel);
//	infoPanel.y = 20;
//	infoPanel.setFocus();	
	//change the mouse to a busy cursor
	
	CursorManager.setBusyCursor();
	busyCursor = true
}
		
private function getReferences(event:ResultEvent):void
{
	//convert references to a dictionary
	var d:Dictionary = DictionaryUtil.collectionToDictionary(event.result as ArrayCollection);
	//create a list of selected linkages
	var sls:ArrayCollection = new ArrayCollection();
	
	//iterate through the linkages of the shape
	var linkages:ArrayCollection = selectedShape.linkages;
	for(var i:int=0;i<linkages.length;i++)
	{
		//get linkage
		var l:Linkage = linkages[i];
		//create a new selected linkage
		var sl:SelectedLinkage = new SelectedLinkage();
		//set the label
		sl.shape2.label = l.shape.label;
		//set the symbol type
		sl.shape2.labelSymbolType = l.shape.labelSymbolType;
		sl.shape1.label = selectedShape.label;
		sl.shape1.labelSymbolType = selectedShape.labelSymbolType;
		//iterate through the citations
		for(var m:int=0;m<l.citationIds.length;m++)
		{
			//find citation from the dictionary
			var c:Citation = d[l.citationIds[m]];
			//add citation to list
			sl.citations.addItem(c);
		}
		//add selected linkage to list
		sls.addItem(sl);
	}	

	//bind to repeater
	sppPanel.rp.dataProvider = sls;
	
	//check if there are no linkages
	if(sls.length==0)
		sppPanel.nolnk.visible = true;
}		
	
private function handleRepeaterEnd(event:FlexEvent):void
{
	//remove busy cursor
	sppPanel.deleteb.enabled = true;
	sppPanel.closeb.enabled = true;

	sppPanel.deleteb.mouseEnabled = true;
	sppPanel.closeb.mouseEnabled = true;

	CursorManager.removeBusyCursor();
	busyCursor = false;
//			//creating informaiton popup
//	PopUpManager.removePopUp(infoPanel);
//	infoPanel = null;
	//	//set focus 
	this.setFocus();
	trace("repeaterEnd event");
}		

private function handleClose(event:MouseEvent):void
{
	closePopUp();
}

private function handleClosePanel(event:CloseEvent):void
{
	closePopUp();
}

private function handleDelete(event:MouseEvent):void
{
	//don't do anything if no items are selected
	if(sppPanel.lnkIndex==null)
		return;
	
	//items to remove
	var itemsToRemove:ArrayCollection = new ArrayCollection();
	
	//iterate through the checkboxes
	for(var i:int=sppPanel.lnkIndex.length-1;i>=0;i--)
	{
		//check if linkage has been checked for deletion
		var cb:CheckBox = sppPanel.lnkIndex[i] as CheckBox;
		if(cb.selected)
		{
			//delete linkage
			var l:Linkage = selectedShape.linkages[i];
			//remove linkage from selected shape
			selectedShape.removeLinkage(l.shape);
			//remove linkage from the other shape of the linkage
			l.shape.removeLinkage(selectedShape);
			//add to items to remove
			itemsToRemove.addItem(i);
		}
	}	
	//info
	selectedShape.printLinkages();
	
	//update data provider
	var dp:ArrayCollection = sppPanel.rp.dataProvider as ArrayCollection;
	for(var m:int=0;m<itemsToRemove.length;m++)
	{
		dp.removeItemAt(itemsToRemove[m]);
	}
	
	//check if there are no linkages
	if(dp.length==0)
		sppPanel.nolnk.visible = true;
}

private function closePopUp():void
{
	//check if you are still trying to receive results
	//Note: if  you don't do this an exception will occur
	if(!busyCursor)
	{
		trace("close " + this);
		PopUpManager.removePopUp(sppPanel);
		sppPanel = null;
		selectedShape = null;
		
		//set focus 
		this.setFocus();
	}
}

