
package org.eel.standards;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for Location complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Location">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="minLongitude" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="maxLongitude" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="minLatitude" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="maxLatitude" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="minElevation" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="maxElevation" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="wktGeometry" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Location", propOrder = {
    "minLongitude",
    "maxLongitude",
    "minLatitude",
    "maxLatitude",
    "minElevation",
    "maxElevation",
    "wktGeometry"
})
public class Location {

    protected Double minLongitude;
    protected Double maxLongitude;
    protected Double minLatitude;
    protected Double maxLatitude;
    protected Double minElevation;
    protected Double maxElevation;
    protected String wktGeometry;

    /**
     * Gets the value of the minLongitude property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getMinLongitude() {
        return minLongitude;
    }

    /**
     * Sets the value of the minLongitude property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setMinLongitude(Double value) {
        this.minLongitude = value;
    }

    /**
     * Gets the value of the maxLongitude property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getMaxLongitude() {
        return maxLongitude;
    }

    /**
     * Sets the value of the maxLongitude property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setMaxLongitude(Double value) {
        this.maxLongitude = value;
    }

    /**
     * Gets the value of the minLatitude property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getMinLatitude() {
        return minLatitude;
    }

    /**
     * Sets the value of the minLatitude property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setMinLatitude(Double value) {
        this.minLatitude = value;
    }

    /**
     * Gets the value of the maxLatitude property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getMaxLatitude() {
        return maxLatitude;
    }

    /**
     * Sets the value of the maxLatitude property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setMaxLatitude(Double value) {
        this.maxLatitude = value;
    }

    /**
     * Gets the value of the minElevation property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getMinElevation() {
        return minElevation;
    }

    /**
     * Sets the value of the minElevation property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setMinElevation(Double value) {
        this.minElevation = value;
    }

    /**
     * Gets the value of the maxElevation property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getMaxElevation() {
        return maxElevation;
    }

    /**
     * Sets the value of the maxElevation property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setMaxElevation(Double value) {
        this.maxElevation = value;
    }

    /**
     * Gets the value of the wktGeometry property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getWktGeometry() {
        return wktGeometry;
    }

    /**
     * Sets the value of the wktGeometry property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setWktGeometry(String value) {
        this.wktGeometry = value;
    }

}
