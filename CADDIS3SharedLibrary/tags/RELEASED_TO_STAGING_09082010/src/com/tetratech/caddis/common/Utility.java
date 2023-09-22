package com.tetratech.caddis.common;

import java.util.Iterator;
import java.util.List;

import com.tetratech.caddis.model.User;

public class Utility {
	
    public static String convertListToString(List list) {
        String result = "";
        if(list == null){
            return result;
        }
        if(list.size() == 0){
            return result;
        }
            
        for (Iterator j = list.iterator(); j.hasNext(); ){
          result += "," + (String)j.next();
        }
        if (result.length() > 0)
          result = result.substring(1);
        return result;
    }
    
    public static String getUserIds(List list) {
        String result = "";
        if(list == null){
            return result;
        }
        if(list.size() == 0){
            return result;
        }
            
        for (Iterator j = list.iterator(); j.hasNext(); ){
          result += "," + ((User)j.next()).getUserId();
        }
        if (result.length() > 0)
          result = result.substring(1);
        return result;
    }
    
    public static boolean IsNullOrEmpty(String stringVar) {
        boolean b = false; 
        if(stringVar == null || stringVar.length() == 0 || stringVar.equals("null")) 
            b = true; 
        return b;
    }
    
	public static String[] getEachKeyword(String searchTerm) {
		//check "" and assume it to be phrase search
		if(searchTerm.startsWith("\"") && searchTerm.endsWith("\""))
		{			
			String [] quoteTokens = searchTerm.split("\"");
			if(quoteTokens.length > 2){
				searchTerm = searchTerm.replaceAll("\"", "");
			} else if(quoteTokens.length == 2) {
				return new String [] {quoteTokens[1]};
			}

		}
		return searchTerm.split(" ");
	}
	
	public static String formatSearchTerm(String[] searchTerms, String searchField, String symbol){

		StringBuffer buffer = new StringBuffer();
		for(int i = 0; i < searchTerms.length; i++) {
			if(i > 0){
				buffer.append(symbol);
			}
			buffer.append(" UPPER(" +  searchField +  ") LIKE '%" + searchTerms[i].toUpperCase() + "%'") ; 
		}
		return buffer.toString();
	}

}
