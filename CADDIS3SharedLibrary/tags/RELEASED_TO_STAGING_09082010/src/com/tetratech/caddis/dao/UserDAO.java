package com.tetratech.caddis.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.naming.NamingException;

import com.tetratech.caddis.exception.DAOException;
import com.tetratech.caddis.model.User;

public class UserDAO extends AbstractDAO {
	
	// singleton instance
	private static UserDAO instance = null;

	private UserDAO() {
	}

	public static synchronized UserDAO getInstance() {
		if (instance != null) {
			return instance;
		}

		if (instance == null) {
			instance = new UserDAO();
		}

		return instance;
	}


	
//	private static final String SQL_INSERT_USER = " INSERT INTO ICD_USER ("
//		+ " USER_ID, FIRST_NAME, "
//		+ " LAST_NAME, USER_NAME, USER_PASSWORD, "
//		+ " USER_EMAIL, LL_ROLE_ID, SESSION_IDENTIFIER, APPLICATION_LOGGED, LAST_UPDATE_TS) "
//		+ " VALUES ( S_ICD_USER_ID.nextval, ?, ?, ?, ?, ?, ?, ?, ?, sysdate) ";
//	
//	public void saveRegisteredUser(User user) throws DAOException {
//		Connection conn = null;
//		PreparedStatement pstmt = null;
//
//		try {
//
//			conn = getConnection();
//			pstmt = conn.prepareStatement(SQL_INSERT_USER);
//			pstmt.setString(1, user.getFirstName());
//
//			pstmt.setString(2, user.getLastName());
//			pstmt.setString(3, user.getUserName());
//			pstmt.setString(4, user.getPassword());
//			pstmt.setString(5, user.getEmail());
//			pstmt.setLong(6, user.getRoleId());
//			pstmt.setString(7, "session identifier");
//			pstmt.setString(8, "ICD");
//			
//			if (pstmt.executeUpdate() != 1)
//				throw new DAOException("Insert User Failed");
//			conn.commit();
//		} catch (NamingException nex) {
//			throw new DAOException(nex);
//		} catch (SQLException sqle) {
//			throw new DAOException(sqle);
//		} finally {
//			try {
//				conn.rollback();
//			} catch (SQLException e) {
//				e.printStackTrace();
//			}
//			closeResources(conn, pstmt);
//		}
//	}
	private static final String SQL_INSERT_USER = " INSERT INTO ICD_USER ("
		+ " USER_ID, FIRST_NAME, "
		+ " LAST_NAME, USER_NAME, "
		+ "  LL_ROLE_ID, SESSION_IDENTIFIER, APPLICATION_LOGGED, LOGIN_TIME, LAST_UPDATE_TS) "
		+ " VALUES ( S_ICD_USER_ID.nextval, ?, ?, ?, ?, ?, ?, sysdate, sysdate) ";
	
	public void saveUser(User user) throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;

