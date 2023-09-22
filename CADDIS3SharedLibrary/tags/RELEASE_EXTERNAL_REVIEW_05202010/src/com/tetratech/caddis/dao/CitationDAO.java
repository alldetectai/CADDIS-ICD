package com.tetratech.caddis.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.naming.NamingException;

import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.common.Utility;
import com.tetratech.caddis.exception.DAOException;
import com.tetratech.caddis.model.Citation;
import com.tetratech.caddis.model.LookupValue;
import com.tetratech.caddis.model.SelectedLinkage;
import com.tetratech.caddis.model.Shape;


public class CitationDAO extends AbstractDAO {
	// singleton instance
	private static CitationDAO instance = null;

	private CitationDAO() {
	}

	public static synchronized CitationDAO getInstance() {
		if (instance != null) {
			return instance;
		}

		if (instance == null) {
			instance = new CitationDAO();
		}

		return instance;
	}


	private static final String SQL_SELECT_ALL_CITATIONS = 
		  "SELECT DISTINCT CITATION_ID, LL_PUBLICATION_ID, LL_PUBLICATION_TYPE_ID, "
		+ "AUTHOR, YEAR, TITLE, KEYWORD, IS_APPROVED, JOURNAL, VOLUME_ISSUE_PAGES, " 
		+ "BOOK, EDITORS, PUBLISHERS, REPORT_NUMBER, PAGES, SOURCE, TYPE, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM ICD_LINKAGE_CITATION_JOIN b "
		+ "					WHERE b.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_ICD, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM P_CADDIS_PAGE_CITATION_JOIN c "
		+ "					WHERE c.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_CADDIS, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM P_DATASET d "
		+ "					WHERE d.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_CADLIT "
		+ "FROM  V_ICD_CITATION_DETAILS a " 
		+ "ORDER BY AUTHOR, YEAR, TITLE ASC ";
	

	//used in New Linkage popup
	public List getAllCitations() throws DAOException {
		List citations = new ArrayList();
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {
			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_ALL_CITATIONS);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				Citation c = new Citation();
				c.setId(rs.getLong("CITATION_ID"));
				c.setPubTypeId(rs.getLong("LL_PUBLICATION_TYPE_ID"));
				c.setAuthor(rs.getString("AUTHOR"));
				c.setTitle(rs.getString("TITLE"));
				c.setDate(rs.getInt("YEAR"));
				if (rs.getString("KEYWORD") != null)
					c.setKeyword(rs.getString("KEYWORD"));

				if(rs.getString("JOURNAL") != null)
					c.setJournal(rs.getString("JOURNAL"));

				if(rs.getString("VOLUME_ISSUE_PAGES") != null)
					c.setVolumeIssuePagesInfo(rs.getString("VOLUME_ISSUE_PAGES"));

				if(rs.getString("IS_APPROVED") != null 
						&& rs.getString("IS_APPROVED").compareToIgnoreCase(Constants.NO) == 0)
					c.setApproved(false);
				else
					c.setApproved(true);
				
				if(rs.getString("IN_ICD") != null
						&& rs.getString("IN_ICD").compareToIgnoreCase(Constants.NO) == 0)
					c.setInICD(false);
				else
					c.setInICD(true);
				
				if(rs.getString("IN_CADDIS") != null
						&& rs.getString("IN_CADDIS").compareToIgnoreCase(Constants.NO) == 0)
					c.setInCADDIS(false);
				else
					c.setInCADDIS(true);
				
				if(rs.getString("IN_CADLIT") != null
						&& rs.getString("IN_CADLIT").compareToIgnoreCase(Constants.NO) == 0)
					c.setInCADLIT(false);
				else
					c.setInCADLIT(true);
				
				if(rs.getString("BOOK") != null)
					c.setBook(rs.getString("BOOK"));
				
				if(rs.getString("EDITORS") != null)
					c.setEditors(rs.getString("EDITORS"));
				
				if(rs.getString("PUBLISHERS") != null)
					c.setPublishers(rs.getString("PUBLISHERS"));
				
				if(rs.getString("REPORT_NUMBER") != null)
					c.setReportNum(rs.getString("REPORT_NUMBER"));
				
				if(rs.getString("PAGES") != null)
					c.setPages(rs.getLong("PAGES"));
				
				if(rs.getString("SOURCE") != null)
					c.setSource(rs.getString("SOURCE"));
				
				if(rs.getString("TYPE") != null)
					c.setType(rs.getString("TYPE"));
				c.setDisplayTitle(formatDisplayTitle(c, true));
				citations.add(c);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return citations;
	}

	private static final String SQL_SELECT_CITATIONS_IN_REVIEW = " SELECT CITATION_ID, LL_PUBLICATION_TYPE_ID,  AUTHOR, YEAR, "
		+ "  TITLE, KEYWORD, " 
		+ "  JOURNAL, VOLUME_ISSUE_PAGES, IS_APPROVED, " 
		+ "  BOOK, EDITORS, PUBLISHERS, REPORT_NUMBER, PAGES, SOURCE, TYPE, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM P_DATASET d "
		+ "					WHERE d.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_CADLIT "
		+ " FROM  V_ICD_CITATION_DETAILS a "
		+ " WHERE UPPER(IS_APPROVED) = 'N' "
		+ " ORDER BY AUTHOR, YEAR, TITLE ASC";

	//used for review Citation
	public List getCitationsInReview() throws DAOException {
		List citations = new ArrayList();
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {
			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_CITATIONS_IN_REVIEW);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				Citation c = new Citation();
				c.setId(rs.getLong("CITATION_ID"));
				c.setPubTypeId(rs.getLong("LL_PUBLICATION_TYPE_ID"));
				c.setAuthor(rs.getString("AUTHOR"));
				c.setTitle(rs.getString("TITLE"));
				c.setDate(rs.getInt("YEAR"));
				if (rs.getString("KEYWORD") != null)
					c.setKeyword(rs.getString("KEYWORD"));
				if(rs.getString("JOURNAL") != null)
					c.setJournal(rs.getString("JOURNAL"));
				if(rs.getString("VOLUME_ISSUE_PAGES") != null)
					c.setVolumeIssuePagesInfo(rs.getString("VOLUME_ISSUE_PAGES"));
				
				if(rs.getString("IS_APPROVED") != null 
						&& rs.getString("IS_APPROVED").compareToIgnoreCase(Constants.NO) == 0)
					c.setApproved(false);
				else
					c.setApproved(true);
				if(rs.getString("IN_CADLIT") != null
						&& rs.getString("IN_CADLIT").compareToIgnoreCase(Constants.NO) == 0)
					c.setInCADLIT(false);
				else
					c.setInCADLIT(true);
				if(rs.getString("BOOK") != null)
					c.setBook(rs.getString("BOOK"));
				
				if(rs.getString("EDITORS") != null)
					c.setEditors(rs.getString("EDITORS"));
				
				if(rs.getString("PUBLISHERS") != null)
					c.setPublishers(rs.getString("PUBLISHERS"));
				
				if(rs.getString("REPORT_NUMBER") != null)
					c.setReportNum(rs.getString("REPORT_NUMBER"));
				
				if(rs.getString("PAGES") != null)
					c.setPages(rs.getLong("PAGES"));
				
				if(rs.getString("SOURCE") != null)
					c.setSource(rs.getString("SOURCE"));
				
				if(rs.getString("TYPE") != null)
					c.setType(rs.getString("TYPE"));
				
				c.setDisplayTitle(formatDisplayTitle(c, false));
				citations.add(c);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return citations;
	}
	
	private static final String SQL_SELECT_CITATIONS_BY_IDS_FILTER = " SELECT distinct CITATION_ID, LL_PUBLICATION_TYPE_ID, AUTHOR, YEAR, \n"
		+ "  TITLE, KEYWORD, VOLUME_ISSUE_PAGES, JOURNAL \n" 
		+ "	 BOOK, EDITORS, PUBLISHERS, REPORT_NUMBER, PAGES, SOURCE, TYPE \n"
		+ " FROM  V_ICD_CITATION_WITH_FILTER \n";

	private static final String SQL_SELECT_CITATIONS_BY_IDS = " SELECT  CITATION_ID, LL_PUBLICATION_TYPE_ID, AUTHOR, YEAR, \n"
		+ "  TITLE, KEYWORD, JOURNAL, VOLUME_ISSUE_PAGES, ABSTRACT, \n" 
		+ "  BOOK, EDITORS, PUBLISHERS, REPORT_NUMBER, PAGES, SOURCE, TYPE, \n"
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM P_DATASET d "
		+ "					WHERE d.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_CADLIT "
		+ " FROM  V_ICD_CITATION_DETAILS a \n"
		+ "	WHERE CITATION_ID IN (";

