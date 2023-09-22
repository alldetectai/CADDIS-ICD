
package org.eel.standards;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for PublicationType.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="PublicationType">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *     &lt;enumeration value="JOURNAL"/>
 *     &lt;enumeration value="BOOK"/>
 *     &lt;enumeration value="BOOKCHAPTER"/>
 *     &lt;enumeration value="REPORT"/>
 *     &lt;enumeration value="OTHER"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "PublicationType")
@XmlEnum
public enum PublicationType {

    JOURNAL,
    BOOK,
    BOOKCHAPTER,
    REPORT,
    OTHER;

    public String value() {
        return name();
    }

    public static PublicationType fromValue(String v) {
        return valueOf(v);
    }

}
