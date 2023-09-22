CREATE OR REPLACE PACKAGE IAMLocator 
AS

FUNCTION authenticate(P_UNAME IN VARCHAR2 , 
                                   P_PASSWORD IN VARCHAR2) RETURN BOOLEAN ;
                             --      P_SESSION_ID IN VARCHAR2,
                              --     P_FLOW_PAGE_D IN VARCHAR2,
                               --    P_FLOW_PAGE_A IN VARCHAR2 
FUNCTION  AuthenticateUser(userName IN VARCHAR2, passwd IN VARCHAR2)  RETURN VARCHAR2;

END IAMLocator;
/

CREATE OR REPLACE PACKAGE BODY IAMLocator AS
FUNCTION authenticate(P_UNAME IN VARCHAR2 , 
                                   P_PASSWORD IN VARCHAR2) RETURN BOOLEAN IS
                             --      P_SESSION_ID IN VARCHAR2,
                              ----     P_FLOW_PAGE_D IN VARCHAR2,
                              --     P_FLOW_PAGE_A IN VARCHAR2
 -- l_obfuscated_password users.password%TYPE;
    l_value               NUMBER;
    l_returnvalue         BOOLEAN;
  
  BEGIN
 --   l_obfuscated_password := obfuscate(text_in => P_PASSWORD);
    
    
    --AuthenticateUser
       l_value := 1;
    l_returnvalue := l_value = 1;
    RETURN l_returnvalue;

  END authenticate;

FUNCTION AuthenticateUser (userName IN VARCHAR2, passwd IN VARCHAR2) 
RETURN VARCHAR2 
IS
l_service          UTL_DBWS.service;
  l_call             UTL_DBWS.call;
  l_a_ns                     VARCHAR2(32767);
  l_wsdl_url         VARCHAR2(32767);
  l_namespace        VARCHAR2(32767);
  l_service_qname    UTL_DBWS.qname;
  l_port_qname       UTL_DBWS.qname;
  l_operation_qname  UTL_DBWS.qname;
  string_type_qname1     sys.utl_dbws.qname;
  string_type_qname2     sys.utl_dbws.qname;

  l_xmltype_in       SYS.XMLTYPE;
  l_xmltype_out      SYS.XMLTYPE;
  l_return           clob;
BEGIN 


  l_wsdl_url        := 'https://ssoprod.epa.gov/iamfw/services/AuthMgr?wsdl';
  l_namespace       := 'http://common.webservices.iamfw.epa.gov/';
  l_service_qname   := UTL_DBWS.to_qname(l_namespace, 'AuthMgrService');
  l_port_qname      := UTL_DBWS.to_qname(l_namespace, 'AuthMgr');
  l_operation_qname := UTL_DBWS.to_qname(l_namespace, 'authenticate');
  l_service := UTL_DBWS.create_service (
    wsdl_document_location => URIFACTORY.getURI(l_wsdl_url),
    service_name           => l_service_qname);

  l_call := UTL_DBWS.create_call (
    service_handle => l_service,
    port_name      => l_port_qname,
    operation_name => l_operation_qname);
    
 -- sys.utl_dbws.set_property(l_call, 'SOAPACTION_USE', 'TRUE');
  --sys.utl_dbws.set_property(l_call, 'SOAPACTION_URI', 'http://tempuri.org/GetFieldsName'); 
  sys.utl_dbws.set_property(l_call, 'ENCODINGSTYLE_URI', 'http://schemas.xmlsoap.org/soap/encoding/');
  sys.utl_dbws.set_property(l_call, 'ENCODINGSTYLE_URI', 'http://schemas.xmlsoap.org/soap/encoding/');
  sys.utl_dbws.set_property(l_call, 'OPERATION_STYLE', 'rpc');
  string_type_qname1 := sys.utl_dbws.to_qname('http://www.w3.org/2001/XMLSchema', 'string');
  string_type_qname2 := sys.utl_dbws.to_qname('http://www.w3.org/2001/XMLSchema', 'string');
  sys.utl_dbws.add_parameter(l_call, 'userId', string_type_qname1, 'ParameterMode.IN');
  sys.utl_dbws.add_parameter(l_call, 'credential', string_type_qname2, 'ParameterMode.IN');
  sys.utl_dbws.add_parameter(l_call, 'authMethod', string_type_qname2, 'ParameterMode.IN');
  sys.utl_dbws.set_return_type(l_call, string_type_qname1);
  sys.utl_dbws.set_return_type(l_call, string_type_qname2);

    

  l_xmltype_in := SYS.XMLTYPE('<?xml version="1.0" encoding="utf-8"?>
    <authenticate xmlns="' || l_namespace || '">
    <userId>' || userName || '</userId>
    <credential>'|| passwd || '</credential>
    <authMethod>password</authMethod>
    </authenticate>');
    
  l_xmltype_out := UTL_DBWS.invoke(call_Handle => l_call,
                                   request     => l_xmltype_in);
  if  l_xmltype_out.extract('/*') is not null then
  l_return := l_xmltype_out.extract('/*').getstringval();

  else
  l_return := null;
  end if;
  dbms_output.put_line(l_return); 
   
    UTL_DBWS.release_call (call_handle => l_call);
  UTL_DBWS.release_service (service_handle => l_service);     
  RETURN (l_return);

END AuthenticateUser;

END IAMLocator;
/

