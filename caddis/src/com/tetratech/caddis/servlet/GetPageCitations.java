package com.tetratech.caddis.servlet;

import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

import com.tetratech.caddis.model.Citation;
import com.tetratech.caddis.service.IcdService;

public class GetPageCitations extends HttpServlet {

	private static final long serialVersionUID = 1L;

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException
	{
		String pageName = request.getParameter("pageName");
		System.out.println("pageName: " + pageName);
		if(pageName!=null && pageName.trim().length()>0){
			try{
				JSONArray ja = retrieveCitations(pageName.trim());
				JSONObject jo = new JSONObject();
				jo.put("citations", ja);
				System.out.println("citations: " + jo.toString());
				String citation = request.getParameter("callback") + "(" + jo.toString() + ");";
				response.setContentType("text/javascript");
				PrintWriter out = response.getWriter();
				out.println(citation);
				out.flush();
				out.close();
				out = null;
			}catch (Exception e){
				e.printStackTrace();
				System.out.print(e.getMessage());
			}
		}
	}
	
	
	private JSONArray retrieveCitations(String pageName)throws Exception{
		JSONArray ja = null;
		JSONObject jo = null;
		Citation c = null;
		List list = null;
		try{
			if(pageName != null && pageName.trim().length()> 0){
				list = IcdService.getCitationsByCADDISPageName(pageName);
				System.out.println("size of Citation List: " + list.size());
				if(list.size()>0){
					ja = new JSONArray();
					for(int i=0;i<list.size();i++){
						c = (Citation)list.get(i);
						jo = new JSONObject();
						jo.put("", "");
//						jo.put("id", String.valueOf(c.getId()));
//						jo.put("author", c.getAuthor());
//						jo.put("title", c.getTitle());
//						jo.put("year", String.valueOf(c.getYear()));
//						jo.put("keyword", c.getKeyword());
//						jo.put("journal", c.getJournal());
//						jo.put("volumeIssuePages", c.getVolumeIssuePagesInfo());
//						if(c.isApproved())
//							jo.put("isApproved", Constants.YES);
//						else
//							jo.put("isApproved", Constants.NO);
						jo.put("displayTitle", c.getDisplayTitle());
						jo.put("ciatationAnno", c.getCitationAnnotation());
						ja.put(jo);
					}
					System.out.println("size of JSONArray: " + ja.length());
				}
			}
		}catch(Exception e){
			e.printStackTrace();
			throw new Exception(e.getMessage());
		}
		return ja;
	}
}
