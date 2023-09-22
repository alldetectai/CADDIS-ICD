package com.tetratech.caddis.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.naming.NamingException;

import com.tetratech.caddis.model.LookupValue;
import com.tetratech.caddis.model.Term;
import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.common.Utility;
import com.tetratech.caddis.exception.DAOException;

public class LookupDAO extends AbstractDAO {
	// singleton instance
    private static LookupDAO instance = null;

    private LookupDAO() {
    }

    public static synchronized LookupDAO getInstance() {
        if (instance != null) {
            return instance;
        }

        if (instance == null) {
            instance = new LookupDAO();
        }

        return instance;
   }

    public List getLookupByType(String type) throws DAOException {
        if (type == null || type.length() == 0)
            throw new DAOException("Get Lookup Failed: Invalid Type");
            
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList list = null;
        String viewType = type;
 
        
        String sql = " SELECT LL_ID," +
                     "        LIST_ITEM_CODE," +
                     "        LIST_ITEM_DESCRIPTION" +
                     "   FROM " + viewType.toUpperCase() + 
                     " ORDER BY ORDER_NUMBER"; 
        
        //TODO:SHOULD HAVE STATUS_ID INCASE WE WANT TO RETIRE ANY VALUE
        //                     "  WHERE STATUS_ID = ? " ;
        try {
            
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            
            rs = pstmt.executeQuery();
            list = new ArrayList();
            
            while (rs.next()) {
                list.add(new LookupValue( rs.getLong("LL_ID"), rs.getString("LIST_ITEM_CODE"),  rs.getString("LIST_ITEM_DESCRIPTION")));
            }
        } catch (NamingException nex) {
                throw new DAOException(nex);
        } catch (SQLException sqle) {
                throw new DAOException(sqle);
        } finally {
                closeResources(conn, pstmt, rs);
        }
            
        return list;
    }
    
    
    private static final String SQL_GET_PUBLICATION_ID = 
    	"SELECT LL_ID FROM P_LIST_ITEM WHERE TYPE_ENTITY_ID = ? AND UPPER(LIST_ITEM_DESCRIPTION) = ?";
    
    /**
     * This method get the publication id by matching publication description
     * @param desc
     * @return
     * @throws DAOException
     */
    public long getPublicationIdByDesc(String desc)throws DAOException
    {
    	long pubId = -1;
    	Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
        	conn = getConnection();
        	ps = conn.prepareStatement(SQL_GET_PUBLICATION_ID);
        	ps.setLong(1, Constants.PUBLICATION_TYPE_ENTITY_ID);
        	ps.setString(2, desc.toUpperCase());
        	rs = ps.executeQuery();
        	if(rs.next())
        	{
        		pubId = rs.getLong("LL_ID");
        	}
        } catch (NamingException nex) {
                throw new DAOException(nex);
        } catch (SQLException sqle) {
                throw new DAOException(sqle);
        } finally {
                closeResources(conn, ps, rs);
        }
    	
