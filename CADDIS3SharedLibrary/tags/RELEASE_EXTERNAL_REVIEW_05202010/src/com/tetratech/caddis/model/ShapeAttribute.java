package com.tetratech.caddis.model;

import java.util.ArrayList;
import java.util.List;

public class ShapeAttribute {
	// DIAGRAM_FILTER  or DISPLAY TYPE
	private long type;
	private List values = new ArrayList();
	
	public ShapeAttribute() {
		
	}

	public long getType() {
		return type;
	}

	public void setType(long type) {
		this.type = type;
	}

	public List getValues() {
		return values;
	}

	public void setValues(List values) {
		this.values = values;
	}	
}