		try {

			conn = getConnection();
			conn.setAutoCommit(false);
			pstmt = conn.prepareStatement(SQL_INSERT_USER);
			pstmt.setString(1, user.getFirstName());
			pstmt.setString(2, user.getLastName());
			pstmt.setString(3, user.getUserName());
			pstmt.setLong(4, user.getRoleId());
			pstmt.setString(5, user.getSessionIdentifier());
			pstmt.setString(6, user.getApplicationLogged());
			
			if (pstmt.executeUpdate() != 1)
				throw new DAOException("Insert User Failed");
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
	
	private static final String SQL_UPDATE_LASTUPDATETS = " UPDATE ICD_USER "
		 + " SET LAST_UPDATE_TS = SYSDATE "
		 + " WHERE SESSION_IDENTIFIER = ? ";

			
		
	public void updateSessionLastUpdateTS(String sessionID) throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;

		try {

			conn = getConnection();
			conn.setAutoCommit(false);
			pstmt = conn.prepareStatement(SQL_UPDATE_LASTUPDATETS);
			pstmt.setString(1, sessionID);
			if (pstmt.executeUpdate() != 1)
				throw new DAOException("update User Failed");
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
		
	private static final String SQL_UPDATE_USER = " UPDATE ICD_USER "
	 + " SET APPLICATION_LOGGED = ?, " 
	 + " LL_ROLE_ID = ?, "
	 + " SESSION_IDENTIFIER = ?, "
	 + " LOGIN_TIME = SYSDATE, "
	 + " LAST_UPDATE_TS = SYSDATE "
	 + " WHERE UPPER(USER_NAME) = ? ";

		
	
	public void updateUserSession(User user) throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;

		try {

			conn = getConnection();
			conn.setAutoCommit(false);
			pstmt = conn.prepareStatement(SQL_UPDATE_USER);
			pstmt.setString(1, user.getApplicationLogged());
			pstmt.setLong(2, user.getRoleId());
			pstmt.setString(3, user.getSessionIdentifier());
			pstmt.setString(4, user.getUserName().toUpperCase());
			if (pstmt.executeUpdate() != 1)
				throw new DAOException("updateUserSession Failed");
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
	
	private static final String SQL_CLEAR_USER_SESSION = " UPDATE ICD_USER "
		 + " SET APPLICATION_LOGGED = ?, " 
		 + " SESSION_IDENTIFIER = NULL, "
		 + " LOGIN_TIME = SYSDATE, "
		 + " LAST_UPDATE_TS = SYSDATE "
		 + " WHERE UPPER(USER_NAME) = ? ";

	public void clearUserSession(User user) throws DAOException {
		Connection conn = null;
		PreparedStatement pstmt = null;

		try {

			conn = getConnection();
			conn.setAutoCommit(false);
			pstmt = conn.prepareStatement(SQL_CLEAR_USER_SESSION);
			pstmt.setString(1, user.getApplicationLogged());
			pstmt.setString(2, user.getUserName().toUpperCase());
			if (pstmt.executeUpdate() != 1)
				throw new DAOException("Insert User Failed");
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
	private static final String SQL_AUTHENTICATE_USER = "SELECT USER_ID, FIRST_NAME, "
		 + " LAST_NAME, USER_NAME, USER_PASSWORD, "
		 + " LL_ROLE_ID, LIST_ITEM_CODE, CREATED_DT "
		 + " FROM ICD_USER, P_LIST_ITEM  "
		 + " WHERE UPPER(USER_NAME) = ? "
		 + " AND USER_PASSWORD = ? "
		 + " AND LL_ROLE_ID = LL_ID";
	
	public User authenticateUser(String username, String password) throws DAOException {
		User user = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {

			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_AUTHENTICATE_USER);
			pstmt.setString(1, username.toUpperCase());
			pstmt.setString(2, password);
			rs = pstmt.executeQuery();
			
			if(rs.next()) {
				user = new User();
				user.setUserId(rs.getLong("USER_ID"));
				user.setFirstName(rs.getString("FIRST_NAME"));
				user.setLastName(rs.getString("LAST_NAME"));
				user.setUserName(rs.getString("USER_NAME"));
				user.setPassword(rs.getString("USER_PASSWORD"));
				user.setRoleId(rs.getLong("LL_ROLE_ID"));
				user.setRole(rs.getString("LIST_ITEM_CODE"));
				user.setCreatedDate(rs.getTimestamp("CREATED_DT"));
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return user;
	}
	
	private static final String SQL_SELECT_USER = "SELECT USER_ID, FIRST_NAME, "
		 + " LAST_NAME, USER_NAME, LAST_UPDATE_TS,"
		 + " LL_ROLE_ID, LIST_ITEM_CODE, CREATED_DT "
		 + " FROM ICD_USER, P_LIST_ITEM  "
		 + " WHERE SESSION_IDENTIFIER = ? "
		 + " AND LL_ROLE_ID = LL_ID";
	
	public User getUser(String sessionIdentifier) throws DAOException {
		User user = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {

			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_USER);
			pstmt.setString(1, sessionIdentifier);
			rs = pstmt.executeQuery();
			
			if(rs.next()) {
				user = new User();
				user.setUserId(rs.getLong("USER_ID"));
				user.setFirstName(rs.getString("FIRST_NAME"));
				user.setLastName(rs.getString("LAST_NAME"));
				user.setUserName(rs.getString("USER_NAME"));
				user.setRoleId(rs.getLong("LL_ROLE_ID"));
				user.setLastUpdatedTimeStamp(rs.getTimestamp("LAST_UPDATE_TS"));
				user.setRole(rs.getString("LIST_ITEM_CODE"));
				user.setCreatedDate(rs.getTimestamp("CREATED_DT"));
				user.setSessionIdentifier(sessionIdentifier);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return user;
	}
	
	private static final String SQL_SELECT_USER_ID = "SELECT USER_ID"
		 + " FROM ICD_USER "
		 + " WHERE UPPER(USER_NAME) = ? ";

	
	public long getUserId(String username) throws DAOException {
		long userId = 0;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {

			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_USER_ID);
			pstmt.setString(1, username.toUpperCase());
			rs = pstmt.executeQuery();
			
			if(rs.next()) {
				userId = rs.getLong("USER_ID");
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return userId;
	}
	
	private static final String SQL_SELECT_ALL_USERS = "SELECT USER_ID, FIRST_NAME, LAST_NAME, " +
	  	" LL_ROLE_ID, LIST_ITEM_CODE  " +
	  	" FROM ICD_USER, P_LIST_ITEM " +
	  	" WHERE LL_ROLE_ID = LL_ID ";
	
	public List getAllUsers() throws DAOException {
    	List allUsers = new ArrayList();
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {

			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_SELECT_ALL_USERS);
			
			rs = pstmt.executeQuery();
			
			while(rs.next()) {
				User user = new User();
				user.setUserId(rs.getLong("USER_ID"));
				user.setFirstName(rs.getString("FIRST_NAME"));
				user.setLastName(rs.getString("LAST_NAME"));
				user.setRoleId(rs.getLong("LL_ROLE_ID"));
				user.setRole(rs.getString("LIST_ITEM_CODE"));
				allUsers.add(user);
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return allUsers;
    }
	
	
	private static final String SQL_CHECK_EXISTING_USERNAME = "SELECT USER_NAME "
		 + " FROM ICD_USER "
		 + " WHERE UPPER(USER_NAME) = ? " ;
	
	public boolean checkExistingUsername(String username) throws DAOException {
		boolean foundUser = false;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;

		try {

			conn = getConnection();
			pstmt = conn.prepareStatement(SQL_CHECK_EXISTING_USERNAME);
			pstmt.setString(1, username.toUpperCase());
			rs = pstmt.executeQuery();
			
			if(rs.next()) {
				foundUser = true;
			}
		} catch (NamingException nex) {
			throw new DAOException(nex);
		} catch (SQLException sqle) {
			throw new DAOException(sqle);
		} finally {
			closeResources(conn, pstmt, rs);
		}
		return foundUser;
	}
}
