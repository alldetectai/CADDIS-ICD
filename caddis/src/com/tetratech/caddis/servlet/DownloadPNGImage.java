package com.tetratech.caddis.servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class DownloadPNGImage extends HttpServlet
{

    private static final long serialVersionUID = 1L;

    public void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        doDownload(request, response);
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException
    {
        doDownload(request, response);
    }
    
    private void doDownload(HttpServletRequest req, HttpServletResponse resp) throws IOException
    {
    	ServletOutputStream op = null;
    	try{
	    	//get image data from the session
	    	HttpSession s = req.getSession();
	    	byte[] data = (byte[])s.getAttribute("image");
	    	String diagramName = (String)s.getAttribute("diagram");
	    	//remove the attributes
    		s.removeAttribute("image");
    		s.removeAttribute("diagram");
	    	//create dummy data if necessary
	    	if(data==null)
	    		data = new byte[0];
	    	if(diagramName==null||diagramName.length()==0)
	    		diagramName = "diagram";
	    	//get the servlet output stream
	        op = resp.getOutputStream();
	        //set headers
	        resp.setContentType("image/png");
	        resp.setHeader("Content-Disposition","attachment; filename="+diagramName+".png");
	        resp.setContentLength((int)data.length);
	        //write data
	        op.write(data,0,data.length);
	        op.flush();
    	}catch(Exception e){
    		e.printStackTrace();
    		throw new IOException(e.getMessage());
    	}finally{
	        try {
				op.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
    	}
    }
}
