package com.tetratech.caddis.model;

import java.util.ArrayList;
import java.util.List;

public class Line {
	
	private Long id;
	private List points = new ArrayList();
	private Long color;
	private Integer thickness;
	private Connector firstConnector;
	private Connector lastConnector;
	
	public Line() {
	}

	public Long getId() {
		return id;
	}
	
	public void setId(Long id) {
		this.id = id;
	}
	
	public void setColor(Long color) {
		this.color = color;
	}

	public Long getColor() {
		return color;
	}
	
	public Integer getThickness() {
		return thickness;
	}

	public void setThickness(Integer thickness) {
		this.thickness = thickness;
	}
	
	public List getPoints() {
		return points;
	}
	
	public void setPoints(List points) {
		this.points = points;
	}
	
	public Connector getFirstConnector() {
		return firstConnector;
	}

	public void setFirstConnector(Connector firstConnector) {
		this.firstConnector = firstConnector;
	}
	
	public Connector getLastConnector() {
		return lastConnector;
	}

	public void setLastConnector(Connector lastConnector) {
		this.lastConnector = lastConnector;
	}
}
