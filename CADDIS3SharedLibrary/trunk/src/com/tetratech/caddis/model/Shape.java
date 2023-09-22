package com.tetratech.caddis.model;

import java.util.ArrayList;
import java.util.List;

public class Shape {

	private Long id;
	private Point origin;
	private Long color;
	private Integer cwidth;
	private Integer cheight;
	private Integer thickness;
	private Integer binIndex;
	private String label;
	private List connectors = new ArrayList();
	//private Shape parentShape;
	//private List childShapes = new ArrayList();
	private List linkages = new ArrayList();
	private List attributes = new ArrayList();// only one object for now, p, n, t, ...
	private Long legendType;
	private Long labelSymbolType;//0 or null represent no symbol
	private Long termId;
		
	public Shape() {

	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Point getOrigin() {
		return origin;
	}

	public void setOrigin(Point origin) {
		this.origin = origin;
	}

	public Long getColor() {
		return color;
	}

	public void setColor(Long color) {
		this.color = color;
	}

	public Integer getCwidth() {
		return cwidth;
	}

	public void setCwidth(Integer cwidth) {
		this.cwidth = cwidth;
	}

	public Integer getCheight() {
		return cheight;
	}

	public void setCheight(Integer cheight) {
		this.cheight = cheight;
	}

	public Integer getThickness() {
		return thickness;
	}

	public void setThickness(Integer thickness) {
		this.thickness = thickness;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public List getLinkages() {
		return linkages;
	}

	public void setLinkages(List linkages) {
		this.linkages = linkages;
	}

	public List getConnectors() {
		return connectors;
	}

	public void setConnectors(List connectors) {
		this.connectors = connectors;
	}

	public Long getLegendType() {
		return legendType;
	}

	public void setLegendType(Long legendType) {
		this.legendType = legendType;
	}

	public Integer getBinIndex() {
		return binIndex;
	}

	public void setBinIndex(Integer binIndex) {
		this.binIndex = binIndex;
	}
	
	public List getAttributes() {
		return attributes;
	}

	public void setAttributes(List attributes) {
		this.attributes = attributes;
	}
	
	public Long getLabelSymbolType() {
		return labelSymbolType;
	}

	public void setLabelSymbolType(Long labelSymbolType) {
		this.labelSymbolType = labelSymbolType;
	}

	public Long getTermId() {
		return termId;
	}

	public void setTermId(Long termId) {
		this.termId = termId;
	}

	public  Linkage findLinkage(Shape shape)
	{
		//search for linkage
		for(int i = 0;i < linkages.size(); i++)
		{
			Linkage l = (Linkage)linkages.get(i);
			if(l.getShape() == shape)
			{
				return l;
			}
		}
		return null;
	}
}
