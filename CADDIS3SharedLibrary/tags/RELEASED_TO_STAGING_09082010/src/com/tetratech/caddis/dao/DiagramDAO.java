package com.tetratech.caddis.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.naming.NamingException;

import oracle.jdbc.OracleTypes;

import com.tetratech.caddis.common.Constants;
import com.tetratech.caddis.common.Utility;
import com.tetratech.caddis.exception.DAOException;
import com.tetratech.caddis.model.SArrowLine;
import com.tetratech.caddis.model.Comment;
import com.tetratech.caddis.model.Connector;
import com.tetratech.caddis.model.Diagram;
import com.tetratech.caddis.model.Ellipse;
import com.tetratech.caddis.model.Hexagon;
import com.tetratech.caddis.model.Line;
import com.tetratech.caddis.model.Linkage;
import com.tetratech.caddis.model.Octagon;
import com.tetratech.caddis.model.Pentagon;
import com.tetratech.caddis.model.Point;
import com.tetratech.caddis.model.Rectangle;
import com.tetratech.caddis.model.RoundRectangle;
import com.tetratech.caddis.model.Shape;
import com.tetratech.caddis.model.ShapeAttribute;
import com.tetratech.caddis.model.User;


public class DiagramDAO extends AbstractDAO {
	
    // singleton instance
    private static DiagramDAO instance = null;
    
  
    private DiagramDAO(){
    }

    public static synchronized DiagramDAO getInstance() {
		if (instance != null) {
			return instance;
		}

		if (instance == null) {
			instance = new DiagramDAO();
		}

		return instance;
	}

    private static final String SQL_SELECT_ALL_DIAGRAMS = " SELECT DIAGRAM_ID,"
		+ "     DIAGRAM_NAME, DIAGRAM_DESC, LL_DIAGRAM_STATUS_ID, " 
		+ "		IS_GOLD_SEAL, IS_PUBLIC, LIST_ITEM_CODE as DIAGRAM_STATUS "  
		+ "	FROM  ICD_DIAGRAM, P_LIST_ITEM " 
		+ " WHERE LL_DIAGRAM_STATUS_ID = LL_ID"
		+ "  ORDER BY upper(DIAGRAM_NAME)";
    
