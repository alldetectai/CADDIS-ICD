package com.tetratech.caddis.model;

public class Term {
	private Long id;
	private String term;
	private String desc;
	private boolean isEELTerm;
	private Long legendType;
	
	public Term() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getTerm() {
		return term;
	}

	public void setTerm(String term) {
		this.term = term;
	}

	public String getDesc() {
		return desc;
	}

	public void setDesc(String desc) {
		this.desc = desc;
	}

	public boolean isEELTerm() {
		return isEELTerm;
	}

	public void setEELTerm(boolean isEELTerm) {
		this.isEELTerm = isEELTerm;
	}

	public Long getLegendType() {
		return legendType;
	}

	public void setLegendType(Long shapeType) {
		this.legendType = shapeType;
	}
}
