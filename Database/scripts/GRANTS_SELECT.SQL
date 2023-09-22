ALTER SESSION SET CURRENT_SCHEMA = CADDIS2;

BEGIN


  for T in (select TABLE_name from all_tables where owner = 'CADDIS' ) loop
    execute immediate
'grant SELECT on CADDIS.'||T.TABLE_NAME||' to CADDIS2';
    
   end loop;
   
END;
/
