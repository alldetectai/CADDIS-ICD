
package org.eel.standards;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for Evidence complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Evidence">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="guid" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="cause" type="{http://eel.org/standards}Cause" minOccurs="0"/>
 *         &lt;element name="effect" type="{http://eel.org/standards}Effect" minOccurs="0"/>
 *         &lt;element name="design" type="{http://eel.org/standards}Design" minOccurs="0"/>
 *         &lt;element name="analysis" type="{http://eel.org/standards}Analysis" minOccurs="0"/>
 *         &lt;element name="context" type="{http://eel.org/standards}Context" minOccurs="0"/>
 *         &lt;element name="url" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Evidence", propOrder = {
    "guid",
    "cause",
    "effect",
    "design",
    "analysis",
    "context",
    "url"
})
public class Evidence {

    protected String guid;
    protected Cause cause;
    protected Effect effect;
    protected Design design;
    protected Analysis analysis;
    protected Context context;
    protected String url;

    /**
     * Gets the value of the guid property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getGuid() {
        return guid;
    }

    /**
     * Sets the value of the guid property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setGuid(String value) {
        this.guid = value;
    }

    /**
     * Gets the value of the cause property.
     * 
     * @return
     *     possible object is
     *     {@link Cause }
     *     
     */
    public Cause getCause() {
        return cause;
    }

    /**
     * Sets the value of the cause property.
     * 
     * @param value
     *     allowed object is
     *     {@link Cause }
     *     
     */
    public void setCause(Cause value) {
        this.cause = value;
    }

    /**
     * Gets the value of the effect property.
     * 
     * @return
     *     possible object is
     *     {@link Effect }
     *     
     */
    public Effect getEffect() {
        return effect;
    }

    /**
     * Sets the value of the effect property.
     * 
     * @param value
     *     allowed object is
     *     {@link Effect }
     *     
     */
    public void setEffect(Effect value) {
        this.effect = value;
    }

    /**
     * Gets the value of the design property.
     * 
     * @return
     *     possible object is
     *     {@link Design }
     *     
     */
    public Design getDesign() {
        return design;
    }

    /**
     * Sets the value of the design property.
     * 
     * @param value
     *     allowed object is
     *     {@link Design }
     *     
     */
    public void setDesign(Design value) {
        this.design = value;
    }

    /**
     * Gets the value of the analysis property.
     * 
     * @return
     *     possible object is
     *     {@link Analysis }
     *     
     */
    public Analysis getAnalysis() {
        return analysis;
    }

    /**
     * Sets the value of the analysis property.
     * 
     * @param value
     *     allowed object is
     *     {@link Analysis }
     *     
     */
    public void setAnalysis(Analysis value) {
        this.analysis = value;
    }

    /**
     * Gets the value of the context property.
     * 
     * @return
     *     possible object is
     *     {@link Context }
     *     
     */
    public Context getContext() {
        return context;
    }

    /**
     * Sets the value of the context property.
     * 
     * @param value
     *     allowed object is
     *     {@link Context }
     *     
     */
    public void setContext(Context value) {
        this.context = value;
    }

    /**
     * Gets the value of the url property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUrl() {
        return url;
    }

    /**
     * Sets the value of the url property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUrl(String value) {
        this.url = value;
    }

}
