package com.tetratech.caddis.model;

import java.util.List;

public class Dataset {
	private long datasetId;
	private String author;
	private String title;
	private String year;
	// design object
	private String studyDesign; // LL_STUDY_DESIGN_ID
	private Integer impactSamples; // IMPACT_SAMPLE
	private Integer controlSamples; // CONTROL_SAMPLES
	private Integer impactReplicates; // IMPACT_REPLICATES
	private Integer controlReplicates; // CONTROL_REPLICATES
	private Integer independentSamples;// not captured
	private String sampleSelection; // LL_SAMPLE_SELECTION_ID
	private String sampleDetails; // SAMPLE_DETAILS
	private String comment;// STUDYDETAILS??
	// from location object
	private Double minLongitude;
	private Double maxLongitude;
	private Double minLatitude;
	private Double maxLatitude;
	private Double minElevation;
	private Double maxElevation;
	private String wktGeometry;// GEOMETRY

	// one selection allowed in cadlit. So should we check if lookup exists
	// among the list ]
	// and insert the found record. If only one exists should we insert the
	// lookup value.
	// from context object
	private List<String> habitat;// LL_HABITAT_ID
	private List<String> climate;// LL_CLIMATE_ID
	private List<String> spatialExtent;// LL_SPATIAL_EXTENT_ID
	private List<String> temporalExtent;// LL_TEMPORAL_EXTENT_ID
	private List<String> sourceData; // LL_SOURCE_DATA_ID
	private List<String> studyType; // LL_STUDY_TYPE_ID
	private String contextComment;// should be added to comment above or
									// LOCATION_COMMENT

	private CauseEffectDetail causeEffectDetails;

	public long getDatasetId() {
		return datasetId;
	}

	public void setDatasetId(long datasetId) {
		this.datasetId = datasetId;
	}

	public String getAuthor() {
		return author;
	}

	public void setAuthor(String author) {
		this.author = author;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getYear() {
		return year;
	}

	public void setYear(String year) {
		this.year = year;
	}

	public String getStudyDesign() {
		return studyDesign;
	}

	public void setStudyDesign(String studyDesign) {
		this.studyDesign = studyDesign;
	}

	public Integer getImpactSamples() {
		return impactSamples;
	}

	public void setImpactSamples(Integer impactSamples) {
		this.impactSamples = impactSamples;
	}

	public Integer getControlSamples() {
		return controlSamples;
	}

	public void setControlSamples(Integer controlSamples) {
		this.controlSamples = controlSamples;
	}

	public Integer getImpactReplicates() {
		return impactReplicates;
	}

	public void setImpactReplicates(Integer impactReplicates) {
		this.impactReplicates = impactReplicates;
	}

	public Integer getControlReplicates() {
		return controlReplicates;
	}

	public void setControlReplicates(Integer controlReplicates) {
		this.controlReplicates = controlReplicates;
	}

	public Integer getIndependentSamples() {
		return independentSamples;
	}

	public void setIndependentSamples(Integer independentSamples) {
		this.independentSamples = independentSamples;
	}

	public String getSampleSelection() {
		return sampleSelection;
	}

	public void setSampleSelection(String sampleSelection) {
		this.sampleSelection = sampleSelection;
	}

	public String getSampleDetails() {
		return sampleDetails;
	}

	public void setSampleDetails(String sampleDetails) {
		this.sampleDetails = sampleDetails;
	}

	public String getComment() {
		return comment;
	}

	public void setComment(String comment) {
		this.comment = comment;
	}

	public Double getMinLongitude() {
		return minLongitude;
	}

	public void setMinLongitude(Double minLongitude) {
		this.minLongitude = minLongitude;
	}

	public Double getMaxLongitude() {
		return maxLongitude;
	}

	public void setMaxLongitude(Double maxLongitude) {
		this.maxLongitude = maxLongitude;
	}

	public Double getMinLatitude() {
		return minLatitude;
	}

	public void setMinLatitude(Double minLatitude) {
		this.minLatitude = minLatitude;
	}

	public Double getMaxLatitude() {
		return maxLatitude;
	}

	public void setMaxLatitude(Double maxLatitude) {
		this.maxLatitude = maxLatitude;
	}

	public Double getMinElevation() {
		return minElevation;
	}

	public void setMinElevation(Double minElevation) {
		this.minElevation = minElevation;
	}

	public Double getMaxElevation() {
		return maxElevation;
	}

	public void setMaxElevation(Double maxElevation) {
		this.maxElevation = maxElevation;
	}

	public String getWktGeometry() {
		return wktGeometry;
	}

	public void setWktGeometry(String wktGeometry) {
		this.wktGeometry = wktGeometry;
	}

	public List<String> getHabitat() {
		return habitat;
	}

	public void setHabitat(List<String> habitat) {
		this.habitat = habitat;
	}

	public List<String> getClimate() {
		return climate;
	}

	public void setClimate(List<String> climate) {
		this.climate = climate;
	}

	public List<String> getSpatialExtent() {
		return spatialExtent;
	}

	public void setSpatialExtent(List<String> spatialExtent) {
		this.spatialExtent = spatialExtent;
	}

	public List<String> getTemporalExtent() {
		return temporalExtent;
	}

	public void setTemporalExtent(List<String> temporalExtent) {
		this.temporalExtent = temporalExtent;
	}

	public List<String> getSourceData() {
		return sourceData;
	}

	public void setSourceData(List<String> sourceData) {
		this.sourceData = sourceData;
	}

	public List<String> getStudyType() {
		return studyType;
	}

	public void setStudyType(List<String> studyType) {
		this.studyType = studyType;
	}

	public String getContextComment() {
		return contextComment;
	}

	public void setContextComment(String contextComment) {
		this.contextComment = contextComment;
	}

	public CauseEffectDetail getCauseEffectDetails() {
		return causeEffectDetails;
	}

	public void setCauseEffectDetails(CauseEffectDetail causeEffectDetails) {
		this.causeEffectDetails = causeEffectDetails;
	}

}