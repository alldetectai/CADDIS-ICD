package com.tetratech.caddis.model;

public class LookupValue {
	private long id;
	private String code;
	private String desc;

	public LookupValue() {

	}

	public LookupValue(long id, String desc) {
		this.id = id;
		this.desc = desc;
	}

	public LookupValue(long id, String code, String desc) {
		this.id = id;
		this.code = code;
		this.desc = desc;
	}
	
	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getDesc() {
		return desc;
	}

	public void setDesc(String desc) {
		this.desc = desc;
	}

}
