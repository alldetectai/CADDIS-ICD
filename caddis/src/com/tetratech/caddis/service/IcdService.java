package com.tetratech.caddis.service;

import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.Set;

import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.dao.CitationDAO;
import com.tetratech.caddis.dao.DiagramDAO;
import com.tetratech.caddis.dao.LookupDAO;
import com.tetratech.caddis.dao.UserDAO;
import com.tetratech.caddis.exception.DAOException;
import com.tetratech.caddis.model.Citation;
import com.tetratech.caddis.model.Comment;
import com.tetratech.caddis.model.Diagram;
import com.tetratech.caddis.model.DownloadData;
import com.tetratech.caddis.model.Linkage;
import com.tetratech.caddis.model.LookupValue;
import com.tetratech.caddis.model.SelectedLinkage;
import com.tetratech.caddis.model.Shape;
import com.tetratech.caddis.model.Term;
import com.tetratech.caddis.model.User;

import flex.messaging.FlexContext;
import flex.messaging.FlexSession;
import gov.epa.iamfw.client.IAMLocator;
import gov.epa.iamfw.webservices.auth.AuthMgr;
import gov.epa.iamfw.webservices.common.AuthMethod;
import gov.epa.iamfw.webservices.group.GroupMgr;
import gov.epa.iamfw.webservices.group.GroupRole;
import gov.epa.iamfw.webservices.userservice.getuser.localschema.Request;
import gov.epa.iamfw.webservices.userservice.getuser.localschema.Response;


public class IcdService {
	
	private static List configuration = new ArrayList();
	
	//maps a diagram to a user that has checked it out (locked it)
	private static Map userToDiagram = new HashMap();
	private static Map userToTimer = new HashMap();

	//this field should equal or exceed SESSION_SERVER_UPDATE_INTERVAL in the SessionMananger.as
	private static final int SESSION_TIMEOUT = 600000; 
	
	static {
        try {
           ResourceBundle properties =  ResourceBundle.getBundle("com.tetratech.caddis.Configuration");
           Enumeration keys = properties.getKeys();

           while (keys.hasMoreElements()) {
               String key = (String)keys.nextElement();
               String value = properties.getString(key);
               LookupValue lk = new LookupValue();
               lk.setCode(key);
               lk.setDesc(value);
               configuration.add(lk);
               System.out.println("CADDIS3: key = " + key + ", " + 
           		       "value = " + value);
           }

        } catch (Exception e) {
          e.printStackTrace();
          System.out.print(e.getMessage());
        }
    }
	
	public static List getConfiguration() {
		return configuration;
	}
	
	private static String getIAMLocator(){
		for(int i = 0; i < configuration.size(); i++) {
			LookupValue lk = (LookupValue)configuration.get(i);
			if(lk.getCode().equalsIgnoreCase(Constants.IAMLOCATOR))
				return lk.getDesc();
		}
		//default
		return "https://badger.epa.gov/iamfw/";
	}
	
	public static void saveDownloadData(DownloadData data) throws Exception{
		/* Store the download data in the session */
		FlexSession fs = FlexContext.getFlexSession();
		fs.setAttribute("downloadData", data);
	} 
	
	public static void saveDiagramAsPNGImage(String diagramName,byte[] data) throws Exception{
		/* Store the image data in the session */
		FlexSession fs = FlexContext.getFlexSession();
		fs.setAttribute("image", data);
		fs.setAttribute("diagram", diagramName);
	} 
	
	public static void saveDiagramEvidencesAsCSV(String diagramName,byte[] data) throws Exception{
		/* Store the image data in the session */
		FlexSession fs = FlexContext.getFlexSession();
		fs.setAttribute("csv", data);
		fs.setAttribute("diagram", diagramName);
	} 
	
	
	public static void saveUserToServer(User user) throws Exception{
		/* Store the user data in the session */
		FlexSession fs = FlexContext.getFlexSession();
		fs.setAttribute("currUser", user);
	}
	
