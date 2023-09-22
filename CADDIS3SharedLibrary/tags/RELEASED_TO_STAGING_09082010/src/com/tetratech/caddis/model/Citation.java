package com.tetratech.caddis.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class Citation {
	private long id;
	private String author;
	//private int date;
	private String title;
	private String keyword;
	private Date created;
	private long createdBy;
	private Date lastUpdate;
	private long lastUpdateBy;
	private String citationAbstract;
	private String citationAnnotation;
	private String citationUrl;
	private String volumeIssuePagesInfo;
	private boolean cadlitSource;
	private String displayTitle;
	private boolean approved;
	//Organism values
	private List filterValues = new ArrayList();
	
	//This is needed for validation (upload)
	private String errorMessage;
	private boolean valid;
	
	
	private long pubTypeId;
	private String pubTypeCode;
	private String pubTypeDesc;
	private long pubId;
	private String pubCode;
	private String pubDesc;
	private String year;
	private String doi;
	
	// publication type specific
	private String startPage;
	private String endPage;
	private String journal;
	private long volume;
	private String issue;
	private String book;
	private String editors;
	private String publishers;
	private String reportNum;
	private long pages;
	private String source;
	private String type;
	private boolean inICD;
	private boolean inCADDIS;
	private boolean inCADLIT;
	// CADDIS pages that quote this citation as reference
	private String caddisPageName;
	private String caddisPageURL;
	private boolean exitDisclaimer;
	
	public Citation() {
		
	}
	
	public boolean isCadlitSource() {
		return cadlitSource;
	}

	public void setCadlitSource(boolean cadlitSource) {
		this.cadlitSource = cadlitSource;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public Date getCreated() {
		return created;
	}

	public void setCreated(Date created) {
		this.created = created;
	}

	public long getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(long createdBy) {
		this.createdBy = createdBy;
	}

	public Date getLastUpdate() {
		return lastUpdate;
	}

	public void setLastUpdate(Date lastUpdate) {
		this.lastUpdate = lastUpdate;
	}

	public long getLastUpdateBy() {
		return lastUpdateBy;
	}

	public void setLastUpdateBy(long lastUpdateBy) {
		this.lastUpdateBy = lastUpdateBy;
	}

	public String getAuthor() {
		return author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

//	public int getDate() {
//		return date;
//	}
//
//	public void setDate(int date) {
//		this.date = date;
//	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getKeyword() {
		return keyword;
	}

	public void setKeyword(String keyword) {
		this.keyword = keyword;
	}

	public String getCitationAbstract() {
		return citationAbstract;
	}

	public void setCitationAbstract(String citationAbstract) {
		this.citationAbstract = citationAbstract;
	}

	public String getCitationAnnotation() {
		return citationAnnotation;
	}

	public void setCitationAnnotation(String citationAnnotation) {
		this.citationAnnotation = citationAnnotation;
	}

	public String getCitationUrl() {
		return citationUrl;
	}

	public void setCitationUrl(String citationUrl) {
		this.citationUrl = citationUrl;
	}
	
	public List getFilterValues() {
		return filterValues;
	}

	public void setFilterValues(List filterValues) {
		this.filterValues = filterValues;
	}

	public String getJournal() {
		return journal;
	}

	public void setJournal(String journal) {
		this.journal = journal;
	}

	public String getVolumeIssuePagesInfo() {
		return volumeIssuePagesInfo;
	}

	public void setVolumeIssuePagesInfo(String volumeIssuePagesInfo) {
		this.volumeIssuePagesInfo = volumeIssuePagesInfo;
	}

	public String getDisplayTitle() {
		return displayTitle;
	}

	public void setDisplayTitle(String displayTitle) {
		this.displayTitle = displayTitle;
	}

	public String getErrorMessage() {
		return errorMessage;
	}

	public void setErrorMessage(String errorMessage) {
		this.errorMessage = errorMessage;
	}
	
	public boolean isValid() {
		return valid;
	}

	public void setValid(boolean valid) {
		this.valid = valid;
	}

	public boolean isApproved() {
		return approved;
	}

	public void setApproved(boolean isApproved) {
		this.approved = isApproved;
	}

	public void print(){
		System.out.println("Id: "+id);
		System.out.println("PublicationTypeId: "+ pubTypeId);
		System.out.println("Created by: "+ createdBy);
		System.out.println("Author: "+author);
		System.out.println("Date: "+year);
		System.out.println("Title: "+title);
		System.out.println("keywords: " + keyword);
		System.out.println("Journal: "+journal);
		System.out.println("Vol: "+volume);
		System.out.println("issue: " + issue);
		System.out.println("startPage : " + startPage);
		System.out.println("endPage : " + endPage);
		System.out.println("Pages : " + pages);
		System.out.println("Source: "+source);
		System.out.println("Type: "+ type);
		System.out.println("reportNum: "+reportNum);
		System.out.println("Publishers: "+ publishers);
		System.out.println("Editors: "+ editors);
		System.out.println("Book: "+ book);
		System.out.println("IsApproved: "+ approved);
		System.out.println("DOI: "+ doi);
		System.out.println("Abstract: "+citationAbstract);
		System.out.println("Error Msg: "+errorMessage);
	}

	public String getYear() {
		return year;
	}

	public void setYear(String year) {
		this.year = year;
	}

	public String getDoi() {
		return doi;
	}

	public void setDoi(String doi) {
		this.doi = doi;
	}

	public String getStartPage() {
		return startPage;
	}

	public void setStartPage(String startPage) {
		this.startPage = startPage;
	}

	public String getEndPage() {
		return endPage;
	}

	public void setEndPage(String endPage) {
		this.endPage = endPage;
	}

	public long getVolume() {
		return volume;
	}

	public void setVolume(long volume) {
		this.volume = volume;
	}

	public String getIssue() {
		return issue;
	}

	public void setIssue(String issue) {
		this.issue = issue;
	}

	public String getBook() {
		return book;
	}

	public void setBook(String book) {
		this.book = book;
	}

	public String getEditors() {
		return editors;
	}

	public void setEditors(String editors) {
		this.editors = editors;
	}

	public String getPublishers() {
		return publishers;
	}

	public void setPublishers(String publishers) {
		this.publishers = publishers;
	}

	public String getReportNum() {
		return reportNum;
	}

	public void setReportNum(String reportNum) {
		this.reportNum = reportNum;
	}

	public long getPages() {
		return pages;
	}

	public void setPages(long pages) {
		this.pages = pages;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public long getPubTypeId() {
		return pubTypeId;
	}

	public void setPubTypeId(long pubTypeId) {
		this.pubTypeId = pubTypeId;
	}

	public long getPubId() {
		return pubId;
	}

	public void setPubId(long pubId) {
		this.pubId = pubId;
	}

	public String getPubTypeCode() {
		return pubTypeCode;
	}

	public void setPubTypeCode(String pubTypeCode) {
		this.pubTypeCode = pubTypeCode;
	}

	public String getPubDesc() {
		return pubDesc;
	}

	public void setPubDesc(String pubDesc) {
		this.pubDesc = pubDesc;
	}

	public String getPubTypeDesc() {
		return pubTypeDesc;
	}

	public void setPubTypeDesc(String pubTypeDesc) {
		this.pubTypeDesc = pubTypeDesc;
	}

	public String getPubCode() {
		return pubCode;
	}

	public void setPubCode(String pubCode) {
		this.pubCode = pubCode;
	}

	public boolean isInICD() {
		return inICD;
	}

	public void setInICD(boolean inICD) {
		this.inICD = inICD;
	}

	public boolean isInCADDIS() {
		return inCADDIS;
	}

	public void setInCADDIS(boolean inCADDIS) {
		this.inCADDIS = inCADDIS;
	}

	public boolean isInCADLIT() {
		return inCADLIT;
	}

	public void setInCADLIT(boolean inCADLIT) {
		this.inCADLIT = inCADLIT;
	}

	public String getCaddisPageName() {
		return caddisPageName;
	}

	public void setCaddisPageName(String caddisPageName) {
		this.caddisPageName = caddisPageName;
	}

	public String getCaddisPageURL() {
		return caddisPageURL;
	}

	public void setCaddisPageURL(String caddisPageURL) {
		this.caddisPageURL = caddisPageURL;
	}

	public boolean isExitDisclaimer() {
		return exitDisclaimer;
	}

	public void setExitDisclaimer(boolean exitDisclaimer) {
		this.exitDisclaimer = exitDisclaimer;
	}


}
