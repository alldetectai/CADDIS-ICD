--DROP FUNCTION CADDIS_DEV.GET_ITEM_CODE;

CREATE OR REPLACE FUNCTION CADDIS_DEV."GET_ITEM_CODE" (V_ID in number)
 return varchar2
 is
     l_str varchar2(4000) default null;
    
 begin
     select distinct A.LIST_ITEM_CODE INTO L_STR
     from P_LIST_ITEM A
     WHERE A.LL_ID = V_ID;
     
     return l_str;
 end;
/
