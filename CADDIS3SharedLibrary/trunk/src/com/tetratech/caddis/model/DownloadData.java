package com.tetratech.caddis.model;

import java.util.ArrayList;
import java.util.List;

public class DownloadData {
	
	private List citationIds = new ArrayList();
	private String format;
	private boolean includeAbstract;
	private boolean includeLinkage;
	private List selectedLinakge = new ArrayList();
	
	public DownloadData() {
		
	}
	
	public List getCitationIds() {
		return citationIds;
	}

	public void setCitationIds(List citationIds) {
		this.citationIds = citationIds;
	}

	public String getFormat() {
		return format;
	}

	public void setFormat(String format) {
		this.format = format;
	}

	public boolean getIncludeAbstract() {
		return includeAbstract;
	}

	public void setIncludeAbstract(boolean includeAbstract) {
		this.includeAbstract = includeAbstract;
	}

	public List getSelectedLinakge() {
		return selectedLinakge;
	}

	public void setSelectedLinakge(List selectedLinakge) {
		this.selectedLinakge = selectedLinakge;
	}

	/**
	 * @return the includeLinkage
	 */
	public boolean getIncludeLinkage() {
		return includeLinkage;
	}

	/**
	 * @param includeLinkage the includeLinkage to set
	 */
	public void setIncludeLinkage(boolean includeLinkage) {
		this.includeLinkage = includeLinkage;
	}
	
}
