package org.eel.services;

import java.util.ArrayList;
import java.util.List;


import org.eel.standards.*;



public class EELClient {

	private static com.tetratech.caddis.model.Citation createICDCitation(Citation eelCitation) {
		com.tetratech.caddis.model.Citation icdCitation = new com.tetratech.caddis.model.Citation();
		icdCitation.setApproved(false);
		icdCitation.setAuthor(eelCitation.getAuthors());
		icdCitation.setTitle(eelCitation.getTitle());
		icdCitation.setBook(eelCitation.getTitle());
		icdCitation.setPubTypeId(com.tetratech.caddis.common.Constants.PUBLICATION_TYPE_ID_JOUNRAL_ARTICLE);
		icdCitation.setIssue(eelCitation.getIssue());

		try {
		icdCitation.setVolume(Long.valueOf(eelCitation.getVolume()));
		} catch(Exception ex) {
			
		}
		icdCitation.setJournal(eelCitation.getSource());
		icdCitation.setPublishers(eelCitation.getPublisher());
		icdCitation.setYear(eelCitation.getYear());
		icdCitation.setStartPage(eelCitation.getPageStart());
		icdCitation.setEndPage(eelCitation.getPageEnd());
		icdCitation.setCitationAbstract(eelCitation.getAbstractText());
		icdCitation.setDisplayTitle(formatDisplayTitle(icdCitation));
		List<com.tetratech.caddis.model.CauseEffectLinkage> linkage = new ArrayList<com.tetratech.caddis.model.CauseEffectLinkage>(); 
		List<Evidence> evidences = eelCitation.getEvidenceItems();
		
		for(int j= 0; j < evidences.size(); j++) {
			Evidence ev = evidences.get(j);
			Cause eviCause = ev.getCause();
			Effect eviEffect = ev.getEffect();
			com.tetratech.caddis.model.CauseEffectLinkage e = new com.tetratech.caddis.model.CauseEffectLinkage();
			com.tetratech.caddis.model.Term term = new com.tetratech.caddis.model.Term();
			term.setTerm(eviCause.getTerm().getLabel());
			term.setDesc(eviCause.getTerm().getDefinition());
			//term.setEELTerm(eviCause.getTerm().isEELTerm())
			e.setCauseTerm(term);
			e.setCauseTrajectory(getSymbolValue(eviCause.getTrajectory()));
			term =  new com.tetratech.caddis.model.Term();
			term.setTerm(eviEffect.getTerm().getLabel());
			term.setDesc(eviEffect.getTerm().getDefinition());
			//term.setEELTerm(eviEffect.getTerm().isEELTerm())
			e.setEffectTrajectory(getSymbolValue(eviEffect.getTrajectory()));
			e.setEffectTerm(term);
			linkage.add(e);
		}
		
		icdCitation.setCauseEffectLinkage(linkage);
		return icdCitation;
	}
	
	public static List<com.tetratech.caddis.model.Citation> getCitations(String cause, String effect) {
		List<com.tetratech.caddis.model.Citation> icdcitations = new ArrayList<com.tetratech.caddis.model.Citation>();
		Result e;

		EELServices srv = new EELServices();
			e = srv.getBasicHttpBindingIEELServices().getCitations(cause, effect);
			List<Citation> citations = e.getCitations();
			for (int i = 0; i < citations.size(); i++) {
				Citation c = citations.get(i);
				System.out.print("Author-- " + c.getAuthors() + "\n");
				System.out.print("Title-- " + c.getTitle() + "\n");
				if(c.getKeywords() != null)
				System.out.print("Keywords-- " + c.getKeywords() + "\n");
				if(c.getAbstractText() != null)
				System.out.print("Abstract-- " + c.getAbstractText() + "\n");
				System.out.print("-----------------------------\n");
				com.tetratech.caddis.model.Citation icdCitation = createICDCitation(c);
				icdcitations.add(icdCitation);
				
			}

			System.out.print("-------- Source  ---------------------\n");
			Source s = e.getSource();
			System.out.print(s.getOrganization() +  " " + s.getUrl()+ "\n");
			System.out.print("-------- Search  ---------------------\n");

			Search se =  e.getSearch();
			System.out.print(se.getCause() +  " " + se.getEffect() + " " + se.getDateTime()+ "\n");
			
			return icdcitations;
	}
	
	public static String formatDisplayTitle(com.tetratech.caddis.model.Citation c) {
		String displayTitle =  
		 c.getAuthor() + " (" + c.getYear() + ")" 
		+  c.getTitle()
		+ (c.getJournal() != null ? " " + c.getJournal() : "") ;
		return displayTitle;
	}
	public static List<com.tetratech.caddis.model.LookupValue> getTerms() {
		List<com.tetratech.caddis.model.LookupValue> lookupTerms = new ArrayList<com.tetratech.caddis.model.LookupValue>();
			System.out.print("***********************************************\n");
			System.out.print("**************Testing method Terms\n");
			TermList termlists;
			EELServices srv = new EELServices();
			termlists = srv.getBasicHttpBindingIEELServices().getTerms();

			List<Term> terms = termlists.getTerms();
			for(int i=0; i < terms.size(); i++) {
				com.tetratech.caddis.model.LookupValue lk = new com.tetratech.caddis.model.LookupValue();
				lk.setCode(terms.get(i).getLabel());
				lk.setDesc(terms.get(i).getDefinition());
				lookupTerms.add(lk);
				System.out.print( terms.get(i).getLabel() + "\n");
			}
			
			System.out.print("***********************************************\n");
			return lookupTerms;

	}
	
	private static Long getSymbolValue(String trajectory){
		System.out.print("Term: " + trajectory+ "\n");
		if(trajectory.compareToIgnoreCase("Change") == 0)
			return com.tetratech.caddis.common.Constants.LL_DELTA_ID;
		else if (trajectory.compareToIgnoreCase("increase") == 0 )
			return com.tetratech.caddis.common.Constants.LL_UPWARD_ARROW_ID;
		else if (trajectory.compareToIgnoreCase("decrease") == 0 )
			return com.tetratech.caddis.common.Constants.LL_DOWNWARD_ARROW_ID;
		 return 0l;
	}
	
}
