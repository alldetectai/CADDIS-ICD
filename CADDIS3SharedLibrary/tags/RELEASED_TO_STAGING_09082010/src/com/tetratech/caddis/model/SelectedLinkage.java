package com.tetratech.caddis.model;

import java.util.ArrayList;
import java.util.List;

public class SelectedLinkage {
	private String label;
	private String diagramName;
	public List citations = new ArrayList();
	private Shape shape1;
	private Shape shape2;
	
	
	public SelectedLinkage() {
		
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public List getCitations() {
		return citations;
	}

	public void setCitations(List citations) {
		this.citations = citations;
	}

	public String getDiagramName() {
		return diagramName;
	}

	public void setDiagramName(String diagramName) {
		this.diagramName = diagramName;
	}

	/**
	 * @return the shape1
	 */
	public Shape getShape1() {
		return shape1;
	}

	/**
	 * @param shape1 the shape1 to set
	 */
	public void setShape1(Shape shape1) {
		this.shape1 = shape1;
	}

	/**
	 * @return the shape2
	 */
	public Shape getShape2() {
		return shape2;
	}

	/**
	 * @param shape2 the shape2 to set
	 */
	public void setShape2(Shape shape2) {
		this.shape2 = shape2;
	}

}
