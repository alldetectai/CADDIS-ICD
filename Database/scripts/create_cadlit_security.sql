DROP PACKAGE CADDIS_DEV.CADLIT_SECURITY;

CREATE OR REPLACE PACKAGE CADDIS_DEV.cadlit_security
AS
  /* The  constants should be set to the following values when the application is deployed  on staging or production environment
        p_auth_base  - cn=users,dc=epa,dc=gov 
        p_host       - iasimdev.rtpnc.epa.gov (staging) / is iasimdev.rtpnc.epa.gov (prod) 
        p_port       - 389 
        --p_group      -  'Chemical Search Admin Users'
        p_group_base - cn=groups,dc=epa,dc=gov 
*/

   c_auth_base    CONSTANT VARCHAR2 (100) := 'cn=users,dc=epa,dc=gov' ;
   c_group_base   CONSTANT VARCHAR2 (100) := 'cn=groups,dc=epa,dc=gov' ;                               
   c_host         CONSTANT VARCHAR2 (100) := 'iasimdev.rtpnc.epa.gov'; --staging host
   c_port         CONSTANT VARCHAR2 (100) := '389';

   --authenticate user
   FUNCTION ldap_authenticate (p_username   IN VARCHAR2,
                               p_password   IN VARCHAR2)
      RETURN BOOLEAN;
      
   --check group membership of user
   FUNCTION ldap_is_member (p_username   IN VARCHAR2,  p_group in VARCHAR2)
      RETURN BOOLEAN;
      
END cadlit_security;
/
DROP PACKAGE BODY CADDIS_DEV.CADLIT_SECURITY;

CREATE OR REPLACE PACKAGE BODY CADDIS_DEV.cadlit_security
AS
   --authenticate user
   FUNCTION ldap_authenticate (p_username   IN VARCHAR2,
                               p_password   IN VARCHAR2)
      RETURN BOOLEAN
   IS
      is_auth     BOOLEAN; 
      is_member   BOOLEAN; 
   BEGIN
      DBMS_OUTPUT.enable (NULL);
      
      is_auth := false;
      is_member := false;
      
      is_auth :=
         apex_ldap.authenticate (p_username      => p_username,
                                 p_password      => p_password,
                                 p_search_base   => c_auth_base,
                                 p_host          => c_host,
                                 p_port          => c_port);

      RETURN is_auth;
   END ldap_authenticate;
   
    FUNCTION ldap_is_member (p_username   IN VARCHAR2, p_group in VARCHAR2)
      RETURN BOOLEAN
   IS      
      is_member   BOOLEAN;
      
   BEGIN

       is_member := false;       
               
           --simulate memebership check in Tt's environment
        DBMS_OUTPUT.put_line ('p_username: ' || p_username);
        DBMS_OUTPUT.put_line ('p_group: ' || p_group);
        
        if p_username is not null and p_username <> 'nobody' then
             is_member := true;           
        else
              is_member := false;                  
        end if;    
        -- end of simulation
        
        --Uncomment this when deployed on EPA's environment
--         is_member :=
--            apex_ldap.is_member (p_username     => p_username,
--                                 p_pass         => NULL,
--                                 p_auth_base    => c_auth_base,
--                                 p_host         => c_host,
--                                 p_port         => c_port,
--                                 p_group        => p_group,
--                                 p_group_base   => c_group_base);        

      RETURN is_member;
      
   END ldap_is_member;
   
   
END cadlit_security;
/

