
package org.eel.standards;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for TrajectoryType.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="TrajectoryType">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *     &lt;enumeration value="INCREASE"/>
 *     &lt;enumeration value="DECREASE"/>
 *     &lt;enumeration value="CHANGE"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "TrajectoryType")
@XmlEnum
public enum TrajectoryType {

    INCREASE,
    DECREASE,
    CHANGE;

    public String value() {
        return name();
    }

    public static TrajectoryType fromValue(String v) {
        return valueOf(v);
    }

}
