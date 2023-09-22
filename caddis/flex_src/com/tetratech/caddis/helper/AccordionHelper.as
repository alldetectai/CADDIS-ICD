// ActionScript file
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.event.OrganismFilterEvent;

import flash.events.MouseEvent;

import mx.core.Container;
import mx.events.EffectEvent;
	 
//dragging fields
private var dragging:Boolean = false;
private var dragTab:Container = null;	
private var oldMouseY:Number = 0; 

//new: flag for organism shown
private var organismFilterShown:Boolean = false;

private function init():void
{
	//init height of tabs
	tab1.height = tab2.height = tab3.height = Constants.ACCORDION_TAB_DEFAULT_HEIGHT;
	//init icons for Constants.closed and Constants.opened buttons
	btn1.source = Constants.opened;
	btn2.source = Constants.opened;
	btn3.source = Constants.opened;
	//add click event listeners 
	btn1.addEventListener(MouseEvent.CLICK,handleUpOrDown);
	btn2.addEventListener(MouseEvent.CLICK,handleUpOrDown);
	btn3.addEventListener(MouseEvent.CLICK,handleUpOrDown);
	//add mouse even listeners - Constants.opened
	tab1bar.addEventListener(MouseEvent.MOUSE_DOWN,handleTabBarSelection);
	tab2bar.addEventListener(MouseEvent.MOUSE_DOWN,handleTabBarSelection);
	tab3bar.addEventListener(MouseEvent.MOUSE_DOWN,handleTabBarSelection);
	//add mouse even listeners - release and move
	addEventListener(MouseEvent.MOUSE_UP,handleTabBarRelease);
	addEventListener(MouseEvent.MOUSE_MOVE,handleTabBarMove);
	
	/* COMMENT OUT ORGANISMS
	//NEW: NEEDED FOR ORGANISM FILTER
	//init filter component
	organismFilter.init();
	//add event handlers
	organismTogglerIcon.addEventListener(MouseEvent.CLICK,handleOrganismToggler);
	organismFilter.addEventListener(EffectEvent.EFFECT_END,handleOrganismEffectEnd);
	organismFilter.addEventListener(OrganismFilterEvent.ORGANISM_FILTER_ALL,handleOrganismAll);
	organismFilter.addEventListener(OrganismFilterEvent.ORGANISM_FILTER_SOME,handleOrganismSome);
	//set up togglers
	organismTogglerIcon.source = Constants.closed;
	//END OF NEW
	*/
}

private function handleUpOrDown(event:MouseEvent):void
{
	if(event.target == btn1)
	{
		if(btn1.source == Constants.opened)
		{
			btn1.source = Constants.closed;
			closeTab(tab1,tab2,btn2.source == Constants.closed,tab3,btn3.source == Constants.closed);
		}
		else
		{
			btn1.source = Constants.opened;
			openTab(tab1,tab2,btn2.source == Constants.closed,tab3,btn3.source == Constants.closed);
		}
		
		hideShowUpDownControls();
	}
	else if(event.target == btn2)
	{
		if(btn2.source == Constants.opened)
		{
			btn2.source = Constants.closed;
			closeTab(tab2,tab1,btn1.source == Constants.closed,tab3,btn3.source == Constants.closed);
		}
		else
		{
			btn2.source = Constants.opened;
			openTab(tab2,tab1,btn1.source == Constants.closed,tab3,btn3.source == Constants.closed);
		}
		
		hideShowUpDownControls();
	}
	else if(event.target == btn3)
	{
		if(btn3.source == Constants.opened)
		{
			btn3.source = Constants.closed;
			closeTab(tab3,tab1,btn1.source == Constants.closed,tab2,btn2.source == Constants.closed);
		}
		else
		{
			btn3.source = Constants.opened;
			openTab(tab3,tab1,btn1.source == Constants.closed,tab2,btn2.source == Constants.closed);
		}
		
		hideShowUpDownControls();
	}
	//*** IMPORTANT ***
	//Disable dragging if you clicked on an Constants.closed or Constants.opened control
	dragging = false;
	//***//
}

private function handleTabBarSelection(event:MouseEvent):void
{
	//the top bar cannot be dragged
	if(event.target == tab1bar)
	{
		//don't do anything
	}
	else if(event.target == tab2bar || event.target.parent.parent == tab2bar)
	{
		//check if you are between to tabs and
		//you should not drag the tab bar
		//because the tab bars are stacked
		if(!(btn1.source == Constants.closed && btn2.source == Constants.closed))
		{
			dragging = true;
			dragTab = tab2;
			oldMouseY = mouseY;
		}
	}
	else if(event.target == tab3bar || event.target.parent.parent == tab3bar)
	{
		dragging = true;
		dragTab = tab3;
		oldMouseY = mouseY;	
	}
}

