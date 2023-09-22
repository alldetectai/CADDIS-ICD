begin

 for e in (select * from TMP_STAND_TERM)
 loop
 update P_STANDARD_TERM 
 set search_keywords = e.search
 where standard_term_id = e.id;
 end loop;
 
 commit;
end;