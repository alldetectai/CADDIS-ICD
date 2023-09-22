package com.tetratech.caddis.model;

public class CauseEffectDetail {
	// K_ANALYSIS_DETAILS
	private Boolean appropriate;
	private String responseStrength;// LL_RESPONSE_STRENGTH_ID
	private String responseForm;// LL_RESPONSE_FORM_ID
	private String numericalRelationship;
	private Boolean evidenceOfCause;// EVIDENCE_OF_CAUSE
	private String comment;// STATUS_COMMENT??
	// K_CAUSE_EFFECT
	private Term causeTerm; // cause_ID
	private Long causeTrajectory; // LL_CAUSE_TRAJECTORY_ID
	private Term effectTerm;// EFFECT_ID
	private Long effectTrajectory; // LL_EFFECT_TRAJECTORY_ID

	public Boolean getAppropriate() {
		return appropriate;
	}

	public void setAppropriate(Boolean appropriate) {
		this.appropriate = appropriate;
	}

	public String getResponseStrength() {
		return responseStrength;
	}

	public void setResponseStrength(String responseStrength) {
		this.responseStrength = responseStrength;
	}

	public String getResponseForm() {
		return responseForm;
	}

	public void setResponseForm(String responseForm) {
		this.responseForm = responseForm;
	}

	public String getNumericalRelationship() {
		return numericalRelationship;
	}

	public void setNumericalRelationship(String numericalRelationship) {
		this.numericalRelationship = numericalRelationship;
	}

	public Boolean getEvidenceOfCause() {
		return evidenceOfCause;
	}

	public void setEvidenceOfCause(Boolean evidenceOfCause) {
		this.evidenceOfCause = evidenceOfCause;
	}

	public String getComment() {
		return comment;
	}

	public void setComment(String comment) {
		this.comment = comment;
	}

	public Term getCauseTerm() {
		return causeTerm;
	}

	public void setCauseTerm(Term causeTerm) {
		this.causeTerm = causeTerm;
	}

	public Term getEffectTerm() {
		return effectTerm;
	}

	public void setEffectTerm(Term effectTerm) {
		this.effectTerm = effectTerm;
	}

	public Long getCauseTrajectory() {
		return causeTrajectory;
	}

	public void setCauseTrajectory(Long causeTrajectory) {
		this.causeTrajectory = causeTrajectory;
	}

	public Long getEffectTrajectory() {
		return effectTrajectory;
	}

	public void setEffectTrajectory(Long effectTrajectory) {
		this.effectTrajectory = effectTrajectory;
	}

}
