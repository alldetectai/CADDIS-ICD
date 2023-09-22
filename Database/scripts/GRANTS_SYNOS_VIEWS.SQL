ALTER SESSION SET CURRENT_SCHEMA = CADDIS2;
BEGIN

  for V in (select VIEW_name from all_VIEWs where owner = 'CADDIS2' AND VIEW_NAME NOT LIKE 'V_ICD%') loop
    execute immediate
'grant SELECT on CADDIS2.'||V.VIEW_name||' to CADDIS2_APEX';

EXECUTE IMMEDIATE
'CREATE SYNONYM CADDIS2_APEX.' || V.VIEW_name|| ' FOR CADDIS2.' ||V.VIEW_name;

    end loop;
    
end;
/
