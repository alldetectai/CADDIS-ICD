package com.tetratech.caddis.model;

import java.util.Date;

public class User
{
	private long userId;
	private String userName;
	private String email;
	private String firstName;
	private String lastName;
	private String middleName;
	private String password;
	private long roleId;
	private String role;
	private Date createdDate;
	private String sessionIdentifier;
	private String applicationLogged;
	private Date lastUpdatedTimeStamp;
	
	public User(){

	}
	
	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	public String getLastName() {
		return lastName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	public String getMiddleName() {
		return middleName;
	}

	public void setMiddleName(String middleName) {
		this.middleName = middleName;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public long getRoleId() {
		return roleId;
	}

	public void setRoleId(long roleId) {
		this.roleId = roleId;
	}

	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

	public Date getCreatedDate() {
		return createdDate;
	}

	public void setCreatedDate(Date createdDate) {
		this.createdDate = createdDate;
	}

	public long getUserId() {
		return userId;
	}

	public void setUserId(long userId) {
		this.userId = userId;
	}

	public String getSessionIdentifier() {
		return sessionIdentifier;
	}

	public void setSessionIdentifier(String sessionIdentifier) {
		this.sessionIdentifier = sessionIdentifier;
	}

	public String getApplicationLogged() {
		return applicationLogged;
	}

	public void setApplicationLogged(String applicationLogged) {
		this.applicationLogged = applicationLogged;
	}

	public Date getLastUpdatedTimeStamp() {
		return lastUpdatedTimeStamp;
	}

	public void setLastUpdatedTimeStamp(Date lastUpdatedTimeStamp) {
		this.lastUpdatedTimeStamp = lastUpdatedTimeStamp;
	}

	public int hashCode() {
		return userName.hashCode();
	}

	public boolean equals(Object obj) {
		if(obj==null)
			return false;
		else if(!(obj instanceof User))
			return false;

		User u = (User)obj;
		return this.userName.equals(u.getUserName());

	}
}