    	return pubId;
    }
   
    private static final String SQL_INSERT_STANDARD_TERM =
    	"INSERT INTO P_STANDARD_TERM (STANDARD_TERM_ID, STANDARD_TERM,  IS_EEL_TERM, STANDARD_TERM_DESC, CREATE_DATE, CREATE_USER, LL_LEGEND_TYPE_ID) " +
    	"VALUES (?, ?, ?, ?, SYSDATE, ?, ?) ";
    
    /**
     * This method inserts a new term into P_STANDARD_TERM
     * @param term
     * @param isEELTerm
     * @param desc
     * @param userId
     * @param legendType
     * @return id
     * @throws DAOException
     */
    public long insertStandardTerm(Term newTerm, long userId)throws DAOException
    {
    	long id = -1;
    	Connection conn = null;
        PreparedStatement ps = null;
    	try{
    		id = getSequenceId("SEQ_STANDARD_TERM_ID");
    		if (id <= 0)
				throw new DAOException("Insert term Failed");
			
    		conn = getConnection();
    		ps = conn.prepareStatement(SQL_INSERT_STANDARD_TERM);
    		ps.setLong(1, id);
    		String term = newTerm.getTerm();
    		if(term.length() > 200)
    			ps.setString(2, term.substring(0, 200));
    		else
    			ps.setString(2, term);
    		if(newTerm.isEELTerm())
    			ps.setString(3, "Y");//user created by default 'N'
    		else
    			ps.setString(3, "N");
    		String desc = newTerm.getDesc();
    		if(desc.length() > 1000)
    			ps.setString(4, desc.substring(0, 1000));
    		else
    			ps.setString(4, desc);

    		ps.setLong(5, userId);
    		
    		if (newTerm.getLegendType() > 0 )
    			ps.setLong(6, newTerm.getLegendType());
    		else
    			ps.setNull(6, java.sql.Types.INTEGER);
    		
    		if (ps.executeUpdate() != 1)
				throw new DAOException("Insert Term Failed");
			
    	}
    	 catch (NamingException nex) {
             throw new DAOException(nex);
     } catch (SQLException sqle) {
             throw new DAOException(sqle);
     } finally {
             closeResources(conn, ps);
     }
    	return id;
    }
    
    private final String SQL_SEARCH_TERMS = "SELECT STANDARD_TERM_ID, STANDARD_TERM,  IS_EEL_TERM, STANDARD_TERM_DESC, A.LL_LEGEND_TYPE_ID AS LEGEND_TYPE "
    	+ " FROM  P_STANDARD_TERM a ";
    
	public List searchTerms(String searchTerm, boolean exactMatch, boolean isStand) throws DAOException {

		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		List terms = new ArrayList();

		StringBuffer sqlExpression = new StringBuffer();
		String sql = SQL_SEARCH_TERMS;
		if(searchTerm != null) {
			if(exactMatch) {
				sqlExpression.append(" WHERE ");
				sqlExpression.append(" ( UPPER(STANDARD_TERM) = '" + searchTerm.toUpperCase() + "' ) ");
			} else {
				String[] searchTerms = Utility.getEachKeyword(searchTerm);
				
				if (searchTerms.length == 1) {
					if(searchTerms[0].trim().length() != 0) {
						String term = searchTerms[0].toUpperCase();
						sqlExpression.append(" WHERE ");
						sqlExpression.append(" ( UPPER(STANDARD_TERM) LIKE '%" + term + "%' ) ");
		
					}
				} else if (searchTerms.length > 1) {
					sqlExpression.append(" WHERE ");
					sqlExpression.append("( ");
					sqlExpression.append(Utility.formatSearchTerm(searchTerms, "STANDARD_TERM", " AND ", exactMatch));
					sqlExpression.append(" )");
				}
			}
		}

		try {
			conn = getConnection();

			if (sqlExpression.length() > 0)
			{
				sql += sqlExpression.toString();
				sql += isStand ? " AND IS_EEL_TERM = 'Y' " : "";
			}
			else
			{
				sql += isStand ? " WHERE IS_EEL_TERM = 'Y' " : "";
			
			}
			sql += " ORDER BY LEGEND_TYPE, STANDARD_TERM ASC ";
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				Term term = new Term();
				term.setId(new Long(rs.getLong("STANDARD_TERM_ID")));
				term.setTerm(rs.getString("STANDARD_TERM"));
				term.setDesc(rs.getString("STANDARD_TERM_DESC"));
				term.setLegendType(rs.getLong("LEGEND_TYPE"));
				if(rs.getString("IS_EEL_TERM").compareToIgnoreCase("Y") == 0)
					term.setEELTerm(true);
				else
					term.setEELTerm(false);
				terms.add(term);
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

		return terms;
	}
    private static final String SQL_INSERT_PUBLICATION =
    	"INSERT INTO P_LIST_ITEM (LL_ID, TYPE_ENTITY_ID, LIST_ITEM_CODE, LIST_ITEM_DESCRIPTION, CREATE_DATE, CREATE_USER) " +
    	"VALUES (?, ?, ?, ?, SYSDATE, ?) ";
    
    /**
     * This method inserts a new publication as a lookup value
     * @param desc
     * @param userId
     * @return pubId
     * @throws DAOException
     */
    public long insertPublication(String desc, long userId)throws DAOException
    {
    	long pubId = -1;
    	Connection conn = null;
        PreparedStatement ps = null;
    	try{
    		pubId = getSequenceId("SEQ_LL_ID");
    		if (pubId <= 0)
				throw new DAOException("Insert Citation Failed: Invalid Citation Id");
			
    		conn = getConnection();
    		ps = conn.prepareStatement(SQL_INSERT_PUBLICATION);
    		ps.setLong(1, pubId);
    		ps.setLong(2, Constants.PUBLICATION_TYPE_ENTITY_ID);
    		if(desc.length()>50)
    			ps.setString(3, desc.substring(0, 50));
    		else
    			ps.setString(3, desc);
    		ps.setString(4, desc);
    		ps.setLong(5, userId);
    		if (ps.executeUpdate() != 1)
				throw new DAOException("Insert Journal Failed");
			
    	}
    	 catch (NamingException nex) {
             throw new DAOException(nex);
     } catch (SQLException sqle) {
             throw new DAOException(sqle);
     } finally {
             closeResources(conn, ps);
     }
    	return pubId;
    }
    
    private static final String SQL_INSERT_NEW_LOOKUP = 
    	"INSERT INTO P_LIST_ITEM (LL_ID, TYPE_ENTITY_ID, LIST_ITEM_CODE, LIST_ITEM_DESCRIPTION, CREATE_DATE, CREATE_USER) " +
    	"VALUES (SEQ_LL_ID.nextVal, ?, ?, ?, SYSDATE, ?) ";
    
    public void insertNewLookup(LookupValue lv, long typeEntityId, long userId) throws DAOException
    {
    	Connection conn = null;
        PreparedStatement ps = null;
        try{

        	conn = getConnection();
        	ps = conn.prepareStatement(SQL_INSERT_NEW_LOOKUP);
        	ps.setLong(1, typeEntityId);
        	ps.setString(2, lv.getCode());
        	ps.setString(3, lv.getDesc());
        	ps.setLong(4, userId);
    		if (ps.executeUpdate() != 1)
				throw new DAOException("Insert New Lookup Failed");
        }catch (NamingException nex) {
            throw new DAOException(nex);
        } catch (SQLException sqle) {
                throw new DAOException(sqle);
        } finally {
                closeResources(conn, ps);
        }
    }
    

	private static final String SQL_ALL_STANDARD_TERM=
			" SELECT STANDARD_TERM_ID, STANDARD_TERM, IS_EEL_TERM,  LL_LEGEND_TYPE_ID AS LEGEND_TYPE "
    	+ " FROM  P_STANDARD_TERM a ";

	public List getAllStandardTerm(boolean isStand) throws DAOException {
		List datasets = new ArrayList();
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
	
		try {
			String sql = isStand ? SQL_ALL_STANDARD_TERM + " WHERE IS_EEL_TERM = 'Y'" : SQL_ALL_STANDARD_TERM;
			sql += " ORDER BY LEGEND_TYPE, STANDARD_TERM ASC ";
			conn = getConnection();
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
	
			while (rs.next()) {
				Term d = new Term();
				d.setTerm(rs.getString("STANDARD_TERM"));
				d.setId(rs.getLong("STANDARD_TERM_ID"));
				boolean isEel = rs.getString("IS_EEL_TERM") == "Y" ? true : false;
				d.setEELTerm(isEel);
				d.setLegendType(rs.getLong("LEGEND_TYPE"));
				datasets.add(d);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return datasets;
	
	}
        
}
