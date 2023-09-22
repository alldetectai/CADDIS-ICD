CREATE OR REPLACE FUNCTION CADDIS_DEV."GET_STUDY_TYPE" (p_a in number)
 return varchar2
 is
     l_str varchar2(4000) default null;
     l_sep varchar2 (1)  default null;
 begin
     for x in (select DISTINCT  LIST_ITEM_CODE  from V_STUDY_TYPE a, k_dataset b  where A.LL_ID = B.LL_STUDY_TYPE_ID and B.CITATION_ID = p_a) loop
       if x.LIST_ITEM_CODE  <> ' ' then
        l_str :=l_str || l_sep || x.LIST_ITEM_CODE ;
        l_sep := ';';
       end if;
     end loop;
     return l_str;
 end;
/
