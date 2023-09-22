
package org.eel.services;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import org.eel.standards.TermList;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="termList" type="{http://eel.org/standards}TermList" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "termList"
})
@XmlRootElement(name = "getTermsResponse")
public class GetTermsResponse {

    protected TermList termList;

    /**
     * Gets the value of the termList property.
     * 
     * @return
     *     possible object is
     *     {@link TermList }
     *     
     */
    public TermList getTermList() {
        return termList;
    }

    /**
     * Sets the value of the termList property.
     * 
     * @param value
     *     allowed object is
     *     {@link TermList }
     *     
     */
    public void setTermList(TermList value) {
        this.termList = value;
    }

}
