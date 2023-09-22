// ActionScript file
import com.tetratech.caddis.event.OrganismFilterEvent;
import com.tetratech.caddis.service.Service;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.CheckBox;
import mx.rpc.events.ResultEvent;

public function init():void
{
	allOrganisms.selected = true;
	allOrganisms.addEventListener(MouseEvent.CLICK,handleOrganismAll);
	getOrganismFilters();
}

private function getOrganismFilters():void
{
	var s:Service = new Service();
	s.serviceHandler = handleGetOrganismFilters;
	s.getOrganismFilters();
}

private function handleGetOrganismFilters(event:ResultEvent):void
{
	//populate organism filters
	rp.dataProvider = event.result as ArrayCollection;
	rp.executeBindings(false);
	//add event handlers for filters
	for(var i:int=0;i<organismFilters.length;i++)
	{
		var cb:CheckBox = organismFilters[i];
		cb.selected = true;
		cb.addEventListener(MouseEvent.CLICK,handleOrganismFilter);
	}
}


private function areAllFiltersSelected():Boolean
{
	for(var i:int=0;i<organismFilters.length;i++)
	{
		var cb:CheckBox = organismFilters[i];
		if(!cb.selected)
			return false;
	}
	return true;
}

//utility method to get the current filters
public function getCurrentFilters():ArrayCollection
{
	if(allOrganisms.selected == true)
		return null;
	else
	{
		var df:ArrayCollection = new ArrayCollection();
		//get the set of filters selected by the user
		for(var i:int=0;i<organismFilters.length;i++)
		{
			if(organismFilters[i].selected)
				df.addItem(rp.dataProvider[i]);
		}
		return df;
	}
}

public function reset():void
{
	//select all
	allOrganisms.selected = true;
	selectAllFilters();
}

private function deselectAllFilters():void
{
	for(var i:int=0;i<organismFilters.length;i++)
	{
		var cb:CheckBox = organismFilters[i];
		cb.selected = false;
	}
}

private function selectAllFilters():void
{
	for(var i:int=0;i<organismFilters.length;i++)
	{
		var cb:CheckBox = organismFilters[i];
		cb.selected = true;
	}
}

private function handleOrganismAll(event:MouseEvent):void
{
	if(allOrganisms.selected)
	{
		//select all filters
		selectAllFilters();
		//boardcast all event
		broadcastOrganismFilterAll();
	}
	else
	{
		//deselect all
		deselectAllFilters();
		//boardcast empty some event 
		broadcastOrganismFilterSome(getCurrentFilters());
	}
}

private function handleOrganismFilter(event:MouseEvent):void
{
	if(areAllFiltersSelected())
	{
		allOrganisms.selected = true;
		//boardcast all event
		broadcastOrganismFilterAll();
	}
	else
	{
		allOrganisms.selected = false;
		//boardcast event with filters
		broadcastOrganismFilterSome(getCurrentFilters());
	}
}

/* This method is used to broadcast a Organism filter event*/
private function broadcastOrganismFilterSome(filters:ArrayCollection):void
{
	var dfe:OrganismFilterEvent = new OrganismFilterEvent(OrganismFilterEvent.ORGANISM_FILTER_SOME);
	dfe.filters = filters;
	this.dispatchEvent(dfe);
}

/* This method is used to broadcast a Organism filter event*/
private function broadcastOrganismFilterAll():void
{
	var dfe:OrganismFilterEvent = new OrganismFilterEvent(OrganismFilterEvent.ORGANISM_FILTER_ALL);
	dfe.filters = null;
	this.dispatchEvent(dfe);
}
 