	public static List getLastUploadedReferenceResults() {
		FlexSession fs = FlexContext.getFlexSession();
		List results = (List)fs.getAttribute("uploadedRefs");
		
		if(results==null)
			results = new ArrayList();
		//clear the list from the session (dont' do this for now)
		//the user might click multiple times on the view button
		//fs.setAttribute("uploadedRefs", new ArrayList());
		return results;
	}
	
	public static List getAllDiagrams() throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.getAllDiagrams();
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving diagrams");
		}	
	}

	public static List getPublishedDiagrams() throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.getPublishedDiagrams();
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving diagrams");
		}	
	}
	
	public static List getDiagramsByUser(String searchTerm, String sortBy, long userId) throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.getDiagramsByUser(searchTerm, sortBy, userId);
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving diagrams");
		}	
	}

//	public static List getDiagramsForRegisteredUser(long userId) throws Exception {
//		try {
//			DiagramDAO ddao = DiagramDAO.getInstance();
//			return ddao.getDiagramsForRegisteredUser(userId);
//		} catch (Exception e) {
//			e.printStackTrace();
//			throw new Exception(e.getMessage());
//		}	
//	}
	
	public static List getAllCitations() throws Exception {
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getAllCitations();
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving citations");
		}	
	}
	
	
	public static List getCitationsInReview() throws Exception {
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getCitationsInReview();
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving citations");
		}	
	}
	
	public static List getCitationsByIDs(List filterList, List ids) throws Exception {
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getCitationsByIDs(filterList, ids);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving citaitons");
		}	
	}
	
	public static Map getCitationsByIDsAsMap(List filterList, List ids) throws Exception {
		Map citationsMap = new HashMap();
		try {
			List citations  = getCitationsByIDs(filterList, ids);
			if(citations != null) {
				for(int i = 0; i < citations.size(); i++) {
					Citation c = (Citation)citations.get(i);
					citationsMap.put(new Long(c.getId()), c);
				}
			}
			return citationsMap;
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving citaitons");
		}	
	}
	
	public static List getAllCitationsAndFilters() throws Exception {
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getAllCitationsAndFilters();
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving citaitons");
		}	
	}
	
	public static Citation getCitation(long id) throws Exception {
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getCitationByID(id);
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving citaiton");
		}	
	}
	
	public static long checkDiagram(String name) throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.checkDiagram(name);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving duplicate diagram");
		}	
    }
	
	public static boolean existsDiagramWithName(String name) throws Exception{
		return checkDiagram(name)>0?true:false;
	}
	
	
	public static Diagram getDiagram(long id) throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.getDiagram(id);
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving diagram");
		}	
	}
	
	public static long saveDiagram(Diagram diagram) throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.saveDiagram(diagram);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Saving Diagram Failed");
		}	
	}
	
	public static long saveDiagramAs(Diagram diagram) throws Exception {
		if(checkDiagram(diagram.getName())>0)
			throw new Exception("A diagram with this name already exists.");
		return saveDiagram(diagram);
	}
		
	public static long updateDiagram(Diagram diagram) throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.updateDiagram(diagram);
		} catch (DAOException e) {
			e.printStackTrace();
			throw new Exception("Updating Diagram Failed");
		}
	}
	
