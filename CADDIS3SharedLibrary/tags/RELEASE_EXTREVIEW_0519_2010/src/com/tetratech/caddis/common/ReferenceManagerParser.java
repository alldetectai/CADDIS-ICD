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
			for(int i=0;i<recordList.size();i++){
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
					if(refType.getValue().equals(REF_TYPE_JOURNAL_FULL)
							||refType.getValue().equals(REF_TYPE_JOURNAL)){
						
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
										addAuthor(c,author.getValue());
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
							addErrorMessage(c,"Could not extract authors.");
						}
						
						//step 2: read the title
						boolean validTitle = true;
						Element titles = record.getChild("titles");
						if(titles!=null){
							Element title = titles.getChild("title");
							if(title!=null){
								c.setTitle(title.getValue());
							}else{
								validTitle = false;
							}
						}else{
							validTitle = false;
						}

						if(!validTitle){
							addErrorMessage(c,"Could not extract title.");
						}
						
						//step3: read periodical
						boolean validPeriodical = true;
						Element periodical = record.getChild("periodical");
						if(periodical!=null){
						Element fullTitle = periodical.getChild("full-title");
						if(fullTitle!=null){
							c.setJournal(fullTitle.getValue());
						}else{
							validPeriodical = false;
						}
						}else{
							validPeriodical = false;
						}
						
						if(!validPeriodical){
							addErrorMessage(c,"Could not extract journal.");
						}
						
						//step 4: read volume, issue and pages
						boolean validVolume = true;
						Element volume = record.getChild("volume");
						if(volume!=null){
							String vol=null;
							String issue=null;
							String start=null;
							String end=null;
							
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
								issue = issueNo.getValue();
							
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
							
							//build string
							StringBuffer volumeStr = new StringBuffer();
							volumeStr.append(vol);
							if(!isEmptyString(issue)){
								volumeStr.append("(");
								volumeStr.append(issue);
								volumeStr.append(")");
							}
							if(!isEmptyString(start)||!isEmptyString(end)){
								volumeStr.append(":");
								if(!isEmptyString(start))
									volumeStr.append(start);
								else
									volumeStr.append(" ");
								volumeStr.append("-");
								if(!isEmptyString(end))
									volumeStr.append(end);
								else
									volumeStr.append(" ");
							}
							c.setVolumeIssuePagesInfo(volumeStr.toString());
						}else{
							validVolume = false;
						}
						
						if(!validVolume){
							addErrorMessage(c,"Could not extract volume information.");
						}
						
						//step 5: read the year
						boolean validYear = true;
						Element dates = record.getChild("dates");
						if(dates!=null){
							Element year = dates.getChild("year");
							if(year!=null){
								c.setDate(Integer.valueOf(year.getValue()).intValue());
							}else{
								validYear = false;
							}
						}else{
							validYear = false;
						}
						
						if(!validYear){
							addErrorMessage(c,"Could not extract year.");
						}

						Element abstr = record.getChild("abstract");
						if(abstr!=null)
							c.setCitationAbstract(abstr.getValue());

					}else{
						addErrorMessage(c, "Unsupported citation type.");
					}

				}catch(Exception e){
					addErrorMessage(c, "Invalid citation record format.");
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

	private static void addErrorMessage(Citation c, String errorMessage){
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
