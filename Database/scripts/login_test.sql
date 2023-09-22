DECLARE 
  RetVal BOOLEAN;
  P_UNAME VARCHAR2(32767);
  P_PASSWORD VARCHAR2(32767);
l_role_id             NUMBER;
BEGIN 
  P_UNAME := 'xlli1';
  P_PASSWORD :=getMD5('1234');
      
  RetVal := IAMLOCATOR.AUTHENTICATE (P_UNAME =>P_UNAME, P_PASSWORD =>P_PASSWORD );
 

  if RetVal = TRUE then 
   SELECT role_id into l_role_id
        FROM p_user_table
       WHERE user_id = P_UNAME;
       DBMS_OUTPUT.PUT_LINE('OK' || l_role_id);
  else
    DBMS_OUTPUT.PUT_LINE('NO');
  end if;
END;