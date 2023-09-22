package com.tetratech.caddis.model;


public class UploadedReferenceResult{
	int row;
	private String item;
	private boolean success;
	
	public UploadedReferenceResult(){
		
	}
	
	public int getRow() {
		return row;
	}

	public void setRow(int row) {
		this.row = row;
	}

	public String getItem() {
		return item;
	}

	public void setItem(String item) {
		this.item = item;
	}

	public boolean isSuccess() {
		return success;
	}

	public void setSuccess(boolean success) {
		this.success = success;
	}
	
}