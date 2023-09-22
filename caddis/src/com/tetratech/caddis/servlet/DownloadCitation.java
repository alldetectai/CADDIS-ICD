package com.tetratech.caddis.servlet;


import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.tetratech.caddis.common.Utility;
import com.tetratech.caddis.model.Citation;
import com.tetratech.caddis.model.DownloadData;
import com.tetratech.caddis.model.SelectedLinkage;
import com.tetratech.caddis.model.User;
import com.tetratech.caddis.service.IcdService;

public class DownloadCitation extends HttpServlet {

	private static final long serialVersionUID = 1L;

	public void doGet(HttpServletRequest request, HttpServletResponse response)
	throws ServletException, IOException
	{
		doPost(request, response);
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException, IOException
	{
		HttpSession session = request.getSession();
		DownloadData data = (DownloadData)session.getAttribute("downloadData");
		User existingUser = (User)session.getAttribute("currUser");
		String format = data.getFormat();

		if(format.equalsIgnoreCase("html"))
			doDownloadHTML(request, response, data);
		else if(format.equalsIgnoreCase("text"))
			doDownloadText(request, response, data);
		else if(format.equalsIgnoreCase("refman"))
			doDownloadRefMan(request, response, data);
		else if(format.equalsIgnoreCase("endnote"))
			/* The same file can be used for both end note and ref man */
			//doDownloadEndNote(request, response, data);
			doDownloadRefMan(request, response, data);
		else {
			 response.setContentType( "text/html; charset=utf-8");
			PrintWriter out =  response.getWriter();
			out.println("<html>");
			out.println("<head><title>Citation List</title></head>");
			out.println("<body>");
				out.println("No data found.");
			out.println("</body></html>");
			out.flush();
			out.close();
			 response.flushBuffer();
		}
			
	}

	private void doDownloadHTML(HttpServletRequest req, HttpServletResponse resp, DownloadData data) throws IOException
	{
		String content = "";
		List citations = new ArrayList();
		List ids = data.getCitationIds();
		List selectedLinkages = data.getSelectedLinakge();

		//TODO: NEED TO STORE THE CITATIONS ITSELF INSTEAD OF IDS.
		if(ids != null && ids.size() > 0) {
			try {
				citations = IcdService.getCitationsByIDs(null, ids);
			} catch (Exception e) {
				e.printStackTrace();
				content = "Unknown error. Please report to System Admin.";
			}
			if(citations != null && citations.size() > 0) {
				content = buildHTMLContent(citations, data);
			}
		} else if(selectedLinkages != null && selectedLinkages.size() > 0) {
			content = buildHTMLContent(selectedLinkages, data);
		}

		resp.setContentType( "text/html; charset=utf-8");
		PrintWriter out = resp.getWriter();
		out.println("<html>");
		out.println("<head><title>Citation List</title></head>");
		out.println("<body>");
		if(content.length() == 0)
			out.println("No data found.");
		else
			out.write(content);
		out.println("</body></html>");
		out.flush();
		out.close();
		resp.flushBuffer();
	}

	private void doDownloadText(HttpServletRequest req, HttpServletResponse resp, DownloadData data) throws IOException
	{
		boolean includeAbstract = data.getIncludeAbstract();

		StringBuffer content = new StringBuffer();
		List selectedLinkages = data.getSelectedLinakge();
		List ids = data.getCitationIds();

		//TODO: NEED TO STORE THE CITATIONS ITSELF INSTEAD OF IDS.
		if(ids != null && ids.size() > 0) {
			List citations = new ArrayList();
			try {
				citations = IcdService.getCitationsByIDs(null, ids);
			} catch (Exception e) {
				e.printStackTrace();
			}
			if(citations != null && citations.size() > 0) {
				content.append("Type\tTitle\tAuthor\tYear\tStart Page\tEnd Page\tJournal\tIssue\tVolume");
				if(includeAbstract)
					content.append("\tAbstract");
				content.append("\r\n");
				content.append(formatCitationInText(citations, includeAbstract, ""));
			}
		} else if(selectedLinkages != null && selectedLinkages.size() > 0) {
			if(data.getIncludeLinkage())
				content.append("Linkages\t");
			content.append("Type\tTitle\tAuthor\tYear\tStart Page\tEnd Page\tJournal\tIssue\tVolume");
			if(includeAbstract)
				content.append("\tAbstract");
			content.append("\r\n");
			for(int i = 0; i < selectedLinkages.size(); i++) {
				SelectedLinkage l = (SelectedLinkage)selectedLinkages.get(i);
				String addLabel = data.getIncludeLinkage() ? l.getLabel() + "\t" : "";
				content.append(formatCitationInText(l.citations, includeAbstract, addLabel));
			}
		}

		resp.setContentType( "Application/csv");
		resp.setHeader("Content-Disposition", "attachment; filename=" + "\"CitationList.txt\"");
		ServletOutputStream out = resp.getOutputStream();
		out.write(content.toString().getBytes());
		out.flush();
		out.close();
		resp.flushBuffer();
	}

	private void doDownloadRefMan(HttpServletRequest req, HttpServletResponse resp, DownloadData data) throws IOException
	{

		StringBuffer content = new StringBuffer();
		List citations = new ArrayList();
		List ids = data.getCitationIds();
		List selectedLinkages = data.getSelectedLinakge();

		try {

			if(ids != null && ids.size() > 0) {
				citations = IcdService.getCitationsByIDs(null, ids);
			}else if(selectedLinkages != null && selectedLinkages.size() > 0){
				int length = selectedLinkages.size();
				for(int i = 0; i < length; i++) {
					SelectedLinkage l = (SelectedLinkage)selectedLinkages.get(i);
					List cits = l.getCitations();
					for(int j = 0; j < cits.size(); j++) {
						citations.add(cits.get(j));
					}
				}

			}

			int length = citations.size();

			content.append("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?><xml><records>");

			for(int i=0;i<length;i++){
				Citation cit = (Citation)citations.get(i);

				content.append("<record><source-app name=\"Reference Manager 12.0\" version=\"12.0.0.2401\">Reference Manager 12.0</source-app>");
				content.append("<rec-number><style face=\"normal\" font=\"default\">");
				content.append(i+1);
				content.append("</style></rec-number>");
				content.append("<ref-type name=\"Journal\">17</ref-type>");

				content.append("<contributors><authors>");					
				String author = removeNull(cit.getAuthor());
				String[] authors = author.split(";");
				if(authors==null||authors.length==0){
					authors = new String[1];
					authors[0] = "";
				}
				for(int m=0;m<authors.length;m++){
					content.append("<author><style face=\"normal\" font=\"default\">");
					content.append(authors[m].trim());
					content.append("</style></author>");
				}
				content.append("</authors></contributors>");

				content.append("<titles><title><style face=\"normal\" font=\"default\">");
				content.append(removeNull(cit.getTitle()));
				content.append("</style></title></titles>");
				content.append("<periodical><full-title><style face=\"normal\" font=\"System\">");
				content.append(removeNull(cit.getJournal()));
				content.append("</style></full-title></periodical>");
				content.append("<pages end=\""+getEndPage(removeNull(cit.getVolumeIssuePagesInfo()))+"\" start=\""
						+getStartPage(removeNull(cit.getVolumeIssuePagesInfo()))+"\">"
						+getStartPage(removeNull(cit.getVolumeIssuePagesInfo()))+"-"
						+getEndPage(removeNull(cit.getVolumeIssuePagesInfo()))+"</pages>");
				content.append("<volume><style face=\"normal\" font=\"default\">");
				content.append(removeNull(getVolume(cit.getVolumeIssuePagesInfo())));
				content.append("</style></volume>");
				content.append("<number><style face=\"normal\" font=\"default\">"+getVolumeIssue(removeNull(cit.getVolumeIssuePagesInfo()))+"</style></number>");
				content.append("<keywords/><dates><year Day=\"0\" Month=\"0\" Year=\"");
				content.append(Utility.IsNullOrEmpty(cit.getYear()) ? "" :  cit.getYear());
				content.append("\">");
				content.append(Utility.IsNullOrEmpty(cit.getYear()) ? "" :  cit.getYear());
				content.append("</year></dates>");
				content.append("<publisher/>");
				content.append("<abstract><style face=\"normal\" font=\"default\">");
				content.append(data.getIncludeAbstract()?removeNull(cit.getCitationAbstract()):"");
				content.append("</style></abstract><urls/>");
				content.append("</record>");
			}

			content.append("</records></xml>");

		} catch (Exception e) {
			e.printStackTrace();
			content = new StringBuffer();
			content.append("Unknown error. Please report to System Admin.");
		}

		resp.setContentType( "text/xml; charset=utf-8");
		resp.setHeader("Content-Disposition", "attachment; filename=" + "\"CitationList.xml\"");
		PrintWriter out = resp.getWriter();
		out.println(content);
		out.flush();
		out.close();
		resp.flushBuffer();
	}



	private String formatJournalAndVolume(Citation c) {

		StringBuffer content = new StringBuffer();
		if( c.getVolumeIssuePagesInfo() != null) {
			String data = c.getVolumeIssuePagesInfo();
			int index = data.indexOf(':', 0);
			int endIndex = data.lastIndexOf('-');

			if(index != -1 && endIndex != -1) {
				String page  = data.substring(index+1, endIndex);
				content.append("\t" + page.trim());
				page  = data.substring(endIndex + 1).trim();
				content.append("\t" + (page.endsWith(".") ? page.substring(0, page.length()-1) : page ));
			}
			else 
				content.append("\t\t");
			content.append(c.getJournal() == null ? "\t" :  "\t" + c.getJournal().trim());
			endIndex = data.lastIndexOf(')');
			String volume = "";
			if(endIndex != -1) {
				index = data.indexOf('(', 0);
				if(index != -1 && endIndex != -1) {
					String issue  = data.substring(index+1, endIndex);
					content.append("\t" + issue.trim());
				}
				else 
					content.append("\t");
			}
			else 
				content.append("\t");
			if(index != -1) {
				volume  = data.substring(0, index);
				content.append("\t" + volume.trim());
			}
			else 
				content.append("\t");
		}
		else {
			content.append("\t\t");
			content.append(c.getJournal() == null ? "\t" :  "\t" + c.getJournal().trim());
			content.append("\t\t");
		}

		return content.toString();
	}

	//helper to create rows
	private String formatCitationInText(List citations, boolean includeAbstract, String addLabel){
		StringBuffer content = new StringBuffer();
		if(citations != null && citations.size() > 0) {
			for(int i = 0; i < citations.size(); i++)
			{
				Citation c = (Citation)citations.get(i);
				content.append(addLabel);
				content.append("JOUR" );
				content.append("\t" + c.getTitle().trim());
				content.append("\t" + c.getAuthor().trim());
				content.append("\t" + c.getYear());
				content.append(formatJournalAndVolume(c));

				if(includeAbstract)
					content.append("\t" + (c.getCitationAbstract() ==  null ? "" : c.getCitationAbstract().trim()));
				content.append("\r\n");
			}
		}
		return content.toString();
	}

	//helper to create citations list
	private String formatCitationInHTML(List citations, boolean includeAbstract) {
		StringBuffer content = new StringBuffer();

		for(int i = 0; i < citations.size(); i++) {
			Citation c = (Citation)citations.get(i);
			int number = i + 1;
			content.append("<br /><strong>" + number  + ".</strong> ");

			content.append(c.getAuthor() + " (" + c.getYear() + ") " 
					+  c.getTitle() + (c.getTitle().endsWith(".") ? "" : ".")
					+ (c.getJournal() != null ? " " + c.getJournal() : "") 
					+ (c.getVolumeIssuePagesInfo() != null ? (" " + c.getVolumeIssuePagesInfo()) : "")
					+ (c.getVolumeIssuePagesInfo() != null && c.getVolumeIssuePagesInfo().endsWith(".") ? "" : ".") );
			content.append("<br />");	
			if(includeAbstract && c.getCitationAbstract() != null) {
				content.append("<br />");
				content.append("<strong>Abstract</strong>&nbsp;&nbsp;" +  c.getCitationAbstract());
				content.append("<br />");
			}
		}
		return content.toString();
	}


	//list can be either citations or selectedlinkage
	private String buildHTMLContent(List list, DownloadData data) {
		StringBuffer content = new StringBuffer();

		if(list.size() > 0) {
			Object o = list.get(0);
			if(o instanceof Citation)
				return formatCitationInHTML(list, data.getIncludeAbstract());
		}
		//if linkages not needed, then use citations list format.
		if(!data.getIncludeLinkage()) {
			List allCitations = new ArrayList();	
			for(int i = 0; i < list.size(); i++) {
				SelectedLinkage l = (SelectedLinkage)list.get(i);
				List citations = l.getCitations();
				for(int j = 0; j < citations.size(); j++) {
					allCitations.add(citations.get(j));
				}
			}
			return formatCitationInHTML(allCitations, data.getIncludeAbstract());
		}
		for(int i = 0; i < list.size(); i++) {
			SelectedLinkage l = (SelectedLinkage) list.get(i);
			content.append("<br />");
			content.append("<div style=\"color:#0000FF;font-Weight:bold\">");
			content.append("<i>LINKAGE: </strong>&nbsp;&nbsp;" + l.getLabel() + "</i>");
			content.append("</div>");
			content.append(formatCitationInHTML(l.getCitations(), data.getIncludeAbstract()));
		}
		return content.toString();
	}

	private String removeNull(String s){
		return s!=null?s.trim():"";
	}

	public String getStartPage(String volume){
		int colonIndex = volume.indexOf(":");
		int dashIndex = volume.indexOf("-");
		if(colonIndex >= 0 && dashIndex >= 0 && colonIndex < dashIndex)
			return volume.substring(colonIndex+1, dashIndex);
		else
			return "";
	}

	public String getEndPage(String volume){
		int colonIndex = volume.indexOf(":");
		int dashIndex = volume.indexOf("-");
		if(colonIndex >= 0 && dashIndex >= 0 && colonIndex < dashIndex)
			return volume.substring(dashIndex+1);
		else
			return "";
	}

	public String getVolumeIssue(String volume){
		int b1 = volume.indexOf("(");
		int b2 = volume.indexOf(")");
		if(b1 >= 0 && b2 >= 0 && b1 < b2)
			return volume.substring(b1+1,b2);
		else
			return "";
	}

		public String getVolume(String volume){
			int colonIndex = volume.indexOf(":");
			int bracketIndex = volume.indexOf("(");
			int dashIndex = volume.indexOf("-");
	
			if(bracketIndex>0)
				return volume.substring(0,bracketIndex);
			else if(colonIndex>0)
				return volume.substring(0,colonIndex);
			else if(dashIndex>0)
				return "";
			else
				return volume;
		}

}
