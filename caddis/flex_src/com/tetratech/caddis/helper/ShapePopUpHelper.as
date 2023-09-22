import com.adobe.utils.StringUtil;
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.drawing.CShape;
import com.tetratech.caddis.model.Model;
import com.tetratech.caddis.service.Service;
import com.tetratech.caddis.view.AddTerm;
import com.tetratech.caddis.vo.LookupValue;
import com.tetratech.caddis.vo.Term;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.CheckBox;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;
import mx.validators.Validator;

private var apPanel:AddTerm = null;
private var legentList:ArrayCollection = null;

public function init():void
{
	//populate all the terms
	getAllTerms(null, true);
	filterc.addEventListener(KeyboardEvent.KEY_UP, keyUpSearchTermHandler);
	getLegentType();
	stype.dropdown.iconField = "icon";

}

private function keyUpSearchTermHandler(event:KeyboardEvent):void {
	if (event.keyCode ==Keyboard.ENTER)
	{
		var isStand = searchEEl.selected ? true : false;
		if(filterc.text!=null && StringUtil.trim(filterc.text).length > 0)
			getAllTerms(filterc.text, isStand);
		else
			getAllTerms(null, isStand);
	}
}

private function searchEelTerms(event:MouseEvent):void
{
	var isStand = searchEEl.selected ? true : false;
	if (searchEEl.selected ) searchAll.selected = false;
	if(filterc.text!=null && StringUtil.trim(filterc.text).length > 0)
		getAllTerms(filterc.text, isStand);
	else
		getAllTerms(null, isStand);
}

private function searchTerms(event:MouseEvent):void
{
	var isStand = searchAll.selected ? false : true;
	if (searchAll.selected ) searchEEl.selected = false;
	if(filterc.text!=null && StringUtil.trim(filterc.text).length > 0)
		getAllTerms(filterc.text, isStand);
	else
		getAllTerms(null, isStand);
}
/*bug 0008379
private function addNewTerm(event:MouseEvent):void
{
	//create pop up panel
	apPanel = new AddTerm();
	//add init event handler for pop up
	apPanel.addEventListener(FlexEvent.INITIALIZE,handleAddTermCreation)
	//show pop up
	PopUpManager.addPopUp(apPanel, this, true);
	PopUpManager.centerPopUp(apPanel);
	apPanel.y = 100;
}

private function handleAddTermCreation(event:FlexEvent):void
{
	//add event listener's for buttons	
	apPanel.save.addEventListener(MouseEvent.CLICK,saveTerm);
	apPanel.cancel.addEventListener(MouseEvent.CLICK,cancelTerm);
	apPanel.addEventListener(CloseEvent.CLOSE,handleCloseTerm);
	apPanel.shapeType.dropdown.iconField = "icon";
	//apPanel.shapeType.dataProvider = Constants.SHAPE_SYMBOLS;
	//Alert(apPanel.shapeType.dataProvider.length);
}

private function saveTerm(evt:MouseEvent):void
{
	//validate errors 
	var valArray:Array = new Array();
	valArray.push(apPanel.valTerm);
	valArray.push(apPanel.valDesc);
	var validatorErrorArray:Array = Validator.validateAll(valArray);
	//don't update shape if there are errors
	if(validatorErrorArray.length == 0)
	{
		var s:Service = new Service();
		s.serviceHandler = handleNoDuplicateNewTerm;
		//check if term exists using exact match
		s.searchTerms(StringUtil.trim(apPanel.term.text), true, true);
	}
	else
	{
		apPanel.error.visible = true;
	}
}

private function handleNoDuplicateNewTerm(evt:ResultEvent):void
{
	var result:ArrayCollection = evt.result as ArrayCollection;
	
	if(result.length > 0)
		Alert.show("Term exists in the system. Please add another new term");
	else {
		
		var term:Term = new Term();
		term.isEELTerm = apPanel.eelTerm.selected;
		term.term = StringUtil.trim(apPanel.term.text);
		term.desc = StringUtil.trim(apPanel.desc.text);
		if ( apPanel.shapeType.selectedItem != null && apPanel.shapeType.selectedItem.value != 0)
			term.legendType = apPanel.shapeType.selectedItem.value;
		
		var s:Service = new Service();
		s.serviceHandler = handleAddNewTerm;
		s.saveTerm(term, Model.user.userId);
	}
}

private function handleAddNewTerm(evt:ResultEvent):void
{
	var result:Number = evt.result as Number;
	slabel.text = StringUtil.trim(apPanel.term.text);
	termId.text = result as String;
	//should we putnew on the top?
	getAllTerms(null, true);
	//remove pop up
	removeAddTermPopUp();
	Alert("Term successfully saved.");
}
*/
private function cancelTerm(evt:MouseEvent):void
{
	removeAddTermPopUp();
}

