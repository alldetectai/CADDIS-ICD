package com.tetratech.caddis.model;

public class CauseEffectLinkage {
	// P_CAUSE_EFFECT_LINKAGE
	private Term causeTerm; // cause_ID
	private Long causeTrajectory; // LL_CAUSE_TRAJECTORY_ID
	private Term effectTerm;// EFFECT_ID
	private Long effectTrajectory; // LL_EFFECT_TRAJECTORY_ID

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
