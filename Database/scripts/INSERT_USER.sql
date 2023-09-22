/*
insert into  P_USER_TABLE(USER_ID, FIRSTNAME, LASTNAME, ROLE_ID, PASSWORD, EMAIL_ADDRESS, ORGANIZATION) values('xlli1', 'Li', 'Li', 3, getMD5('1234'), 'li.li@tetratech.com', 'Tetratech inc. ')
insert into  P_USER_TABLE(USER_ID, FIRSTNAME, LASTNAME, ROLE_ID, PASSWORD, EMAIL_ADDRESS, ORGANIZATION) values('xFatema', 'Fatema', 'Faizullabhoy', 1, getMD5('1234'), 'Fatema.Faizullabhoy@tetratech.com', 'Tetratech inc. ')


select *
from P_USER_TABLE 
*/

/*
create or replace function getMD5(
  in_string in varchar2)
return varchar2
as
  cln_md5raw raw(2000);
  out_raw raw(16);
begin
  cln_md5raw := utl_raw.cast_to_raw(in_string);
  dbms_obfuscation_toolkit.md5(input=>cln_md5raw,checksum=>out_raw);
  -- return hex version (32 length)
  return rawtohex(out_raw);
end;
*/