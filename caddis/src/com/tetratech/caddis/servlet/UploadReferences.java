package com.tetratech.caddis.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.fileupload.FileItemIterator;
import org.apache.commons.fileupload.FileItemStream;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.common.ReferenceManagerParser;
import com.tetratech.caddis.dao.LookupDAO;
import com.tetratech.caddis.model.Citation;
import com.tetratech.caddis.service.IcdService;


public class UploadReferences extends HttpServlet
{

	private static final long serialVersionUID = 1L;

	public void doGet(HttpServletRequest request, HttpServletResponse response)
	throws ServletException, IOException
	{
		doUpload(request, response);
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException, IOException
	{
		doUpload(request, response);
	}

	private void doUpload(HttpServletRequest req, HttpServletResponse resp) throws IOException
	{
		try{

			HttpSession session = req.getSession();
			String userID = req.getParameter("currUserID");

			// Create a new file upload handler
			ServletFileUpload upload = new ServletFileUpload();
			IcdService s = new IcdService();

			// Parse the request
			FileItemIterator iter = upload.getItemIterator(req);
			while (iter.hasNext()) {
			    FileItemStream item = iter.next();
			    if (!item.isFormField()) {
			    	//get the citations from the parser
					List citations = ReferenceManagerParser.parseXMLFile(item.openStream());
					//copy the valid citations
					List validCits = new ArrayList();
					boolean isRecordValid = true;
					for(int k=0;k<citations.size();k++){
						Citation cit = (Citation)citations.get(k);
						if (s.getDuplicateCitations(cit) != ""){
							ReferenceManagerParser.addErrorMessage(cit,"Found duplicate citation.");
						}
						if( !cit.isValid() ){
							isRecordValid = false;
						}
						
					}
					if(isRecordValid){
						for(int i=0;i<citations.size();i++){
							Citation c = (Citation)citations.get(i);
							if(c.isValid())
								c.setCreatedBy(Long.parseLong(userID));
								if(c.getPubTypeId() == Constants.PUBLICATION_TYPE_ID_JOUNRAL_ARTICLE) {
									try
									{
										LookupDAO ldao = LookupDAO.getInstance();
										long pubId = ldao.getPublicationIdByDesc(c.getJournal());
										if (pubId <= 0) {
											pubId = ldao.insertPublication(c.getJournal(), c.getCreatedBy());
										}
										c.setPubId(pubId);
									} catch(Exception e) {
										c.setValid(false);
										c.setErrorMessage("Could not insert journal type.");
									}
								}
								if(c.isValid())
									validCits.add(citations.get(i));
						}
						//save the valid citations
						s.saveCitations(validCits);
					}

					//store the citations in session
					session.setAttribute("uploadedRefs",citations);
			    	break;
			    }
			}
		} catch(Exception e){
			e.printStackTrace();
			System.out.print(e.getMessage());
			throw new IOException("Failed uploading");
		}
	}
	
}