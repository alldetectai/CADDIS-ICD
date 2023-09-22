
package org.eel.services;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.RequestWrapper;
import javax.xml.ws.ResponseWrapper;
import org.eel.standards.Result;
import org.eel.standards.TermList;


/**
 * This class was generated by the JAX-WS RI.
 * JAX-WS RI 2.1.1 in JDK 6
 * Generated source version: 2.1
 * 
 */
@WebService(name = "IEELServices", targetNamespace = "http://eel.org/services")
@XmlSeeAlso({
    org.eel.standards.ObjectFactory.class,
    org.eel.services.ObjectFactory.class
})
public interface IEELServices {


    /**
     * 
     * @param cause
     * @param effect
     * @return
     *     returns org.eel.standards.Result
     */
    @WebMethod(action = "http://eel.org/services/EELServices/getCitationsRequest")
    @WebResult(name = "result", targetNamespace = "")
    @RequestWrapper(localName = "getCitations", targetNamespace = "http://eel.org/services", className = "org.eel.services.GetCitations")
    @ResponseWrapper(localName = "getCitationsResponse", targetNamespace = "http://eel.org/services", className = "org.eel.services.GetCitationsResponse")
    public Result getCitations(
        @WebParam(name = "cause", targetNamespace = "")
        String cause,
        @WebParam(name = "effect", targetNamespace = "")
        String effect);

    /**
     * 
     * @return
     *     returns org.eel.standards.TermList
     */
    @WebMethod(action = "http://eel.org/services/EELServices/getTermsRequest")
    @WebResult(name = "termList", targetNamespace = "")
    @RequestWrapper(localName = "getTerms", targetNamespace = "http://eel.org/services", className = "org.eel.services.GetTerms")
    @ResponseWrapper(localName = "getTermsResponse", targetNamespace = "http://eel.org/services", className = "org.eel.services.GetTermsResponse")
    public TermList getTerms();

}
