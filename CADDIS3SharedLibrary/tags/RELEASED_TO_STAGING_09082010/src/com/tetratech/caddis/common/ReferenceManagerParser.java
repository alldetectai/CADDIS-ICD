package com.tetratech.caddis.common;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.input.SAXBuilder;

import com.tetratech.caddis.model.Citation;


public class ReferenceManagerParser {

	private static final String REF_TYPE_JOURNAL_FULL = "18";
	private static final String REF_TYPE_JOURNAL = "17";
	private static final String REF_TYPE_BOOK = "6";
	private static final String REF_TYPE_BOOK_CHAPTER = "5";
	private static final String REF_TYPE_REPORT = "27";

	public static List parseXMLFile(InputStream stream) throws Exception{
		List refs = new ArrayList();

		try
		{
			SAXBuilder builder = new SAXBuilder();
			Document doc = builder.build(stream);
			//get the root and records tag
			Element root = doc.getRootElement();
			Element records = root.getChild("records");
			//get the list of records
			List recordList = records.getChildren();
			//iterate through the list
			for(int i=0;i<recordList.size();i++) {
				//create a new citation and add it to the list
				Citation c = new Citation();
				c.setValid(true);
				refs.add(c);
				//parse the record
				try{
					//get the record
					Element record = (Element)recordList.get(i);
					//read the source 
					Element source = record.getChild("source-app");
					String appName = source.getAttribute("name").getValue();
					//read the record id
					Element recId = record.getChild("rec-number");
					c.setId(Long.valueOf(recId.getValue()).longValue());
					//read the record type
					Element refType = record.getChild("ref-type");
//					if(refType.getValue().equals(REF_TYPE_JOURNAL_FULL)
//							||refType.getValue().equals(REF_TYPE_JOURNAL)
//							|| refType.getValue().equals(REF_TYPE_BOOK)
//							|| refType.getValue().equals(REF_TYPE_BOOK_CHAPTER)) 
					{
						
						//step1: get the authors
						boolean validAuthors = true;
						
						Element contributors = record.getChild("contributors");
						if(contributors!=null){
							Element authors = contributors.getChild("authors");
							if(authors!=null){
								List authorList = authors.getChildren();
								if(authorList!=null&&authorList.size()>0){
									for(int j=0;j<authorList.size();j++){
										Element author = (Element)authorList.get(j);
										addAuthor(c,author.getValue().trim());
									}
									if ( c.getAuthor()!= null && c.getAuthor().trim().length() > 500){
										validAuthors = false;
										addErrorMessage(c,"The author is longer than the maximum allowed length of 500 characters.");
									}
								}else{
									validAuthors = false;
								}
							}else{
								validAuthors = false;
							}
						}else{
							validAuthors = false;
						}
						
						if(!validAuthors){
							addErrorMessage(c,"Could not extract authors.\n");
						}
						
						
						//step 2: read the title
						boolean validTitle = true;
						Element titles = record.getChild("titles");
						if(titles!=null){
							Element title = titles.getChild("title");
							if(title!=null){
								if(title.getValue().trim().length() <= 500 )
									c.setTitle(title.getValue().trim());
								else{
									validTitle = false;
									addErrorMessage(c,"The title is longer than the maximum allowed length of 500 characters.");
								}
							}else{
								validTitle = false;
							}
						}else{
							validTitle = false;
						}

						if(!validTitle){
							addErrorMessage(c,"Could not extract title.\n");
						}
						
						//step 3 read the year
						boolean validYear = true;
						Element dates = record.getChild("dates");
						if(dates!=null){
							Element year = dates.getChild("year");
							if(year!=null){
								if( year.getValue().length() <= 4)
									c.setYear(year.getValue());
								else{
									validYear = false;
									addErrorMessage(c,"The year is longer than the maximum allowed length of 4 characters.");
								}
									
							}else{
								validYear = false;
							}
						}else{
							validYear = false;
						}
						//year is required
						if(!validYear){
							addErrorMessage(c,"Could not extract year.\n");
						}
						
						//keyword optional
						Element keywords = record.getChild("keywords");
						if (keywords != null) {

							List keywordList = keywords.getChildren();
							if (keywordList != null && keywordList.size() > 0) {
								for (int j = 0; j < keywordList.size(); j++) {
									Element keyword = (Element) keywordList.get(j);
									if (c.getKeyword() == null)
										c.setKeyword(keyword.getValue().trim());
									else
										c.setKeyword(c.getKeyword() + "; " + keyword.getValue().trim());
								}
								if (c.getKeyword() != null && c.getKeyword().length() > 1000 ) //If length is too long for DB, ignore data.
									c.setKeyword("");  
							}
						}
						//urls optional
						Element urls = record.getChild("urls");
						if(urls != null) {
							Element weburls = urls.getChild("web-urls");
							if(weburls != null) {
								Element url = weburls.getChild("url");
								if(url != null && url.getValue().length() <= 255)
									c.setCitationUrl(url.getValue().trim());
							}
						}
						
						//Abstract
						Element abstr = record.getChild("abstract");
						if(abstr!=null)
							c.setCitationAbstract(abstr.getValue().trim());
						
						String start=null;
						String end=null;
						//read pages
						Element pages = record.getChild("pages");
						if(pages!=null){
							if(appName.indexOf("Reference Manager")>=0){
								start = pages.getAttributeValue("start");
								end = pages.getAttributeValue("end");
							}else if(appName.indexOf("EndNote")>=0){
								String startend = pages.getValue();
								if(startend.indexOf("-")>0){
									String[] parts = startend.split("-");
									start = parts[0];
									end = parts[1];
								}
							}
						}
						if(!Utility.IsNullOrEmpty(start))
							c.setStartPage(start);
						if(!Utility.IsNullOrEmpty(end))
							c.setEndPage(end);
						if(refType.getValue().equals(REF_TYPE_JOURNAL_FULL)
								||refType.getValue().equals(REF_TYPE_JOURNAL)) {
							
							c.setPubTypeId(Constants.PUBLICATION_TYPE_ID_JOUNRAL_ARTICLE);

							// read periodical
							boolean validPeriodical = true;
							Element periodical = record.getChild("periodical");
							if(periodical!=null){
							Element fullTitle = periodical.getChild("full-title");
							if(fullTitle!=null){
								if( fullTitle.getValue().trim().length() <= 1000 )
									c.setJournal(fullTitle.getValue().trim());
								else{
									validPeriodical = false;
									addErrorMessage(c,"The journal is longer than the maximum allowed length of 1000 characters.");
								}
							}else{
								validPeriodical = false;
							}
							}else{
								validPeriodical = false;
							}
							
							if(!validPeriodical){
								addErrorMessage(c,"Could not extract journal.\n");
							}
							// read volume, issue and pages
							boolean validVolume = true;
							Element volume = record.getChild("volume");
							if(volume!=null) {
								String vol=null;
								String issue=null;

								
								//read volume
								vol = volume.getValue();
								//remove unnecessary formating from volume
								if(vol.indexOf("(")>0)
									vol = vol.substring(0,vol.indexOf("("));
								else if(vol.indexOf(":")>0)
									vol = vol.substring(0,vol.indexOf(":"));
								
								//read issue number
								Element issueNo = record.getChild("number");
								if(issueNo != null)
									issue = issueNo.getValue().trim();
								if(!Utility.IsNullOrEmpty(vol)){
									if (vol.length() <= 4 )
										c.setVolume(Long.valueOf(vol).longValue());
									else{
										validVolume = false;
										addErrorMessage(c,"The volume is longer than the maximum allowed length of 4 characters.");
									}
								}
								c.setIssue(issue);
							} else{
								validVolume = false;
							}
						
							if(!validVolume){
								addErrorMessage(c,"Could not extract volume information.\n");
							}
							//end of journal
						} else if(refType.getValue().equals(REF_TYPE_BOOK)) {
							//book
							c.setPubTypeId(Constants.PUBLICATION_TYPE_ID_BOOK);
							//optional
							Element publisher = record.getChild("publisher");
							if(publisher != null && publisher.getValue().trim().length() <= 255)
								c.setPublishers(publisher.getValue().trim());
							
							//editors are secondary authors and optional
							if(contributors!=null) {
								Element editors = contributors.getChild("secondary-authors");
								if(editors != null) {
									List editorList = editors.getChildren();
									if(editorList!=null && editorList.size()>0) {
										for(int j=0; j < editorList.size(); j++){
											Element editor = (Element) editorList.get(j);
											if (c.getEditors() == null)
												c.setEditors(editor.getValue().trim());
											else
												c.setEditors(c.getEditors() + "; " + editor.getValue().trim());
										}
										if (c.getEditors() != null && c.getEditors().length() > 255 ) //If length is too long for DB, ignore data.
											c.setEditors("");  
									}
								}
							}

							// we are using end page tag for pages. <pages end="1" start="200">-</pages>
							c.setPages(Long.valueOf(c.getEndPage()).longValue());
						} else if(refType.getValue().equals(REF_TYPE_BOOK_CHAPTER)) {
							//book chapter 
							c.setPubTypeId(Constants.PUBLICATION_TYPE_ID_BOOK_CHAPTER);
							//optional
							Element publisher = record.getChild("publisher");
							if(publisher != null && publisher.getValue().trim().length() <= 255 )
								c.setPublishers(publisher.getValue().trim());
							//editors are secondary authors and are required
							if(contributors!=null) {
								Element editors = contributors.getChild("secondary-authors");
								if(editors != null) {
									List editorList = editors.getChildren();
									if(editorList!=null && editorList.size()>0) {
										for(int j=0; j < editorList.size(); j++){
											Element editor = (Element) editorList.get(j);
											if (c.getEditors() == null)
												c.setEditors(editor.getValue().trim());
											else
												c.setEditors(c.getEditors() + "; " + editor.getValue().trim());
										}
										if (c.getEditors() != null && c.getEditors().length() > 255 ){
											c.setEditors(null);  
											addErrorMessage(c,"The editor(s) are longer than the maximum allowed length of 255 characters.");
										}
											
									}
								}
							}

							if(Utility.IsNullOrEmpty( c.getEditors()))
								addErrorMessage(c,"Could not extract editor.\n");
							
							//book title is "alt-title" and is required
							if(titles != null){
								Element bookTitle = titles.getChild("alt-title");
								if(bookTitle != null){
									if( bookTitle.getValue().trim().length() <= 255)
										c.setBook(bookTitle.getValue().trim());
									else{
										addErrorMessage(c,"The book title is longer than the maximum allowed length of 255 characters.");
										addErrorMessage(c,"Could not extract book.\n");
									}
								}
							}
							if(Utility.IsNullOrEmpty( c.getBook()))
								addErrorMessage(c,"Could not extract book.\n");
							
						} else if(refType.getValue().equals(REF_TYPE_REPORT)) {
							//book chapter
							c.setPubTypeId(Constants.PUBLICATION_TYPE_ID_REPORT);
							
							//required publisher or agency number
							Element publisher = record.getChild("publisher");
							if(publisher != null){
								if( publisher.getValue().trim().length() <= 255 )
									c.setPublishers(publisher.getValue().trim());
								else{
									addErrorMessage(c,"The publisher is longer than the maximum allowed length of 255 characters.");
									addErrorMessage(c,"Could not extract publisher.\n");									
								}
							}
							if(Utility.IsNullOrEmpty( c.getPublishers()))
								addErrorMessage(c,"Could not extract publisher.\n");
							
							
							//Report # optional and uses volume tag in xml
							Element reportNum = record.getChild("volume");
							if( reportNum  != null && reportNum.getValue().trim().length() <= 255 )
								c.setReportNum(reportNum.getValue().trim());
							// we are using end page tag for pages. <pages end="1" start="200">-</pages>
							c.setPages(Long.valueOf(c.getEndPage()).longValue());

						} else {
							c.setPubTypeId(Constants.PUBLICATION_TYPE_ID_OTHER);
							//source optional
							Element sourceVal = record.getChild("source");
							if(sourceVal != null && sourceVal.getValue().trim().length() <= 100 )
								c.setSource(sourceVal.getValue().trim());
							String type = refType.getAttributeValue("name");
							if(type  != null && type.trim().length() <= 100 )
								c.setType(type.trim());
							// we are using end page tag for pages. <pages end="1" start="200">-</pages>
							c.setPages(Long.valueOf(c.getEndPage()).longValue());
						}
						
					} 


				} catch(Exception e) {
					e.printStackTrace();
					addErrorMessage(c, "Invalid citation record format.\n");
				}
			}
			
			for(int m=0;m<refs.size();m++){
				((Citation)refs.get(m)).print();
				System.out.println("------------------------------");
			}

		}catch(Exception e){
			throw new Exception("An error occured while reading XML file.");
		}

		return refs;
	}

	public static void addErrorMessage(Citation c, String errorMessage){
		c.setValid(false);
		if(c.getErrorMessage()==null)
			c.setErrorMessage(errorMessage);
		else
			c.setErrorMessage(c.getErrorMessage()+" "+errorMessage);
	}

	private static void addAuthor(Citation c,String author){
		if(c.getAuthor()==null)
			c.setAuthor(author);
		else
			c.setAuthor(c.getAuthor()+"; "+author.trim());
	}
	
	private static boolean isEmptyString(String str){
		return str==null||str.trim().length() == 0;
	}

}
