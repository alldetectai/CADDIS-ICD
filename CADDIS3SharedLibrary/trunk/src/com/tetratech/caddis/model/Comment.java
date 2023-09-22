package com.tetratech.caddis.model;

import java.util.Date;

public class Comment {
	private Long diagramId;
	private String commentor;
	private String commentText;
	private Date createdDate;
	private String email;
	private Long userId;
	
	public Comment() {
		
	}

	public Long getDiagramId() {
		return diagramId;
	}

	public void setDiagramId(Long diagramId) {
		this.diagramId = diagramId;
	}

	public String getCommentor() {
		return commentor;
	}

	public void setCommentor(String commentor) {
		this.commentor = commentor;
	}

	public String getCommentText() {
		return commentText;
	}

	public void setCommentText(String commentText) {
		this.commentText = commentText;
	}

	public Date getCreatedDate() {
		return createdDate;
	}

	public void setCreatedDate(Date createdDate) {
		this.createdDate = createdDate;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public Long getUserId() {
		return userId;
	}

	public void setUserId(Long userId) {
		this.userId = userId;
	}

}
