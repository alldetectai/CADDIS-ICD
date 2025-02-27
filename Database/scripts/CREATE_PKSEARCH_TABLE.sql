DROP TABLE CADDIS_DEV.T_PKSEARCH_LIST CASCADE CONSTRAINTS;

CREATE TABLE CADDIS_DEV.T_PKSEARCH_LIST
(
  CITATION_ID  NUMBER(11),
  SESSION_ID   VARCHAR2(4000 BYTE),
  UPDATE_DATE  DATE
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

