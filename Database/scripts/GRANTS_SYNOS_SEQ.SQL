ALTER SESSION SET CURRENT_SCHEMA = CADDIS2;

BEGIN

  for S in (select sequence_name from all_sequences where  sequence_owner = 'CADDIS2' AND sequence_name LIKE 'SEQ_%') loop
    execute immediate
'GRANT SELECT ON  CADDIS2.'||S.sequence_name||' to CADDIS2_APEX';



EXECUTE IMMEDIATE
'CREATE SYNONYM CADDIS2_APEX.' || S.sequence_name || ' FOR  CADDIS2.' ||S.sequence_name;

    end loop;
    
end;
/

