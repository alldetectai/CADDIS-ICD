
package org.eel.standards;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for Result complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="Result">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="search" type="{http://eel.org/standards}Search" minOccurs="0"/>
 *         &lt;element name="source" type="{http://eel.org/standards}Source" minOccurs="0"/>
 *         &lt;element name="citations" type="{http://eel.org/standards}Citation" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "Result", propOrder = {
    "search",
    "source",
    "citations"
})
public class Result {

    protected Search search;
    protected Source source;
    protected List<Citation> citations;

    /**
     * Gets the value of the search property.
     * 
     * @return
     *     possible object is
     *     {@link Search }
     *     
     */
    public Search getSearch() {
        return search;
    }

    /**
     * Sets the value of the search property.
     * 
     * @param value
     *     allowed object is
     *     {@link Search }
     *     
     */
    public void setSearch(Search value) {
        this.search = value;
    }

    /**
     * Gets the value of the source property.
     * 
     * @return
     *     possible object is
     *     {@link Source }
     *     
     */
    public Source getSource() {
        return source;
    }

    /**
     * Sets the value of the source property.
     * 
     * @param value
     *     allowed object is
     *     {@link Source }
     *     
     */
    public void setSource(Source value) {
        this.source = value;
    }

    /**
     * Gets the value of the citations property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the citations property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCitations().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Citation }
     * 
     * 
     */
    public List<Citation> getCitations() {
        if (citations == null) {
            citations = new ArrayList<Citation>();
        }
        return this.citations;
    }

}
