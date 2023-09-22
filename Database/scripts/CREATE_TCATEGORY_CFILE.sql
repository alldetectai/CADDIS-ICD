CREATE TABLE P_CITATION_FILE
(
    CITATION_FILE_ID  NUMBER(11) NOT NULL ,
    CITATION_ID          NUMBER(11) NOT NULL ,
    FILE_NAME            VARCHAR2(200) NOT NULL ,
    FILE_TYPE            VARCHAR2(20) NOT NULL ,
    FILE_CONTENT         BLOB NOT NULL ,
    CREATE_DATE          DATE NOT NULL ,
    UPDATE_DATE          DATE NULL ,
    CREATE_USER          VARCHAR2(100) NOT NULL ,
    UPDATE_USER          VARCHAR2(100) NULL 
);

COMMENT ON COLUMN P_CITATION_FILE.CITATION_ID IS  'REQUIRED. Links the Study Design record to the appropriate Citation. Refers back to the Citation record identified as CITATION_ID in the Table P_CITATION';

CREATE UNIQUE INDEX XPKP_CITATION_FILE ON P_CITATION_FILE
(CITATION_FILE_ID   ASC);

ALTER TABLE P_CITATION_FILE
ADD CONSTRAINT  XPKP_CITATION_FILE PRIMARY KEY (CITATION_FILE_ID);

ALTER TABLE P_CITATION_FILE
ADD CONSTRAINT FK_CITATION_ID_FILE FOREIGN KEY (CITATION_ID) REFERENCES P_CITATION (CITATION_ID);


CREATE SEQUENCE SEQ_FILE_ID
START WITH 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
MINVALUE 0
NOCACHE 
NOCYCLE 
NOORDER ;

CREATE TABLE P_STERM_CATEGORY
(
    STERM_CATEGORY_ID    INTEGER NOT NULL ,
    STANDARD_TERM_ID     NUMBER(12) NOT NULL ,
    LL_CATEGORY_ID       NUMBER(11) NOT NULL 
);


COMMENT ON COLUMN P_STERM_CATEGORY.STERM_CATEGORY_ID IS 'Uniue identifier of the list item record';
COMMENT ON COLUMN P_STERM_CATEGORY.LL_CATEGORY_ID IS 'CATEGORY info,  the foreign key from P_LIST_ITEM table.';

CREATE UNIQUE INDEX XPKP_STERM_CATEGORY ON P_STERM_CATEGORY
(STERM_CATEGORY_ID   ASC);

ALTER TABLE P_STERM_CATEGORY
ADD CONSTRAINT  XPKP_STERM_CATEGORY PRIMARY KEY (STERM_CATEGORY_ID);

ALTER TABLE P_STERM_CATEGORY
ADD CONSTRAINT FK_PSTERM_CATEGORY_ID FOREIGN KEY (STANDARD_TERM_ID) REFERENCES P_STANDARD_TERM (STANDARD_TERM_ID) ON DELETE SET NULL;



ALTER TABLE P_STERM_CATEGORY
ADD CONSTRAINT FK_P_LIST_ID_STERM_CATEGORY FOREIGN KEY (LL_CATEGORY_ID) REFERENCES P_LIST_ITEM (LL_ID) ON DELETE SET NULL;


CREATE SEQUENCE SEQ_CATEGORY_ID
START WITH 1
MAXVALUE 999999999999999999999999999
INCREMENT BY 1
MINVALUE 0
NOCACHE 
NOCYCLE 
NOORDER ;
