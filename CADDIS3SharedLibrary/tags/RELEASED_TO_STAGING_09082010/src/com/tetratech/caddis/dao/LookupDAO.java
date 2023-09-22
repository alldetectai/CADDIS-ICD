package com.tetratech.caddis.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.naming.NamingException;

import com.tetratech.caddis.model.LookupValue;
import com.tetratech.caddis.common.Constants;
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
        
}
