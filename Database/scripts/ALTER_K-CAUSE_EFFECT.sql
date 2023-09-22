--ALTER TABLE CADDIS_DEV.K_CAUSE_EFFECT
 --ADD (EVIDENCE_DOCUMENTATION  VARCHAR2(4000 BYTE));
 
 ALTER TABLE CADDIS_DEV.ICD_LINKAGE_CITATION_JOIN
    ADD(CAUSE_EFFECT_ID NUMBER(12));
 
 ALTER TABLE CADDIS_DEV.ICD_LINKAGE_CITATION_JOIN ADD (
  CONSTRAINT FK_K_CAUSE_EFFECT_ID 
  FOREIGN KEY (CAUSE_EFFECT_ID) 
  REFERENCES CADDIS_DEV.K_CAUSE_EFFECT (CAUSE_EFFECT_ID));
  
   ALTER TABLE CADDIS_DEV.ICD_LINKAGE_CITATION_JOIN
    ADD(IS_EFFECTRELATIONSHIP CHAR(1));
 
 ALTER TABLE CADDIS_DEV.ICD_LINKAGE_CITATION_JOIN_REV
    ADD(CAUSE_EFFECT_ID NUMBER(12));
ALTER TABLE CADDIS_DEV.ICD_LINKAGE_CITATION_JOIN_REV ADD (
  CONSTRAINT FK_K_CAUSE_EFFECT_ID_REV 
  FOREIGN KEY (CAUSE_EFFECT_ID) 
  REFERENCES CADDIS_DEV.K_CAUSE_EFFECT (CAUSE_EFFECT_ID));
  
   ALTER TABLE CADDIS_DEV.ICD_LINKAGE_CITATION_JOIN_REV
    ADD(IS_EFFECTRELATIONSHIP CHAR(1));
   

ALTER TABLE CADDIS_DEV.ICD_LINKAGE_CITATION_JOIN
  MODIFY CONSTRAINT XAK1ICD_LINAKAGE_CITATION_JOIN
  DISABLE;
  
ALTER TABLE CADDIS_DEV.ICD_LINKAGE_CITATION_JOIN_REV
  MODIFY CONSTRAINT XAK1ICD_LINAKAGE_CITATION_JOIN_
  DISABLE;
  
ALTER TABLE CADDIS_DEV.ICD_SHAPE
    ADD(STANDARD_TERM_ID NUMBER(12));
    
ALTER TABLE CADDIS_DEV.ICD_SHAPE ADD (
  CONSTRAINT FK_K_STANDARD_TERM_ID
  FOREIGN KEY (STANDARD_TERM_ID) 
  REFERENCES CADDIS_DEV.P_STANDARD_TERM (STANDARD_TERM_ID));
  
  ALTER TABLE CADDIS_DEV.ICD_SHAPE_REV
    ADD(STANDARD_TERM_ID NUMBER(12));
    
ALTER TABLE CADDIS_DEV.ICD_SHAPE_REV ADD (
  CONSTRAINT FK_K_STANDARD_TERM_ID_REV
  FOREIGN KEY (STANDARD_TERM_ID) 
  REFERENCES CADDIS_DEV.P_STANDARD_TERM (STANDARD_TERM_ID));
  
ALTER TABLE CADDIS_DEV.P_LOCATION
ADD( LL_TYPE_ENTITY_ID  NUMBER(11));

ALTER TABLE CADDIS_DEV.P_LOCATION ADD (
  CONSTRAINT FK_TYPE_ENTITY_R_LOCATION 
  FOREIGN KEY (LL_TYPE_ENTITY_ID) 
  REFERENCES CADDIS_DEV.P_TYPE_ENTITY_NAME (TYPE_ENTITY_ID));
