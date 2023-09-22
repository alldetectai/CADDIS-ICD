/** 
* +---------------------------------------------------------------------------+
* | Environmental Data Analysis System (EDAS2)                                |
* +---------------------------------------------------------------------------+
* | Copyright (C) 2008-2009 by Tetra Tech, Inc., http://www.tetratech.com     |
* |                                                                           |
* |   Contributors:  Dan Allen, Martin Hurd, Benjamin Jessup, Erik Leppo      |
* |   Vladislav Royzman, Sunitha Sajjan, Daniel Sporea                        |
* |   Dritan Tako, Jeff White, Liejun Wu, John Zastrow                        |
* +---------------------------------------------------------------------------+
* |                                                                           |
* | This program is free software; you can redistribute it and/or             |
* | modify it under the terms of the GNU General Public License               |
* | as published by the Free Software Foundation; either version 2            |
* | of the License, or (at your option) any later version.                    |
* |                                                                           |
* | This program is distributed in the hope that it will be useful,           |
* | but WITHOUT ANY WARRANTY; without even the implied warranty of            |
* | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             |
* | GNU General Public License for more details.                              |
* |                                                                           |
* | You should have received a copy of the GNU General Public License         |
* | along with this program; if not, write to the Free Software Foundation,   |
* | Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.           |
* |                                                                           |
* +---------------------------------------------------------------------------+
*
*/

package com.tetratech.caddis.common;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class GenericDataTable {
	private Map data = new HashMap();
	private int rowCount = 0;
	
	public GenericDataTable(){

	}

	public String getData(int row, String column){
		if(!data.keySet().contains(column))
			throw new RuntimeException("Column " + column + " doesn't exist in data table");

		List colData = (List)data.get(column);

		if(row>=colData.size())
			throw new RuntimeException("Out of bound row index");

		return (String)colData.get(row);
	}
	
	public List getData(String column){
		if(!data.keySet().contains(column))
			throw new RuntimeException("Column " + column + " doesn't exist in data table");

		return (List)data.get(column);
	}
	
	public void removeRow(int row) {
		Set columns = data.keySet();
		//make sure value list is in the range for all the columns
		//may not need this check
		Iterator i = columns.iterator();
		while(i.hasNext()){
			String column = (String)i.next();
			if(row >= ((List)data.get(column)).size())
				throw new RuntimeException("Out of bound row index");
		}
		//remove the row iterating the columns
		while(i.hasNext()){
			String columnName = (String)i.next();	
			((List)data.get(columnName)).remove(row);
		}
		//update row count
		if(rowCount > 0)
			rowCount--;
	}
	
	public  void setData(int row,String column,String cellData){
		if(!data.keySet().contains(column))
			throw new RuntimeException("Column " + column + " doesn't exist in data table");

		List colData = (List)data.get(column);

		if(row>=colData.size())
			throw new RuntimeException("Out of bound row index");

		colData.set(row,cellData);
	}

	public void addData(String column,String cellData){
		if(!data.keySet().contains(column))
			throw new RuntimeException("Column " + column + " doesn't exist in data table");

		List colData = (List)data.get(column);
		colData.add(cellData);
		
		//update count
		if(rowCount < colData.size())
			rowCount = colData.size();

	}

	public void addColumn(String column){
		if(data.keySet().contains(column))
			throw new RuntimeException("Column " + column + " has been already added to data table");

		data.put(column, new ArrayList());

	}

	public void removeColumn(String column){
		if(!data.keySet().contains(column))
			throw new RuntimeException("Column " + column + " doesn't exist in data table");

		data.keySet().remove(column);
	}

	public Set getColumns() {
		return data.keySet();
	}

	public void setColumns(Set columns) {
		data.keySet().clear();
		data.keySet().addAll(columns);
	}

	public int size(){
		return rowCount;
	}

	public int columns(){
		return data.keySet().size();
	}

}
