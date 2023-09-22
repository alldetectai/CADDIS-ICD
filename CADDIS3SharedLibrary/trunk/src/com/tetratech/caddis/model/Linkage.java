package com.tetratech.caddis.model;

import java.util.ArrayList;
import java.util.List;

public class Linkage {
	private long id;
	private Shape shape; //Effect shape or shape_to
	private List citationIds = new ArrayList();
	private long causeId;
	private long effectId;
	private boolean strongLinkage;
	private boolean effectRelationship;
	private List causeEffectIds = new ArrayList();
	private List dataSetIds = new ArrayList();
	
	public Linkage() {

	}

	public List getDataSetIds() {
		return dataSetIds;
	}

	public void setDataSetIds(List dataSetIds) {
		this.dataSetIds = dataSetIds;
	}
	
	public List getCauseEffectIds() {
		return causeEffectIds;
	}

	public void setCauseEffectIds(List causeEffectIds) {
		this.causeEffectIds = causeEffectIds;
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

	public long getCauseId() {
		return causeId;
	}

	public void setCauseId(long causeId) {
		this.causeId = causeId;
	}

	public long getEffectId() {
		return effectId;
	}

	public void setEffectId(long effectId) {
		this.effectId = effectId;
	}

	public boolean isStrongLinkage() {
		return strongLinkage;
	}

	public void setStrongLinkage(boolean strongLinkage) {
		this.strongLinkage = strongLinkage;
	}

	public boolean isEffectRelationship() {
		return effectRelationship;
	}

	public void setEffectRelationship(boolean effectRelationship) {
		this.effectRelationship = effectRelationship;
	}


}
