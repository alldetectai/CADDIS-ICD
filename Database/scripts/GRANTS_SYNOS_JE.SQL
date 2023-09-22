ALTER SESSION SET CURRENT_SCHEMA = CADDIS2;

BEGIN
/* VIEWS */
  for V in (select VIEW_name from all_VIEWs where owner = 'CADDIS2' ) loop
    execute immediate
'grant SELECT on CADDIS2.'||V.VIEW_name||' to CADDIS2_JE';

EXECUTE IMMEDIATE
'CREATE SYNONYM CADDIS2_JE.' || V.VIEW_name|| ' FOR CADDIS2.' ||V.VIEW_name;

    end loop;
    
/* TABLES */    
    for T in (select TABLE_name from all_TABLEs where owner = 'CADDIS2' ) loop
    execute immediate
'grant SELECT, UPDATE, DELETE, INSERT on CADDIS2.'||T.TABLE_name||' to CADDIS2_JE';

EXECUTE IMMEDIATE
'CREATE SYNONYM CADDIS2_JE.' ||T.TABLE_name|| ' FOR CADDIS2.' ||T.TABLE_name;
   end loop;
   
/* SEQUENCE */
 for S in (select sequence_name from all_sequences where  sequence_owner = 'CADDIS2' AND ( sequence_name LIKE 'SEQ_%' OR sequence_name LIKE 'S_%'  )  ) loop
    execute immediate
'GRANT SELECT ON  CADDIS2.'||S.sequence_name||' to CADDIS2_JE';

EXECUTE IMMEDIATE
'CREATE SYNONYM CADDIS2_JE.' || S.sequence_name || ' FOR  CADDIS2.' ||S.sequence_name;

    end loop;   
    
  /* FUNCTION, PACKAGE */  
    FOR O IN (select * from dba_objects 
                   where owner = 'CADDIS2' 
                     and object_type in ( 'PROCEDURE', 'PACKAGE', 'FUNCTION'))  LOOP
                     
               execute immediate
'GRANT EXECUTE ON  CADDIS2.'||O.OBJECT_NAME||' to CADDIS2_JE';       

    END LOOP;
end;
/