	public List getCitationsByIDs(List filterList, List ids) throws DAOException {
		List citations = new ArrayList();

		if(ids == null || (ids != null && ids.size() == 0))
			return citations;

		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		StringBuffer sqlExpression = new StringBuffer();
		String sql = "";
		if (filterList != null && filterList.size() > 0) {
			sqlExpression.append(" WHERE LL_ORGANISM_ID in (");
			for (int i = 0; i < filterList.size(); i++) {
				if (i > 0)
					sqlExpression.append(", ");
				sqlExpression.append(filterList.get(i));
			}
			sqlExpression.append(")\n AND CITATION_ID IN (");
		}
		if (filterList == null || filterList.size() == 0) 
			sql = SQL_SELECT_CITATIONS_BY_IDS;
		else
			sql = SQL_SELECT_CITATIONS_BY_IDS_FILTER;

		try {
			conn = getConnection();
			for(int i = 0; i < ids.size(); i++) {
				if(i > 0)
					sqlExpression.append(", ");
				sqlExpression.append(ids.get(i));
			}
			sqlExpression.append(")");
			sql += sqlExpression.toString();
			//sql.append(sqlExpression.toString());

			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				Citation c = new Citation();
				c.setId(rs.getLong("CITATION_ID"));
				c.setPubTypeId(rs.getLong("LL_PUBLICATION_TYPE_ID"));
				c.setAuthor(rs.getString("AUTHOR"));
				c.setTitle(rs.getString("TITLE"));
				c.setDate(rs.getInt("YEAR"));
				if (rs.getString("KEYWORD") != null)
					c.setKeyword(rs.getString("KEYWORD"));
				
				if(rs.getString("JOURNAL") != null)
					c.setJournal(rs.getString("JOURNAL"));
				if(rs.getString("VOLUME_ISSUE_PAGES") != null)
					c.setVolumeIssuePagesInfo(rs.getString("VOLUME_ISSUE_PAGES"));
				
				if (filterList == null || filterList.size() == 0)  {
					if(rs.getString("ABSTRACT") != null)
						c.setCitationAbstract(rs.getString("ABSTRACT"));
				}
				if(rs.getString("IN_CADLIT") != null
						&& rs.getString("IN_CADLIT").compareToIgnoreCase(Constants.NO) == 0)
					c.setInCADLIT(false);
				else
					c.setInCADLIT(true);
				
				if(rs.getString("BOOK") != null)
					c.setBook(rs.getString("BOOK"));
				
				if(rs.getString("EDITORS") != null)
					c.setEditors(rs.getString("EDITORS"));
				
				if(rs.getString("PUBLISHERS") != null)
					c.setPublishers(rs.getString("PUBLISHERS"));
				
				if(rs.getString("REPORT_NUMBER") != null)
					c.setReportNum(rs.getString("REPORT_NUMBER"));
				
				if(rs.getString("PAGES") != null)
					c.setPages(rs.getLong("PAGES"));
				
				if(rs.getString("SOURCE") != null)
					c.setSource(rs.getString("SOURCE"));
				
				if(rs.getString("TYPE") != null)
					c.setType(rs.getString("TYPE"));
				
				c.setDisplayTitle(formatDisplayTitle(c, false));
				citations.add(c);

			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return citations;
	}

	private static final String SQL_SELECT_ALL_CITATIONS_WITH_FILTERS = " SELECT CITATION_ID, LL_PUBLICATION_TYPE_ID, AUTHOR, YEAR, "
		+ "  TITLE, KEYWORD, LL_ORGANISM_ID, "
		+ "	 VOLUME_ISSUE_PAGES,JOURNAL "
		+ "	 BOOK, EDITORS, PUBLISHERS, REPORT_NUMBER, PAGES, SOURCE, TYPE "
		+ " FROM V_ICD_CITATION_WITH_FILTER "
		+ " order by CITATION_ID ";

	public List getAllCitationsAndFilters() throws DAOException {
		List citations = new ArrayList();
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {

			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_ALL_CITATIONS_WITH_FILTERS);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				boolean found = false;
				long citationId = rs.getLong("CITATION_ID");

				long filterId = rs.getLong("LL_ORGANISM_ID");
				if(filterId != 0){
					for ( int i = 0; i < citations.size(); i++) {
						if (((Citation) citations.get(i)).getId() == citationId) {
							found = true;
							((Citation)citations.get(i)).getFilterValues().add(new Long(filterId));
						}

					}
				}
				if(!found) {
					Citation c = new Citation();
					c.setId(citationId);
					c.setPubTypeId(rs.getLong("LL_PUBLICATION_TYPE_ID"));
					c.setAuthor(rs.getString("AUTHOR"));
					c.setTitle(rs.getString("TITLE"));
					c.setDate(rs.getInt("YEAR"));
					if (rs.getString("KEYWORD") != null)
						c.setKeyword(rs.getString("KEYWORD"));
					if(rs.getString("JOURNAL") != null)
						c.setJournal(rs.getString("JOURNAL"));
					if(rs.getString("VOLUME_ISSUE_PAGES") != null)
						c.setVolumeIssuePagesInfo(rs.getString("VOLUME_ISSUE_PAGES"));
					if(rs.getString("BOOK") != null)
						c.setBook(rs.getString("BOOK"));
					
					if(rs.getString("EDITORS") != null)
						c.setEditors(rs.getString("EDITORS"));
					
					if(rs.getString("PUBLISHERS") != null)
						c.setPublishers(rs.getString("PUBLISHERS"));
					
					if(rs.getString("REPORT_NUMBER") != null)
						c.setReportNum(rs.getString("REPORT_NUMBER"));
					
					if(rs.getString("PAGES") != null)
						c.setPages(rs.getLong("PAGES"));
					
					if(rs.getString("SOURCE") != null)
						c.setSource(rs.getString("SOURCE"));
					
					if(rs.getString("TYPE") != null)
						c.setType(rs.getString("TYPE"));
					if(filterId != 0)
						c.getFilterValues().add(new Long(filterId));
					citations.add(c);
				}
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return citations;
	}

//	public List getSelectedLinkages(List shapes) {
//		return null;
//	}

	private static final String SQL_SELECT_CITATION_BY_ID =
	"SELECT p.*, vpt.LIST_ITEM_CODE as PUBLICATION_TYPE_CODE, vpt.LIST_ITEM_DESCRIPTION as PUBLICATION_TYPE_DESC, " +
	"vp.LIST_ITEM_CODE as PUBLICATION_CODE, vp.LIST_ITEM_DESCRIPTION as PUBLICATION_DESC " + 
	"FROM P_CITATION p, V_PUBLICATION vp, V_PUBLICATION_TYPE vpt " +
	"WHERE p.LL_PUBLICATION_TYPE_ID = vpt.LL_ID " +
	"AND p.LL_PUBLICATION_ID = vp.LL_ID(+) " +
	"AND p.CITATION_ID = ? "; 

	public Citation getCitationByID(long id) throws DAOException
	{
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Citation c = null;
		long pubTypeId = -1;
		try {
			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_CITATION_BY_ID);
			pstmt.setLong(1, id);
			rs = pstmt.executeQuery();
			if(rs.next())
			{
				c = new Citation();
				pubTypeId = rs.getLong("LL_PUBLICATION_TYPE_ID");
				c.setPubTypeId(pubTypeId);
				c.setPubTypeCode(rs.getString("PUBLICATION_TYPE_CODE"));
				c.setPubTypeDesc(rs.getString("PUBLICATION_TYPE_DESC"));
				c.setId(rs.getLong("CITATION_ID"));
				c.setAuthor(rs.getString("AUTHOR"));
				c.setTitle(rs.getString("TITLE"));
				c.setYear(rs.getLong("YEAR"));
				c.setKeyword(rs.getString("KEYWORD"));
				c.setCitationAbstract(rs.getString("ABSTRACT"));
				c.setDoi(rs.getString("DOI"));
				c.setApproved(false);
				if(rs.getString("IS_APPROVED")!=null 
				&& rs.getString("IS_APPROVED").equalsIgnoreCase(Constants.YES))
					c.setApproved(true);
				if(pubTypeId == Constants.PUBLICATION_TYPE_ID_JOUNRAL_ARTICLE){
					c.setPubId(rs.getLong("LL_PUBLICATION_ID"));
					c.setPubCode(rs.getString("PUBLICATION_CODE"));
					c.setPubDesc(rs.getString("PUBLICATION_DESC"));
					c.setVolume(rs.getLong("VOLUME"));
					c.setIssue(rs.getString("ISSUE"));
					c.setStartPage(rs.getLong("START_PAGE"));
					c.setEndPage(rs.getLong("END_PAGE"));
				}else if(pubTypeId == Constants.PUBLICATION_TYPE_ID_BOOK_CHAPTER){
					c.setBook(rs.getString("BOOK"));
					c.setEditors(rs.getString("EDITORs"));
					c.setPublishers(rs.getString("PUBLISHERS"));
					c.setStartPage(rs.getLong("START_PAGE"));
					c.setEndPage(rs.getLong("END_PAGE"));
				}else if(pubTypeId == Constants.PUBLICATION_TYPE_ID_BOOK){
					c.setEditors(rs.getString("EDITORs"));
					c.setPublishers(rs.getString("PUBLISHERS"));
					c.setPages(rs.getLong("PAGES"));
				}else if(pubTypeId == Constants.PUBLICATION_TYPE_ID_REPORT){
					c.setPublishers(rs.getString("PUBLISHERS"));
					c.setReportNum(rs.getString("REPORT_NUMBER"));
					c.setPages(rs.getLong("PAGES"));
				}else if(pubTypeId == Constants.PUBLICATION_TYPE_ID_OTHER){
					c.setSource(rs.getString("SOURCE"));
					c.setType(rs.getString("TYPE"));
					c.setPages(rs.getLong("PAGES"));
				}
				
			}
			

		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return c;
	}

	private static final String SQL_DELETE_CITATION = "{ ? = call  CADDIS_PG.FN_DELETE_CITATION (?) } ";
	
	public boolean deleteCitation(long id) throws DAOException {

		if (id <= 0) {
			throw new DAOException(
			"Delete Citation Failed: Invalid Citation Id");
		}
		Connection conn = null;
		CallableStatement cs = null;
		String result = null;
		boolean success = false;
		try {
			conn = getConnection();
			cs = conn.prepareCall(SQL_DELETE_CITATION);
            cs.registerOutParameter(1,Types.VARCHAR);
            cs.setLong(2,id);
            cs.execute();
            result = cs.getString(1);
            System.out.println("deleteCitation()====> id: " + id + " result: " + result);
            if(result.equalsIgnoreCase(Constants.DELETE_CITATION_SUCCESS))
            	success = true;
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			try {
				conn.rollback();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			closeResources(conn, cs);
		}
		return success;
	}

	private static final String SQL_INSERT_CITATION = "INSERT INTO P_CITATION ( "
		+ "	CITATION_ID, AUTHOR, YEAR, TITLE, KEYWORD, CREATE_DATE, CREATE_USER, "
		+ "	 ABSTRACT,  IS_APPROVED) "
		+ " VALUES ( ?,  "
		+ " 	?, ?, ?, ?, "
		+ " 	SYSDATE, ?, ?)";

	private static final String SQL_INSERT_CITATION_FILTER_JOIN = "INSERT INTO ICD_CITATION_FILTER_JOIN ("
		+ "   CITATION_FILTER_JOIN_ID, CITATION_ID, LL_ORGANISM_ID) "
		+ "VALUES ( S_ICD_CITATION_FILTER_JOIN_ID.nextVal, ?, ?)";

	
	public long saveCitation(Citation citation) throws DAOException {
		long id = 0;
		Connection conn = null;
		PreparedStatement pstmt = null;
		try {
			id = this.getSequenceId("SEQ_CITATION_ID");
			if (id == 0) {
				throw new DAOException(
				"Insert Citation Failed: Invalid Citation Id");
			}
			conn = getConnection();
			conn.setAutoCommit(false);
			pstmt = conn.prepareStatement(SQL_INSERT_CITATION);

			pstmt.setLong(1, id);
			pstmt.setString(2, citation.getAuthor());
			pstmt.setInt(3, citation.getDate());
			pstmt.setString(4, citation.getTitle());

			if(citation.getKeyword() != null)
				pstmt.setString(5, citation.getKeyword());
			else
				pstmt.setNull(5, Types.VARCHAR);

			pstmt.setLong(6, citation.getCreatedBy());
			if(citation.getCitationAbstract() != null)
				pstmt.setString(7, citation.getCitationAbstract());
			else
				pstmt.setNull(7, Types.VARCHAR);

			if(citation.isApproved())
				pstmt.setString(8, Constants.YES);
			else
				pstmt.setString(8, Constants.NO);
			
			if (pstmt.executeUpdate() != 1)
				throw new DAOException("Insert Citation Failed");
			closeResources(pstmt);

			pstmt = conn.prepareStatement(SQL_INSERT_CITATION_FILTER_JOIN);
			for (Iterator l = citation.getFilterValues().iterator(); l.hasNext(); ) {
				long value = 0;
				Object o = l.next();
				if(o instanceof Long)
					value = ((Long) o).longValue();
				else if(o instanceof Integer)
					value = ((Integer)o).longValue();
				pstmt.setLong(1, id);
				pstmt.setLong(2, value);
				pstmt.addBatch();
			}
			pstmt.executeBatch();

			conn.commit();
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			try {
				conn.rollback();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			closeResources(conn, pstmt);
		}
		return id;
	}


	public void saveCitations(List citations) throws DAOException {
		long id = 0;
		Connection conn = null;
		PreparedStatement pstmt = null;
		try {

			conn = getConnection();
			conn.setAutoCommit(false);
			
			for(int i=0;i<citations.size();i++){

				Citation citation = (Citation)citations.get(i);	

				id = this.getSequenceId("SEQ_CITATION_ID");
				if (id == 0) {
					throw new DAOException(
					"Insert Citation Failed: Invalid Citation Id");
				}

				pstmt = conn.prepareStatement(SQL_INSERT_CITATION);
				pstmt.setLong(1, id);
				pstmt.setString(2, citation.getAuthor());
				pstmt.setInt(3, citation.getDate());
				pstmt.setString(4, citation.getTitle());

				if(citation.getKeyword() != null)
					pstmt.setString(5, citation.getKeyword());
				else
					pstmt.setNull(5, Types.VARCHAR);

				pstmt.setLong(6, citation.getCreatedBy());
				
				if(citation.getCitationAbstract() != null)
					pstmt.setString(7, citation.getCitationAbstract());
				else
					pstmt.setNull(7, Types.VARCHAR);

				
				if(citation.isApproved())
					pstmt.setString(8, Constants.YES);
				else
					pstmt.setString(8, Constants.NO);
				if (pstmt.executeUpdate() != 1)
					throw new DAOException("Insert Citation Failed");
				closeResources(pstmt);

				pstmt = conn.prepareStatement(SQL_INSERT_CITATION_FILTER_JOIN);
				for (Iterator l = citation.getFilterValues().iterator(); l.hasNext(); ) {
					long value = 0;
					Object o = l.next();
					if(o instanceof Long)
						value = ((Long) o).longValue();
					else if(o instanceof Integer)
						value = ((Integer)o).longValue();
					pstmt.setLong(1, id);
					pstmt.setLong(2, value);
					pstmt.addBatch();
				}
				pstmt.executeBatch();
				closeResources(pstmt);
			}

			conn.commit();
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			try {
				conn.rollback();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			closeResources(conn, pstmt);
		}
	}

	private static final String SQL_UPDATE_APPROVE_CITATION = "UPDATE P_CITATION  "
		+ "	SET  IS_APPROVED = 'Y' "
		+ "WHERE CITATION_ID = ? ";
	
	public void approveCitations(List citationIds) throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;
		try {

			conn = getConnection();
			conn.setAutoCommit(false);
			pstmt = conn.prepareStatement(SQL_UPDATE_APPROVE_CITATION);
			for (int i = 0; i < citationIds.size(); i++) {
				pstmt.setInt(1, ((Integer)citationIds.get(i)).intValue());
				pstmt.addBatch();
			}
			pstmt.executeBatch();
			conn.commit();
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			try {
				conn.rollback();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			closeResources(conn, pstmt);
		}
	}


	private String formatDisplayTitle(Citation c, boolean includeNewTag) {

		String flag = includeNewTag && !c.isApproved() ?"(NEW) " : "";
		String displayTitle ="";
		if(c.getPubTypeId() == Constants.PUBLICATION_TYPE_ID_JOUNRAL_ARTICLE) {
			displayTitle = flag 
			+ c.getAuthor() + " (" + c.getDate() + ") " 
			+  c.getTitle() + (c.getTitle().endsWith(".") ? "" : ".")
			+ (c.getJournal() != null ? " " + c.getJournal() : "") 
			+ (Utility.IsNullOrEmpty(c.getVolumeIssuePagesInfo()) ?  "" : (" " + c.getVolumeIssuePagesInfo()))
			+ (!Utility.IsNullOrEmpty(c.getVolumeIssuePagesInfo()) && !c.getVolumeIssuePagesInfo().endsWith(".") ? "." : "");
		} else if(c.getPubTypeId() == Constants.PUBLICATION_TYPE_ID_BOOK_CHAPTER) {
			displayTitle = flag 
			+ c.getAuthor() + " (" + c.getDate() + ") " 
			+  c.getTitle() + (c.getTitle().endsWith(".") ? "" : ".")
			+ (c.getStartPage() == 0 ?  "" : (" Pp. " + c.getStartPage()))
			+ (c.getEndPage() == 0 ?  "" : (" - " + c.getEndPage()))
			//+ (Utility.IsNullOrEmpty(c.getVolumeIssuePagesInfo()) ?  "" : (" Pp. " + c.getVolumeIssuePagesInfo()))
			+ (Utility.IsNullOrEmpty(c.getEditors()) ?  "" : (" in: " + c.getEditors() + " (Eds).") )
			+ (Utility.IsNullOrEmpty(c.getBook()) ?  "" : (" " + c.getBook()))
			+ (!Utility.IsNullOrEmpty(c.getBook()) && !c.getBook().endsWith(".") ? "." : "")
			+ (Utility.IsNullOrEmpty(c.getPublishers()) ?  "" : (" " + c.getPublishers()))
			+ (!Utility.IsNullOrEmpty(c.getPublishers()) && !c.getPublishers().endsWith(".") ? "." : "");
		} else if(c.getPubTypeId() == Constants.PUBLICATION_TYPE_ID_BOOK) {
			displayTitle = flag 
			+ c.getAuthor() + " (" + c.getDate() + ") " 
			+  c.getTitle() + (c.getTitle().endsWith(".") ? "" : ".")
			+ (Utility.IsNullOrEmpty(c.getPublishers()) ?  "" : (" " + c.getPublishers()))
			+ (!Utility.IsNullOrEmpty(c.getPublishers()) && !c.getPublishers().endsWith(".") ? "." : "")
			+ (c.getPages() == 0 ?  "" : (" " + c.getPages()+ " pp."));
		} else if(c.getPubTypeId() == Constants.PUBLICATION_TYPE_ID_REPORT) {
			displayTitle = flag 
			+ c.getAuthor() + " (" + c.getDate() + ") " 
			+  c.getTitle() + (c.getTitle().endsWith(".") ? "" : ".")
			+ (Utility.IsNullOrEmpty(c.getPublishers()) ?  "" : (" " + c.getPublishers()))
			+ (!Utility.IsNullOrEmpty(c.getPublishers()) && !c.getPublishers().endsWith(".") ? "." : "")
			+ (Utility.IsNullOrEmpty(c.getReportNum()) ?  "" : (" " + c.getReportNum()))
			+ (!Utility.IsNullOrEmpty(c.getReportNum()) && !c.getReportNum().endsWith(".") ? "." : "")
			+ (c.getPages() == 0 ?  "" : (" " + c.getPages()+ " pp."));
		}
		else if(c.getPubTypeId() == Constants.PUBLICATION_TYPE_ID_OTHER) {
			displayTitle = flag 
			+ c.getAuthor() + " (" + c.getDate() + ") " 
			+  c.getTitle() + (c.getTitle().endsWith(".") ? "" : ".")
			+ (Utility.IsNullOrEmpty(c.getType()) ?  "" : (" " + c.getType()));
		}
		//			+ (c.isCadlitSource() ? " <b>(Cadlit)</b>" : "")
		//			+ (c.getCitationUrl() != null ? ("\n<a href='" + c.getCitationUrl() + "' target=\"_blank\"><font color=\"#0000FF\">URL  " + c.getCitationUrl()+"</font></a>") : "")); 
		return displayTitle;
	}

	private final String SQL_SEARCH_CITATIONS_SHAPES = " SELECT DISTINCT CITATION_ID, LL_PUBLICATION_TYPE_ID, AUTHOR, YEAR, "
		+ "  TITLE, KEYWORD, JOURNAL, VOLUME_ISSUE_PAGES, IS_APPROVED, " 
		+ "	 BOOK, EDITORS, PUBLISHERS, REPORT_NUMBER, PAGES, SOURCE, TYPE, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM P_DATASET d "
		+ "					WHERE d.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_CADLIT "
		+ " FROM  V_ICD_CITATION_WITH_FILTER a " ;


	public List searchCitationsNShapes(List filterList, String searchTerm)
	throws DAOException {

		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		ArrayList citations = new ArrayList();

		String[] searchTerms = Utility.getEachKeyword(searchTerm);
		StringBuffer sqlExpression = new StringBuffer();
		String sql = SQL_SEARCH_CITATIONS_SHAPES;
		if (filterList != null && filterList.size() > 0) {
			sqlExpression.append(" WHERE LL_ORGANISM_ID in (");
			for (int i = 0; i < filterList.size(); i++) {
				if (i > 0)
					sqlExpression.append(", ");
				sqlExpression.append(filterList.get(i));
			}
			sqlExpression.append(") ");
		}

		if (searchTerms.length == 1) {
			if(searchTerms[0].trim().length() != 0) {
				String term = searchTerms[0].toUpperCase();
				if (sqlExpression.length() > 0)
					sqlExpression.append(" AND ");
				else
					sqlExpression.append(" WHERE ");
				sqlExpression.append(" ( UPPER(AUTHOR) LIKE '%" + term + "%' "
						+ " OR UPPER(TITLE) LIKE '%" + term + "%' "
						+ " OR UPPER(KEYWORD) LIKE  '%" + term + "%'"
						+ " OR UPPER(ABSTRACT)  LIKE  '%" + term + "%'"
						+ " OR UPPER(SHAPES_NAME)  LIKE  '%" + term + "%'"
						+ " OR YEAR LIKE '%" + term + "%')");
			}
		} else if (searchTerms.length > 1) {
			if (sqlExpression.length() > 0)
				sqlExpression.append(" AND ");
			else
				sqlExpression.append(" WHERE ");
			sqlExpression.append("(( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "AUTHOR", " AND "));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "TITLE", " AND "));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "KEYWORD",	" AND "));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "ABSTRACT", " AND"));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "SHAPES_NAME", " AND"));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "YEAR", " AND "));
			sqlExpression.append(" ))");
		}

		try {
			conn = getConnection();

			if (sqlExpression.length() > 0)
				sql += sqlExpression.toString();
			sql += " ORDER BY AUTHOR, YEAR, TITLE ASC ";
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				Citation c = new Citation();
				c.setId(rs.getLong("CITATION_ID"));
				c.setPubTypeId(rs.getLong("LL_PUBLICATION_TYPE_ID"));
				c.setAuthor(rs.getString("AUTHOR"));
				c.setTitle(rs.getString("TITLE"));
				c.setDate(rs.getInt("YEAR"));
				if (rs.getString("KEYWORD") != null)
					c.setKeyword(rs.getString("KEYWORD"));
				if(rs.getString("JOURNAL") != null)
					c.setJournal(rs.getString("JOURNAL"));
				
				if(rs.getString("IS_APPROVED") != null 
						&& rs.getString("IS_APPROVED").compareToIgnoreCase(Constants.NO) == 0)
					c.setApproved(false);
				else
					c.setApproved(true);
				
				if(rs.getString("VOLUME_ISSUE_PAGES") != null)
					c.setVolumeIssuePagesInfo(rs.getString("VOLUME_ISSUE_PAGES"));
				if(rs.getString("IN_CADLIT") != null
						&& rs.getString("IN_CADLIT").compareToIgnoreCase(Constants.NO) == 0)
					c.setInCADLIT(false);
				else
					c.setInCADLIT(true);
				
				if(rs.getString("BOOK") != null)
					c.setBook(rs.getString("BOOK"));
				
				if(rs.getString("EDITORS") != null)
					c.setEditors(rs.getString("EDITORS"));
				
				if(rs.getString("PUBLISHERS") != null)
					c.setPublishers(rs.getString("PUBLISHERS"));
				
				if(rs.getString("REPORT_NUMBER") != null)
					c.setReportNum(rs.getString("REPORT_NUMBER"));
				
				if(rs.getString("PAGES") != null)
					c.setPages(rs.getLong("PAGES"));
				
				if(rs.getString("SOURCE") != null)
					c.setSource(rs.getString("SOURCE"));
				
				if(rs.getString("TYPE") != null)
					c.setType(rs.getString("TYPE"));
				
				c.setDisplayTitle(formatDisplayTitle(c, false));
				citations.add(c);
			}

		} 
		catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} 
		finally {
			closeResources(conn, pstmt, rs);
		}

		return citations;
	}

	private final String SQL_SEARCH_CITATIONS = 
		  "SELECT CITATION_ID, LL_PUBLICATION_TYPE_ID, AUTHOR, YEAR, "
		+ "TITLE, KEYWORD, JOURNAL, VOLUME_ISSUE_PAGES, IS_APPROVED, " 
		+ "	 BOOK, EDITORS, PUBLISHERS, REPORT_NUMBER, PAGES, SOURCE, TYPE, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM ICD_LINKAGE_CITATION_JOIN b "
		+ "					WHERE b.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_ICD, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM P_CADDIS_PAGE_CITATION_JOIN c "
		+ "					WHERE c.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_CADDIS, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM P_DATASET d "
		+ "					WHERE d.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_CADLIT "
		+ "FROM  V_ICD_CITATION_DETAILS a ";

	public List searchCitations(String searchTerm) throws DAOException {

		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		ArrayList citations = new ArrayList();

		String[] searchTerms = Utility.getEachKeyword(searchTerm);
		StringBuffer sqlExpression = new StringBuffer();
		String sql = SQL_SEARCH_CITATIONS;

		if (searchTerms.length == 1) {
			if(searchTerms[0].trim().length() != 0) {
				String term = searchTerms[0].toUpperCase();
				sqlExpression.append(" WHERE ");
				sqlExpression.append(" ( UPPER(AUTHOR) LIKE '%" + term + "%' "
						+ " OR UPPER(TITLE) LIKE '%" + term + "%' "
						+ " OR UPPER(KEYWORD) LIKE  '%" + term + "%'"
						+ " OR UPPER(ABSTRACT)  LIKE  '%" + term + "%'"
						+ " OR YEAR LIKE '%" + term + "%')");
			}
		} else if (searchTerms.length > 1) {
			sqlExpression.append(" WHERE ");
			sqlExpression.append("(( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "AUTHOR", " AND "));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "TITLE", " AND "));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "KEYWORD",	" AND "));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "ABSTRACT", " AND"));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "YEAR", " AND "));
			sqlExpression.append(" ))");
		}

		try {
			conn = getConnection();

			if (sqlExpression.length() > 0)
				sql += sqlExpression.toString();
			sql += " ORDER BY AUTHOR, YEAR, TITLE ASC ";
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				Citation c = new Citation();
				c.setId(rs.getLong("CITATION_ID"));
				c.setPubTypeId(rs.getLong("LL_PUBLICATION_TYPE_ID"));
				c.setAuthor(rs.getString("AUTHOR"));
				c.setTitle(rs.getString("TITLE"));
				c.setDate(rs.getInt("YEAR"));
				if (rs.getString("KEYWORD") != null)
					c.setKeyword(rs.getString("KEYWORD"));
				if(rs.getString("JOURNAL") != null)
					c.setJournal(rs.getString("JOURNAL"));
				if(rs.getString("VOLUME_ISSUE_PAGES") != null)
					c.setVolumeIssuePagesInfo(rs.getString("VOLUME_ISSUE_PAGES"));
				
				if(rs.getString("IS_APPROVED") != null 
						&& rs.getString("IS_APPROVED").compareToIgnoreCase(Constants.NO) == 0)
					c.setApproved(false);
				else
					c.setApproved(true);
				if(rs.getString("BOOK") != null)
					c.setBook(rs.getString("BOOK"));
				
				if(rs.getString("EDITORS") != null)
					c.setEditors(rs.getString("EDITORS"));
				
				if(rs.getString("PUBLISHERS") != null)
					c.setPublishers(rs.getString("PUBLISHERS"));
				
				if(rs.getString("REPORT_NUMBER") != null)
					c.setReportNum(rs.getString("REPORT_NUMBER"));
				
				if(rs.getString("PAGES") != null)
					c.setPages(rs.getLong("PAGES"));
				
				if(rs.getString("SOURCE") != null)
					c.setSource(rs.getString("SOURCE"));
				
				if(rs.getString("TYPE") != null)
					c.setType(rs.getString("TYPE"));

				if(rs.getString("IN_ICD") != null
						&& rs.getString("IN_ICD").compareToIgnoreCase(Constants.NO) == 0)
					c.setInICD(false);
				else
					c.setInICD(true);
				
				if(rs.getString("IN_CADDIS") != null
						&& rs.getString("IN_CADDIS").compareToIgnoreCase(Constants.NO) == 0)
					c.setInCADDIS(false);
				else
					c.setInCADDIS(true);
				
				if(rs.getString("IN_CADLIT") != null
						&& rs.getString("IN_CADLIT").compareToIgnoreCase(Constants.NO) == 0)
					c.setInCADLIT(false);
				else
					c.setInCADLIT(true);
				
				c.setDisplayTitle(formatDisplayTitle(c, true));
				citations.add(c);
			}

		} 
		catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} 
		finally {
			closeResources(conn, pstmt, rs);
		}

		return citations;
	}


	private final String SQL_SELECT_DIAGRAMNAMES_BY_CITATION_ID = "SELECT DISTINCT	DIAGRAM_NAME "
		+ "	FROM V_ICD_SHAPE_LINKAGES "
		+ "	WHERE CITATION_ID = ? "
		+ " AND LL_DIAGRAM_STATUS_ID = ? "
		+ "	ORDER BY UPPER(DIAGRAM_NAME) ";
	
	public List getDiagramNamesByCitationId(long citationId) throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List diagramNames =  new ArrayList();
		try {
			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_DIAGRAMNAMES_BY_CITATION_ID);
			
			pstmt.setLong(1, citationId);
			pstmt.setLong(2, Constants.LL_PUBLISHED_STATUS);

			rs = pstmt.executeQuery();
			while (rs.next()) {
				String diagramName = rs.getString("DIAGRAM_NAME");
				diagramNames.add(diagramName);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return diagramNames;
	}
	
	private final String SQL_SELECT_DNAMES_BY_CIT_ID_USER = "SELECT DISTINCT DIAGRAM_NAME "
		+ "	FROM V_ICD_DIAGRAM_LINAKGES_USERS "
		+ "	WHERE CITATION_ID = ? "
		+ " AND (LL_DIAGRAM_STATUS_ID = ? or IS_PUBLIC = 'Y' or USER_ID = ? or CREATED_BY = ?)"
		+ "	ORDER BY UPPER(DIAGRAM_NAME) ";
	
	//just diagram names 
	public List getDiagramNamesByCitationIdNUser(long citationId, long userId) throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List diagramNames =  new ArrayList();
		try {
			conn = getConnection();
			
			pstmt = conn.prepareStatement(SQL_SELECT_DNAMES_BY_CIT_ID_USER);
				
			pstmt.setLong(1, citationId);
			pstmt.setLong(2, Constants.LL_PUBLISHED_STATUS);
			pstmt.setLong(3, userId);
			pstmt.setLong(4, userId);
			
			rs = pstmt.executeQuery();
			while (rs.next()) {
				String diagramName = rs.getString("DIAGRAM_NAME");
				diagramNames.add(diagramName);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return diagramNames;
	}
	
	
	private final String SQL_SELECT_LINKAGES_BY_CIT_ID_AND_DIAG_ID = "SELECT 	DIAGRAM_NAME, "
		+ "	SHAPE_FROM_BIN_INDEX, SHAPE_FROM_LABEL, SHAPE_FROM_LABEL_SYMBOL,"
		+ " SHAPE_ID_FROM, SHAPE_TO_LABEL, SHAPE_TO_LABEL_SYMBOL, SHAPE_ID_TO, SHAPE_LINKAGE_ID, CITATION_ID " 
		+ "	FROM V_ICD_SHAPE_LINKAGES "
		+ "	WHERE CITATION_ID = ? "
		+ "	AND DIAGRAM_ID = ? "
		+ "	ORDER BY DIAGRAM_NAME, SHAPE_FROM_BIN_INDEX, SHAPE_ID_FROM ";
	

	//get linkages by diagram id and citationID
	public List getLinakgesByCitationIdNDiagramId(long citationId, long diagramId) throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Set shapeSet = new HashSet();
		List linkages =  new ArrayList();
		try {
			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_LINKAGES_BY_CIT_ID_AND_DIAG_ID );
			
			pstmt.setLong(1, citationId);
			pstmt.setLong(2, diagramId);
			

			rs = pstmt.executeQuery();
			while (rs.next()) {
				String diagramName = rs.getString("DIAGRAM_NAME");
				String fromLabel = rs.getString("SHAPE_FROM_LABEL");
				String toLabel = rs.getString("SHAPE_TO_LABEL");
				Long shapeFromId = new Long(rs.getLong("SHAPE_ID_FROM"));
				Long shapeToId = new Long(rs.getLong("SHAPE_ID_TO"));
				Long fromLabelSymbolType = new Long(rs.getLong("SHAPE_FROM_LABEL_SYMBOL"));
				Long toLabelSymbolType = new Long(rs.getLong("SHAPE_TO_LABEL_SYMBOL"));
				
				Shape shape1 = new Shape();
				shape1.setLabel(fromLabel);
				shape1.setLabelSymbolType(fromLabelSymbolType);
				Shape shape2 = new Shape();
				shape2.setLabel(toLabel);
				shape2.setLabelSymbolType(toLabelSymbolType);
				
				if (!shapeSet.contains(shapeToId)) {
					shapeSet.add(shapeFromId);
					SelectedLinkage l = new SelectedLinkage();
					l.setDiagramName(diagramName);
					l.setShape1(shape1);
					l.setShape2(shape2);
					l.setLabel(fromLabel + " And " + toLabel);
					linkages.add(l);
				}
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return linkages;
	}
	
	private final String SQL_SELECT_LINKAGES_BY_CITATIONS_ID = "SELECT 	DIAGRAM_NAME, "
		+ "	SHAPE_FROM_BIN_INDEX, SHAPE_FROM_LABEL, SHAPE_FROM_LABEL_SYMBOL,"
		+ " SHAPE_ID_FROM, SHAPE_TO_LABEL, SHAPE_TO_LABEL_SYMBOL, SHAPE_ID_TO, SHAPE_LINKAGE_ID, CITATION_ID " 
		+ "	FROM V_ICD_SHAPE_LINKAGES "
		+ "	WHERE CITATION_ID = ? "
		+ "	ORDER BY DIAGRAM_NAME, SHAPE_FROM_BIN_INDEX, SHAPE_ID_FROM ";

	public List getLinakgesByCitationID(long citationId) throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Set shapeSet = new HashSet();
		List linkages =  new ArrayList();
		try {
			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_LINKAGES_BY_CITATIONS_ID);
			
			pstmt.setLong(1, citationId);

			rs = pstmt.executeQuery();
			while (rs.next()) {
				String diagramName = rs.getString("DIAGRAM_NAME");
				String fromLabel = rs.getString("SHAPE_FROM_LABEL");
				String toLabel = rs.getString("SHAPE_TO_LABEL");
				Long shapeFromId = new Long(rs.getLong("SHAPE_ID_FROM"));
				Long shapeToId = new Long(rs.getLong("SHAPE_ID_TO"));
				Long fromLabelSymbolType = new Long(rs.getLong("SHAPE_FROM_LABEL_SYMBOL"));
				Long toLabelSymbolType = new Long(rs.getLong("SHAPE_TO_LABEL_SYMBOL"));
				
				Shape shape1 = new Shape();
				shape1.setLabel(fromLabel);
				shape1.setLabelSymbolType(fromLabelSymbolType);
				Shape shape2 = new Shape();
				shape2.setLabel(toLabel);
				shape2.setLabelSymbolType(toLabelSymbolType);
				
				if (!shapeSet.contains(shapeToId)) {
					shapeSet.add(shapeFromId);
					SelectedLinkage l = new SelectedLinkage();
					l.setDiagramName(diagramName);
					l.setShape1(shape1);
					l.setShape2(shape2);
					l.setLabel(fromLabel + " And " + toLabel);
					linkages.add(l);
				}
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return linkages;
	}
	
	private static final String SQL_GET_ALL_CITATION_AUTHOR = 
		"SELECT DISTINCT AUTHOR FROM P_CITATION ORDER BY UPPER(AUTHOR)";

	/**
	 * This method gets all the citation authors
	 * @return
	 * @throws DAOException
	 */
	public List getAllAuthors() throws DAOException
	{
		List list = new ArrayList();
		Connection conn = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			conn = getConnection();
			ps = conn.prepareStatement(SQL_GET_ALL_CITATION_AUTHOR);
			rs = ps.executeQuery();
			while(rs.next())
			{
				list.add(rs.getString(1));
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, ps, rs);
		}
		return list;
	}
	
	private static final String SQL_GET_ALL_CITATION_TITLE = 
		"SELECT DISTINCT TITLE FROM P_CITATION ORDER BY UPPER(TITLE)";
	
	/**
	 * This method gets all the citation titles
	 * @return list
	 * @throws DAOException
	 */
	public List getAllTitles() throws DAOException
	{
		List list = new ArrayList();
		Connection conn = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			conn = getConnection();
			ps = conn.prepareStatement(SQL_GET_ALL_CITATION_TITLE);
			rs = ps.executeQuery();
			while(rs.next())
			{
				list.add(rs.getString(1));
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, ps, rs);
		}
		return list;
	}
	
	
	private static final String SQL_INSERT_NEW_CITATION = 
		"INSERT INTO P_CITATION (CITATION_ID, LL_PUBLICATION_ID, LL_PUBLICATION_TYPE_ID, " +
		"AUTHOR, YEAR, TITLE, KEYWORD, ABSTRACT, IS_APPROVED, DOI, VOLUME, ISSUE, " +
		"START_PAGE, END_PAGE, BOOK, EDITORS, PUBLISHERS, REPORT_NUMBER, PAGES, SOURCE, " +
		"TYPE, CREATE_DATE, CREATE_USER) " +
		"VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATE, ?)";
	
	
	/**
	 * This method inserts a new citation and returns the primary key
	 * @param c
	 * @return cId
	 * @throws DAOException
	 */
	public long insertCitation(Citation c)throws DAOException
	{
		long cId = -1;
		Connection conn = null;
		PreparedStatement ps = null;
		
		try{
			cId = this.getSequenceId("SEQ_CITATION_ID");
			if (cId <= 0)
				throw new DAOException("Insert Citation Failed: Invalid Citation Id");
			conn = getConnection();
			ps = conn.prepareStatement(SQL_INSERT_NEW_CITATION);
			ps.setLong(1, cId);
			ps.setNull(2, Types.NUMERIC);
			if(c.getPubId()>0)
				ps.setLong(2, c.getPubId());
			ps.setLong(3, c.getPubTypeId());
			ps.setString(4, c.getAuthor());
			ps.setLong(5, c.getYear());
			ps.setString(6, c.getTitle());
			ps.setString(7, c.getKeyword());
			ps.setString(8, c.getCitationAbstract());
			if(c.isApproved())
				ps.setString(9, Constants.YES);
			else
				ps.setString(9, Constants.NO);
			ps.setString(10, c.getDoi());
			ps.setNull(11, Types.NUMERIC);
			if(c.getVolume()>0)
				ps.setLong(11, c.getVolume());
			ps.setString(12, c.getIssue());
			ps.setNull(13, Types.NUMERIC);
			if(c.getStartPage()>0)
				ps.setLong(13, c.getStartPage());
			ps.setNull(14, Types.NUMERIC);
			if(c.getEndPage()>0)
				ps.setLong(14, c.getEndPage());
			ps.setString(15, c.getBook());
			ps.setString(16, c.getEditors());
			ps.setString(17, c.getPublishers());
			ps.setString(18, c.getReportNum());
			ps.setNull(19, Types.NUMERIC);
			if(c.getPages()>0)
				ps.setLong(19, c.getPages());
			ps.setString(20, c.getSource());
			ps.setString(21, c.getType());
			ps.setLong(22, c.getCreatedBy());
			if (ps.executeUpdate() != 1)
				throw new DAOException("Method insertCitation() failed!");
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, ps);
		}
		return cId;
	}
	
