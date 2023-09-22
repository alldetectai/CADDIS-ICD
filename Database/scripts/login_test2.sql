update  P_USER_TABLE
set password =  getMD5('1234')
where user_id = 'xlli1'

insert into  P_USER_TABLE(USER_ID, FIRSTNAME, LASTNAME, ROLE_ID, PASSWORD, EMAIL_ADDRESS, ORGANIZATION) values('xFatema', 'Fatema', 'Faizullabhoy', 1, getMD5('1234'), 'Fatema.Faizullabhoy@tetratech.com', 'Tetratech inc. ')