//    public static boolean deleteDiagram(String name) throws Exception { 
//    	long id = checkDiagram(name);
//    	if(id != 0) {
//    		return deleteDiagram(id);
//    	}
//    	return false;
//    }
    
    public static boolean renameDiagram(Diagram diagram, long userId, long diagramId) throws Exception { 
    	try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.updateDiagramDetails(diagram, userId, diagramId);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Updating Diagram Failed");
		}
    }
    
	public static boolean deleteDiagram(long diagramId) throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.deleteDiagram(diagramId);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Deleting Diagram Failed");
		}	
	}
	
	public static boolean updateDiagramInfo(Diagram diagram)throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.updateDiagramInfo(diagram);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Updating Diagram Failed");
		}	
	}

	public static void saveCitations(List citations) throws Exception {
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			cdao.saveCitations(citations);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Saving Citations Failed");
		}	
	}
	public void approveCitations(List citationIds) throws Exception {
		
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			cdao.approveCitations(citationIds);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Saving approved citations failed");
		}	
	}
	
	public static long updateCitation(Citation c) throws Exception {
		try {
			if(c.getPubTypeId() == Constants.PUBLICATION_TYPE_ID_JOUNRAL_ARTICLE){
				LookupDAO ldao = LookupDAO.getInstance();
				long pubId = ldao.getPublicationIdByDesc(c.getJournal());
				if(pubId<=0){
					pubId = ldao.insertPublication(c.getJournal(), c.getLastUpdateBy());
				}
				c.setPubId(pubId);
			}
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.updateCitation(c);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Updating Citation Failed");
		}	
	}
	
	
	public static boolean deleteCitation(long citationId) throws Exception {
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.deleteCitation(citationId);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Deleting Citation Failed");
		}	
	}
	
	
	public static List getLookupByType(String type) throws Exception {
		try {
			LookupDAO ldao = LookupDAO.getInstance();
			return ldao.getLookupByType(type);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving look up values");
		}	
	}
	
	/*
	 * filterList can be null or searchterm can be empty 
	 * searches both citations and shape name
	 */
	public static List searchCitationsNShapes(List filterList, String searchTerm) throws Exception {
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.searchCitationsNShapes(filterList, searchTerm);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving citations for your search");
		}	
	}
	
	/**
	 * 
	 * @param causeTerm
	 * @param effectTerm
	 * @return
	 * @throws Exception
	 */
	public static List searchCitationsByCauseNEffect(String causeTerm, String effectTerm,String sourceType) throws Exception {
		try {
			
		//	if(sourceType.compareToIgnoreCase(Constants.SEARCH_EPA_SOURCE) == 0) {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.searchCitationsByCauseNEffect(causeTerm, effectTerm);
		//	} else {
		//	return null; //org.eel.services.EELClient.getCitations(causeTerm, effectTerm);
		//	} 
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving citations for your search");
		}	
	}
	
	/**
	 * 
	 * @param causeTerm
	 * @param effectTerms
	 * @param diagramId
	 * @return
	 * @throws Exception
	 */
	public static List searchCitationsByCauseNEffects(String causeTerm, List effectTerms , Long diagramId) throws Exception {
		try {
			/*
			if(sourceType.compareToIgnoreCase(Constants.SEARCH_EPA_SOURCE) == 0) { */
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.searchCitationsByCauseNEffects(causeTerm, effectTerms, diagramId);
		/*	} else {
			return org.eel.services.EELClient.getCitations(causeTerm, effectTerm);
			} */
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving citations/Evidences for your search");
		}	
	}
	
	
	/*
	 * searches only citations 
	 */
	public static List searchCitations(String searchTerm) throws Exception {
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.searchCitations(searchTerm);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving citations for your search");
		}	
	}
	
	/*
	 * Function just retrieves label s1<->s2 for given citationid and diagramId
	 * Used for Linkage dialog 
	 */
	public static List getLinakgesByCitationIdNDiagramId(long citationId, long diagramId) throws Exception {
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getLinakgesByCitationIdNDiagramId(citationId, diagramId);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving linkages");
		}	
	}
	
	public static List getDiagramEvidences(long diagramId) throws Exception 
	{
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getDiagramEvidences( diagramId);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving Diagram - evidences");
		}	
	}
	
	public static List getEvidencesForAllDiagramByCitationId(long citationId)throws Exception 
	{
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getEvidencesForAllDiagramByCitationId( citationId);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving Diagram - evidences");
		}	
	}
	
	/*
	 * Function just retrieves diagramNames for given citationid and role/userID
	 * Used for Linkage popup
	 */
	public static List getDiagramNamesByCitationIdNUser(long citationId,long userId) throws Exception {
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getDiagramNamesByCitationIdNUser(citationId, userId);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving diagrams");
		}	
	}
	
	/*
	 * Function just retrieves diagramNames for given citationid
	 * Used for Linkage popup 
	 */
	public static List getDiagramNamesByCitationId(long citationId) throws Exception {
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getDiagramNamesByCitationId(citationId);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving diagrams");
	
		}
	}
	
	public List getSelectedLinkages(List filterList, List clickedShapes) throws Exception {
		//selectedLinkage returned
		List selectedLinkages = new ArrayList();
		//list of unique citationIds which will be fetched from database
		List citationIds = new ArrayList();
		// keeps track of linkages which are match to next shape in the clickedShapes
		List orderedLinkages = new ArrayList();
		int len =  clickedShapes.size();

		if(len > 1) {
			for(int i = 0; i < len ; i++) {
				Shape shape1  = (Shape)clickedShapes.get(i);
				Shape shape2 = null;
				//finding next shape or first one
				if (i < len - 1) {
					shape2 = (Shape) clickedShapes.get(i + 1);
				} else if ( len > 2) {
					shape2 = (Shape) clickedShapes.get(0);
				}
				if(shape2 != null) {
					Linkage linkage = shape1.findLinkage(shape2);
					if (shape1.findLinkage(shape2) != null) {
						SelectedLinkage sl = new SelectedLinkage();
						String label = shape1.getLabel() + " AND " + shape2.getLabel();
						sl.setLabel(label);
						sl.setShape1(shape1);
						sl.setShape2(shape2);
						selectedLinkages.add(sl);
						orderedLinkages.add(linkage);
						List ids = linkage.getCitationIds();
						for (int k = 0; k < ids.size(); k++) {
							if (!citationIds.contains(ids.get(k))) {
								citationIds.add(ids.get(k));
							}
						}
					}
					else {//create dummy citation for display
							SelectedLinkage sl = new SelectedLinkage();
							String label = shape1.getLabel() + " AND " + shape2.getLabel();
							sl.setLabel(label);
							sl.setShape1(shape1);
							sl.setShape2(shape2);
							Citation c = new Citation();
							c.setId(0l);
							c.setDisplayTitle("No citation currently in database");
							sl.getCitations().add(c);
							selectedLinkages.add(sl);
							orderedLinkages.add(null);
					}
				}
			}
			//get citations from database using filterList and citationIds	
			Map citationMap = getCitationsByIDsAsMap(filterList, citationIds);
			//iterate add citations to linkages
			if(citationMap != null) {
				for(int i = 0; i < orderedLinkages.size(); i++)	{
					Linkage linkage = (Linkage)orderedLinkages.get(i);
					if(linkage != null) {
						List ids = linkage.getCitationIds();
						for(int k = 0; k < ids.size(); k++) {
							//get citationid
							long value = 0;
		                	Object o = ids.get(k);
		                	if(o instanceof Long)
		                		value = ((Long) o).longValue();
		                	else if(o instanceof Integer)
		                		value = ((Integer)o).longValue();
		                	//check map for citation else create dummy
							Citation c = (Citation) citationMap.get(new Long(value));
							if(c != null) {
								((SelectedLinkage) selectedLinkages.get(i)).getCitations().add(c);
							} else if(((SelectedLinkage) selectedLinkages.get(i)).getCitations().size() == 0) {
								Citation c1 = new Citation();
								c1.setId(0l);
								c1.setDisplayTitle("No citation currently in database");
								((SelectedLinkage) selectedLinkages.get(i)).getCitations().add(c1);
							}
						}
					}
		        }
			}
		}
		return selectedLinkages;
	}
	
	/**
	 * This function updates the diagram that the user is viewing and
	 * the time when it viewed it.
	 * 
	 * @param diagramId
	 * @param user
	 */
	public static synchronized void sendInfoToServer(Integer diagramId, User user){
		//System.out.println(user.getName()+" "+diagramId);
		//update data structures
		userToDiagram.put(user, diagramId);
		userToTimer.put(user,new Long(System.currentTimeMillis()));
	}
	
	/**
	 * This function reserves a diagram for the user; If successful
	 * it return null; otherwise it returns the user that has
	 * checked this diagram out before
	 *  
	 * @param diagramId
	 * @param user
	 * @return
	 */
	public static synchronized User checkoutDiagram(Integer diagramId, User user){
		User auser = isDiagramLockedByAnotherUser(diagramId,user);
		if(auser==null){
			//System.out.println("Locking diagram for "+user.getName()+" "+diagramId);
			//lock diagram for the current user
			userToDiagram.put(user, diagramId);
			userToTimer.put(user,new Long(System.currentTimeMillis()));
			return null;
		}else{
			//System.out.println("Failed to obtain lock for diagram for "+user.getName()+" "+diagramId);
			return auser;
		}
	}

	/**
	 * Utility function to check whether the diagram is locked
	 * @param diagramId
	 * @return
	 */
	private static User isDiagramLockedByAnotherUser(Integer diagramId, User user){
		//check if the diagram has been checked out by another user
		Set users = userToDiagram.keySet();
		//System.out.println("Number of users "+users.size());
		Iterator i = users.iterator();
		while(i.hasNext()){
			User u = (User)i.next();
			//System.out.println("comparing user "+user.getName()+" to "+u.getName());
			//avoid the current user
			if(!u.equals(user)){
				Integer userDiagramId = (Integer)userToDiagram.get(u);
				//check if the diagram id-s are equal
				//System.out.println("Comparing diagram ids "+diagramId+" "+userDiagramId);
				if(userDiagramId.intValue()==diagramId.intValue()){
					//check if the user has closed the browser of moved away from the app
					if(hasUserSessionTerminated(u)){
						//System.out.println("Session terminated");
						//lock out the diagram (the user is gone)
						//it automatically checks in the diagram of the previous user
						userToDiagram.put(u, new Integer(0));
						userToTimer.put(u, new Long(0));
						return null;
					}else{
						//the diagram is locked - return the user
						return u;
					}
				}
			}
		}
		//return null this diagram is not locked
		return null;
	}
	
	/**
	 * This function checks whether the session has terminated
	 * @param user
	 * @return
	 */
	private static boolean hasUserSessionTerminated(User user){		
		long currentTime = System.currentTimeMillis();
		long lastUpdateFromUser = userToTimer.get(user)!=null?((Long)userToTimer.get(user)).longValue():0;
		//check the difference in time
		//System.out.println("Time diff for "+user.getName()+" "+(currentTime - lastUpdateFromUser));
		return currentTime - lastUpdateFromUser > SESSION_TIMEOUT ? true : false;
	}
	
	public static void saveDiagramComment(Comment comment) throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			ddao.saveDiagramComment(comment);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed saving comment");
		}	
	}
	
	public static List getCommentsByDiagramId(long diagramId, boolean isInternalComments) throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.getCommentsByDiagramId(diagramId, isInternalComments);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving comments");
		}
	}
	
