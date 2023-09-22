package com.tetratech.caddis.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import com.tetratech.caddis.exception.DAOException;

public abstract class AbstractDAO {
    
    public static Connection getConnection(String name) throws SQLException, NamingException {
        InitialContext jndiContext = new InitialContext();
        DataSource dataSource = (DataSource) jndiContext.lookup(name);
        Connection conn = dataSource.getConnection();

        return conn;
    }

    public static Connection getConnection() throws SQLException, NamingException {
    	
    	Connection conn = null;
        try{
            Class.forName("oracle.jdbc.driver.OracleDriver");
            //DEV
            String database = "jdbc:oracle:thin:@ttdffxs-brazos.tetratech-ffx.com:1521:swqmis"; 
            conn = DriverManager.getConnection( database , "caddis_dev", "caddis_dev");
            //TEST
            //String database = "jdbc:oracle:thin:@ttdffxs-klamath.tetratech-ffx.com:1521:ffxora1"; 
            //conn = DriverManager.getConnection( database , "caddis", "caddis");
            //new instance for public review
//            String database = "jdbc:oracle:thin:@ttdffxs-brazos.tetratech-ffx.com:1521:swqmis2"; 
//            conn = DriverManager.getConnection( database , "caddis_test", "caddis_test");
        }catch (Exception e) {
          e.printStackTrace();
        }
        return conn;
    	
        //return getConnection("java:/CADDIS_DS"); // for jboss
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

