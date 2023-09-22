package com.tetratech.caddis.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;


public class Diagram {
	private Long id;
	private String name;
	private Long color;
	private List shapes = new ArrayList();
	private List lines = new ArrayList();
	private Integer width;
	private Integer height;
	private String description;
	//list has tiersIndex which are non collapsible
	private List nonCollapsibleBins = new ArrayList();
	private String diagramStatus;
	private long diagramStatusId;
	private boolean goldSeal;
	private boolean locked;
	private long createdBy;
	private Date createdDate;
	private long updatedBy;
	private Date updatedDate;
	//can obtain lock but may not update the diagram
	private User lockedUser;
	private User creatorUser;
	private boolean openToPublic;
	//user who can edit the diagram
	private List userList = new ArrayList();
	
	private String location;
	private String keywords;
	
	public Diagram() {
		
	}
	
	public Integer getWidth() {
		return width;
	}

	public void setWidth(Integer width) {
		this.width = width;
	}

	public Integer getHeight() {
		return height;
	}

	public void setHeight(Integer height) {
		this.height = height;
	}

	public Long getId() {
		return id;
	}
	
	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}
	
	public void setName(String name) {
		this.name = name;
	}
	

	public void setColor(Long color) {
		this.color = color;
	}

	public Long getColor() {
		return color;
	}
	

	public List getShapes() {
		return shapes;
	}
	
	public void setShapes(List shapes) {
		this.shapes = shapes;
	}
	

	public List getLines() {
		return lines;
	}

	public void setLines(List lines) {
		this.lines = lines;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public List getNonCollapsibleBins() {
		return nonCollapsibleBins;
	}

	public void setNonCollapsibleBins(List nonCollapsibleBins) {
		this.nonCollapsibleBins = nonCollapsibleBins;
	}

	public String getDiagramStatus() {
		return diagramStatus;
	}

	public void setDiagramStatus(String diagramStatus) {
		this.diagramStatus = diagramStatus;
	}

	public long getDiagramStatusId() {
		return diagramStatusId;
	}

	public void setDiagramStatusId(long diagramStatusId) {
		this.diagramStatusId = diagramStatusId;
	}

	public boolean isGoldSeal() {
		return goldSeal;
	}

	public void setGoldSeal(boolean goldSeal) {
		this.goldSeal = goldSeal;
	}

	public boolean isLocked() {
		return locked;
	}

	public void setLocked(boolean locked) {
		this.locked = locked;
	}

	public long getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(long createdBy) {
		this.createdBy = createdBy;
	}

	public long getUpdatedBy() {
		return updatedBy;
	}

	public void setUpdatedBy(long updatedBy) {
		this.updatedBy = updatedBy;
	}

	public Date getUpdatedDate() {
		return updatedDate;
	}

	public void setUpdatedDate(Date updatedDate) {
		this.updatedDate = updatedDate;
	}

	public Date getCreatedDate() {
		return createdDate;
	}

	public void setCreatedDate(Date createdDate) {
		this.createdDate = createdDate;
	}

	public boolean isOpenToPublic() {
		return openToPublic;
	}

	public void setOpenToPublic(boolean openToPublic) {
		this.openToPublic = openToPublic;
	}

	public User getLockedUser() {
		return lockedUser;
	}

	public void setLockedUser(User lockedUser) {
		this.lockedUser = lockedUser;
	}

	public User getCreatorUser() {
		return creatorUser;
	}

	public void setCreatorUser(User creatorUser) {
		this.creatorUser = creatorUser;
	}

	public List getUserList() {
		return userList;
	}

	public void setUserList(List userList) {
		this.userList = userList;
	}
	
	public void setKeywords(String keywords) {
		this.keywords = keywords;
	}
	
	public String getKeywords() {
		return keywords;
	}
	
	public void setLocation(String location) {
		this.location =  location;
	}
	
	public String getLocation() {
		return location;
	}
}
