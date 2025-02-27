ALTER TABLE CADDIS_DEV.P_SI_SIGNIFICANTS_EVIDENCE
 DROP PRIMARY KEY CASCADE;

DROP TABLE CADDIS_DEV.P_SI_SIGNIFICANTS_EVIDENCE CASCADE CONSTRAINTS;

CREATE TABLE CADDIS_DEV.P_SI_SIGNIFICANTS_EVIDENCE
(
  SI_SIGNIFICANTS_EVIDENCE_ID  NUMBER(11)       NOT NULL,
  LL_SI_EVIDENCE_ID            NUMBER(11),
  CREATE_DATE                  DATE,
  CREATE_USER                  VARCHAR2(50 BYTE),
  UPDATE_DATE                  DATE,
  UPDATE_USER                  VARCHAR2(50 BYTE),
  SI_SIGNIFICANT_ID            NUMBER(11)
)
TABLESPACE CADDIS_DATA
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


CREATE UNIQUE INDEX CADDIS_DEV.PK_SI_SIGNIFICANTS_EVIDENCE ON CADDIS_DEV.P_SI_SIGNIFICANTS_EVIDENCE
(SI_SIGNIFICANTS_EVIDENCE_ID)
LOGGING
TABLESPACE CADDIS_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


ALTER TABLE CADDIS_DEV.P_SI_SIGNIFICANTS_EVIDENCE ADD (
  CONSTRAINT PK_SI_SIGNIFICANTS_EVIDENCE
  PRIMARY KEY
  (SI_SIGNIFICANTS_EVIDENCE_ID)
  USING INDEX CADDIS_DEV.PK_SI_SIGNIFICANTS_EVIDENCE);

ALTER TABLE CADDIS_DEV.P_SI_SIGNIFICANTS_EVIDENCE ADD (
  CONSTRAINT FK_SIG_EVID_EVIDENCE_ID 
  FOREIGN KEY (LL_SI_EVIDENCE_ID) 
  REFERENCES CADDIS_DEV.P_LIST_ITEM (LL_ID)
  ON DELETE SET NULL,
  CONSTRAINT FK_SIG_EVID_SIG_ID 
  FOREIGN KEY (SI_SIGNIFICANT_ID) 
  REFERENCES CADDIS_DEV.P_SI_SIGNIFICANTS (SI_SIGNIFICANT_ID)
  ON DELETE SET NULL);
  
  DROP SEQUENCE CADDIS_DEV.SEQ_SI_SIG_EVIDENCE_ID;

CREATE SEQUENCE CADDIS_DEV.SEQ_SI_SIG_EVIDENCE_ID
  START WITH 10003
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;
