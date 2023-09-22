package com.tetratech.caddis.exception;

public class DAOException extends Exception {

    /**
	 * 
	 */
	private static final long serialVersionUID = -4020784406612204644L;


	public DAOException() {
        super();

    }


    public DAOException(String message) {
        super(message);
    }


    public DAOException(Exception e) {
        super("Exception Occured " + e);
    }
}

