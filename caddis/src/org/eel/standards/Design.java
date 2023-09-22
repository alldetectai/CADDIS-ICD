
package org.eel.standards;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for Design complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Design">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="studyDesign" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="impactSamples" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="controlSamples" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="impactReplicates" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="controlReplicates" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="independentSamples" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="sampleSelection" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="sampleDetails" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="comment" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Design", propOrder = {
    "studyDesign",
    "impactSamples",
    "controlSamples",
    "impactReplicates",
    "controlReplicates",
    "independentSamples",
    "sampleSelection",
    "sampleDetails",
    "comment"
})
public class Design {

    protected String studyDesign;
    protected Integer impactSamples;
    protected Integer controlSamples;
    protected Integer impactReplicates;
    protected Integer controlReplicates;
    protected Integer independentSamples;
    protected String sampleSelection;
    protected String sampleDetails;
    protected String comment;

    /**
     * Gets the value of the studyDesign property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStudyDesign() {
        return studyDesign;
    }

    /**
     * Sets the value of the studyDesign property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStudyDesign(String value) {
        this.studyDesign = value;
    }

    /**
     * Gets the value of the impactSamples property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getImpactSamples() {
        return impactSamples;
    }

    /**
     * Sets the value of the impactSamples property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setImpactSamples(Integer value) {
        this.impactSamples = value;
    }

    /**
     * Gets the value of the controlSamples property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getControlSamples() {
        return controlSamples;
    }

    /**
     * Sets the value of the controlSamples property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setControlSamples(Integer value) {
        this.controlSamples = value;
    }

    /**
     * Gets the value of the impactReplicates property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getImpactReplicates() {
        return impactReplicates;
    }

    /**
     * Sets the value of the impactReplicates property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setImpactReplicates(Integer value) {
        this.impactReplicates = value;
    }

    /**
     * Gets the value of the controlReplicates property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getControlReplicates() {
        return controlReplicates;
    }

    /**
     * Sets the value of the controlReplicates property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setControlReplicates(Integer value) {
        this.controlReplicates = value;
    }

    /**
     * Gets the value of the independentSamples property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getIndependentSamples() {
        return independentSamples;
    }

    /**
     * Sets the value of the independentSamples property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setIndependentSamples(Integer value) {
        this.independentSamples = value;
    }

    /**
     * Gets the value of the sampleSelection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSampleSelection() {
        return sampleSelection;
    }

    /**
     * Sets the value of the sampleSelection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSampleSelection(String value) {
        this.sampleSelection = value;
    }

    /**
     * Gets the value of the sampleDetails property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSampleDetails() {
        return sampleDetails;
    }

    /**
     * Sets the value of the sampleDetails property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSampleDetails(String value) {
        this.sampleDetails = value;
    }

    /**
     * Gets the value of the comment property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getComment() {
        return comment;
    }

    /**
     * Sets the value of the comment property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setComment(String value) {
        this.comment = value;
    }

}