    public List getAllDiagrams() throws DAOException {
    	List diagrams = new ArrayList();
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {

			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_ALL_DIAGRAMS);
			rs = pstmt.executeQuery();
			
			while(rs.next()) {
				Diagram diagram = new Diagram();
				diagram.setId(new Long(rs.getLong("DIAGRAM_ID")));
				diagram.setName(rs.getString("DIAGRAM_NAME"));
				if(rs.getString("DIAGRAM_DESC") != null)
					diagram.setDescription(rs.getString("DIAGRAM_DESC"));
				else
					diagram.setDescription("");
				
				if(rs.getString("IS_GOLD_SEAL").equalsIgnoreCase("Y"))
					diagram.setGoldSeal(true);
				else
					diagram.setGoldSeal(false);
				if(rs.getString("IS_PUBLIC").equalsIgnoreCase("Y"))
					diagram.setOpenToPublic(true);
				else
					diagram.setOpenToPublic(false);
				diagram.setDiagramStatus(rs.getString("DIAGRAM_STATUS"));
				diagram.setDiagramStatusId(rs.getLong("LL_DIAGRAM_STATUS_ID"));
				diagrams.add(diagram);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return diagrams;
    }
    
    private static final String SQL_SELECT_REV_DIAGRAMS = " SELECT d.REV_DIAGRAM_ID,"+
    	" d.DIAGRAM_NAME, d.DIAGRAM_DESC, d.LL_DIAGRAM_STATUS_ID, "+
    	" d.LAST_UPDATED_DT, "+
    	" d.IS_GOLD_SEAL, u.USER_ID, u.FIRST_NAME, u.LAST_NAME " +
    	" FROM  ICD_DIAGRAM_REV d, icd_user u"+
    	" WHERE d.ORIGINAL_DIAGRAM_ID = ? "+
    	" AND u.USER_ID = d.LAST_UPDATED_BY(+) "+
    	" ORDER BY d.LAST_UPDATED_DT DESC ";
    
    public List getRevisionDiagrams(Long diagramId) throws DAOException {
    	List diagrams = new ArrayList();
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {

			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_REV_DIAGRAMS);
			pstmt.setLong(1, diagramId.longValue());
			rs = pstmt.executeQuery();
			
			while(rs.next()) {
				Diagram diagram = new Diagram();
				diagram.setId(new Long(rs.getLong("REV_DIAGRAM_ID")));
				diagram.setOrginialId(diagramId);
				diagram.setName(rs.getString("DIAGRAM_NAME"));
				if(rs.getString("DIAGRAM_DESC") != null)
					diagram.setDescription(rs.getString("DIAGRAM_DESC"));
				else
					diagram.setDescription("");
				
//				if(rs.getString("IS_GOLD_SEAL").equalsIgnoreCase("Y"))
//					diagram.setGoldSeal(true);
//				else
//					diagram.setGoldSeal(false);
//				if(rs.getString("IS_PUBLIC").equalsIgnoreCase("Y"))
//					diagram.setOpenToPublic(true);
//				else
//					diagram.setOpenToPublic(false);
//				diagram.setDiagramStatus(rs.getString("DIAGRAM_STATUS"));
//				diagram.setDiagramStatusId(rs.getLong("LL_DIAGRAM_STATUS_ID"));
				User user = new User();
				user.setUserId(rs.getLong("USER_ID"));
				user.setFirstName(rs.getString("FIRST_NAME"));
				user.setLastName(rs.getString("LAST_NAME"));
				diagram.setUpdatedUser(user);
				diagram.setUpdatedDate(rs.getTimestamp("LAST_UPDATED_DT"));
				diagrams.add(diagram);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return diagrams;
    }
    
    private static final String SQL_CHECKIN_DIAGRAM  = " update icd_diagram d " + 
    	" SET d.LAST_UPDATED_DT = sysdate, " +
    	" d.LOCKED_BY_USER_ID = null " +
    	" where (d.LAST_UPDATED_DT + " +
    	+ Constants.DIAGRAM_CHECK_IN_DAYS + 
    	" ) < sysdate ";

    private static final String SQL_SELECT_DIAGRAMS_BY_USER =  "SELECT distinct d.DIAGRAM_ID, " +
    	"	d.DIAGRAM_NAME, d.DIAGRAM_DESC, d.KEYWORDS, d.LOCATION, d.LL_DIAGRAM_STATUS_ID, " +
    	"	d.IS_GOLD_SEAL, d.IS_PUBLIC, l.LIST_ITEM_CODE as DIAGRAM_STATUS, " +
    	" 	d.CREATED_BY AS CREATED_BY, d.CREATED_DT AS CREATED_DT,  "+
    	"   u.FIRST_NAME CREATOR_FIRST_NAME, u.LAST_NAME CREATOR_LAST_NAME, " +
    	" 	d.LAST_UPDATED_BY AS LAST_UPDATED_BY, d.LAST_UPDATED_DT AS LAST_UPDATED_DT,"+
    	"   u2.FIRST_NAME lockedUserFN, u2.LAST_NAME lockedUserLN, d.LOCKED_BY_USER_ID " +
    	" FROM  ICD_DIAGRAM d, P_LIST_ITEM l, ICD_DIAGRAM_USER_JOIN duj, icd_user u,icd_user u2 " +
    	" WHERE d.LL_DIAGRAM_STATUS_ID = l.LL_ID " +
    	"	AND d.DIAGRAM_ID = duj.DIAGRAM_ID(+) " +
    	"	AND (d.LL_DIAGRAM_STATUS_ID = ? or d.IS_PUBLIC = 'Y' or duj.USER_ID = ? or d.CREATED_BY = ?)" +
    	"   AND u.USER_ID = d.CREATED_BY " +
    	"   AND d.LOCKED_BY_USER_ID = u2.USER_ID(+) " +
    	" ORDER BY ";
    
    private static final String SQL_SEARCH_DIAGRAM =  "SELECT distinct d.DIAGRAM_ID, " +
	"	d.DIAGRAM_NAME, d.DIAGRAM_DESC, d.KEYWORDS, d.LOCATION, d.LL_DIAGRAM_STATUS_ID, " +
	"	d.IS_GOLD_SEAL, d.IS_PUBLIC, l.LIST_ITEM_CODE as DIAGRAM_STATUS, " +
	" 	d.CREATED_BY AS CREATED_BY, d.CREATED_DT AS CREATED_DT,  "+
	"   u.FIRST_NAME CREATOR_FIRST_NAME, u.LAST_NAME CREATOR_LAST_NAME, " +
	" 	d.LAST_UPDATED_BY AS LAST_UPDATED_BY, d.LAST_UPDATED_DT AS LAST_UPDATED_DT,"+
	"   u2.FIRST_NAME lockedUserFN, u2.LAST_NAME lockedUserLN, d.LOCKED_BY_USER_ID " +
	" FROM  ICD_DIAGRAM d, P_LIST_ITEM l, ICD_DIAGRAM_USER_JOIN duj, icd_user u,icd_user u2 " ;
    
    private static final String SQL_SELECT_USERS_BY_DIAGRAMID = "SELECT u.USER_ID, u.FIRST_NAME, u.LAST_NAME, u.LL_ROLE_ID, l.LIST_ITEM_CODE " +
    		" FROM ICD_USER u, P_LIST_ITEM l, ICD_DIAGRAM_USER_JOIN duj " +	
    		" WHERE duj.USER_ID = u.USER_ID " +
    		" AND LL_ROLE_ID = LL_ID " +
    		" AND duj.DIAGRAM_ID = ? ";
    
    public List getDiagramsByUser(String searchTerm, String sortBy, long userId) throws DAOException {
    	List diagrams = new ArrayList();
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		PreparedStatement pstmt2 = null;
		ResultSet rs2 = null;

		try {
			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_CHECKIN_DIAGRAM);
			if (pstmt.executeUpdate() != 1)
				System.out.println("None updated for CHECKIN DIAGARM FOR OVER 3 DAY");
			closeResources(pstmt);
			if (searchTerm.trim() != "") {
				String[] searchTerms = Utility.getEachKeyword(searchTerm);
				StringBuffer sqlExpression = new StringBuffer(SQL_SEARCH_DIAGRAM);
				if (searchTerms.length == 1 && searchTerms[0].trim().length() != 0) {
					String term = searchTerms[0].toUpperCase();
					sqlExpression.append(" WHERE ");
					sqlExpression.append(" ( UPPER(d.KEYWORDS) LIKE '%" + term + "%' "
								+ " OR UPPER(d.LOCATION) LIKE '%" + term + "%' "
								+ " OR UPPER(d.DIAGRAM_NAME) LIKE '%" + term + "%' "
								+ " OR UPPER(d.DIAGRAM_DESC) LIKE '%" + term + "%' "
								+ " OR UPPER(u.FIRST_NAME) LIKE  '%" + term + "%'"
								+ " OR UPPER(u.LAST_NAME)  LIKE  '%" + term + "%')");

				} else {
					sqlExpression.append(" WHERE ");
					sqlExpression.append("(( ");
					sqlExpression.append(Utility.formatSearchTerm(searchTerms, "d.KEYWORDS", " AND "));
					sqlExpression.append(" ) OR ( ");
					sqlExpression.append(Utility.formatSearchTerm(searchTerms, "d.LOCATION", " AND "));
					sqlExpression.append(" ) OR ( ");
					sqlExpression.append(Utility.formatSearchTerm(searchTerms, "d.DIAGRAM_NAME", " AND "));
					sqlExpression.append(" ) OR ( ");
					sqlExpression.append(Utility.formatSearchTerm(searchTerms, "d.DIAGRAM_DESC", " AND "));
					sqlExpression.append(" ) OR ( ");
					sqlExpression.append(Utility.formatSearchTerm(searchTerms, "u.FIRST_NAME",	" AND "));
					sqlExpression.append(" ) OR ( ");
					sqlExpression.append(Utility.formatSearchTerm(searchTerms, "u.LAST_NAME", " AND"));
					sqlExpression.append(" ))");
				}
				sqlExpression.append( " AND d.LL_DIAGRAM_STATUS_ID = l.LL_ID " +
			    	"	AND d.DIAGRAM_ID = duj.DIAGRAM_ID(+) " +
			    	"	AND (d.LL_DIAGRAM_STATUS_ID = ? or d.IS_PUBLIC = 'Y' or duj.USER_ID = ? or d.CREATED_BY = ?)" +
			    	"   AND u.USER_ID = d.CREATED_BY " +
			    	"   AND d.LOCKED_BY_USER_ID = u2.USER_ID(+) " +
			    	" ORDER BY ");
				if(sortBy.compareToIgnoreCase(Constants.DIAGRAM_CREATED_DATE) == 0)
					sqlExpression.append( sortBy + " DESC" );
				else
					sqlExpression.append( " upper(" + sortBy + ")");
				
				pstmt = conn.prepareStatement(sqlExpression.toString());
			} else {
				String sql = "";
				if(sortBy.compareToIgnoreCase(Constants.DIAGRAM_CREATED_DATE) == 0)
					sql = SQL_SELECT_DIAGRAMS_BY_USER +  sortBy + " DESC";
				else
					sql = SQL_SELECT_DIAGRAMS_BY_USER + " upper(" + sortBy + ")";
				
				pstmt = conn.prepareStatement(sql);
			}
			pstmt.setLong(1, Constants.LL_PUBLISHED_STATUS);
			pstmt.setLong(2, userId);
			pstmt.setLong(3, userId);
			pstmt2 = conn.prepareStatement(SQL_SELECT_USERS_BY_DIAGRAMID);
			rs = pstmt.executeQuery();
			
			while(rs.next()) {
				Diagram diagram = new Diagram();
				diagram.setId(new Long(rs.getLong("DIAGRAM_ID")));
				diagram.setName(rs.getString("DIAGRAM_NAME"));
				if(rs.getString("DIAGRAM_DESC") != null)
					diagram.setDescription(rs.getString("DIAGRAM_DESC"));
				else
					diagram.setDescription("");
				
				if(rs.getString("LOCATION") != null)
					diagram.setLocation(rs.getString("LOCATION"));
				else
					diagram.setLocation("");
				
				diagram.setKeywords(rs.getString("KEYWORDS"));
				
				if(rs.getString("IS_GOLD_SEAL").equalsIgnoreCase("Y"))
					diagram.setGoldSeal(true);
				else
					diagram.setGoldSeal(false);
				
				if(rs.getString("IS_PUBLIC").equalsIgnoreCase("Y"))
					diagram.setOpenToPublic(true);
				else
					diagram.setOpenToPublic(false);
				
				diagram.setDiagramStatus(rs.getString("DIAGRAM_STATUS"));
				diagram.setDiagramStatusId(rs.getLong("LL_DIAGRAM_STATUS_ID"));
				
				diagram.setCreatedBy(rs.getLong("CREATED_BY"));
				diagram.setCreatedDate(rs.getTimestamp("CREATED_DT"));
				diagram.setUpdatedBy(rs.getLong("LAST_UPDATED_BY"));
				diagram.setUpdatedDate(rs.getTimestamp("LAST_UPDATED_DT"));
				
				User creatorUser = new User();
				creatorUser.setUserId(rs.getLong("CREATED_BY"));
				creatorUser.setFirstName(rs.getString("CREATOR_FIRST_NAME"));
				creatorUser.setLastName(rs.getString("CREATOR_LAST_NAME"));
				diagram.setCreatorUser(creatorUser);	

				User lockedUser = new User();
				lockedUser.setUserId(rs.getLong("LOCKED_BY_USER_ID"));
				if(lockedUser.getUserId() != 0) {
					diagram.setLocked(true);
					lockedUser.setFirstName(rs.getString("lockedUserFN"));
					lockedUser.setLastName(rs.getString("lockedUserLN"));
					
				} else
					diagram.setLocked(false);
				diagram.setLockedUser(lockedUser);
				
				pstmt2.setLong(1, diagram.getId().longValue());

				rs2 = pstmt2.executeQuery();
				List userList = new ArrayList();
				while(rs2.next()) {
					User user = new User();
					user.setUserId(rs2.getLong("USER_ID"));
					user.setFirstName(rs2.getString("FIRST_NAME"));
					user.setLastName(rs2.getString("LAST_NAME"));
					userList.add(user);
				}
				diagram.setUserList(userList);
				diagrams.add(diagram);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
			closeResources(pstmt, rs);
		}
		return diagrams;
    }
    
    private static final String SQL_SELECT_PUBLISHED_DIAGRAMS = " SELECT DIAGRAM_ID,"
		+ "     DIAGRAM_NAME, DIAGRAM_DESC, LL_DIAGRAM_STATUS_ID, " 
		+ "		IS_GOLD_SEAL, IS_PUBLIC, LIST_ITEM_CODE as DIAGRAM_STATUS  "  
		+ "	FROM  ICD_DIAGRAM, P_LIST_ITEM " 
		+ " WHERE LL_DIAGRAM_STATUS_ID = LL_ID "
		+ "		AND LL_DIAGRAM_STATUS_ID = ? "
		+ "  ORDER BY upper(DIAGRAM_NAME)";
    
    public List getPublishedDiagrams() throws DAOException {
    	List diagrams = new ArrayList();
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {

			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_PUBLISHED_DIAGRAMS);
			pstmt.setLong(1, Constants.LL_PUBLISHED_STATUS);
			rs = pstmt.executeQuery();
			
			while(rs.next()) {
				Diagram diagram = new Diagram();
				diagram.setId(new Long(rs.getLong("DIAGRAM_ID")));
				diagram.setName(rs.getString("DIAGRAM_NAME"));
				if(rs.getString("DIAGRAM_DESC") != null)
					diagram.setDescription(rs.getString("DIAGRAM_DESC"));
				else
					diagram.setDescription("");
				
				if(rs.getString("IS_GOLD_SEAL").equalsIgnoreCase("Y"))
					diagram.setGoldSeal(true);
				else
					diagram.setGoldSeal(false);
				if(rs.getString("IS_PUBLIC").equalsIgnoreCase("Y"))
					diagram.setOpenToPublic(true);
				else
					diagram.setOpenToPublic(false);
				diagram.setDiagramStatus(rs.getString("DIAGRAM_STATUS"));
				diagram.setDiagramStatusId(rs.getLong("LL_DIAGRAM_STATUS_ID"));
				diagrams.add(diagram);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return diagrams;
    }
    
    private static final String SQL_CHECK_DIAGRAM = " SELECT DIAGRAM_ID"
		+ "	FROM  ICD_DIAGRAM d " 
		+ " WHERE UPPER(DIAGRAM_NAME) = ? ";
    
    public long checkDiagram(String name) throws DAOException {
    	long diagramId = 0;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {

			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_CHECK_DIAGRAM);
			pstmt.setString(1, name.toUpperCase());
			rs = pstmt.executeQuery();
			
			if(rs.next()) {
				diagramId = rs.getLong(1);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return diagramId;
    }
    

    private static final String SQL_SELECT_DIAGRAM = " SELECT d.DIAGRAM_NAME AS DIAGRAM_NAME, d.DIAGRAM_DESC AS DIAGRAM_DESC, "+
    " 	d.DIAGRAM_COLOR AS DIAGRAM_COLOR, d.DIAGRAM_WIDTH AS DIAGRAM_WIDTH, d.DIAGRAM_HEIGHT AS DIAGRAM_HEIGHT, "+
    " 	d.LL_DIAGRAM_STATUS_ID AS DIAGRAM_STATUS_ID, lk.LIST_ITEM_CODE AS DIAGRAM_STATUS, "+
    " 	d.IS_GOLD_SEAL AS IS_GOLD_SEAL, d.IS_PUBLIC,"+
    " 	d.LAST_UPDATED_BY AS LAST_UPDATED_BY, d.LAST_UPDATED_DT AS LAST_UPDATED_DT,"+
    " 	d.CREATED_BY AS CREATED_BY, d.CREATED_DT AS CREATED_DT,  "+
    "	u.FIRST_NAME AS CREATORFN, u.LAST_NAME AS CREATORLN,"+
    "	u2.FIRST_NAME AS lockedUserFN, u2.LAST_NAME AS lockedUserLN, "+
    "	d.LOCKED_BY_USER_ID as LOCKED_BY_USER_ID"+
    " FROM ICD_DIAGRAM d, P_LIST_ITEM lk, ICD_USER u,icd_user u2"+
    " WHERE d.DIAGRAM_ID = ? "+
    "	AND d.LL_DIAGRAM_STATUS_ID = lk.LL_ID "+
    "	AND u.USER_ID = d.CREATED_BY"+
    "	AND d.LOCKED_BY_USER_ID = u2.USER_ID(+)";

	private static final String SQL_SELECT_SHAPES_BY_DIAGRAMID = " select * " 
		+ " from (SELECT v.SHAPE_ID as SHAPE_ID, "
	    + "     v.SHAPE_COLOR as COLOR, v.SHAPE_LABEL as LABEL, v.SHAPE_WIDTH as WIDTH, "
	    + "		v.SHAPE_HEIGHT as HEIGHT, v.SHAPE_THICKNESS as THICKNESS,"  
	    + "		v.PARENT_SHAPE_ID as PARENT_SHAPE_ID, v.SHAPE_TYPE as SHAPE_TYPE, "
	    + "		v.LL_LEGEND_FILTER_ID AS FILTER_ATTRIBUTE, v.LL_SHAPE_LABEL_SYMBOL_ID as LL_SHAPE_LABEL_SYMBOL_ID, " 
	    + "		v.TOP_LEFT_CORNER_PT_X as X, v. TOP_LEFT_CORNER_PT_Y as Y, " 
	    + "		v.SHAPE_BIN_INDEX as BIN_INDEX, "
	    + "		LEVEL as SHAPE_LEVEL  "
	    + " FROM V_ICD_DIAGRAM_SHAPE v "
	    + " WHERE  v.DIAGRAM_ID = ? "
	    + " START WITH v.parent_shape_id is null " 
	    + " CONNECT BY PRIOR v.SHAPE_ID = v.parent_shape_id  ) "
	    + " order by SHAPE_LEVEL ";
	
	private static final String SQL_SELECT_LINES_BY_DIAGRAMID = " SELECT v.LINE_ID as LINE_ID,"
		+ "     v.LINE_COLOR as COLOR,v.LINE_TYPE as LINE_TYPE, v.LINE_THICKNESS as THICKNESS, " 
		+ "		v.POINT_ID as POINT_ID, v.PT_X as X, v.PT_Y as Y"
		+ "  FROM  V_ICD_DIAGRAM_LINE v "
		+ "  WHERE v.DIAGRAM_ID = ? ";
	
    private static final String SQL_SELECT_CONNECTOR_BY_DIAGRAMID = " SELECT SHAPE_LINE_JOIN_ID, SHAPE_ID, "
		+ "       LINE_ID, EDGE_INDEX, START_PT " 
		+ "	FROM   ICD_SHAPE_LINE_JOIN slj "
		+ " WHERE slj.DIAGRAM_ID = ? "
		+ "	ORDER BY SHAPE_ID";

    
    private static final String SQL_SELECT_LINKAGES_BY_DIAGRAMID = "SELECT SHAPE_FROM_ID, SHAPE_TO_ID, CITATION_ID " 
		+ "	FROM V_ICD_SHAPE_LINKAGES " 
		+ "	WHERE  DIAGRAM_ID = ? "
		+ "	ORDER BY SHAPE_FROM_ID, SHAPE_TO_ID ";
    
    private static final String SQL_SELECT_SHAPE_ATTR_BY_DIAGRAMID = "SELECT v.SHAPE_ID as SHAPE_ID, " 
    	+ " 	v.ATTRIBUTE_TYPE_ID as ATTRIBUTE_TYPE_ID, v.ATTRIBUTE_VALUE_ID as ATTRIBUTE_VALUE_ID " 
		+ "	FROM V_ICD_SHAPE_ATTRIBUTES v " 
		+ "	WHERE  v.DIAGRAM_ID = ? "
		+ "	ORDER BY v.SHAPE_ID ";

    private static final String SQL_SELECT_NC_BIN_BY_DIAGRAMID = " SELECT DIAGRAM_BIN_INDEX "
    	+ " FROM ICD_NON_COLLAPSIBLE_BIN" 
    	+ "	WHERE  DIAGRAM_ID = ? ";
    
    private static final String SQL_SELECT_DIAGRAM_USER_JOIN_BY_DIAGRAMID = " SELECT DIAGRAM_USER_JOIN_ID, DIAGRAM_ID, USER_ID " 
		 + " FROM ICD_DIAGRAM_USER_JOIN " 
		 + " WHERE DIAGRAM_ID = ? ";
    
	public Diagram getDiagram(long diagramId) throws DAOException {
		System.out.println("Load diagram id " + diagramId);
		Diagram diagram = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Map  shapeMap = new HashMap();
		Map  lineMap = new HashMap();
		
		if(diagramId == 0) 
			throw new DAOException("Get Diagram: Invalid name");

		try {

			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_DIAGRAM);
			pstmt.setLong(1, diagramId);

			rs = pstmt.executeQuery();

			if (rs.next()) {
				diagram = new Diagram();
				diagram.setId(new Long(diagramId));
				diagram.setName(rs.getString("DIAGRAM_NAME"));
				if(rs.getString("DIAGRAM_DESC") != null)
					diagram.setDescription(rs.getString("DIAGRAM_DESC"));
				diagram.setColor(new Long(rs.getLong("DIAGRAM_COLOR")));
				diagram.setWidth(new Integer(rs.getInt("DIAGRAM_WIDTH")));
				diagram.setHeight(new Integer(rs.getInt("DIAGRAM_HEIGHT")));
				diagram.setColor(new Long(rs.getLong("DIAGRAM_COLOR")));
				if(rs.getString("IS_GOLD_SEAL").equalsIgnoreCase("Y"))
					diagram.setGoldSeal(true);
				else
					diagram.setGoldSeal(false);
				if(rs.getString("IS_PUBLIC").equalsIgnoreCase("Y"))
					diagram.setOpenToPublic(true);
				else
					diagram.setOpenToPublic(false);
				diagram.setDiagramStatus(rs.getString("DIAGRAM_STATUS"));
				diagram.setDiagramStatusId(rs.getLong("DIAGRAM_STATUS_ID"));
				diagram.setCreatedBy(rs.getLong("CREATED_BY"));
				diagram.setCreatedDate(rs.getTimestamp("CREATED_DT"));
				diagram.setUpdatedBy(rs.getLong("LAST_UPDATED_BY"));
				diagram.setUpdatedDate(rs.getTimestamp("LAST_UPDATED_DT"));
				
				User creatorUser = new User();
				creatorUser.setUserId(rs.getLong("CREATED_BY"));
				creatorUser.setFirstName(rs.getString("CREATORFN"));
				creatorUser.setLastName(rs.getString("CREATORLN"));
					

				User lockedUser = new User();
				lockedUser.setUserId(rs.getLong("LOCKED_BY_USER_ID"));
				if(lockedUser.getUserId() != 0) {
					diagram.setLocked(true);
					lockedUser.setFirstName(rs.getString("lockedUserFN"));
					lockedUser.setLastName(rs.getString("lockedUserLN"));
					
				} else
					diagram.setLocked(false);
				diagram.setLockedUser(lockedUser);
					
					
				closeResources(pstmt, rs);
				
				//get ALL NON COLLAPSIBLE BINS
				pstmt = conn.prepareStatement(SQL_SELECT_NC_BIN_BY_DIAGRAMID);
				pstmt.setLong(1, diagramId);
	            rs = pstmt.executeQuery();
	            
	            while (rs.next()) 
	            {
	            	diagram.getNonCollapsibleBins().add(new Integer(rs.getInt("DIAGRAM_BIN_INDEX")));
	            }
	            closeResources(pstmt, rs);
	            
				//get all shapes for diagramid
				pstmt = conn.prepareStatement(SQL_SELECT_SHAPES_BY_DIAGRAMID);
				pstmt.setLong(1, diagramId);
	            rs = pstmt.executeQuery();
	            
	            while (rs.next()) 
	            {
	            	Shape shape = null;
	            	String type = rs.getString("SHAPE_TYPE");
	            	if (type.equalsIgnoreCase(Constants.RECTANGLE_TYPE)) {
						shape = new Rectangle();
					} else if (type.equalsIgnoreCase(Constants.ROUND_RECTANGLE_TYPE)) {
						shape = new RoundRectangle();
					} else if (type.equalsIgnoreCase(Constants.ELLIPSE_TYPE)) {
						shape = new Ellipse();
					} else if (type.equalsIgnoreCase(Constants.HEXAGON_TYPE)) {
						shape = new Hexagon();
					} else if (type.equalsIgnoreCase(Constants.OCTAGON_TYPE)) {
						shape = new Octagon();
					} else if (type.equalsIgnoreCase(Constants.PENTAGON_TYPE)) {
						shape = new Pentagon();
					} else {
						shape = new Shape();
					}
	            	
	            	shape.setId(new Long(rs.getLong("SHAPE_ID")));
	            	shape.setLabel(rs.getString("LABEL"));
	            	shape.setColor(new Long(rs.getLong("COLOR")));
	            	shape.setThickness(new Integer(rs.getInt("THICKNESS")));
	            	shape.setCwidth(new Integer(rs.getInt("WIDTH")));
	            	shape.setCheight(new Integer(rs.getInt("HEIGHT")));
	            	shape.setLegendType(new Long(rs.getLong("FILTER_ATTRIBUTE")));
	            	shape.setLabelSymbolType(new Long(rs.getLong("LL_SHAPE_LABEL_SYMBOL_ID")));
	            	shape.setBinIndex(new Integer(rs.getInt("BIN_INDEX")));
	            	Point originPoint = new Point();
	            	originPoint.setX(new Double(rs.getDouble("X")));
	            	originPoint.setY(new Double(rs.getDouble("Y")));
	            	shape.setOrigin(originPoint);
	            	Long parentId = new Long(rs.getLong("PARENT_SHAPE_ID"));

	            	//notes: get parent id and find parent from map
	            	// assign this shape as children of parent and
	            	// found parent shape as parent to this shape object
	            	if(parentId != null) {
		            	Shape parentShape = (Shape)shapeMap.get(parentId);
		            	if(parentShape != null) {
		            		shape.setParentShape(parentShape);
		            		parentShape.getChildShapes().add(shape);
		            	}
	            	}
	                shapeMap.put(shape.getId(), shape);
	                
	            }
	            closeResources(pstmt, rs);
	            
	            //get all lines for diagramid
	            pstmt = conn.prepareStatement(SQL_SELECT_LINES_BY_DIAGRAMID);
				pstmt.setLong(1, diagramId);
	            rs = pstmt.executeQuery();
	            
	            while (rs.next()) 
	            {
	            	Long lineId = new Long(rs.getLong("LINE_ID"));
	            	Line line = (Line)lineMap.get(lineId);
	            	if(lineMap.get(lineId) != null ) {
	            		Point point = new Point();
		            	point.setId(new Long(rs.getLong("POINT_ID")));
		            	point.setX(new Double(rs.getDouble("X")));
		            	point.setY(new Double(rs.getDouble("Y")));
		            	line.getPoints().add(point);
	            	} else {
	            		String type = rs.getString("LINE_TYPE");
	            		if (type.equalsIgnoreCase(Constants.SINGLEARROWLINE_TYPE)) {
	            			System.out.println("SALine "  + type);
							line = new SArrowLine();
						} else {
							System.out.println("Line "  + type);
							line = new Line();
						}
		            	line.setId(lineId);
		            	line.setColor(new Long(rs.getLong("COLOR")));
		            	line.setThickness(new Integer(rs.getInt("THICKNESS")));

		            	Point point = new Point();
		            	point.setId(new Long(rs.getLong("POINT_ID")));
		            	point.setX(new Double(rs.getDouble("X")));
		            	point.setY(new Double(rs.getDouble("Y")));
		            	line.getPoints().add(point);
	
		                lineMap.put(line.getId(), line);
	            	}
	                
	            }
	            closeResources(pstmt, rs);
	            
				//connectors
				pstmt = conn.prepareStatement(SQL_SELECT_CONNECTOR_BY_DIAGRAMID);
				pstmt.setLong(1, diagramId);
	            rs = pstmt.executeQuery();
	            
	            while (rs.next()) 
	            {
	            	//Long connectorId = new Long(rs.getLong("SHAPE_LINE_JOIN_ID"));
	            	Long shapeId = new Long(rs.getLong("SHAPE_ID"));
	            	Long lineId = new Long(rs.getLong("LINE_ID"));
	            	Integer index = new Integer(rs.getInt("EDGE_INDEX"));
	            	Boolean start = rs.getString("START_PT").equals("0") ? new Boolean(false) : new Boolean(true) ;
	            	Shape shape = (Shape)shapeMap.get(shapeId);
	            	Line line = (Line) lineMap.get(lineId);
	            	Connector c = new Connector(shape, line, index, start);
	            	shape.getConnectors().add(c);
	            	if(start.booleanValue() == true)
	            		line.setFirstConnector(c);
	            	else
	            		line.setLastConnector(c);
	            }
	            closeResources(pstmt, rs);
	            
	            //linkages
	            pstmt = conn.prepareStatement(SQL_SELECT_LINKAGES_BY_DIAGRAMID);
				pstmt.setLong(1, diagramId);
	            rs = pstmt.executeQuery();
	            
	            while (rs.next()) 
	            {
	            	Long shapeFromId = new Long(rs.getLong("SHAPE_FROM_ID"));
	            	Long shapeToId = new Long(rs.getLong("SHAPE_TO_ID"));
	            	Long citationId = new Long(rs.getLong("CITATION_ID"));

	            	Shape shapeFrom = (Shape)shapeMap.get(shapeFromId);
	            	boolean found = false;
	            	for (int i = 0; i < shapeFrom.getLinkages().size(); i++) {
						if (((Linkage) shapeFrom.getLinkages().get(i)).getShape().getId().compareTo(shapeToId) == 0) {

							found = true;
							((Linkage) shapeFrom.getLinkages().get(i)).getCitationIds().add(citationId);
						}

					}
	            	if(!found) {
	            		Linkage linkage = new Linkage();
	            		linkage.setShape((Shape)shapeMap.get(shapeToId));
	            		linkage.getCitationIds().add(citationId);
	            		shapeFrom.getLinkages().add(linkage);
	            	}

	            }
	            closeResources(pstmt, rs);
	            //shape attribbutes
	            pstmt = conn.prepareStatement(SQL_SELECT_SHAPE_ATTR_BY_DIAGRAMID);
	            pstmt.setLong(1, diagramId);
	            rs = pstmt.executeQuery();
	            
	            while (rs.next()) 
	            {
	            	long shapeId = rs.getLong("SHAPE_ID");
	            	long type = rs.getLong("ATTRIBUTE_TYPE_ID");
	            	long value = rs.getLong("ATTRIBUTE_VALUE_ID");

	            	Shape shape = (Shape)shapeMap.get(new Long(shapeId));
	            	boolean found = false;
	            	for (int i = 0; i < shape.getAttributes().size(); i++) {
						if (((ShapeAttribute) shape.getAttributes().get(i)).getType() == type) {

							found = true;
							((ShapeAttribute) shape.getAttributes().get(i)).getValues().add(new Long(value));
						}
					}
	            	if(!found) {
	            		ShapeAttribute attr = new ShapeAttribute();
	            		attr.setType(type);
	            		attr.getValues().add(new Long(value));
	            		shape.getAttributes().add(attr);
	            	}
	            }
	            closeResources(pstmt, rs);
	            
	            pstmt = conn.prepareStatement(SQL_SELECT_DIAGRAM_USER_JOIN_BY_DIAGRAMID);
	            pstmt.setLong(1, diagramId);
	            rs = pstmt.executeQuery();
				List userList = new ArrayList();
				while(rs.next()) {
					User user = new User();
					user.setUserId(rs.getLong("USER_ID"));
					System.out.println("select " + user.getUserId());
					userList.add(user);
				}
				diagram.setUserList(userList);
	            for(Iterator i = shapeMap.keySet().iterator(); i.hasNext(); ) {
	            	diagram.getShapes().add(shapeMap.get((Long)i.next()));
	            }

	            for(Iterator i = lineMap.keySet().iterator(); i.hasNext(); ) {
	            	diagram.getLines().add(lineMap.get((Long)i.next()));
	            }
			}
            
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}

		return diagram;
	}

	private static final String SQL_SELECT_DIAGRAM_REV = " SELECT rd.REV_DIAGRAM_ID AS DIAGRAM_ID, " +
		"	rd.ORIGINAL_DIAGRAM_ID ORIGINAL_ID, " +
		"	rd.DIAGRAM_NAME AS DIAGRAM_NAME, " +
		"	rd.DIAGRAM_DESC AS DIAGRAM_DESC, "+
	    " 	rd.DIAGRAM_COLOR AS DIAGRAM_COLOR, rd.DIAGRAM_WIDTH AS DIAGRAM_WIDTH, rd.DIAGRAM_HEIGHT AS DIAGRAM_HEIGHT, "+
	    " 	d.LL_DIAGRAM_STATUS_ID AS DIAGRAM_STATUS_ID, lk.LIST_ITEM_CODE AS DIAGRAM_STATUS, "+
	    " 	d.IS_GOLD_SEAL AS IS_GOLD_SEAL, d.IS_PUBLIC,"+
	    " 	d.LAST_UPDATED_BY AS LAST_UPDATED_BY, d.LAST_UPDATED_DT AS LAST_UPDATED_DT,"+
	    " 	d.CREATED_BY AS CREATED_BY, d.CREATED_DT AS CREATED_DT,  "+
	    "	u.FIRST_NAME AS CREATORFN, u.LAST_NAME AS CREATORLN,"+
	    "	u2.FIRST_NAME AS lockedUserFN, u2.LAST_NAME AS lockedUserLN, "+
	    "	d.LOCKED_BY_USER_ID as LOCKED_BY_USER_ID"+
	    " FROM ICD_DIAGRAM_REV rd, ICD_DIAGRAM d, P_LIST_ITEM lk, ICD_USER u,icd_user u2"+
	    " WHERE rd.REV_DIAGRAM_ID = ? " +
	    "	and rd.ORIGINAL_DIAGRAM_ID = d.DIAGRAM_ID "+
	    "	AND d.LL_DIAGRAM_STATUS_ID = lk.LL_ID "+
	    "	AND u.USER_ID = d.CREATED_BY"+
	    "	AND d.LOCKED_BY_USER_ID = u2.USER_ID(+)";

	private static final String SQL_SELECT_SHAPES_BY_DIAGRAMID_REV = " select * " 
		+ " from (SELECT v.REV_SHAPE_ID as SHAPE_ID, "
	    + "     v.SHAPE_COLOR as COLOR, v.SHAPE_LABEL as LABEL, v.SHAPE_WIDTH as WIDTH, "
	    + "		v.SHAPE_HEIGHT as HEIGHT, v.SHAPE_THICKNESS as THICKNESS,"  
	    + "		v.REV_PARENT_SHAPE_ID as PARENT_SHAPE_ID, v.SHAPE_TYPE as SHAPE_TYPE, "
	    + "		v.LL_LEGEND_FILTER_ID AS FILTER_ATTRIBUTE, v.LL_SHAPE_LABEL_SYMBOL_ID as LL_SHAPE_LABEL_SYMBOL_ID, " 
	    + "		v.TOP_LEFT_CORNER_PT_X as X, v. TOP_LEFT_CORNER_PT_Y as Y, " 
	    + "		v.SHAPE_BIN_INDEX as BIN_INDEX, "
	    + "		LEVEL as SHAPE_LEVEL  "
	    + " FROM V_ICD_DIAGRAM_SHAPE_REV v "
	    + " WHERE  v.REV_DIAGRAM_ID = ? "
	    + " START WITH v.rev_parent_shape_id is null " 
	    + " CONNECT BY PRIOR v.REV_SHAPE_ID = v.rev_parent_shape_id  ) "
	    + " order by SHAPE_LEVEL ";
	
	private static final String SQL_SELECT_LINES_BY_DIAGRAMID_REV = " SELECT v.REV_LINE_ID as LINE_ID,"
		+ "     v.LINE_COLOR as COLOR, v.LINE_TYPE as LINE_TYPE, v.LINE_THICKNESS as THICKNESS, " 
		+ "		v.REV_POINT_ID as POINT_ID, v.PT_X as X, v.PT_Y as Y"
		+ "  FROM  V_ICD_DIAGRAM_LINE_REV  v "
		+ "  WHERE v.REV_DIAGRAM_ID = ? ";
	
    private static final String SQL_SELECT_CONNECTOR_BY_DIAGRAMID_REV = " SELECT REV_SHAPE_LINE_JOIN_ID AS SHAPE_LINE_JOIN_ID," 
    	+	" REV_SHAPE_ID AS SHAPE_ID, "
		+ "      REV_LINE_ID AS LINE_ID, EDGE_INDEX, START_PT " 
		+ "	FROM   ICD_SHAPE_LINE_JOIN_REV slj "
		+ " WHERE slj.REV_DIAGRAM_ID = ? "
		+ "	ORDER BY REV_SHAPE_ID";

    
    private static final String SQL_SELECT_LINKAGES_BY_DIAGRAMID_REV = "SELECT REV_SHAPE_FROM_ID, REV_SHAPE_TO_ID, CITATION_ID " 
		+ "	FROM V_ICD_SHAPE_LINKAGES_REV  " 
		+ "	WHERE  REV_DIAGRAM_ID = ? "
		+ "	ORDER BY REV_SHAPE_FROM_ID, REV_SHAPE_TO_ID ";
    
    private static final String SQL_SELECT_SHAPE_ATTR_BY_DIAGRAMID_REV = "SELECT v.REV_SHAPE_ID as SHAPE_ID, " 
    	+ " 	v.ATTRIBUTE_TYPE_ID as ATTRIBUTE_TYPE_ID, v.ATTRIBUTE_VALUE_ID as ATTRIBUTE_VALUE_ID " 
		+ "	FROM V_ICD_SHAPE_ATTRIBUTES_REV  v " 
		+ "	WHERE  v.REV_DIAGRAM_ID = ? "
		+ "	ORDER BY v.REV_SHAPE_ID ";

    private static final String SQL_SELECT_NC_BIN_BY_DIAGRAMID_REV = " SELECT DIAGRAM_BIN_INDEX "
    	+ " FROM ICD_NON_COLLAPSIBLE_BIN_REV" 
    	+ "	WHERE  REV_DIAGRAM_ID = ? ";
    
	
	//note: last updated, diagram status, lockED USER, USER LIST etc are from original diagram
    public Diagram getRevisionDiagramById(long revDiagramId) throws DAOException {
		System.out.println("Load revision diagram id " + revDiagramId);
		Diagram diagram = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		Map  shapeMap = new HashMap();
		Map  lineMap = new HashMap();
		
		if(revDiagramId == 0) 
			throw new DAOException("Get Diagram: Invalid name");

		try {

			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_DIAGRAM_REV);
			pstmt.setLong(1, revDiagramId);

			rs = pstmt.executeQuery();

			if (rs.next()) {
				diagram = new Diagram();
				diagram.setId(new Long(revDiagramId));
				diagram.setOrginialId(new Long(rs.getLong("ORIGINAL_ID")));
				diagram.setName(rs.getString("DIAGRAM_NAME"));
				if(rs.getString("DIAGRAM_DESC") != null)
					diagram.setDescription(rs.getString("DIAGRAM_DESC"));
				diagram.setColor(new Long(rs.getLong("DIAGRAM_COLOR")));
				diagram.setWidth(new Integer(rs.getInt("DIAGRAM_WIDTH")));
				diagram.setHeight(new Integer(rs.getInt("DIAGRAM_HEIGHT")));
				diagram.setColor(new Long(rs.getLong("DIAGRAM_COLOR")));
				if(rs.getString("IS_GOLD_SEAL").equalsIgnoreCase("Y"))
					diagram.setGoldSeal(true);
				else
					diagram.setGoldSeal(false);
				if(rs.getString("IS_PUBLIC").equalsIgnoreCase("Y"))
					diagram.setOpenToPublic(true);
				else
					diagram.setOpenToPublic(false);
				diagram.setDiagramStatus(rs.getString("DIAGRAM_STATUS"));
				diagram.setDiagramStatusId(rs.getLong("DIAGRAM_STATUS_ID"));
				diagram.setCreatedBy(rs.getLong("CREATED_BY"));
				diagram.setCreatedDate(rs.getTimestamp("CREATED_DT"));
				diagram.setUpdatedBy(rs.getLong("LAST_UPDATED_BY"));
				diagram.setUpdatedDate(rs.getTimestamp("LAST_UPDATED_DT"));
				
				User creatorUser = new User();
				creatorUser.setUserId(rs.getLong("CREATED_BY"));
				creatorUser.setFirstName(rs.getString("CREATORFN"));
				creatorUser.setLastName(rs.getString("CREATORLN"));
					

				User lockedUser = new User();
				lockedUser.setUserId(rs.getLong("LOCKED_BY_USER_ID"));
				if(lockedUser.getUserId() != 0) {
					diagram.setLocked(true);
					lockedUser.setFirstName(rs.getString("lockedUserFN"));
					lockedUser.setLastName(rs.getString("lockedUserLN"));
					
				} else
					diagram.setLocked(false);
				diagram.setLockedUser(lockedUser);
					
					
				closeResources(pstmt, rs);
				
				//get ALL NON COLLAPSIBLE BINS
				pstmt = conn.prepareStatement(SQL_SELECT_NC_BIN_BY_DIAGRAMID_REV);
				pstmt.setLong(1, revDiagramId);
	            rs = pstmt.executeQuery();
	            
	            while (rs.next()) 
	            {
	            	diagram.getNonCollapsibleBins().add(new Integer(rs.getInt("DIAGRAM_BIN_INDEX")));
	            }
	            closeResources(pstmt, rs);
	            
				//get all shapes for diagramid
				pstmt = conn.prepareStatement(SQL_SELECT_SHAPES_BY_DIAGRAMID_REV);
				pstmt.setLong(1, revDiagramId);
	            rs = pstmt.executeQuery();
	            
	            while (rs.next()) 
	            {
	            	Shape shape = null;
	            	String type = rs.getString("SHAPE_TYPE");
	            	if (type.equalsIgnoreCase(Constants.RECTANGLE_TYPE)) {
						shape = new Rectangle();
					} else if (type.equalsIgnoreCase(Constants.ROUND_RECTANGLE_TYPE)) {
						shape = new RoundRectangle();
					} else if (type.equalsIgnoreCase(Constants.ELLIPSE_TYPE)) {
						shape = new Ellipse();
					} else if (type.equalsIgnoreCase(Constants.HEXAGON_TYPE)) {
						shape = new Hexagon();
					} else if (type.equalsIgnoreCase(Constants.OCTAGON_TYPE)) {
						shape = new Octagon();
					} else if (type.equalsIgnoreCase(Constants.PENTAGON_TYPE)) {
						shape = new Pentagon();
					} else {
						shape = new Shape();
					}
	            	
	            	shape.setId(new Long(rs.getLong("SHAPE_ID")));
	            	shape.setLabel(rs.getString("LABEL"));
	            	shape.setColor(new Long(rs.getLong("COLOR")));
	            	shape.setThickness(new Integer(rs.getInt("THICKNESS")));
	            	shape.setCwidth(new Integer(rs.getInt("WIDTH")));
	            	shape.setCheight(new Integer(rs.getInt("HEIGHT")));
	            	shape.setLegendType(new Long(rs.getLong("FILTER_ATTRIBUTE")));
	            	shape.setLabelSymbolType(new Long(rs.getLong("LL_SHAPE_LABEL_SYMBOL_ID")));
	            	shape.setBinIndex(new Integer(rs.getInt("BIN_INDEX")));
	            	Point originPoint = new Point();
	            	originPoint.setX(new Double(rs.getDouble("X")));
	            	originPoint.setY(new Double(rs.getDouble("Y")));
	            	shape.setOrigin(originPoint);
	            	Long parentId = new Long(rs.getLong("PARENT_SHAPE_ID"));

	            	//notes: get parent id and find parent from map
	            	// assign this shape as children of parent and
	            	// found parent shape as parent to this shape object
	            	if(parentId != null) {
		            	Shape parentShape = (Shape)shapeMap.get(parentId);
		            	if(parentShape != null) {
		            		shape.setParentShape(parentShape);
		            		parentShape.getChildShapes().add(shape);
		            	}
	            	}
	                shapeMap.put(shape.getId(), shape);
	                
	            }
	            closeResources(pstmt, rs);
	            
	            //get all lines for diagramid
	            pstmt = conn.prepareStatement(SQL_SELECT_LINES_BY_DIAGRAMID_REV);
				pstmt.setLong(1, revDiagramId);
	            rs = pstmt.executeQuery();
	            
	            while (rs.next()) 
	            {
	            	Long lineId = new Long(rs.getLong("LINE_ID"));
	            	Line line = (Line)lineMap.get(lineId);
	            	if(lineMap.get(lineId) != null ) {
	            		Point point = new Point();
		            	point.setId(new Long(rs.getLong("POINT_ID")));
		            	point.setX(new Double(rs.getDouble("X")));
		            	point.setY(new Double(rs.getDouble("Y")));
		            	line.getPoints().add(point);
	            	} else {
	            		String type = rs.getString("LINE_TYPE");
	            		if (type.equalsIgnoreCase(Constants.SINGLEARROWLINE_TYPE)) {
	            			System.out.println("SALine "  + type);
							line = new SArrowLine();
						} else {
							System.out.println("Line "  + type);
							line = new Line();
						}
		            	line.setId(lineId);
		            	line.setColor(new Long(rs.getLong("COLOR")));
		            	line.setThickness(new Integer(rs.getInt("THICKNESS")));

		            	Point point = new Point();
		            	point.setId(new Long(rs.getLong("POINT_ID")));
		            	point.setX(new Double(rs.getDouble("X")));
		            	point.setY(new Double(rs.getDouble("Y")));
		            	line.getPoints().add(point);
	
		                lineMap.put(line.getId(), line);
	            	}
	                
	            }
	            closeResources(pstmt, rs);
	            
				//connectors
				pstmt = conn.prepareStatement(SQL_SELECT_CONNECTOR_BY_DIAGRAMID_REV);
				pstmt.setLong(1, revDiagramId);
	            rs = pstmt.executeQuery();
	            
	            while (rs.next()) 
	            {
	            	//Long connectorId = new Long(rs.getLong("SHAPE_LINE_JOIN_ID"));
	            	Long shapeId = new Long(rs.getLong("SHAPE_ID"));
	            	Long lineId = new Long(rs.getLong("LINE_ID"));
	            	Integer index = new Integer(rs.getInt("EDGE_INDEX"));
	            	Boolean start = rs.getString("START_PT").equals("0") ? new Boolean(false) : new Boolean(true) ;
	            	Shape shape = (Shape)shapeMap.get(shapeId);
	            	Line line = (Line) lineMap.get(lineId);
	            	Connector c = new Connector(shape, line, index, start);
	            	shape.getConnectors().add(c);
	            	if(start.booleanValue() == true)
	            		line.setFirstConnector(c);
	            	else
	            		line.setLastConnector(c);
	            }
	            closeResources(pstmt, rs);
	            
	            //linkages
	            pstmt = conn.prepareStatement(SQL_SELECT_LINKAGES_BY_DIAGRAMID_REV);
				pstmt.setLong(1, revDiagramId);
	            rs = pstmt.executeQuery();
	            
	            while (rs.next()) 
	            {
	            	Long shapeFromId = new Long(rs.getLong("REV_SHAPE_FROM_ID"));
	            	Long shapeToId = new Long(rs.getLong("REV_SHAPE_TO_ID"));
	            	Long citationId = new Long(rs.getLong("CITATION_ID"));

	            	Shape shapeFrom = (Shape)shapeMap.get(shapeFromId);
	            	boolean found = false;
	            	for (int i = 0; i < shapeFrom.getLinkages().size(); i++) {
						if (((Linkage) shapeFrom.getLinkages().get(i)).getShape().getId().compareTo(shapeToId) == 0) {

							found = true;
							((Linkage) shapeFrom.getLinkages().get(i)).getCitationIds().add(citationId);
						}

					}
	            	if(!found) {
	            		Linkage linkage = new Linkage();
	            		linkage.setShape((Shape)shapeMap.get(shapeToId));
	            		linkage.getCitationIds().add(citationId);
	            		shapeFrom.getLinkages().add(linkage);
	            	}

	            }
	            closeResources(pstmt, rs);
	            //shape attribbutes
	            pstmt = conn.prepareStatement(SQL_SELECT_SHAPE_ATTR_BY_DIAGRAMID_REV);
	            pstmt.setLong(1, revDiagramId);
	            rs = pstmt.executeQuery();
	            
	            while (rs.next()) 
	            {
	            	long shapeId = rs.getLong("REV_SHAPE_ID");
	            	long type = rs.getLong("ATTRIBUTE_TYPE_ID");
	            	long value = rs.getLong("ATTRIBUTE_VALUE_ID");

	            	Shape shape = (Shape)shapeMap.get(new Long(shapeId));
	            	boolean found = false;
	            	for (int i = 0; i < shape.getAttributes().size(); i++) {
						if (((ShapeAttribute) shape.getAttributes().get(i)).getType() == type) {

							found = true;
							((ShapeAttribute) shape.getAttributes().get(i)).getValues().add(new Long(value));
						}
					}
	            	if(!found) {
	            		ShapeAttribute attr = new ShapeAttribute();
	            		attr.setType(type);
	            		attr.getValues().add(new Long(value));
	            		shape.getAttributes().add(attr);
	            	}
	            }
	            closeResources(pstmt, rs);
	            
	            pstmt = conn.prepareStatement(SQL_SELECT_DIAGRAM_USER_JOIN_BY_DIAGRAMID);
	            pstmt.setLong(1, revDiagramId);
	            rs = pstmt.executeQuery();
				List userList = new ArrayList();
				while(rs.next()) {
					User user = new User();
					user.setUserId(rs.getLong("USER_ID"));
					System.out.println("select " + user.getUserId());
					userList.add(user);
				}
				diagram.setUserList(userList);
	            for(Iterator i = shapeMap.keySet().iterator(); i.hasNext(); ) {
	            	diagram.getShapes().add(shapeMap.get((Long)i.next()));
	            }

	            for(Iterator i = lineMap.keySet().iterator(); i.hasNext(); ) {
	            	diagram.getLines().add(lineMap.get((Long)i.next()));
	            }
			}
            
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}

		return diagram;
	}
	
	private final String SQL_INSERT_DIAGRAM = "INSERT INTO ICD_DIAGRAM ( " 
							+ "		DIAGRAM_ID, DIAGRAM_NAME, DIAGRAM_DESC, DIAGRAM_COLOR, DIAGRAM_WIDTH, DIAGRAM_HEIGHT, LL_DIAGRAM_STATUS_ID, "
							+ "		CREATED_DT, CREATED_BY, LAST_UPDATED_BY,  IS_GOLD_SEAL, IS_PUBLIC, LOCKED_BY_USER_ID, KEYWORDS, LOCATION, LAST_UPDATED_DT) "
							+ "VALUES ( ?, ?, ?, ?, ?, ?,  ?, ?, ?, ?,  ?, ?, ?, ?, ?, SYSDATE)";
	
	private final String SQL_INSERT_SHAPE = "INSERT INTO ICD_SHAPE ("
			   + " 		SHAPE_ID, SHAPE_LABEL, "
			   + "  	SHAPE_COLOR, SHAPE_WIDTH, SHAPE_HEIGHT, "
			   + "  	SHAPE_THICKNESS, SHAPE_TYPE, LL_LEGEND_FILTER_ID, " 
			   + "		TOP_LEFT_CORNER_PT_X, TOP_LEFT_CORNER_PT_Y, SHAPE_BIN_INDEX, LL_SHAPE_LABEL_SYMBOL_ID) "
			   + " VALUES ( ?, ?, "
			   + "   	?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
	
	private final String SQL_INSERT_DIAGRAM_SHAPE_JOIN = "INSERT INTO ICD_DIAGRAM_SHAPE_JOIN ("
			   + " 	DIAGRAM_SHAPE_JOIN_ID, DIAGRAM_ID, SHAPE_ID) "
			   + " VALUES ( S_ICD_DIAGRAM_SHAPE_JOIN_ID.nextval, ?, ? )";
	
	private final String SQL_INSERT_POINT = "INSERT INTO ICD_POINT ("
			   + "	POINT_ID, PT_X, PT_Y) "
			   + " VALUES ( ?,? ,? )";
	
	
	private final String SQL_INSERT_LINE = "INSERT INTO ICD_LINE (" 
			+ "   LINE_ID, LINE_TYPE, LINE_COLOR, LINE_THICKNESS) "
			+ "VALUES (?, ?, ?, ?)";
	
	private final String SQL_INSERT_DIAGRAM_LINE_JOIN = "INSERT INTO ICD_DIAGRAM_LINE_JOIN ("
		   + "	DIAGRAM_LINE_JOIN_ID, DIAGRAM_ID, LINE_ID) "
		   + "VALUES ( S_ICD_DIAGRAM_LINE_JOIN_ID.nextVal, ?, ?)";
	
	private final String SQL_INSERT_LINE_POINT_JOIN = "INSERT INTO ICD_LINE_POINT_JOIN (" 
			   + "LINE_POINT_JOIN_ID, LINE_ID, POINT_ID) " 
			   + "VALUES ( S_ICD_LINE_POINT_JOIN_ID.nextVal, ?, ?)";
	
	private final String SQL_UPDATE_SHAPE_WITH_PARENTID = "UPDATE ICD_SHAPE "
			+ "		SET    PARENT_SHAPE_ID = ? "
			+ "WHERE  SHAPE_ID = ? ";
	
	private final String SQL_INSERT_SHAPE_LINE_JOIN = "INSERT INTO ICD_SHAPE_LINE_JOIN ( "
			   + "	SHAPE_LINE_JOIN_ID, DIAGRAM_ID, SHAPE_ID, "
			   + "	LINE_ID, EDGE_INDEX, START_PT) "
			   + "VALUES ( S_ICD_SHAPE_LINE_JOIN_ID.nextVal, ?, ?,"
			    + "		?, ?, ?)";
	
	private final String SQL_INSERT_SHAPE_LINKAGE = "INSERT INTO ICD_SHAPE_LINKAGE ("
			   + "	SHAPE_LINKAGE_ID, SHAPE_FROM_ID, SHAPE_TO_ID) " 
			   + "VALUES ( ?, ?, ? )";
	
	private final String SQL_INSERT_LINKAGE_CITATION_JOIN = "INSERT INTO ICD_LINKAGE_CITATION_JOIN ("
		   + "	LINKAGE_CITATION_JOIN_ID, SHAPE_LINKAGE_ID, CITATION_ID) " 
		   + "VALUES ( S_ICD_LINKAGE_CITATION_JOIN_ID.nextVal, ?, ? )";
		
	private final String SQL_INSERT_SHAPE_ATTRIBUTE = "INSERT INTO ICD_SHAPE_ATTRIBUTE ("
			   + " SHAPE_ATTRIBUTE_ID, SHAPE_ID,  "
			   + " LL_ATTRIBUTE_TYPE_ID, LL_DISPLAY_DIAGRAM_FILTER_ID) "
			   + " VALUES ( S_ICD_SHAPE_ATTRIBUTE_ID.nextVal, ?, ?, ?)";
	
	private final String SQL_INSERT_NON_COLLAPSIBLE_BIN = "INSERT INTO ICD_NON_COLLAPSIBLE_BIN ("
			 +  " NON_COLLAPSIBLE_BIN_ID, DIAGRAM_ID, DIAGRAM_BIN_INDEX)" 
			 +	"  VALUES ( S_ICD_NON_COLLAPSIBLE_BIN_ID.nextVal, ?, ?)";
	
	private static final String SQL_INSERT_DIAGRAM_USER_JOIN = "INSERT INTO ICD_DIAGRAM_USER_JOIN (" +
	   	"	DIAGRAM_USER_JOIN_ID, DIAGRAM_ID, USER_ID)" + 
	   	"	VALUES ( S_ICD_DIAGRAM_USER_JOIN_ID.nextVal, ?, ?)";


	private static final String SQL_UPDATE_DIAGRAM_LAST_UPDATED_BY = " UPDATE ICD_DIAGRAM " +
			" SET LAST_UPDATED_DT = sysdate, " +
			" 	  LAST_UPDATED_BY = ? " +
			" 	  WHERE DIAGRAM_ID = ? ";
	
	public long saveDiagram(Diagram diagram) throws DAOException {
		return saveDiagram(null, diagram);
	}
	
	public long saveDiagram(Connection connection, Diagram diagram) throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;
		PreparedStatement pstmt2 = null;
		PreparedStatement pstmt3 = null;
		PreparedStatement pstmt4 = null;
		PreparedStatement pstmt5 = null;
		PreparedStatement pstmt6 = null;
		ResultSet rs = null;

		long diagramId = 0;
		
		try {
			if(connection == null) {//NEW DIAGRAM
	            conn = getConnection();
	            conn.setAutoCommit(false);
	            pstmt = conn.prepareStatement("SELECT S_ICD_DIAGRAM_ID.nextVal ID FROM DUAL");
				rs = pstmt.executeQuery();
	            
	            if (rs.next()) {
	            	diagramId = rs.getLong("ID");
	            } else {
	                throw new DAOException("Failed to retrieve S_ICD_DIAGRAM_ID Sequence Number");
	            }
	            closeResources(pstmt, rs);
	            pstmt = conn.prepareStatement(SQL_INSERT_DIAGRAM);
	            pstmt.setLong(1, diagramId);
	            pstmt.setString(2, diagram.getName());
	            if(diagram.getDescription() != null)
					pstmt.setString(3, diagram.getDescription());
				else
					pstmt.setNull(3, Types.VARCHAR);
	            pstmt.setLong(4, diagram.getColor().longValue());
	            pstmt.setInt(5, diagram.getWidth().intValue());
	            pstmt.setInt(6, diagram.getHeight().intValue());
	            pstmt.setLong(7, diagram.getDiagramStatusId());
	            
	            if(diagram.getCreatedDate() != null)
	            	pstmt.setTimestamp(8, new Timestamp(diagram.getCreatedDate().getTime()));
	            else
	            	pstmt.setTimestamp(8, new Timestamp(new java.util.Date().getTime()));
	            
	            pstmt.setLong(9, diagram.getCreatedBy());
	            
	            if(diagram.getUpdatedBy() != 0)
	            	pstmt.setLong(10, diagram.getUpdatedBy());
	            else
	            	pstmt.setLong(10, diagram.getCreatedBy());
	            
	            if(diagram.isGoldSeal())
					pstmt.setString(11, "Y");
				else
					pstmt.setString(11, "N");
							
	            if(diagram.isOpenToPublic())
					pstmt.setString(12, "Y");
				else
					pstmt.setString(12, "N");
				if(diagram.getLockedUser().getUserId() != 0)
					pstmt.setLong(13, diagram.getLockedUser().getUserId());
				else
					pstmt.setNull(13, Types.NULL);
	            
				if(diagram.getKeywords() != null)
					pstmt.setString(14, diagram.getKeywords());
				else
					pstmt.setNull(14, Types.VARCHAR);
	            
	            if(diagram.getLocation() != null)
					pstmt.setString(15, diagram.getLocation());
				else
					pstmt.setNull(15, Types.VARCHAR);
        	} else {//UPDATING EXISTING DIAGRAM
        		//if update, just update the last updated by information
        		conn = connection;
        		diagramId = diagram.getId().longValue();
                if (diagramId == 0) {
                    throw new DAOException("Insert Diagram Failed: Invalid Diagram Id");
                }
                pstmt = conn.prepareStatement(SQL_UPDATE_DIAGRAM_LAST_UPDATED_BY);
                if(diagram.getUpdatedBy() != 0)
                	pstmt.setLong(1, diagram.getUpdatedBy());
                else
                	pstmt.setLong(1, diagram.getCreatedBy());
                pstmt.setLong(2, diagramId);
        	}
            if (pstmt.executeUpdate() != 1) {
                throw new DAOException("insert/update Diagram Failed");
            }
            closeResources(pstmt);
            //INSERT NON COLLAPSIBLE BINS
            if(diagram.getNonCollapsibleBins().size() > 0) {
	            pstmt = conn.prepareStatement(SQL_INSERT_NON_COLLAPSIBLE_BIN);
	    		for (Iterator i = diagram.getNonCollapsibleBins().iterator(); i.hasNext(); ) {
	    			pstmt.setLong(1, diagramId);
	    			pstmt.setInt(2, ((Integer)i.next()).intValue());
	    			pstmt.addBatch();
	    		}
	    		pstmt.executeBatch();
	    		closeResources(pstmt);
            }
    		
            if(diagram.getShapes().size() > 0) {
            	long shapeId = 0;
            	pstmt = conn.prepareStatement(SQL_INSERT_SHAPE);
                pstmt2 = conn.prepareStatement(SQL_INSERT_DIAGRAM_SHAPE_JOIN);
                pstmt3 = conn.prepareStatement("SELECT S_ICD_SHAPE_ID.nextVal ID FROM DUAL");

	            for (Iterator i = diagram.getShapes().iterator(); i.hasNext(); ) {
	            	rs = pstmt3.executeQuery();
	                
	                if (rs.next()) {
	                	shapeId = rs.getLong("ID");
	                } else {
	                    throw new DAOException("Failed to retrieve S_ICD_SHAPE_ID Sequence Number");
	                }
	                closeResources(rs);

            		Shape shape = (Shape)i.next();
	            	//insert shape
	            	shape.setId(new Long(shapeId));
	            	pstmt.setLong(1, shapeId);
	            	pstmt.setString(2, shape.getLabel());
	            	//pstmt.setLong(3, 0);
	            	pstmt.setLong(3, shape.getColor().longValue());
	            	pstmt.setInt(4, shape.getCwidth().intValue());
	            	pstmt.setInt(5, shape.getCheight().intValue());
	            	pstmt.setInt(6, shape.getThickness().intValue());
	            	if (shape instanceof Rectangle) {
						pstmt.setString(7, Constants.RECTANGLE_TYPE);
					} else if (shape instanceof RoundRectangle) {
						pstmt.setString(7, Constants.ROUND_RECTANGLE_TYPE);
					} else if (shape instanceof Ellipse) {
						pstmt.setString(7, Constants.ELLIPSE_TYPE);
					} else if (shape instanceof Hexagon) {
						pstmt.setString(7, Constants.HEXAGON_TYPE);
					} else if (shape instanceof Octagon) {
						pstmt.setString(7, Constants.OCTAGON_TYPE);
					} else if (shape instanceof Pentagon) {
						pstmt.setString(7, Constants.PENTAGON_TYPE);
					} else {
						pstmt.setString(7, Constants.OTHER_TYPE);
					}
	            	//pstmt.setString(8, shape.getModelType());
	            	pstmt.setLong(8, shape.getLegendType().longValue());
	            	pstmt.setDouble(9, shape.getOrigin().getX().doubleValue());
	            	pstmt.setDouble(10, shape.getOrigin().getY().doubleValue());
	            	pstmt.setInt(11, shape.getBinIndex().intValue());
	            	if(shape.getLabelSymbolType() != null && shape.getLabelSymbolType().compareTo(new Long(0)) != 0) {
	            		pstmt.setLong(12, shape.getLabelSymbolType().longValue());
	            	}
	            	else
	            		pstmt.setNull(12,  Types.NULL);
	                pstmt.addBatch(); 
	                
	                //insert diagram and shape link
	                pstmt2.setLong(1, diagramId);
	                pstmt2.setLong(2, shapeId);
	                pstmt2.addBatch();
	                
	                System.out.println("Shape " + shape.getId() + shape.getLabel());
	            }
	            pstmt.executeBatch();
	            pstmt2.executeBatch();

	            closeResources(pstmt);
	            closeResources(pstmt2);
				closeResources(pstmt3);

            }

				
	        if(diagram.getLines().size() > 0) {
	            	pstmt = conn.prepareStatement(SQL_INSERT_LINE);
		            pstmt2 = conn.prepareStatement(SQL_INSERT_DIAGRAM_LINE_JOIN);
		            pstmt3 = conn.prepareStatement(SQL_INSERT_POINT);
		            pstmt4 = conn.prepareStatement(SQL_INSERT_LINE_POINT_JOIN);
		            pstmt5 = conn.prepareStatement("SELECT S_ICD_LINE_ID.nextVal ID FROM DUAL");
	                pstmt6 = conn.prepareStatement("SELECT S_ICD_POINT_ID.nextVal ID FROM DUAL");
		            for (Iterator i = diagram.getLines().iterator(); i.hasNext(); ) {
		            	long lineId = 0; 
		            	rs = pstmt5.executeQuery();
		                
		                if (rs.next()) {
		                	lineId = rs.getLong("ID");
		                } else {
		                    throw new DAOException("Failed to retrieve S_ICD_LINE_ID Sequence Number");
		                }
		                closeResources(rs);
		            	Line line = (Line)i.next();
		            	
		            	//insert line
		            	line.setId(new Long(lineId));
		            	pstmt.setLong(1, lineId);
		            	if (line instanceof SArrowLine)
							pstmt.setString(2, Constants.SINGLEARROWLINE_TYPE);
						else
							pstmt.setString(2, Constants.LINE_TYPE);
		            	pstmt.setLong(3, line.getColor().longValue());
		            	pstmt.setInt(4, line.getThickness().intValue());
		                pstmt.addBatch();
		                
		                //insert diagram and line link
		                pstmt2.setLong(1, diagramId);
		                pstmt2.setLong(2, lineId);
		                pstmt2.addBatch();
		                
		                //insert all the points of line in point and line_point_join table
		                if(line.getPoints() != null) {
		                	for (Iterator j = line.getPoints().iterator(); j.hasNext(); ) {
		                		Point point = (Point)j.next();
		                		long pointId = 0; 
		                		rs = pstmt6.executeQuery();
				                
				                if (rs.next()) {
				                	pointId = rs.getLong("ID");
				                } else {
				                    throw new DAOException("Failed to retrieve S_ICD_POINT_ID Sequence Number");
				                }
				                closeResources(rs);
				                
		                		pstmt3.setLong(1, pointId);
		                		pstmt3.setDouble(2, point.getX().doubleValue());
		                		pstmt3.setDouble(3, point.getY().doubleValue());
		                		pstmt3.addBatch();

				                pstmt4.setLong(1, lineId);
				                pstmt4.setLong(2, pointId);
				                pstmt4.addBatch();
		                	}
		                }
		            }
		            pstmt.executeBatch();
		            pstmt2.executeBatch();
		            pstmt3.executeBatch();
		            pstmt4.executeBatch();
		            closeResources(pstmt);
		            closeResources(pstmt2);
					closeResources(pstmt3);
					closeResources(pstmt4);
					closeResources(pstmt5);
					closeResources(pstmt6);
	        }
			//iterate shapes
			//update parent id , insert connectors, linakges, and shape attributes.
			if(diagram.getShapes().size() > 0) {

				pstmt = conn.prepareStatement(SQL_UPDATE_SHAPE_WITH_PARENTID);
				pstmt2 = conn.prepareStatement(SQL_INSERT_SHAPE_LINE_JOIN);
				pstmt3 = conn.prepareStatement(SQL_INSERT_SHAPE_LINKAGE);
				pstmt4 = conn.prepareStatement("SELECT S_ICD_SHAPE_LINKAGE_ID.nextVal ID FROM DUAL");
				pstmt5 = conn.prepareStatement(SQL_INSERT_LINKAGE_CITATION_JOIN);
				pstmt6 = conn.prepareStatement(SQL_INSERT_SHAPE_ATTRIBUTE);
				for (Iterator i = diagram.getShapes().iterator(); i.hasNext(); ) {
					//update parent id
					Shape shape = (Shape)i.next();
					if(shape.getParentShape() != null) {
						pstmt.setLong(1, shape.getParentShape().getId().longValue());
		            	pstmt.setLong(2, shape.getId().longValue());
		                pstmt.addBatch();
					}
					//update connector
					if(shape.getConnectors().size() > 0) {
						for (Iterator j = shape.getConnectors().iterator(); j.hasNext(); ) {
							Connector c = (Connector) j.next(); 

							pstmt2.setLong(1, diagramId);
							pstmt2.setLong(2, shape.getId().longValue());
							pstmt2.setLong(3, c.getLine().getId().longValue());
							pstmt2.setInt(4, c.getIndex().intValue());
							if(c.getStart().booleanValue() == true)
								pstmt2.setString(5, "1");
							else 
								pstmt2.setString(5, "0");
							pstmt2.addBatch();
						}
					}
					//insert linkages
					if(shape.getLinkages().size() > 0) {
						for (Iterator k = shape.getLinkages().iterator(); k.hasNext(); ) {
							long linkageId = 0; 
			            	rs = pstmt4.executeQuery();
			                
			                if (rs.next()) {
			                	linkageId = rs.getLong("ID");
			                } else {
			                    throw new DAOException("Failed to retrieve S_ICD_SHAPE_LINKAGE_ID Sequence Number");
			                }
			                closeResources(rs);
							Linkage linkage = (Linkage)k.next();
							pstmt3.setLong(1, linkageId);
							pstmt3.setLong(2, shape.getId().longValue());
			            	pstmt3.setLong(3, linkage.getShape().getId().longValue());
			                pstmt3.addBatch();
			                for (Iterator l = linkage.getCitationIds().iterator(); l.hasNext(); ) {
			                	long value = 0;
			                	Object o = l.next();
			                	if(o instanceof Long)
			                		value = ((Long) o).longValue();
			                	else if(o instanceof Integer)
			                		value = ((Integer)o).longValue();
			                	pstmt5.setLong(1, linkageId);
			                	pstmt5.setLong(2, value);
			                	pstmt5.addBatch();
			                }
						}
					}
					//INSERT ATTRIBUTES
					if(shape.getAttributes().size() > 0) {
						for (Iterator k = shape.getAttributes().iterator(); k.hasNext(); ) {
							ShapeAttribute attr = (ShapeAttribute) k.next();
			                for (Iterator l = attr.getValues().iterator(); l.hasNext(); ) {
			                	pstmt6.setLong(1, shape.getId().longValue());
			                	pstmt6.setLong(2, attr.getType());
			                	long value = 0;
			                	Object o = l.next();
			                	if(o instanceof Long)
			                		value = ((Long) o).longValue();
			                	else if(o instanceof Integer)
			                		value = ((Integer)o).longValue();
			                	pstmt6.setLong(3, value);
			                	pstmt6.addBatch();
			                }
						}
					}
				}
				pstmt.executeBatch();
				pstmt2.executeBatch();
				pstmt3.executeBatch();
				pstmt5.executeBatch();
				pstmt6.executeBatch();
				//insert user list
				closeResources(pstmt);
//				pstmt = conn.prepareStatement(SQL_INSERT_DIAGRAM_USER_JOIN);
//	            for (Iterator i = diagram.getUserList().iterator(); i.hasNext(); ) {
//	            	User user = (User)i.next();
//		            pstmt.setLong(1, diagramId);
//		            pstmt.setLong(2, user.getUserId());
//		            System.out.println("insert " + user.getUserId());
//		            pstmt.addBatch();
//	            }
//	            pstmt.executeBatch();
			}
			
//			if(connection == null) 
//				conn.commit();
			diagram.setId(new Long(diagramId));
			saveRevisionDiagram(conn, diagram);
			conn.commit();
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			sqle.printStackTrace();
			throw new DAOException(sqle);
		} finally {
			try {
				if(connection == null) 
					conn.rollback();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			if(connection == null) 
				closeResources(conn, pstmt);
			closeResources(pstmt2);
			closeResources(pstmt3);
			closeResources(pstmt4);
			closeResources(pstmt5);
			closeResources(pstmt6);
		}
		System.out.println("save diagram id " + diagramId);
		
		return diagramId;
	}
	
	private final String SQL_INSERT_DIAGRAM_REV = "INSERT INTO ICD_DIAGRAM_REV ( " 
		+ "		REV_DIAGRAM_ID, ORIGINAL_DIAGRAM_ID, DIAGRAM_NAME, DIAGRAM_DESC, DIAGRAM_COLOR, DIAGRAM_WIDTH, DIAGRAM_HEIGHT, LL_DIAGRAM_STATUS_ID, "
		+ "		CREATED_DT, CREATED_BY, LAST_UPDATED_BY,  IS_GOLD_SEAL, IS_PUBLIC, LOCKED_BY_USER_ID, KEYWORDS, LOCATION, LAST_UPDATED_DT) "
		+ "VALUES ( ?, ?, ?, ?, ?, ?, ?,  ?, ?, ?, ?,  ?, ?, ?, ?, ?, SYSDATE)";

	private final String SQL_INSERT_SHAPE_REV = "INSERT INTO ICD_SHAPE_REV ("
		+ " 		REV_SHAPE_ID, SHAPE_LABEL, "
		+ "  	SHAPE_COLOR, SHAPE_WIDTH, SHAPE_HEIGHT, "
		+ "  	SHAPE_THICKNESS, SHAPE_TYPE, LL_LEGEND_FILTER_ID, " 
		+ "		TOP_LEFT_CORNER_PT_X, TOP_LEFT_CORNER_PT_Y, SHAPE_BIN_INDEX, LL_SHAPE_LABEL_SYMBOL_ID) "
		+ " VALUES ( ?, ?, "
		+ "   	?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
	
	private final String SQL_INSERT_DIAGRAM_SHAPE_JOIN_REV = "INSERT INTO ICD_DIAGRAM_SHAPE_JOIN_REV ("
		+ " 	REV_DIAGRAM_SHAPE_JOIN_ID, REV_DIAGRAM_ID, REV_SHAPE_ID) "
		+ " VALUES ( S_REV_DIAGRAM_SHAPE_JOIN_ID.nextval, ?, ? )";
	
	private final String SQL_INSERT_POINT_REV = "INSERT INTO ICD_POINT_REV ("
		+ "	REV_POINT_ID, PT_X, PT_Y) "
		+ " VALUES ( ?,? ,? )";
	
	
	private final String SQL_INSERT_LINE_REV = "INSERT INTO ICD_LINE_REV (" 
		+ "   REV_LINE_ID, LINE_TYPE, LINE_COLOR, LINE_THICKNESS) "
		+ "VALUES (?, ?, ?, ?)";
	
	private final String SQL_INSERT_DIAGRAM_LINE_JOIN_REV = "INSERT INTO ICD_DIAGRAM_LINE_JOIN_REV ("
		+ "	REV_DIAGRAM_LINE_JOIN_ID, REV_DIAGRAM_ID, REV_LINE_ID) "
		+ "VALUES ( S_REV_DIAGRAM_LINE_JOIN_ID.nextVal, ?, ?)";
	
	private final String SQL_INSERT_LINE_POINT_JOIN_REV = "INSERT INTO ICD_LINE_POINT_JOIN_REV (" 
		+ "REV_LINE_POINT_JOIN_ID, REV_LINE_ID, REV_POINT_ID) " 
		+ "VALUES ( S_REV_LINE_POINT_JOIN_ID.nextVal, ?, ?)";
	
	private final String SQL_UPDATE_SHAPE_WITH_PARENTID_REV = "UPDATE ICD_SHAPE_REV "
		+ "		SET    PARENT_REV_SHAPE_ID = ? "
		+ "WHERE  REV_SHAPE_ID = ? ";
	
	private final String SQL_INSERT_SHAPE_LINE_JOIN_REV = "INSERT INTO ICD_SHAPE_LINE_JOIN_REV ( "
		+ "	REV_SHAPE_LINE_JOIN_ID, REV_DIAGRAM_ID, REV_SHAPE_ID, "
		+ "	REV_LINE_ID, EDGE_INDEX, START_PT) "
		+ "VALUES ( S_REV_SHAPE_LINE_JOIN_ID.nextVal, ?, ?,"
		+ "		?, ?, ?)";
	
	private final String SQL_INSERT_SHAPE_LINKAGE_REV = "INSERT INTO ICD_SHAPE_LINKAGE_REV ("
		+ "	REV_SHAPE_LINKAGE_ID, REV_SHAPE_FROM_ID, REV_SHAPE_TO_ID) " 
		+ "VALUES ( ?, ?, ? )";
	
	private final String SQL_INSERT_LINKAGE_CITATION_JOIN_REV = "INSERT INTO ICD_LINKAGE_CITATION_JOIN_REV ("
		+ "	REV_LINKAGE_CITATION_JOIN_ID, REV_SHAPE_LINKAGE_ID, CITATION_ID) " 
		+ "VALUES ( S_REV_LINKAGE_J_ID.nextVal, ?, ? )";
		
	private final String SQL_INSERT_SHAPE_ATTRIBUTE_REV = "INSERT INTO ICD_SHAPE_ATTRIBUTE_REV ("
		+ " REV_SHAPE_ATTRIBUTE_ID, REV_SHAPE_ID,  "
		+ " LL_ATTRIBUTE_TYPE_ID, LL_DISPLAY_DIAGRAM_FILTER_ID) "
		+ " VALUES ( S_REV_SHAPE_ATTRIBUTE_ID.nextVal, ?, ?, ?)";
	
	private final String SQL_INSERT_NON_COLLAPSIBLE_BIN_REV = "INSERT INTO ICD_NON_COLLAPSIBLE_BIN_REV ("
		+  " REV_NON_COLLAPSIBLE_BIN_ID, REV_DIAGRAM_ID, DIAGRAM_BIN_INDEX)" 
		+	"  VALUES ( S_REV_NON_COLLAPSIBLE_BIN_ID.nextVal, ?, ?)";
	
	private static final String SQL_INSERT_DIAGRAM_USER_JOIN_REV= "INSERT INTO ICD_DIAGRAM_USER_JOIN_REV (" +
		"	REV_DIAGRAM_USER_JOIN_ID, REV_DIAGRAM_ID, USER_ID)" + 
		"	VALUES ( S_REV_DIAGRAM_USER_JOIN_ID.nextVal, ?, ?)";

	public long saveRevisionDiagram(Connection connection, Diagram diagram) throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;
		PreparedStatement pstmt2 = null;
		PreparedStatement pstmt3 = null;
		PreparedStatement pstmt4 = null;
		PreparedStatement pstmt5 = null;
		PreparedStatement pstmt6 = null;
		ResultSet rs = null;

		long diagramId = 0;
		
		try {

        	conn = connection;

			pstmt = conn.prepareStatement("SELECT S_REV_DIAGRAM_ID.nextVal ID FROM DUAL");
			rs = pstmt.executeQuery();
            
            if (rs.next()) {
            	diagramId = rs.getLong("ID");
            } else {
                throw new DAOException("Failed to retrieve S_REV_DIAGRAM_ID Sequence Number");
            }
            closeResources(pstmt, rs);
			//diagramId = getSequenceId("SEQ_DIAGRAM_ID");	   
            if (diagramId == 0) {
                throw new DAOException("Insert Diagram Failed: Invalid Diagram Id");
            }
			pstmt = conn.prepareStatement(SQL_INSERT_DIAGRAM_REV);
            pstmt.setLong(1, diagramId);
            pstmt.setLong(2, diagram.getId().longValue());
            pstmt.setString(3, diagram.getName());
            if(diagram.getDescription() != null)
				pstmt.setString(4, diagram.getDescription());
			else
				pstmt.setNull(4, Types.VARCHAR);
            pstmt.setLong(5, diagram.getColor().longValue());
            pstmt.setInt(6, diagram.getWidth().intValue());
            pstmt.setInt(7, diagram.getHeight().intValue());
            pstmt.setLong(8, diagram.getDiagramStatusId());
            
            if(diagram.getCreatedDate() != null)
            	pstmt.setTimestamp(9, new Timestamp(diagram.getCreatedDate().getTime()));
            else
            	pstmt.setTimestamp(9, new Timestamp(new java.util.Date().getTime()));
            
            pstmt.setLong(10, diagram.getCreatedBy());
            
            if(diagram.getUpdatedBy() != 0)
            	pstmt.setLong(11, diagram.getUpdatedBy());
            else
            	pstmt.setLong(11, diagram.getCreatedBy());
            
            if(diagram.isGoldSeal())
				pstmt.setString(12, "Y");
			else
				pstmt.setString(12, "N");
						
            if(diagram.isOpenToPublic())
				pstmt.setString(13, "Y");
			else
				pstmt.setString(13, "N");
			if(diagram.getLockedUser().getUserId() != 0)
				pstmt.setLong(14, diagram.getLockedUser().getUserId());
			else
				pstmt.setNull(14, Types.NULL);
            
			if(diagram.getKeywords() != null)
				pstmt.setString(15, diagram.getKeywords());
			else
				pstmt.setNull(15, Types.VARCHAR);
            
            if(diagram.getLocation() != null)
				pstmt.setString(16, diagram.getLocation());
			else
				pstmt.setNull(16, Types.VARCHAR);
            
            if (pstmt.executeUpdate() != 1) {
                throw new DAOException("insert Diagram Failed");
            }
            closeResources(pstmt);
            //INSERT NON COLLAPSIBLE BINS
            if(diagram.getNonCollapsibleBins().size() > 0) {
	            pstmt = conn.prepareStatement(SQL_INSERT_NON_COLLAPSIBLE_BIN_REV);
	    		for (Iterator i = diagram.getNonCollapsibleBins().iterator(); i.hasNext(); ) {
	    			pstmt.setLong(1, diagramId);
	    			pstmt.setInt(2, ((Integer)i.next()).intValue());
	    			pstmt.addBatch();
	    		}
	    		pstmt.executeBatch();
	    		closeResources(pstmt);
            }
    		
            if(diagram.getShapes().size() > 0) {
            	long shapeId = 0;
            	pstmt = conn.prepareStatement(SQL_INSERT_SHAPE_REV);
                pstmt2 = conn.prepareStatement(SQL_INSERT_DIAGRAM_SHAPE_JOIN_REV);
                pstmt3 = conn.prepareStatement("SELECT S_REV_SHAPE_ID.nextVal ID FROM DUAL");

	            for (Iterator i = diagram.getShapes().iterator(); i.hasNext(); ) {
	            	rs = pstmt3.executeQuery();
	                
	                if (rs.next()) {
	                	shapeId = rs.getLong("ID");
	                } else {
	                    throw new DAOException("Failed to retrieve S_REV_SHAPE_ID Sequence Number");
	                }
	                closeResources(rs);

            		Shape shape = (Shape)i.next();
	            	//insert shape
	            	shape.setId(new Long(shapeId));
	            	pstmt.setLong(1, shapeId);
	            	pstmt.setString(2, shape.getLabel());
	            	//pstmt.setLong(3, 0);
	            	pstmt.setLong(3, shape.getColor().longValue());
	            	pstmt.setInt(4, shape.getCwidth().intValue());
	            	pstmt.setInt(5, shape.getCheight().intValue());
	            	pstmt.setInt(6, shape.getThickness().intValue());
	            	if (shape instanceof Rectangle) {
						pstmt.setString(7, Constants.RECTANGLE_TYPE);
					} else if (shape instanceof RoundRectangle) {
						pstmt.setString(7, Constants.ROUND_RECTANGLE_TYPE);
					} else if (shape instanceof Ellipse) {
						pstmt.setString(7, Constants.ELLIPSE_TYPE);
					} else if (shape instanceof Hexagon) {
						pstmt.setString(7, Constants.HEXAGON_TYPE);
					} else if (shape instanceof Octagon) {
						pstmt.setString(7, Constants.OCTAGON_TYPE);
					} else if (shape instanceof Pentagon) {
						pstmt.setString(7, Constants.PENTAGON_TYPE);
					} else {
						pstmt.setString(7, Constants.OTHER_TYPE);
					}
	            	//pstmt.setString(8, shape.getModelType());
	            	pstmt.setLong(8, shape.getLegendType().longValue());
	            	pstmt.setDouble(9, shape.getOrigin().getX().doubleValue());
	            	pstmt.setDouble(10, shape.getOrigin().getY().doubleValue());
	            	pstmt.setInt(11, shape.getBinIndex().intValue());
	            	if(shape.getLabelSymbolType() != null && shape.getLabelSymbolType().compareTo(new Long(0)) != 0) {
	            		pstmt.setLong(12, shape.getLabelSymbolType().longValue());
	            	}
	            	else
	            		pstmt.setNull(12,  Types.NULL);
	                pstmt.addBatch(); 
	                
	                //insert diagram and shape link
	                pstmt2.setLong(1, diagramId);
	                pstmt2.setLong(2, shapeId);
	                pstmt2.addBatch();
	                
	                System.out.println("Shape " + shape.getId() + shape.getLabel());
	            }
	            pstmt.executeBatch();
	            pstmt2.executeBatch();

	            closeResources(pstmt);
	            closeResources(pstmt2);
				closeResources(pstmt3);

            }

				
	        if(diagram.getLines().size() > 0) {
	            	pstmt = conn.prepareStatement(SQL_INSERT_LINE_REV);
		            pstmt2 = conn.prepareStatement(SQL_INSERT_DIAGRAM_LINE_JOIN_REV);
		            pstmt3 = conn.prepareStatement(SQL_INSERT_POINT_REV);
		            pstmt4 = conn.prepareStatement(SQL_INSERT_LINE_POINT_JOIN_REV);
		            pstmt5 = conn.prepareStatement("SELECT S_REV_LINE_ID.nextVal ID FROM DUAL");
	                pstmt6 = conn.prepareStatement("SELECT S_REV_POINT_ID.nextVal ID FROM DUAL");
		            for (Iterator i = diagram.getLines().iterator(); i.hasNext(); ) {
		            	long lineId = 0; 
		            	rs = pstmt5.executeQuery();
		                
		                if (rs.next()) {
		                	lineId = rs.getLong("ID");
		                } else {
		                    throw new DAOException("Failed to retrieve S_REV_LINE_ID Sequence Number");
		                }
		                closeResources(rs);
		            	Line line = (Line)i.next();
		            	
		            	//insert line
		            	line.setId(new Long(lineId));
		            	pstmt.setLong(1, lineId);
		            	if (line instanceof SArrowLine)
							pstmt.setString(2, Constants.SINGLEARROWLINE_TYPE);
						else
							pstmt.setString(2, Constants.LINE_TYPE);
		            	pstmt.setLong(3, line.getColor().longValue());
		            	pstmt.setInt(4, line.getThickness().intValue());
		                pstmt.addBatch();
		                
		                //insert diagram and line link
		                pstmt2.setLong(1, diagramId);
		                pstmt2.setLong(2, lineId);
		                pstmt2.addBatch();
		                
		                //insert all the points of line in point and line_point_join table
		                if(line.getPoints() != null) {
		                	for (Iterator j = line.getPoints().iterator(); j.hasNext(); ) {
		                		Point point = (Point)j.next();
		                		long pointId = 0; 
		                		rs = pstmt6.executeQuery();
				                
				                if (rs.next()) {
				                	pointId = rs.getLong("ID");
				                } else {
				                    throw new DAOException("Failed to retrieve S_REV_POINT_ID Sequence Number");
				                }
				                closeResources(rs);
				                
		                		pstmt3.setLong(1, pointId);
		                		pstmt3.setDouble(2, point.getX().doubleValue());
		                		pstmt3.setDouble(3, point.getY().doubleValue());
		                		pstmt3.addBatch();

				                pstmt4.setLong(1, lineId);
				                pstmt4.setLong(2, pointId);
				                pstmt4.addBatch();
		                	}
		                }
		            }
		            pstmt.executeBatch();
		            pstmt2.executeBatch();
		            pstmt3.executeBatch();
		            pstmt4.executeBatch();
		            closeResources(pstmt);
		            closeResources(pstmt2);
					closeResources(pstmt3);
					closeResources(pstmt4);
					closeResources(pstmt5);
					closeResources(pstmt6);
	        }
			//iterate shapes
			//update parent id , insert connectors, linakges, and shape attributes.
			if(diagram.getShapes().size() > 0) {

				pstmt = conn.prepareStatement(SQL_UPDATE_SHAPE_WITH_PARENTID_REV);
				pstmt2 = conn.prepareStatement(SQL_INSERT_SHAPE_LINE_JOIN_REV);
				pstmt3 = conn.prepareStatement(SQL_INSERT_SHAPE_LINKAGE_REV);
				pstmt4 = conn.prepareStatement("SELECT S_REV_SHAPE_LINKAGE_ID.nextVal ID FROM DUAL");
				pstmt5 = conn.prepareStatement(SQL_INSERT_LINKAGE_CITATION_JOIN_REV);
				pstmt6 = conn.prepareStatement(SQL_INSERT_SHAPE_ATTRIBUTE_REV);
				for (Iterator i = diagram.getShapes().iterator(); i.hasNext(); ) {
					//update parent id
					Shape shape = (Shape)i.next();
					if(shape.getParentShape() != null) {
						pstmt.setLong(1, shape.getParentShape().getId().longValue());
		            	pstmt.setLong(2, shape.getId().longValue());
		                pstmt.addBatch();
					}
					//update connector
					if(shape.getConnectors().size() > 0) {
						for (Iterator j = shape.getConnectors().iterator(); j.hasNext(); ) {
							Connector c = (Connector) j.next(); 

							pstmt2.setLong(1, diagramId);
							pstmt2.setLong(2, shape.getId().longValue());
							pstmt2.setLong(3, c.getLine().getId().longValue());
							pstmt2.setInt(4, c.getIndex().intValue());
							if(c.getStart().booleanValue() == true)
								pstmt2.setString(5, "1");
							else 
								pstmt2.setString(5, "0");
							pstmt2.addBatch();
						}
					}
					//insert linkages
					if(shape.getLinkages().size() > 0) {
						for (Iterator k = shape.getLinkages().iterator(); k.hasNext(); ) {
							long linkageId = 0; 
			            	rs = pstmt4.executeQuery();
			                
			                if (rs.next()) {
			                	linkageId = rs.getLong("ID");
			                } else {
			                    throw new DAOException("Failed to retrieve S_REV_SHAPE_LINKAGE_ID Sequence Number");
			                }
			                closeResources(rs);
							Linkage linkage = (Linkage)k.next();
							pstmt3.setLong(1, linkageId);
							pstmt3.setLong(2, shape.getId().longValue());
			            	pstmt3.setLong(3, linkage.getShape().getId().longValue());
			                pstmt3.addBatch();
			                for (Iterator l = linkage.getCitationIds().iterator(); l.hasNext(); ) {
			                	long value = 0;
			                	Object o = l.next();
			                	if(o instanceof Long)
			                		value = ((Long) o).longValue();
			                	else if(o instanceof Integer)
			                		value = ((Integer)o).longValue();
			                	pstmt5.setLong(1, linkageId);
			                	pstmt5.setLong(2, value);
			                	pstmt5.addBatch();
			                }
						}
					}
					//INSERT ATTRIBUTES
					if(shape.getAttributes().size() > 0) {
						for (Iterator k = shape.getAttributes().iterator(); k.hasNext(); ) {
							ShapeAttribute attr = (ShapeAttribute) k.next();
			                for (Iterator l = attr.getValues().iterator(); l.hasNext(); ) {
			                	pstmt6.setLong(1, shape.getId().longValue());
			                	pstmt6.setLong(2, attr.getType());
			                	long value = 0;
			                	Object o = l.next();
			                	if(o instanceof Long)
			                		value = ((Long) o).longValue();
			                	else if(o instanceof Integer)
			                		value = ((Integer)o).longValue();
			                	pstmt6.setLong(3, value);
			                	pstmt6.addBatch();
			                }
						}
					}
				}
				pstmt.executeBatch();
				pstmt2.executeBatch();
				pstmt3.executeBatch();
				pstmt5.executeBatch();
				pstmt6.executeBatch();
				//insert user list
				closeResources(pstmt);
				pstmt = conn.prepareStatement(SQL_INSERT_DIAGRAM_USER_JOIN_REV);
	            for (Iterator i = diagram.getUserList().iterator(); i.hasNext(); ) {
	            	User user = (User)i.next();
		            pstmt.setLong(1, diagramId);
		            pstmt.setLong(2, user.getUserId());
		            System.out.println("REVISION insert " + user.getUserId());
		            pstmt.addBatch();
	            }
	            pstmt.executeBatch();
			}

		} catch (SQLException sqle) {
			sqle.printStackTrace();
			throw new DAOException(sqle);
		} finally {
			try {
				if(connection == null) 
					conn.rollback();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			closeResources(pstmt);
			closeResources(pstmt2);
			closeResources(pstmt3);
			closeResources(pstmt4);
			closeResources(pstmt5);
			closeResources(pstmt6);
		}
		System.out.println("save REVISION diagram id " + diagramId);
		return diagramId;
	}
	
	public long updateDiagram(Diagram diagram) throws DAOException {
		System.out.println("old updated diagram id " + diagram.getId());
		Connection conn = null;
		long diagramId = 0;
		try {
	            conn = getConnection();
	            conn.setAutoCommit(false);
//	            if(diagram.getOrginialId().compareTo(new Long(0)) != 0)
//	            	deleteDiagram(conn, diagram.getOrginialId().longValue());
//	            else
	            if(diagram.getOrginialId().compareTo(new Long(0)) != 0)
	            	diagram.setId(diagram.getOrginialId());
	            deleteDiagramForUpdate(conn, diagram.getId().longValue());
	            diagramId = saveDiagram(conn, diagram);
	            conn.commit();
		} catch (Exception e) {
            throw new DAOException("DAOException caught in updateDiagram() \n" + e.getMessage());
        } finally {
        	  try {
        		conn.rollback();
			} catch (SQLException e) {

				e.printStackTrace();
			}
			closeResources(conn);
         }
        System.out.println("updated diagram id " + diagramId);
        return diagramId;
	}
	
	private static final String SQL_FN_DEL_FOR_UPDATE_DIAGRAM = " begin ? := fn_icd_delete_diag_for_update(?); end; ";

	public boolean deleteDiagramForUpdate(Connection connection, long diagramId)
			throws DAOException {
		CallableStatement cstmt = null;
		String str = "";
		try {

			cstmt = connection.prepareCall(SQL_FN_DEL_FOR_UPDATE_DIAGRAM);
			cstmt.registerOutParameter(1, OracleTypes.VARCHAR);
			cstmt.setLong(2, diagramId);
			cstmt.execute();
			str = (String) cstmt.getObject(1);
			if (str.equalsIgnoreCase("success")) {
				return true;
			}
		} catch (Exception e) {
			throw new DAOException("DAOException caught in deleteDiagramForUpdate() \n"
					+ e.getMessage());
		} finally {
			closeResources(cstmt);
		}
		return false;
	}
	    
    private static final String SQL_FN_DEL_DIAGRAM = " begin ? := fn_icd_delete_diagram(?); end; ";
    
    public boolean deleteDiagram(long diagramId) throws DAOException {
    	return deleteDiagram(null, diagramId);
    }
    
	public boolean deleteDiagram(Connection connection, long diagramId) throws DAOException {
        Connection conn = null;
        CallableStatement cstmt = null;
        
        String str = "";
        
        try {
        	if(connection == null){
	            conn = getConnection();
	            conn.setAutoCommit(false);
        	} else {
        		conn = connection;
        	}
        	
            cstmt = conn.prepareCall(SQL_FN_DEL_DIAGRAM);
            cstmt.registerOutParameter(1, OracleTypes.VARCHAR );
            cstmt.setLong(2, diagramId);
            cstmt.execute();
            str = (String) cstmt.getObject(1);
            if (str.equalsIgnoreCase("success")){
            	if(connection == null) 
            		conn.commit();
            	return true;
            }
        } catch (Exception e) {
            throw new DAOException("DAOException caught in deleteDiagram() \n" + e.getMessage());
        } finally {
        	  try {
        		  if(connection == null)  
        			  conn.rollback();
			} catch (SQLException e) {

				e.printStackTrace();
			}
			if(connection == null) 
				closeResources(conn, cstmt);
			else
				closeResources(cstmt);
         }
		 return false;
	}
	
	private static final String SQL_FN_DEL_REV_DIAGRAM = " begin ? := fn_icd_delete_rev_diagram(?); end; ";
	
	public boolean deleteRevisionDiagram(long revDiagramId) throws DAOException {
        Connection conn = null;
        CallableStatement cstmt = null;
        
        String str = "";
        
        try {
	        conn = getConnection();
	        conn.setAutoCommit(false);
        	
            cstmt = conn.prepareCall(SQL_FN_DEL_REV_DIAGRAM);
            cstmt.registerOutParameter(1, OracleTypes.VARCHAR );
            cstmt.setLong(2, revDiagramId);
            cstmt.execute();
            str = (String) cstmt.getObject(1);
            if (str.equalsIgnoreCase("success")) {
            	conn.commit();
            	return true;
            }
        } catch (Exception e) {
            throw new DAOException("DAOException caught in deleteRevisionDiagram \n" + e.getMessage());
        } finally {
        	try {
        		conn.rollback();
			} catch (SQLException e) {

				e.printStackTrace();
			}
			closeResources(conn, cstmt);
         }
		 return false;
	}
	
	private static final String SQL_SELECT_DIAGRAM_ROW = " SELECT LOCKED_BY_USER_ID "
		 +  "	FROM ICD_DIAGRAM "
	     +  "	WHERE  DIAGRAM_ID	 = ? "
	     +  " FOR UPDATE NOWAIT ";
 
	private static final String SQL_UPDATE_DIAGRAM_STATUS = "UPDATE ICD_DIAGRAM " 
		 +	"  SET    LL_DIAGRAM_STATUS_ID = ?, "
	     +  "  	IS_PUBLIC = ?, "
	     +  "  	LOCKED_BY_USER_ID = ?, "
	     +  "  	DIAGRAM_NAME = ?, "
	     +  "  	KEYWORDS = ?, "
	     +  "  	LOCATION = ?, "
	     +  "  	DIAGRAM_DESC = ?, "
	     +  "  	LAST_UPDATED_BY    = ?, "
	     +  "	LAST_UPDATED_DT = sysdate "
	     +  "	WHERE  DIAGRAM_ID	 = ? ";
//	 
//	 private static final String SQL_INSERT_DIAGRAM_USER_JOIN = "INSERT INTO ICD_DIAGRAM_USER_JOIN ("+
//			   "DIAGRAM_USER_JOIN_ID, DIAGRAM_ID, USER_ID)"+ 
//			"VALUES ( S_ICD_DIAGRAM_USER_JOIN_ID.nextVal, ?, ?)";
		
	private static final String SQL_SELECT_DIAGRAM_USER_JOIN_BY_USERID = " SELECT DIAGRAM_USER_JOIN_ID, DIAGRAM_ID, USER_ID" 
		 + " FROM ICD_DIAGRAM_USER_JOIN " 
		 + " WHERE DIAGRAM_ID = ? " 	
		 + " AND USER_ID = ? ";
	 
	private static final String SQL_DELETE_DIAGRAM_USER_JOIN = "DELETE ICD_DIAGRAM_USER_JOIN WHERE DIAGRAM_ID = ? ";
	 
	public boolean updateDiagramInfo(Diagram diagram)
			throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;
		PreparedStatement pstmt2 = null;
		ResultSet rs = null;
		boolean saveSuccess = false;

		if (diagram.getId() == null)
			throw new DAOException("updateDiagramStatus : Invalid diagram id");
		long diagramId = diagram.getId().longValue();
		try {
			conn = getConnection();
			conn.setAutoCommit(false);
			pstmt = conn.prepareStatement(SQL_SELECT_DIAGRAM_ROW);
			pstmt.setLong(1, diagramId);
			
			rs = pstmt.executeQuery();
			if(rs.next())
			{
				//isLockedByOtherUser = rs.getString("IS_LOCKED").equalsIgnoreCase("Y");
				long currLockedUserId = rs.getLong("LOCKED_BY_USER_ID");
				long lockedUserId = diagram.getLockedUser().getUserId();
				System.out.println(" status " + currLockedUserId + " " + lockedUserId);
				if (currLockedUserId == lockedUserId || currLockedUserId == 0 || lockedUserId == 0) {
					saveSuccess = true; 
					pstmt2 = conn.prepareStatement(SQL_UPDATE_DIAGRAM_STATUS);
					pstmt2.setLong(1, diagram.getDiagramStatusId());
					if(diagram.isOpenToPublic())
						pstmt2.setString(2, "Y");
					else
						pstmt2.setString(2, "N");

					if(lockedUserId != 0)
						pstmt2.setLong(3, lockedUserId);
					else
						pstmt2.setNull(3, Types.NULL);
					pstmt2.setString(4, diagram.getName());
					pstmt2.setString(5, diagram.getKeywords());
					pstmt2.setString(6, diagram.getLocation());
					pstmt2.setString(7, diagram.getDescription());
					pstmt2.setLong(8, diagram.getUpdatedBy());

					pstmt2.setLong(9, diagramId);

					pstmt2.executeUpdate();
					closeResources(pstmt);
					closeResources(pstmt2, rs);
					List userList = diagram.getUserList();
		            //Update USER who can edit the diagram
		            if(userList!= null && userList.size() > 0){
		                //Delete 
		                String sql = "";
		                sql = "DELETE ICD_DIAGRAM_USER_JOIN WHERE DIAGRAM_ID = ? AND USER_ID NOT IN ( " + Utility.getUserIds(userList) + ")";
		                pstmt = conn.prepareStatement(sql);
		                
		                pstmt.setLong(1, diagramId);
		                pstmt.executeUpdate();
		                closeResources(pstmt);
		                
		                
		                pstmt = conn.prepareStatement(SQL_INSERT_DIAGRAM_USER_JOIN);
		                pstmt2 = conn.prepareStatement(SQL_SELECT_DIAGRAM_USER_JOIN_BY_USERID);
		                for (Iterator i =  userList.iterator(); i.hasNext(); ){
		                   long userId = ((User) i.next()).getUserId();
		                   
		                   pstmt2.setLong(1, diagramId);
		                   pstmt2.setLong(2, userId);
		                   rs = pstmt2.executeQuery();
		                   if(!rs.next()){
		                       //set diagramId
		                       pstmt.setLong(1, diagramId);
		                       //set userId
		                       pstmt.setLong(2, userId);
		                       pstmt.executeUpdate();
		                   }
		                }
		                closeResources(pstmt2, rs);
		            } else {
		                //Delete all users
		                pstmt = conn.prepareStatement(SQL_DELETE_DIAGRAM_USER_JOIN);
		                // set diagram id
		                pstmt.setLong(1, diagramId);
		                pstmt.executeUpdate();
		            }
		            closeResources(pstmt);
					conn.commit();
				}
			}

		} catch (Exception e) {
			throw new DAOException(	"DAOException caught in updateDiagramStatus() \n" + e.getMessage());
			// TODO: handle exception
		} finally {
			try {
				if (conn != null) {
					conn.rollback();
				}
			} catch (SQLException e) {
				saveSuccess = false;
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			closeResources(conn, pstmt, rs);
			closeResources(pstmt2);
		}
		return saveSuccess;
	}
	 
	 
	private static final String SQL_UPDATE_DIAGRAN_NAME = "UPDATE ICD_DIAGRAM " 
		 +	"  SET   DIAGRAM_NAME = ?, "
		 + 	"	KEYWORDS = ?, "
		 + 	"	LOCATION = ?, "
		 + 	"	DIAGRAM_DESC = ?, "
	     +  "  	LAST_UPDATED_BY    = ?, "
	     +  "	LAST_UPDATED_DT = sysdate "
	     +  "	WHERE  DIAGRAM_ID	 = ? ";
	 
	public boolean updateDiagramDetails(Diagram diagram, long userId, long diagramId)
			throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;
		
		boolean saveSuccess = true;

		if (diagramId == 0)
			throw new DAOException("updateDiagramName : Invalid diagram id");

		try {
			conn = getConnection();
			conn.setAutoCommit(false);
			pstmt = conn.prepareStatement(SQL_UPDATE_DIAGRAN_NAME);
			pstmt.setString(1, diagram.getName());
			pstmt.setString(2, diagram.getKeywords());
			pstmt.setString(3, diagram.getLocation());
			pstmt.setString(4, diagram.getDescription());
			pstmt.setLong(5, userId);
			pstmt.setLong(6, diagramId);
			pstmt.executeUpdate();
			conn.commit();

		} catch (Exception e) {
			saveSuccess = false;
			throw new DAOException(	"DAOException caught in updateDiagramStatus() \n" + e.getMessage());
			// TODO: handle exception
		} finally {
			try {
				if (conn != null) {
					conn.rollback();
				}
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			closeResources(conn, pstmt);
		}
		return saveSuccess;
	}
	 
	//diagram comment functions
	private static final String SQL_INSERT_DIAGRAM_COMMENT = "INSERT INTO ICD_DIAGRAM_COMMENT ("
			  + " DIAGRAM_COMMENT_ID, DIAGRAM_ID, COMMENTOR_NAME, COMMENT_TEXT, EMAIL, CREATED_BY) "
			  + " VALUES (S_ICD_DIAGRAM_COMMENT_ID.NEXTVAL, ?, ?, ?, ?, ? )";
	
	public void saveDiagramComment(Comment comment) throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;

		long diagramId = comment.getDiagramId().longValue();
		
		if(diagramId == 0)
			throw new DAOException("saveDiagramComment: Invalid diagram id");
		
		try {
			conn = getConnection();
            conn.setAutoCommit(false);
            
			pstmt = conn.prepareStatement(SQL_INSERT_DIAGRAM_COMMENT);
			pstmt.setLong(1, diagramId);
			pstmt.setString(2, comment.getCommentor());
			pstmt.setString(3, comment.getCommentText());
			if(comment.getEmail() != null)
				pstmt.setString(4, comment.getEmail());
			else
				pstmt.setNull(4, Types.VARCHAR);

			if(comment.getUserId().longValue() != 0 )
				pstmt.setLong(5, comment.getUserId().longValue());
			else
				pstmt.setNull(5, Types.NULL);

			pstmt.executeUpdate();
			conn.commit();

		} catch (Exception e) {
			throw new DAOException("DAOException caught in saveDiagramComment() \n" + e.getMessage());
			// TODO: handle exception
		} finally {
			try {
				if(conn != null)
					conn.rollback();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			closeResources(conn, pstmt);
		}
	}
	
	private static final String SQL_SELECT_INTERNAL_COMMENTS_BY_DIAGRAMID = 
		" SELECT COMMENTOR_NAME, COMMENT_TEXT, CREATED_DT, EMAIL "  
		+ "	FROM  ICD_DIAGRAM_COMMENT " 
		+ "	WHERE DIAGRAM_ID = ? "
		+ "		AND CREATED_BY is not null "
		+ "  ORDER BY CREATED_DT DESC";
	
	private static final String SQL_SELECT_PUBLIC_COMMENTS_BY_DIAGRAMID = 
		" SELECT COMMENTOR_NAME, COMMENT_TEXT, CREATED_DT, EMAIL "  
		+ "	FROM  ICD_DIAGRAM_COMMENT " 
		+ "	WHERE DIAGRAM_ID = ? "
		+ "		AND CREATED_BY is null "
		+ "  ORDER BY CREATED_DT DESC";
   
    public List getCommentsByDiagramId(long diagramId, boolean isInternalComments) throws DAOException {
    	List comments = new ArrayList();
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {

			conn = getConnection();
			if(isInternalComments)
				pstmt = conn.prepareStatement(SQL_SELECT_INTERNAL_COMMENTS_BY_DIAGRAMID);
			else
				pstmt = conn.prepareStatement(SQL_SELECT_PUBLIC_COMMENTS_BY_DIAGRAMID);
			
			pstmt.setLong(1, diagramId);

			rs = pstmt.executeQuery();
			
			while(rs.next()) {
				Comment comment = new Comment();
				comment.setCommentor(rs.getString("COMMENTOR_NAME"));
				comment.setCommentText(rs.getString("COMMENT_TEXT"));
				comment.setCreatedDate(rs.getTimestamp("CREATED_DT"));
				if(rs.getString("EMAIL") != null)
					comment.setEmail(rs.getString("EMAIL"));

				comments.add(comment);
			}

		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return comments;
    }
}