private function handleTabBarRelease(event:MouseEvent):void
{
	if(dragging)
	{
		//disable dragging on release
		oldMouseY = 0;
		dragging = false;
	}
}

private function handleTabBarMove(event:MouseEvent):void
{
	if(dragging)
	{
		//calculate delta move
		var delta:Number = -(mouseY - oldMouseY);
		//do something based on tab dragging
		if(dragTab == tab2)
		{
			//check if you need to open the upper tab
			//if you move in the downward position
			if(delta < 0 && btn1.source == Constants.closed)
			{
				btn1.source = Constants.opened;	
				//check if you need to hide the control
				if(btn2.visible == false)
					btn2.visible = true;
			}
			//check if you need to open the current tab
			//if you move in the upward position
			else(delta > 0 && btn2.source == Constants.closed)
			{
				btn2.source = Constants.opened;
				//check if you need to hide the control
				if(btn1.visible == false)
					btn1.visible = true;
			}
			
			//check if the tab bar is within the 
			//required boundaries of the upper tab
			// (if so close to the upper tab and disable dragging)
			if((tab1.height - delta) <= Constants.ACCORDION_TAB_MIN_HEIGHT)
			{
				btn1.source = Constants.closed;
				
				tab1.height = Constants.ACCORDION_TAB_MIN_HEIGHT;
				tab2.height = 3*Constants.ACCORDION_TAB_DEFAULT_HEIGHT - tab1.height - tab3.height;  
				
				tab1con.height = tab1.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
				tab2con.height = tab2.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
				
				dragging = false;
				//check if you need to hide the control
				if(btn3.source == Constants.closed)
					btn2.visible = false;
			}
			//check if the tab bar is within the 
			//required boundaries of the lower tab
			//(if so close to the current tab and disable dragging)
			else if((tab2.height + delta) <= Constants.ACCORDION_TAB_MIN_HEIGHT)
			{
				btn2.source = Constants.closed;
				
				tab2.height = Constants.ACCORDION_TAB_MIN_HEIGHT;
				tab1.height = 3*Constants.ACCORDION_TAB_DEFAULT_HEIGHT - tab2.height - tab3.height; 
				
				tab1con.height = tab1.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
				tab2con.height = tab2.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
				
				dragging = false;
				//check if you need to hide the control
				if(btn3.source == Constants.closed)
					btn1.visible = false;
			}
			else
			{
				//drag tab around
				tab1.height -= delta;
				tab2.height += delta;
				
				tab1con.height = tab1.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
				tab2con.height = tab2.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
			}
		}
		else if(dragTab == tab3)
		{
			//check if you need to open the upper tab
			//if you move in the downward position
			if(delta < 0 && btn2.source == Constants.closed)
			{
				btn2.source = Constants.opened;
				//check if you need to hide the control
				if(btn3.visible == false)
					btn3.visible = true;	
			}
			//check if you need to open the current tab
			//if you move in the upward position
			else(delta > 0 && btn3.source == Constants.closed)
			{
				btn3.source = Constants.opened;
				//check if you need to hide the control
				if(btn2.visible == false)
					btn2.visible = true;	
			}
			
			//check if the tab bar is within the 
			//required boundaries of the upper tab
			// (if so close to the upper tab and disable dragging)
			if((tab2.height - delta) <= Constants.ACCORDION_TAB_MIN_HEIGHT)
			{
				btn2.source = Constants.closed;
				
				tab2.height = Constants.ACCORDION_TAB_MIN_HEIGHT;
				tab3.height = 3*Constants.ACCORDION_TAB_DEFAULT_HEIGHT - tab1.height - tab2.height; 
				
				tab2con.height = tab2.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
				tab3con.height = tab3.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
				
				dragging = false;
				//check if you need to hide the control
				if(btn1.source == Constants.closed)
					btn3.visible = false;
			}
			//check if the tab bar is within the 
			//required boundaries of the lower tab
			//(if so close to the current tab and disable dragging)
			else if((tab3.height + delta) <= Constants.ACCORDION_TAB_MIN_HEIGHT)
			{
				btn3.source = Constants.closed;
				
				tab3.height = Constants.ACCORDION_TAB_MIN_HEIGHT;
				tab2.height = 3*Constants.ACCORDION_TAB_DEFAULT_HEIGHT - tab1.height - tab3.height; 
				
				tab2con.height = tab2.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
				tab3con.height = tab3.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
				
				dragging = false;
				//check if you need to hide the control
				if(btn1.source == Constants.closed)
					btn2.visible = false;
			}
			else
			{
				//drag tab around
				tab2.height -= delta;
				tab3.height += delta;
				
				tab2con.height = tab2.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
				tab3con.height = tab3.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
			}
		
		}
		//update the mouse position
		oldMouseY = mouseY;
	}
}