	private static final String SQL_APPROVE_CITATION = 
		"UPDATE P_CITATION SET IS_APPROVED = ?, UPDATE_DATE = SYSDATE, " +
		"UPDATE_USER = ? WHERE CITATION_ID = ?";
	
	/**
	 * This method updates the approved flag of one single citation.
	 * @param citationId
	 * @param userId
	 * @throws DAOException
	 */
	public void approveCitation(long citationId, long userId) throws DAOException{
		Connection conn = null;
		PreparedStatement ps = null;
		try {
			conn = getConnection();
			ps = conn.prepareStatement(SQL_APPROVE_CITATION);
			ps.setString(1, Constants.YES);
			ps.setLong(2, userId);
			ps.setLong(3, citationId);
			if (ps.executeUpdate() != 1)
				throw new DAOException("Failed to approve a citation with Id: " + citationId);
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			try {
				conn.rollback();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			closeResources(conn, ps);
		}
	}
	
	
	private static final String SQL_UPDATE_CITATION = 
		"UPDATE P_CITATION SET LL_PUBLICATION_ID = ?, LL_PUBLICATION_TYPE_ID = ?,  " +
		"AUTHOR = ?, YEAR = ?, TITLE = ?, KEYWORD = ?, UPDATE_DATE = SYSDATE, UPDATE_USER = ?, ABSTRACT = ?, " +
		"IS_APPROVED = ?, DOI = ?, VOLUME = ?, ISSUE = ?, START_PAGE = ?, END_PAGE = ?,  " +
		"BOOK = ?, EDITORS = ?, PUBLISHERS = ?, REPORT_NUMBER = ?, PAGES = ?, SOURCE = ?, TYPE = ?  " +
		"WHERE CITATION_ID = ?";

	public long updateCitation(Citation c) throws DAOException{
		Connection conn = null;
		PreparedStatement ps = null;
		try{
			conn = getConnection();
			ps = conn.prepareStatement(SQL_UPDATE_CITATION);
			ps.setNull(1, Types.NUMERIC);
			if(c.getPubId()>0)
				ps.setLong(1, c.getPubId());
			ps.setLong(2, c.getPubTypeId());
			ps.setString(3,c.getAuthor());
			ps.setLong(4, c.getYear());
			ps.setString(5, c.getTitle());
			ps.setString(6, c.getKeyword());
			ps.setLong(7, c.getLastUpdateBy());
			ps.setString(8, c.getCitationAbstract());
			if(c.isApproved())
				ps.setString(9, Constants.YES);
			else
				ps.setString(9, Constants.NO);
			ps.setString(10, c.getDoi());
			ps.setNull(11, Types.NUMERIC);
			if(c.getVolume()>0)
				ps.setLong(11, c.getVolume());
			ps.setString(12, c.getIssue());
			ps.setNull(13, Types.NUMERIC);
			if(c.getStartPage()>0)
				ps.setLong(13, c.getStartPage());
			ps.setNull(14, Types.NUMERIC);
			if(c.getEndPage()>0)
				ps.setLong(14, c.getEndPage());
			ps.setString(15, c.getBook());
			ps.setString(16, c.getEditors());
			ps.setString(17, c.getPublishers());
			ps.setString(18, c.getReportNum());
			ps.setNull(19, Types.NUMERIC);
			if(c.getPages()>0)
				ps.setLong(19, c.getPages());
			ps.setString(20, c.getSource());
			ps.setString(21, c.getType());
			ps.setLong(22, c.getId());
			if (ps.executeUpdate() != 1)
				throw new DAOException("Method updateCitation() failed!");
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			try {
				conn.rollback();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			closeResources(conn, ps);
		}
		return c.getId();
	}
	
	private static final String SQL_IS_CITATION_DUPLICATE =
		"SELECT CITATION_ID, AUTHOR, YEAR, TITLE FROM P_CITATION " +
		"WHERE YEAR = ? " +
		"AND CADDIS_PG.percent_match(AUTHOR, ?) > 70 " +
		"AND CADDIS_PG.percent_match(TITLE , ?) > 70 " +
		"AND CITATION_ID <> ? ";
	
	public String getDuplicateCitations(Citation c) throws DAOException{
		String dupCitation = "";
		Connection conn = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			conn = getConnection();
			ps = conn.prepareStatement(SQL_IS_CITATION_DUPLICATE);
			ps.setLong(1, c.getYear());
			ps.setString(2, c.getAuthor());
			ps.setString(3, c.getTitle());
//			ps.setNull(4, Types.NUMERIC);
//			if(c.getId()>0)
			ps.setLong(4, c.getId());
			rs = ps.executeQuery();
			while(rs.next())
			{
				if(dupCitation.length()>0)
					dupCitation += "\n";
				dupCitation += rs.getString("AUTHOR");
				dupCitation += " (" + rs.getLong("YEAR") + ") ";
				dupCitation += rs.getString("TITLE");
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, ps, rs);
		}
		return dupCitation;
	}
	
   private static final String SQL_GET_AVAILABLE_CADDIS_PAGES = 
    	"SELECT LL_ID, LIST_ITEM_CODE, LIST_ITEM_DESCRIPTION " +
    	"FROM V_CADDIS_PAGE v " +
    	"WHERE NOT EXISTS( " +
    	"	SELECT * FROM P_CADDIS_PAGE_CITATION_JOIN p " +
    	"	WHERE p.CITATION_ID = ? " +
    	"	AND p.LL_CADDIS_PAGE_ID = v.LL_ID) " +
    	"ORDER BY LIST_ITEM_CODE";
    
    /**
     * This method retrieves all the CADDIS pages that don't quote the citation as reference.
     * @param citationId
     * @return
     * @throws DAOException
     */
    public List getAvailableCADDISPages(long citationId) throws DAOException
    {
    	List list = null;
    	LookupValue lv = null;
    	Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try{
        	list = new ArrayList();
        	conn = getConnection();
        	ps = conn.prepareStatement(SQL_GET_AVAILABLE_CADDIS_PAGES);
        	ps.setLong(1, citationId);
        	rs = ps.executeQuery();
        	while(rs.next()){
        		lv = new LookupValue();
        		lv.setId(rs.getLong(1));
        		lv.setCode(rs.getString(2));
        		lv.setDesc(rs.getString(3));
        		list.add(lv);
        	}
        }catch (NamingException nex) {
            throw new DAOException(nex);
        } catch (SQLException sqle) {
                throw new DAOException(sqle);
        } finally {
                closeResources(conn, ps, rs);
        }
    	return list;
    }
    
    private static final String SQL_GET_USED_CADDIS_PAGES = 
    	"SELECT LL_ID, LIST_ITEM_CODE, LIST_ITEM_DESCRIPTION " +
    	"FROM V_CADDIS_PAGE v " +
    	"WHERE EXISTS( " +
    	"	SELECT * FROM P_CADDIS_PAGE_CITATION_JOIN p " +
    	"	WHERE p.CITATION_ID = ? " +
    	"	AND p.LL_CADDIS_PAGE_ID = v.LL_ID) " +
    	"ORDER BY LIST_ITEM_CODE";
    
    /**
     * This method retrieves all the CADDIS pages that quote the citation as reference.
     * @param citationId
     * @return
     * @throws DAOException
     */
    public List getUsedCADDISPages(long citationId) throws DAOException
    {
    	List list = null;
    	LookupValue lv = null;
    	Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try{
        	list = new ArrayList();
        	conn = getConnection();
        	ps = conn.prepareStatement(SQL_GET_USED_CADDIS_PAGES);
        	ps.setLong(1, citationId);
        	rs = ps.executeQuery();
        	while(rs.next()){
        		lv = new LookupValue();
        		lv.setId(rs.getLong(1));
        		lv.setCode(rs.getString(2));
        		lv.setDesc(rs.getString(3));
        		list.add(lv);
        	}
        }catch (NamingException nex) {
            throw new DAOException(nex);
        } catch (SQLException sqle) {
                throw new DAOException(sqle);
        } finally {
                closeResources(conn, ps, rs);
        }
    	return list;
    }
    
    private static final String SQL_INSERT_CADDIS_PAGE_CITATION_JOIN = 
    	"INSERT INTO P_CADDIS_PAGE_CITATION_JOIN " +
    	"(CADDIS_PAGE_CITATION_ID, LL_CADDIS_PAGE_ID, CITATION_ID, CREATE_DATE, CREATE_USER) " +
    	"VALUES (SEQ_CADDIS_PAGE_CITATION_ID.NEXTVAL, ?, ?, SYSDATE, ?)";
    
    /**
     * This method insert CADDIS page citation join
     * @param pageId
     * @param citationId
     * @param userId
     * @throws DAOException
     */
    public void insertCADDISPageCitationJoin(long[] pageId, long citationId, long userId) throws DAOException
    {
    	Connection conn = null;
        PreparedStatement ps = null;
        try{
        	conn= getConnection();
        	ps = conn.prepareStatement(SQL_INSERT_CADDIS_PAGE_CITATION_JOIN);
        	ps.setLong(2, citationId);
        	ps.setLong(3, userId);
            for(int i=0;i<pageId.length;i++){
                ps.setLong(1,pageId[i]);
                ps.addBatch();
            }
            ps.executeBatch();
        }catch (NamingException nex) {
            throw new DAOException(nex);
        } catch (SQLException sqle) {
                throw new DAOException(sqle);
        } finally {
                closeResources(conn, ps);
        }
    }
    
    private static final String SQL_DELETE_CADDIS_PAGE_CITATION_JOIN = 
    	"DELETE FROM P_CADDIS_PAGE_CITATION_JOIN WHERE LL_CADDIS_PAGE_ID = ? AND CITATION_ID = ? ";
    
    /**
     * This method deletes a CADDIS page citation join
     * @param pageId
     * @param citationId
     * @throws DAOException
     */
    public void deleteCADDISPageCitationJoin(long pageId, long citationId) throws DAOException
    {
    	Connection conn = null;
        PreparedStatement ps = null;
        try{
        	conn = getConnection();
        	ps = conn.prepareStatement(SQL_DELETE_CADDIS_PAGE_CITATION_JOIN);
        	ps.setLong(1, pageId);
        	ps.setLong(2, citationId);
    		if (ps.executeUpdate() != 1)
				throw new DAOException("Delete CADDIS Page Citatoin Join Failed");
        }catch (NamingException nex) {
            throw new DAOException(nex);
        } catch (SQLException sqle) {
                throw new DAOException(sqle);
        } finally {
                closeResources(conn, ps);
        }
    }
    
    private static final String SQL_GET_CITATIONS_FOR_CADDIS_PAGES = 
    	"SELECT j.CADDIS_PAGE_CITATION_ID, v.LIST_ITEM_CODE PAGE_NAME, LIST_ITEM_DESCRIPTION PAGE_URL, " +
    	"c.CITATION_ID, c.AUTHOR, c.LL_PUBLICATION_TYPE_ID, c.YEAR, c.TITLE, c.KEYWORD, c.JOURNAL, c.VOLUME_ISSUE_PAGES, c.IS_APPROVED, " +
    	" c.BOOK, c.EDITORS, c.PUBLISHERS, c.REPORT_NUMBER, c.PAGES, c.SOURCE, c.TYPE "+
    	"FROM  V_ICD_CITATION_DETAILS c, P_CADDIS_PAGE_CITATION_JOIN j, V_CADDIS_PAGE v " +
    	"WHERE c.CITATION_ID = j.CITATION_ID " +
    	"AND j.LL_CADDIS_PAGE_ID = v.LL_ID ";
    
	/**
	 * This method retrieves a list of citations on selected CADDIS pages
	 * The parameter is a list of caddis page ids that are separated by comma
	 * @param pageIds
	 * @return list
	 * @throws DAOException
	 */
    public List getCitationsForCADDISPages(String pageIds) throws DAOException
    {
		List citations = new ArrayList();
		Connection conn = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		String sql = SQL_GET_CITATIONS_FOR_CADDIS_PAGES;

		try {
			sql += "AND v.LL_ID in (" + pageIds +") ";
			sql += "ORDER BY LL_ID, CITATION_ID";
			conn = getConnection();
			ps = conn.prepareStatement(sql);
			rs = ps.executeQuery();
			while (rs.next()) {
				Citation c = new Citation();
				c.setCaddisPageName(rs.getString("PAGE_NAME"));
				c.setCaddisPageURL(rs.getString("PAGE_URL"));
				c.setId(rs.getLong("CITATION_ID"));
				c.setPubTypeId(rs.getLong("LL_PUBLICATION_TYPE_ID"));
				c.setAuthor(rs.getString("AUTHOR"));
				c.setTitle(rs.getString("TITLE"));
				c.setDate(rs.getInt("YEAR"));
				if (rs.getString("KEYWORD") != null)
					c.setKeyword(rs.getString("KEYWORD"));

				if(rs.getString("JOURNAL") != null)
					c.setJournal(rs.getString("JOURNAL"));

				if(rs.getString("VOLUME_ISSUE_PAGES") != null)
					c.setVolumeIssuePagesInfo(rs.getString("VOLUME_ISSUE_PAGES"));

				if(rs.getString("IS_APPROVED") != null 
						&& rs.getString("IS_APPROVED").compareToIgnoreCase(Constants.NO) == 0)
					c.setApproved(false);
				else
					c.setApproved(true);
				if(rs.getString("BOOK") != null)
					c.setBook(rs.getString("BOOK"));
				
				if(rs.getString("EDITORS") != null)
					c.setEditors(rs.getString("EDITORS"));
				
				if(rs.getString("PUBLISHERS") != null)
					c.setPublishers(rs.getString("PUBLISHERS"));
				
				if(rs.getString("REPORT_NUMBER") != null)
					c.setReportNum(rs.getString("REPORT_NUMBER"));
				
				if(rs.getString("PAGES") != null)
					c.setPages(rs.getLong("PAGES"));
				
				if(rs.getString("SOURCE") != null)
					c.setSource(rs.getString("SOURCE"));
				
				if(rs.getString("TYPE") != null)
					c.setType(rs.getString("TYPE"));
				c.setDisplayTitle(formatDisplayTitle(c, true));

				citations.add(c);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, ps, rs);
		}
		return citations;
    }
    
    private static final String SQL_SELECT_CADDIS_PAGE_BY_NAME = 
    	"SELECT * FROM V_CADDIS_PAGE WHERE UPPER(LIST_ITEM_CODE) = ?";
    
    public boolean isPageNameDuplicate(String pageName) throws DAOException
    {
    	boolean isDuplicate = false;
    	Connection conn = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			conn = getConnection();
			ps = conn.prepareStatement(SQL_SELECT_CADDIS_PAGE_BY_NAME);
			ps.setString(1, pageName.toUpperCase());
			rs = ps.executeQuery();
			if(rs.next())
				isDuplicate = true;
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, ps, rs);
		}
    	return isDuplicate;
    }
    
    private static final String SQL_GET_CITATIONS_BY_CADDIS_PAGE_NAME = 
    	"SELECT DISTINCT a.CITATION_ID, LL_PUBLICATION_ID, LL_PUBLICATION_TYPE_ID, " +
    	"AUTHOR, YEAR, TITLE, KEYWORD, IS_APPROVED, JOURNAL, VOLUME_ISSUE_PAGES, " +
    	"BOOK, EDITORS, PUBLISHERS, REPORT_NUMBER, PAGES, SOURCE, TYPE " +
    	"FROM V_ICD_CITATION_DETAILS a, P_CADDIS_PAGE_CITATION_JOIN b, V_CADDIS_PAGE c " +
    	"WHERE a.CITATION_ID = b.CITATION_ID " +
    	"AND b.LL_CADDIS_PAGE_ID = c.LL_ID " +
    	"AND upper(c.LIST_ITEM_CODE) = ? ";
    
    public List getCitationsByCADDISPageName(String pageName) throws DAOException
    {
		List citations = new ArrayList();
		Connection conn = null;
		PreparedStatement ps = null;
		ResultSet rs = null;

		try {
			conn = getConnection();
			ps = conn.prepareStatement(SQL_GET_CITATIONS_BY_CADDIS_PAGE_NAME);
			ps.setString(1, pageName.toUpperCase());
			rs = ps.executeQuery();
			while (rs.next()) {
				Citation c = new Citation();
				c.setId(rs.getLong("CITATION_ID"));
				c.setPubTypeId(rs.getLong("LL_PUBLICATION_TYPE_ID"));
				c.setAuthor(rs.getString("AUTHOR"));
				c.setTitle(rs.getString("TITLE"));
				c.setDate(rs.getInt("YEAR"));
				if (rs.getString("KEYWORD") != null)
					c.setKeyword(rs.getString("KEYWORD"));

				if(rs.getString("JOURNAL") != null)
					c.setJournal(rs.getString("JOURNAL"));

				if(rs.getString("VOLUME_ISSUE_PAGES") != null)
					c.setVolumeIssuePagesInfo(rs.getString("VOLUME_ISSUE_PAGES"));

				if(rs.getString("IS_APPROVED") != null 
						&& rs.getString("IS_APPROVED").compareToIgnoreCase(Constants.NO) == 0)
					c.setApproved(false);
				else
					c.setApproved(true);
				if(rs.getString("BOOK") != null)
					c.setBook(rs.getString("BOOK"));
				
				if(rs.getString("EDITORS") != null)
					c.setEditors(rs.getString("EDITORS"));
				
				if(rs.getString("PUBLISHERS") != null)
					c.setPublishers(rs.getString("PUBLISHERS"));
				
				if(rs.getString("REPORT_NUMBER") != null)
					c.setReportNum(rs.getString("REPORT_NUMBER"));
				
				if(rs.getString("PAGES") != null)
					c.setPages(rs.getLong("PAGES"));
				
				if(rs.getString("SOURCE") != null)
					c.setSource(rs.getString("SOURCE"));
				
				if(rs.getString("TYPE") != null)
					c.setType(rs.getString("TYPE"));
				c.setDisplayTitle(formatDisplayTitle(c, true));

				citations.add(c);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, ps, rs);
		}
		return citations;
    }
    
    private static final String SQL_GET_ALL_CITATION_COUNT = 
    	"SELECT COUNT(*) FROM V_ICD_CITATION_DETAILS";
    
    public long getAllCitationCount()throws DAOException {
		long count = 0;
		Connection conn = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			conn = getConnection();
			ps = conn.prepareStatement(SQL_GET_ALL_CITATION_COUNT);
			rs = ps.executeQuery();
			if(rs.next()){
				count = rs.getLong(1);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, ps, rs);
		}
		return count;
    }
    
    private static final String SQL_GET_ALL_CITATION_BY_PAGE_NUM = 
		  "SELECT * FROM  ( SELECT p.*, ROWNUM RNUM FROM ( "
		+ "SELECT DISTINCT CITATION_ID, LL_PUBLICATION_ID, LL_PUBLICATION_TYPE_ID, "
		+ "AUTHOR, YEAR, TITLE, KEYWORD, IS_APPROVED, JOURNAL, VOLUME_ISSUE_PAGES, " 
		+ "BOOK, EDITORS, PUBLISHERS, REPORT_NUMBER, PAGES, SOURCE, TYPE, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM ICD_LINKAGE_CITATION_JOIN b "
		+ "					WHERE b.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_ICD, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM P_CADDIS_PAGE_CITATION_JOIN c "
		+ "					WHERE c.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_CADDIS, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM P_DATASET d "
		+ "					WHERE d.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_CADLIT "
		+ "FROM  V_ICD_CITATION_DETAILS a " 
		+ "ORDER BY AUTHOR, YEAR, TITLE ASC "
		+ ") p WHERE ROWNUM <= ? ) WHERE RNUM >= ? ";

	public List getAllCitationsByPageNum(long pageNum, long recordsPerPage) throws DAOException {
		List citations = new ArrayList();
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {
			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_GET_ALL_CITATION_BY_PAGE_NUM);
			pstmt.setLong(1, pageNum*recordsPerPage);
			pstmt.setLong(2, (pageNum-1)*recordsPerPage + 1);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				Citation c = new Citation();
				c.setId(rs.getLong("CITATION_ID"));
				c.setPubTypeId(rs.getLong("LL_PUBLICATION_TYPE_ID"));
				c.setAuthor(rs.getString("AUTHOR"));
				c.setTitle(rs.getString("TITLE"));
				c.setDate(rs.getInt("YEAR"));
				if (rs.getString("KEYWORD") != null)
					c.setKeyword(rs.getString("KEYWORD"));

				if(rs.getString("JOURNAL") != null)
					c.setJournal(rs.getString("JOURNAL"));

				if(rs.getString("VOLUME_ISSUE_PAGES") != null)
					c.setVolumeIssuePagesInfo(rs.getString("VOLUME_ISSUE_PAGES"));

				if(rs.getString("IS_APPROVED") != null 
						&& rs.getString("IS_APPROVED").compareToIgnoreCase(Constants.NO) == 0)
					c.setApproved(false);
				else
					c.setApproved(true);
				
				
				if(rs.getString("IN_ICD") != null
						&& rs.getString("IN_ICD").compareToIgnoreCase(Constants.NO) == 0)
					c.setInICD(false);
				else
					c.setInICD(true);
				
				if(rs.getString("IN_CADDIS") != null
						&& rs.getString("IN_CADDIS").compareToIgnoreCase(Constants.NO) == 0)
					c.setInCADDIS(false);
				else
					c.setInCADDIS(true);
				
				if(rs.getString("IN_CADLIT") != null
						&& rs.getString("IN_CADLIT").compareToIgnoreCase(Constants.NO) == 0)
					c.setInCADLIT(false);
				else
					c.setInCADLIT(true);
				
				if(rs.getString("BOOK") != null)
					c.setBook(rs.getString("BOOK"));
				
				if(rs.getString("EDITORS") != null)
					c.setEditors(rs.getString("EDITORS"));
				
				if(rs.getString("PUBLISHERS") != null)
					c.setPublishers(rs.getString("PUBLISHERS"));
				
				if(rs.getString("REPORT_NUMBER") != null)
					c.setReportNum(rs.getString("REPORT_NUMBER"));
				
				if(rs.getString("PAGES") != null)
					c.setPages(rs.getLong("PAGES"));
				
				if(rs.getString("SOURCE") != null)
					c.setSource(rs.getString("SOURCE"));
				
				if(rs.getString("TYPE") != null)
					c.setType(rs.getString("TYPE"));
				
				c.setDisplayTitle(formatDisplayTitle(c, true));
				citations.add(c);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return citations;
	}
    
    private static final String SQL_GET_CITATION_SEARCH_COUNT = 
    	"SELECT COUNT(*) FROM V_ICD_CITATION_DETAILS ";
    
    public long getCitationSearchCount(String searchTerm) throws DAOException {
    	long count = 0;
    	Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		String[] searchTerms = Utility.getEachKeyword(searchTerm);
		StringBuffer sqlExpression = new StringBuffer();
		String sql = SQL_GET_CITATION_SEARCH_COUNT;
		
		if (searchTerms.length == 1) {
			if(searchTerms[0].trim().length() != 0) {
				String term = searchTerms[0].toUpperCase();
				sqlExpression.append(" WHERE ");
				sqlExpression.append(" ( UPPER(AUTHOR) LIKE '%" + term + "%' "
						+ " OR UPPER(TITLE) LIKE '%" + term + "%' "
						+ " OR UPPER(KEYWORD) LIKE  '%" + term + "%'"
						+ " OR UPPER(ABSTRACT)  LIKE  '%" + term + "%'"
						+ " OR YEAR LIKE '%" + term + "%')");
			}
		} else if (searchTerms.length > 1) {
			sqlExpression.append(" WHERE ");
			sqlExpression.append("(( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "AUTHOR", " AND "));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "TITLE", " AND "));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "KEYWORD",	" AND "));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "ABSTRACT", " AND"));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "YEAR", " AND "));
			sqlExpression.append(" ))");
		}

		try {
			conn = getConnection();
			if (sqlExpression.length() > 0)
				sql += sqlExpression.toString();
			pstmt = conn.prepareStatement(sql);
//			System.out.println(sql);
			rs = pstmt.executeQuery();
			if(rs.next()){
				count = rs.getLong(1);
			}
		} 
		catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} 
		finally {
			closeResources(conn, pstmt, rs);
		}

		return count;
	}
    
    private static final String SQL_GET_CITATION_SEARCH = 
		  "SELECT * FROM  ( SELECT p.*, ROWNUM RNUM FROM ( "
		+ "SELECT DISTINCT CITATION_ID, LL_PUBLICATION_ID, LL_PUBLICATION_TYPE_ID, "
		+ "AUTHOR, YEAR, TITLE, KEYWORD, IS_APPROVED, JOURNAL, VOLUME_ISSUE_PAGES, " 
		+ "BOOK, EDITORS, PUBLISHERS, REPORT_NUMBER, PAGES, SOURCE, TYPE, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM ICD_LINKAGE_CITATION_JOIN b "
		+ "					WHERE b.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_ICD, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM P_CADDIS_PAGE_CITATION_JOIN c "
		+ "					WHERE c.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_CADDIS, "
		+ "CASE WHEN EXISTS(SELECT * "
		+ "					FROM P_DATASET d "
		+ "					WHERE d.CITATION_ID = a.CITATION_ID) THEN 'Y' "
		+ "	 	ELSE 'N' "
		+ "END AS IN_CADLIT "
		+ "FROM  V_ICD_CITATION_DETAILS a " ;
    
	public List getCitationSearchByPageNum(String searchTerm, long pageNum, long recordsPerPage) throws DAOException {

		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		ArrayList citations = new ArrayList();

		String[] searchTerms = Utility.getEachKeyword(searchTerm);
		StringBuffer sqlExpression = new StringBuffer();
		String sql = SQL_GET_CITATION_SEARCH;

		if (searchTerms.length == 1) {
			if(searchTerms[0].trim().length() != 0) {
				String term = searchTerms[0].toUpperCase();
				sqlExpression.append(" WHERE ");
				sqlExpression.append(" ( UPPER(AUTHOR) LIKE '%" + term + "%' "
						+ " OR UPPER(TITLE) LIKE '%" + term + "%' "
						+ " OR UPPER(KEYWORD) LIKE  '%" + term + "%'"
						+ " OR UPPER(ABSTRACT)  LIKE  '%" + term + "%'"
						+ " OR YEAR LIKE '%" + term + "%')");
			}
		} else if (searchTerms.length > 1) {
			sqlExpression.append(" WHERE ");
			sqlExpression.append("(( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "AUTHOR", " AND "));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "TITLE", " AND "));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "KEYWORD",	" AND "));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "ABSTRACT", " AND"));
			sqlExpression.append(" ) OR ( ");
			sqlExpression.append(Utility.formatSearchTerm(searchTerms, "YEAR", " AND "));
			sqlExpression.append(" ))");
		}

		try {
			conn = getConnection();

			if (sqlExpression.length() > 0)
				sql += sqlExpression.toString();
			sql += " ORDER BY AUTHOR, YEAR, TITLE ASC ";
			sql += ") p WHERE ROWNUM <= ? ) WHERE RNUM >= ? ";
//			System.out.println(sql);
			
			pstmt = conn.prepareStatement(sql);
			pstmt.setLong(1, pageNum*recordsPerPage);
			pstmt.setLong(2, (pageNum-1)*recordsPerPage + 1);
			
			rs = pstmt.executeQuery();

			while (rs.next()) {
				Citation c = new Citation();
				c.setId(rs.getLong("CITATION_ID"));
				c.setPubTypeId(rs.getLong("LL_PUBLICATION_TYPE_ID"));
				c.setAuthor(rs.getString("AUTHOR"));
				c.setTitle(rs.getString("TITLE"));
				c.setDate(rs.getInt("YEAR"));
				if (rs.getString("KEYWORD") != null)
					c.setKeyword(rs.getString("KEYWORD"));
				if(rs.getString("JOURNAL") != null)
					c.setJournal(rs.getString("JOURNAL"));
				if(rs.getString("VOLUME_ISSUE_PAGES") != null)
					c.setVolumeIssuePagesInfo(rs.getString("VOLUME_ISSUE_PAGES"));
				
				if(rs.getString("IS_APPROVED") != null 
						&& rs.getString("IS_APPROVED").compareToIgnoreCase(Constants.NO) == 0)
					c.setApproved(false);
				else
					c.setApproved(true);

				if(rs.getString("IN_ICD") != null
						&& rs.getString("IN_ICD").compareToIgnoreCase(Constants.NO) == 0)
					c.setInICD(false);
				else
					c.setInICD(true);
				
				if(rs.getString("IN_CADDIS") != null
						&& rs.getString("IN_CADDIS").compareToIgnoreCase(Constants.NO) == 0)
					c.setInCADDIS(false);
				else
					c.setInCADDIS(true);
				
				if(rs.getString("IN_CADLIT") != null
						&& rs.getString("IN_CADLIT").compareToIgnoreCase(Constants.NO) == 0)
					c.setInCADLIT(false);
				else
					c.setInCADLIT(true);
				
				if(rs.getString("BOOK") != null)
					c.setBook(rs.getString("BOOK"));
				
				if(rs.getString("EDITORS") != null)
					c.setEditors(rs.getString("EDITORS"));
				
				if(rs.getString("PUBLISHERS") != null)
					c.setPublishers(rs.getString("PUBLISHERS"));
				
				if(rs.getString("REPORT_NUMBER") != null)
					c.setReportNum(rs.getString("REPORT_NUMBER"));
				
				if(rs.getString("PAGES") != null)
					c.setPages(rs.getLong("PAGES"));
				
				if(rs.getString("SOURCE") != null)
					c.setSource(rs.getString("SOURCE"));
				
				if(rs.getString("TYPE") != null)
					c.setType(rs.getString("TYPE"));
				
				c.setDisplayTitle(formatDisplayTitle(c, true));
				citations.add(c);
			}

		} 
		catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} 
		finally {
			closeResources(conn, pstmt, rs);
		}

		return citations;
	}
}