private function handleCloseTerm(evt:CloseEvent):void
{
	removeAddTermPopUp();
}

private function removeAddTermPopUp():void
{
	//remove pop up
	PopUpManager.removePopUp(apPanel);
	apPanel = null;
	
	this.setFocus();
}

private function getAllTerms(filter:String, isStand:Boolean):void
{
	var s:Service = new Service();
	s.serviceHandler = handleGetAllTerms;
	//if the user specifices a filter get filtered terms
	//otherwise get the entire list
	s.searchTerms(filter, false, isStand);
}

private function handleGetAllTerms(event:ResultEvent):void
{
	//update term list
	var rc:ArrayCollection = event.result as ArrayCollection;
	//assign data provider
	terms.dataProvider = rc;
	terms.labelField = "term";
}

private function getLegentType():void
{
	var s:Service = new Service();
	s.serviceHandler = handleGetLegentTypes;
	s.getLegentType();
}

private function handleGetLegentTypes(event:ResultEvent):void
{
	var list = event.result as ArrayCollection;	
	var nullObj:LookupValue = new LookupValue();
	nullObj.id = 0;
	nullObj.code = "";
	nullObj.desc = "";
	list.addItemAt(nullObj, 0);
	legentList = list;
	
	//stype.dataProvider = Constants.SHAPE_SYMBOLS; 
}

private function termDoubleClickHandler(event:ListEvent):void
{
	//get the current selected term
	var t:Term = terms.selectedItem as Term;
	if(t != null)
	{
		slabel.text = t.term;
		termId.text = t.id.toString();
		
		//Alert(t.legendType.toString());
		if (t.legendType == 0 )
			stype.selectedItem = null;	
		else 
			stype.selectedItem = selectShape(t.legendType);
	}
}

private function selectShape(id:int):Object
{
	var dp:ArrayCollection = Constants.SHAPE_SYMBOLS;
	for(var i:int=0;i<dp.length;i++){
		if(id == dp[i].value)
			return dp[i];
	}
	return null;
}

//will set the iconClass for parent dropdown combobox 
private function getIconForShape(value:Object):Class
{
	var cellData:Object = value;
	if(cellData!=null)
	{
		//cast the shape
		var shape:CShape = value as CShape;

 		//set the symbol
 		if(shape.labelSymbolType == Constants.SYMBOL_ARROW_UP)
 			return Constants.SYMBOL_IMAGE_INCREASING;
 		else if(shape.labelSymbolType == Constants.SYMBOL_DELTA)
 			return Constants.SYMBOL_IMAGE_CHANGE;
 		else if(shape.labelSymbolType == Constants.SYMBOL_ARROW_DOWN)
 			return Constants.SYMBOL_IMAGE_DECREASING;
 		else
 			//shapeSymbol.width = 0;
 			return Constants.SYMBOL_IMAGE_NONE;	
	} else {
		
		//shapeSymbol.width = 0;
		return Constants.SYMBOL_IMAGE_NONE;
	}
} 