private function closeTab(tab:Container,otherTab1:Container,otherTab1Closed:Boolean,otherTab2:Container,otherTab2Closed:Boolean):void
{

		//check what to do with the other tabs		
		if(!otherTab1Closed && !otherTab2Closed)
		{
			otherTab1.height = otherTab2.height = (3*Constants.ACCORDION_TAB_DEFAULT_HEIGHT-Constants.ACCORDION_TAB_MIN_HEIGHT)/2;
			tab.height = Constants.ACCORDION_TAB_MIN_HEIGHT;
		}
		else if(!otherTab1Closed && otherTab2Closed)
		{
			otherTab1.height = 3*Constants.ACCORDION_TAB_DEFAULT_HEIGHT-2*Constants.ACCORDION_TAB_MIN_HEIGHT;
			tab.height = Constants.ACCORDION_TAB_MIN_HEIGHT;
		}
		else if(otherTab1Closed && !otherTab2Closed)
		{
			otherTab2.height = 3*Constants.ACCORDION_TAB_DEFAULT_HEIGHT-2*Constants.ACCORDION_TAB_MIN_HEIGHT;
			tab.height = Constants.ACCORDION_TAB_MIN_HEIGHT;
		}
		else
		{
			throw new Error("Should never be here");
		}
		//update container's height
		updateTabContainerHeight();
}

private function openTab(tab:Container,otherTab1:Container,otherTab1Closed:Boolean,otherTab2:Container,otherTab2Closed:Boolean):void
{
		//check what to do with the other tabs		
		if(!otherTab1Closed && !otherTab2Closed)
		{
			tab.height = otherTab1.height = otherTab2.height = Constants.ACCORDION_TAB_DEFAULT_HEIGHT;
		}
		else if(!otherTab1Closed && otherTab2Closed)
		{
			tab.height = otherTab1.height = (3*Constants.ACCORDION_TAB_DEFAULT_HEIGHT-Constants.ACCORDION_TAB_MIN_HEIGHT)/2;
		}
		else if(otherTab1Closed && !otherTab2Closed)
		{
			tab.height = otherTab2.height = (3*Constants.ACCORDION_TAB_DEFAULT_HEIGHT-Constants.ACCORDION_TAB_MIN_HEIGHT)/2;
		}
		else
		{
			throw new Error("Should never be here");
		}
		//update container's height
		updateTabContainerHeight();
}

private function hideShowUpDownControls():void
{
	if(btn1.source == Constants.opened && btn2.source == Constants.closed && btn3.source == Constants.closed)
		btn1.visible = false;
	else if(btn1.source == Constants.closed && btn2.source == Constants.opened && btn3.source == Constants.closed)
		btn2.visible = false;
	else if(btn1.source == Constants.closed && btn2.source == Constants.closed && btn3.source == Constants.opened)
		btn3.visible = false;
	else
		btn1.visible = btn2.visible = btn3.visible = true;
}

private function updateTabContainerHeight():void
{
	tab1con.height = tab1.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
	tab2con.height = tab2.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
	tab3con.height = tab3.height - Constants.ACCORDION_TAB_MIN_HEIGHT;
}

/* COMMENT OUT ORGANISMS
//NEW: NEEDED FOR ORGANISM FILTER
private function handleOrganismAll(event:OrganismFilterEvent):void
{
	//call code from ViewSelectionHelper.as
	setSelectedLinkagesForExistingShapes(event.filters);
}

private function handleOrganismSome(event:OrganismFilterEvent):void
{
	//call code from ViewSelectionHelper.as
	setSelectedLinkagesForExistingShapes(event.filters);
}

private function handleOrganismToggler(event:MouseEvent):void
{
	if(!organismFilterShown)
	{
		organismTogglerIcon.source = Constants.opened;
		organismFilter.height = 94;
		organismFilter.visible = true;
		organismFilterShown = true;
	}
	else
	{
		organismTogglerIcon.source = Constants.closed;
		organismFilter.visible = false;
		organismFilterShown = false;
	}
}

private function handleOrganismEffectEnd(event:EffectEvent):void
{
	//NOTE: Need to do this after the effect ends
	//otherwise the effect doesn't work
	if(!organismFilterShown)
	{
		organismFilter.height = 0;
	}
}
//END OF NEW
*/