//	public static void saveRegisteredUser(User user) throws Exception {
//		try {
//			UserDAO udao = UserDAO.getInstance();
//			udao.saveRegisteredUser(user);
//		} catch(Exception e){
//			e.printStackTrace();
//			throw new Exception(e.getMessage());
//		}	
//	}
	public static boolean checkExistingUsername(String username) throws Exception {
		try {
			UserDAO udao = UserDAO.getInstance();
			return udao.checkExistingUsername(username);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving duplicate username");
		}	
	}
	
	
	
	public static List getAllUsers() throws Exception {
		try {
			UserDAO udao = UserDAO.getInstance();
			return udao.getAllUsers();
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving all users");
		}
	}
	public static List getAllAuthors() throws Exception {
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getAllAuthors();
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving all authors");
		}	
	}
	
	public static List getAllTitles() throws Exception{
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getAllTitles();
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving all titles");
		}
	}
	
	public static long insertCitation(Citation c)throws Exception{
		
		try{
			if(c.getPubTypeId() == Constants.PUBLICATION_TYPE_ID_JOUNRAL_ARTICLE){
				LookupDAO ldao = LookupDAO.getInstance();
				long pubId = ldao.getPublicationIdByDesc(c.getJournal());
				if(pubId<=0){
					pubId = ldao.insertPublication(c.getJournal(), c.getCreatedBy());
				}
				c.setPubId(pubId);
			}
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.insertCitation(c);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed saving citation");
		}
	}
	
	public String getDuplicateCitations(Citation c) throws Exception{
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getDuplicateCitations(c);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving duplicate citation");
		}
	}
	
	public void insertNewLookup(LookupValue lv, long typeEntityId, long userId) throws Exception{
		try{
			LookupDAO ldao = LookupDAO.getInstance();
			ldao.insertNewLookup(lv, typeEntityId, userId);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed saving look up value");
		}
	}
	
	public List getRevisionDiagrams(Long diagramId) throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.getRevisionDiagrams(diagramId);
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving revision diagrams");
		}	
	}
	
	public Diagram loadRevisionDiagramById(long revDiagramId) throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.getRevisionDiagramById(revDiagramId);
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving revision diagram");
		}	
	}
	
	public boolean deleteRevisionDiagram(long revDiagramId) throws Exception {
		try {
			DiagramDAO ddao = DiagramDAO.getInstance();
			return ddao.deleteRevisionDiagram(revDiagramId);
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed deleting diagrams");
		}	
	}
	
	public static User checkIfAuthenticated(String sessionID) {
		User user = null;
		FlexSession fs = FlexContext.getFlexSession();
		try {
			UserDAO udao = UserDAO.getInstance();
			user = udao.getUser( sessionID);
			long currTime = new Date().getTime();
			long lastUpdate = user.getLastUpdatedTimeStamp().getTime();
			long diff = currTime - lastUpdate;
			if(diff > SESSION_TIMEOUT)
				//expired session
				return null;
			fs.setAttribute("currUser", user);
			fs.setTimeoutPeriod(SESSION_TIMEOUT);
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print(e.getMessage());
			// TODO: handle exception
			return null;
		}
		return user;
	}
	
	public static User authenticateUser(String username, String password) throws Exception {
		User user = new User();
	    FlexSession fs = FlexContext.getFlexSession();
	    try {
		    IAMLocator iamLocator = IAMLocator.getInstance(getIAMLocator());
		    AuthMgr authMgr = iamLocator.getAuthMgr();
		    String token = authMgr.authenticate(username, password,AuthMethod.password);
			Request req = new Request();
			req.setToken(token);
			req.setUserId(username);
			Response res = iamLocator.getUserService().getUser(req);
			if("0".equals(res.getStatus())) {
				System.out.println("User: " + res.getUserProfile().getFirstName()[0] 
			               + " " + res.getUserProfile().getLastName()[0]);
				user.setFirstName(res.getUserProfile().getFirstName()[0] );
				user.setLastName(res.getUserProfile().getLastName()[0]);
			}
			    
			GroupMgr groupMgr = iamLocator.getGroupManager();
			String[] groups = groupMgr.getUserGroups(token, username, GroupRole.member);
			
			Set roles = new HashSet();
		    for(int i=0; i < groups.length; i++) {
		    	System.out.println(groups[i]);
		    	roles.add(groups[i]);
		    }
		    
		    if (roles.contains(Constants.CADDIS_ADMINSISTRATOR)) {
				user.setRole(Constants.CADDIS_ADMINSISTRATOR);
				user.setRoleId(Constants.LL_ADMIN_USER);
			} else if (roles.contains(Constants.CADDIS_ICD_USER)) {
				//user.setRole(Constants.CADDIS_CADLIT_USER);
				//user.setRoleId(Constants.LL_CADLIT_USER);
				user.setRole(Constants.CADDIS_ICD_USER);
				user.setRoleId(Constants.LL_ICD_USER);
			} else {
				//CADLit user or other group
				System.out.print("not a user in the group");

				return null;
				
			}

			user.setApplicationLogged(Constants.ICD_APPLICATION);

			//User existingUser = (User)fs.getAttribute("currUser");
			user.setUserName(username);
			user.setPassword(password);
			user.setSessionIdentifier(fs.getId());
			//either insert or update the user information if authenticated

				UserDAO udao = UserDAO.getInstance();
				long userId = udao.getUserId(username);
				if(userId == 0) {
					udao.saveUser(user);
					userId = udao.getUserId(username);
				}
				else
					udao.updateUserSession(user);
				user.setUserId(userId);
				fs.setAttribute("currUser", user);
				fs.setTimeoutPeriod(SESSION_TIMEOUT);
			
	    } catch(Exception e){
	      e.printStackTrace();
	      System.out.print(e.getMessage());
	      return null;
	    }
	    return user;
	}
	
	public static boolean updateUserLogOut(User user) {
		FlexSession fs = FlexContext.getFlexSession();

		try {
			User existingUser = (User)fs.getAttribute("currUser");
			existingUser.setApplicationLogged(Constants.ICD_APPLICATION);
			UserDAO udao = UserDAO.getInstance();
			udao.clearUserSession(existingUser);
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print(e.getMessage());
			// TODO: handle exception
		}
		fs.setAttribute("currUser", null);
		fs.invalidate();
		return true;
	}

	public static String updateSessionLastUpdateTS() {
		String sessionID = "";
		try {
			FlexSession fs = FlexContext.getFlexSession();
			sessionID = (String)fs.getAttribute("seesionID");
			UserDAO udao = UserDAO.getInstance();
			udao.updateSessionLastUpdateTS(sessionID);
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print(e.getMessage());
			// TODO: handle exception
		}
		return sessionID;
	}
	
	/*
	 * searches terms if not null else returns complete list
	 */
	public static List searchTerms(String searchTerm, boolean exactMatch, boolean isStand) throws Exception {
		try {
			LookupDAO ldao = LookupDAO.getInstance();
			return ldao.searchTerms(searchTerm, exactMatch, isStand);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving citations for your search");
		}	
	}
	
	public static List getCitationsByCADDISPageName(String pageName)throws Exception{
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getCitationsByCADDISPageName(pageName);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving citations");
		}
	}
	
	public static long saveTerm(Term newTerm, long userId) throws Exception{
		try {
			LookupDAO ldao = LookupDAO.getInstance();
			return ldao.insertStandardTerm(newTerm, userId);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed saving term");
		}
	}
	
	public List getLinakgesByCitationID(long citationId)throws Exception{
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getLinakgesByCitationID(citationId);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Faield retrieving linkages");
		}
	}
	
	public List getAllEvidenceForCitation(long citationId)throws Exception{
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.getAllEvidenceForCitation(citationId);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Faield retrieving evidences");
		}
	}
	
	public List searchEvidenceByDaigramShapeFrom(String causeTerm, List effectTerms, long diagramId)throws Exception{
		try {
			CitationDAO cdao = CitationDAO.getInstance();
			return cdao.searchEvidenceByDaigramShapeFrom(causeTerm,effectTerms,  diagramId);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Faield retrieving evidences for diagram/selected shape");
		}
	}
	/*
	 * get all of terms 
	 */
	public static List getAllTerms(boolean isStand) throws Exception {
		try {
			LookupDAO ldao = LookupDAO.getInstance();
			return ldao.getAllStandardTerm(isStand);
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new Exception("Failed retrieving standard terms");
		}	
	}
	
}
