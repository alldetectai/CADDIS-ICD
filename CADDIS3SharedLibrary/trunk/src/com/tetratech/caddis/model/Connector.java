package com.tetratech.caddis.model;


public class Connector {
	private Long id;
	private Shape shape;
	private Line line;
	private Integer index;
	private Boolean start;

	public Connector() {
	}
	
	public Connector(Long id, Shape shape, Line line, Integer index, Boolean start) {
		this.id = id;
		this.shape = shape;
		this.line = line;
		this.index = index;
		this.start = start;
	}
	
	public Connector(Shape shape, Line line, Integer index, Boolean start) {
		this.shape = shape;
		this.line = line;
		this.index = index;
		this.start = start;
	}
	
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Shape getShape() {
		return shape;
	}

	public void setShape(Shape shape) {
		this.shape = shape;
	}

	public Line getLine() {
		return line;
	}

	public void setLine(Line line) {
		this.line = line;
	}

	public Integer getIndex() {
		return index;
	}

	public void setIndex(Integer index) {
		this.index = index;
	}

	public Boolean getStart() {
		return start;
	}

	public void setStart(Boolean start) {
		this.start = start;
	}
}
