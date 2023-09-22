package com.tetratech.caddis.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import com.tetratech.caddis.exception.DAOException;

public abstract class AbstractDAO {
	
	private static DataSource dataSource;
	
    static {
        try {
        	InitialContext jndiContext = new InitialContext();
        	//dataSource = (DataSource) jndiContext.lookup("java:/CADDIS3_DS");//JBOSS
        	//dataSource = (DataSource) jndiContext.lookup("jdbc/CADDIS_DS");//OAS
        	Context envContext = (Context)jndiContext.lookup("java:/comp/env");//tomcat
        	dataSource = (DataSource)envContext.lookup("jdbc/CADDIS_DS");//tomcat
        } catch (NamingException e) {
          e.printStackTrace();
          System.out.print("Could not find jdbc/CADDIS_DS JNDIContext");
        }
    }
    
    public static Connection getConnection() throws SQLException, NamingException {

    	Connection conn = null;
        try {
          conn = dataSource.getConnection();
        } catch(SQLException e) {
        	e.printStackTrace();
            throw new SQLException(e.getMessage());
        } 
        return conn;
    }


    public static void closeResources(Connection conn, Statement statement,
			ResultSet rs) {
		try {
			if (rs != null) {
				rs.close();
			}
		} catch (Throwable t) {
		} finally {
			rs = null;
		}

		try {
			if (statement != null) {
				statement.close();
			}
		} catch (Throwable t) {
		} finally {
			statement = null;
		}

		try {
			if (conn != null) {
				conn.close();
			}
		} catch (Throwable t) {
		} finally {
			conn = null;
		}
	}

    public static void closeResources(Connection conn,
			PreparedStatement statement, ResultSet rs) {
		try {
			if (rs != null) {
				rs.close();
			}

		} catch (Throwable t) {
		} finally {
			rs = null;
		}

		try {
			if (statement != null) {
				statement.close();
			}
		} catch (Throwable t) {
		} finally {
			statement = null;
		}

		try {
			if (conn != null) {
				conn.close();
			}
		} catch (Throwable t) {
		} finally {
			conn = null;
		}
	}


    public static void closeResources(Connection conn,
			PreparedStatement statement) {
		closeResources(conn, statement, null);
	}

	public static void closeResources(PreparedStatement statement, ResultSet rs) {
		closeResources(null, statement, rs);
	}

    public static void closeResources(PreparedStatement statement) {
		closeResources(statement, null);
	}

	public static void closeResources(Statement statement, ResultSet rs) {
		closeResources(null, statement, rs);
	}

    public static void closeResources(ResultSet rs) {
		closeResources(null, null, rs);
	}

	public static void closeResources(Statement statement) {
		closeResources(statement, null);
	}

	public static void closeResources(Connection conn, Statement statement) {
		closeResources(conn, statement, null);
	}

	public static void closeResources(Connection conn) {
		closeResources(conn, null, null);
	}
    
    public long getSequenceId(String sequenceName) throws DAOException {
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT " + sequenceName + ".nextVal ID FROM DUAL";
        long seqId = 0;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                seqId = rs.getLong("ID");
            } else {
                throw new DAOException("Failed to retrieve Sequence Number");
            }
            
        } catch (NamingException nex) {
            throw new DAOException(nex);
        } catch (SQLException sqle) {
            throw new DAOException(sqle);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return seqId;
    }
    
}

