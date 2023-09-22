package com.tetratech.caddis.model;

import java.util.ArrayList;
import java.util.List;

public class Linkage {
	private long id;
	private Shape shape;
	private List citationIds = new ArrayList();

	public Linkage() {

	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public Shape getShape() {
		return shape;
	}

	public void setShape(Shape shape) {
		this.shape = shape;
	}

	public List getCitationIds() {
		return citationIds;
	}

	public void setCitationIds(List citationIds) {
		this.citationIds = citationIds;
	}


}
