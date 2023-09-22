
package org.eel.standards;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for Analysis complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Analysis">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="appropriate" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="responseStrength" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="responseForm" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="numericalRelationship" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="evidenceOfCause" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
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
@XmlType(name = "Analysis", propOrder = {
    "appropriate",
    "responseStrength",
    "responseForm",
    "numericalRelationship",
    "evidenceOfCause",
    "comment"
})
public class Analysis {

    protected Boolean appropriate;
    protected String responseStrength;
    protected String responseForm;
    protected String numericalRelationship;
    protected Boolean evidenceOfCause;
    protected String comment;

    /**
     * Gets the value of the appropriate property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isAppropriate() {
        return appropriate;
    }

    /**
     * Sets the value of the appropriate property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setAppropriate(Boolean value) {
        this.appropriate = value;
    }

    /**
     * Gets the value of the responseStrength property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getResponseStrength() {
        return responseStrength;
    }

    /**
     * Sets the value of the responseStrength property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setResponseStrength(String value) {
        this.responseStrength = value;
    }

    /**
     * Gets the value of the responseForm property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getResponseForm() {
        return responseForm;
    }

    /**
     * Sets the value of the responseForm property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setResponseForm(String value) {
        this.responseForm = value;
    }

    /**
     * Gets the value of the numericalRelationship property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNumericalRelationship() {
        return numericalRelationship;
    }

    /**
     * Sets the value of the numericalRelationship property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNumericalRelationship(String value) {
        this.numericalRelationship = value;
    }

    /**
     * Gets the value of the evidenceOfCause property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isEvidenceOfCause() {
        return evidenceOfCause;
    }

    /**
     * Sets the value of the evidenceOfCause property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setEvidenceOfCause(Boolean value) {
        this.evidenceOfCause = value;
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
