CREATE OR REPLACE PROCEDURE UPLOAD_DATAENTRY
 
IS

    V_CITATION_ID  P_CITATION.CITATION_ID%TYPE;
    V_DATASET_ID K_DATASET.DATASET_ID%TYPE;
    V_CAUSE_EFFECT_ID K_CAUSE_EFFECT.CAUSE_EFFECT_ID%TYPE;
    V_STATE_ENTITY_TYPE_ID P_TYPE_ENTITY_NAME.TYPE_ENTITY_ID%TYPE;
     V_ENTITY_TYPE_ID P_TYPE_ENTITY_NAME.TYPE_ENTITY_ID%TYPE;
    V_LL_SOURCE_DATA_ID P_LIST_ITEM.LL_ID%TYPE;
    V_LL_STUDY_TYPE_ID P_LIST_ITEM.LL_ID%TYPE;
    V_LL_HABITAT_ID P_LIST_ITEM.LL_ID%TYPE;
    V_LL_CAUSE_TRAJECTORY_ID P_LIST_ITEM.LL_ID%TYPE;
    V_LL_EFFECT_TRAJECTORY_ID P_LIST_ITEM.LL_ID%TYPE;
    V_CAUSE_TERM_ID P_STANDARD_TERM.STANDARD_TERM_ID%TYPE;
    V_EFFECT_TERM_ID P_STANDARD_TERM.STANDARD_TERM_ID%TYPE;
    
    V_ERROR  VARCHAR2(4000);
BEGIN

    FOR R IN (SELECT * FROM TMP_DATA_ENTRY)
    LOOP
    
        IF R.AUTHOR IS NOT NULL AND R.YEAR IS NOT NULL THEN
           BEGIN
                SELECT CITATION_ID INTO V_CITATION_ID 
                  FROM P_CITATION
                 WHERE AUTHOR = R.AUTHOR 
                      AND YEAR = R.YEAR
                      AND ROWNUM = 1;
                      
                V_DATASET_ID := SEQ_DATASET_ID.NEXTVAL;
                
                BEGIN
                    SELECT L.LL_ID INTO V_LL_SOURCE_DATA_ID 
                      FROM P_LIST_ITEM L
                    WHERE L.TYPE_ENTITY_ID = (SELECT TYPE_ENTITY_ID FROM P_TYPE_ENTITY_NAME N WHERE N.TYPE_ENTITY_NAME = 'SOURCE_DATA')
                        AND L.LIST_ITEM_DESCRIPTION = R.SOURCE_DATA;
               EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        SELECT SEQ_LL_ID.NEXTVAL INTO V_LL_SOURCE_DATA_ID  FROM DUAL;
                        INSERT INTO P_LIST_ITEM(LL_ID, TYPE_ENTITY_ID, LIST_ITEM_CODE, LIST_ITEM_DESCRIPTION) 
                        VALUES(V_LL_SOURCE_DATA_ID,  (SELECT TYPE_ENTITY_ID FROM P_TYPE_ENTITY_NAME N WHERE N.TYPE_ENTITY_NAME = 'SOURCE_DATA'), R.SOURCE_DATA, R.SOURCE_DATA);
               END;
               
                BEGIN
                    SELECT L.LL_ID INTO V_LL_STUDY_TYPE_ID 
                      FROM P_LIST_ITEM L
                    WHERE L.TYPE_ENTITY_ID = (SELECT TYPE_ENTITY_ID FROM P_TYPE_ENTITY_NAME N WHERE N.TYPE_ENTITY_NAME = 'STUDY TYPE')
                        AND L.LIST_ITEM_DESCRIPTION = R.STUDY_TYPE;
               EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        SELECT SEQ_LL_ID.NEXTVAL INTO V_LL_STUDY_TYPE_ID  FROM DUAL;
                        INSERT INTO P_LIST_ITEM(LL_ID, TYPE_ENTITY_ID, LIST_ITEM_CODE, LIST_ITEM_DESCRIPTION) 
                        VALUES(V_LL_STUDY_TYPE_ID,  (SELECT TYPE_ENTITY_ID FROM P_TYPE_ENTITY_NAME N WHERE N.TYPE_ENTITY_NAME = 'STUDY TYPE'), R.STUDY_TYPE, R.STUDY_TYPE);
                END;
                
                BEGIN
                    SELECT L.LL_ID INTO V_LL_HABITAT_ID 
                      FROM P_LIST_ITEM L
                    WHERE L.TYPE_ENTITY_ID= (SELECT TYPE_ENTITY_ID FROM P_TYPE_ENTITY_NAME N WHERE N.TYPE_ENTITY_NAME = 'HABITAT')
                        AND L.LIST_ITEM_DESCRIPTION = R.HABITAT;
               EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        SELECT SEQ_LL_ID.NEXTVAL INTO V_LL_HABITAT_ID  FROM DUAL;
                        INSERT INTO P_LIST_ITEM(LL_ID, TYPE_ENTITY_ID, LIST_ITEM_CODE, LIST_ITEM_DESCRIPTION) 
                        VALUES(V_LL_HABITAT_ID,  (SELECT TYPE_ENTITY_ID FROM P_TYPE_ENTITY_NAME N WHERE N.TYPE_ENTITY_NAME = 'HABITAT'), R.HABITAT, R.HABITAT);
                    
                END;
                
                INSERT INTO K_DATASET (DATASET_ID, LL_SOURCE_DATA_ID, LL_STUDY_TYPE_ID, LL_HABITAT_ID, STUDYDETAILS,  LOCATION_COMMENT, CREATE_USER) 
                            VALUES(V_DATASET_ID,  V_LL_SOURCE_DATA_ID,V_LL_STUDY_TYPE_ID, V_LL_HABITAT_ID, R.DESIGN_COMMENT, R.CONTEXT_COMMENT, 'CADDIS_DEV');
               
               DBMS_OUTPUT.PUT_LINE('DATASET_ID IS ' || V_DATASET_ID);
            EXCEPTION
             WHEN NO_DATA_FOUND THEN
                    V_ERROR := 'CAN NOT FIND CITATION FOR ' || R.AUTHOR || '/ ' || R.YEAR;
             
          END;
             
           
        END IF;
        
          BEGIN
                    SELECT L.LL_ID INTO V_LL_CAUSE_TRAJECTORY_ID 
                      FROM P_LIST_ITEM L
                    WHERE L.TYPE_ENTITY_ID= (SELECT TYPE_ENTITY_ID FROM P_TYPE_ENTITY_NAME N WHERE N.TYPE_ENTITY_NAME = 'TRAJECTORY')
                        AND L.LIST_ITEM_DESCRIPTION = R.CAUSE_TRAJECTORY;
               EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        SELECT SEQ_LL_ID.NEXTVAL INTO V_LL_CAUSE_TRAJECTORY_ID  FROM DUAL;
                        INSERT INTO P_LIST_ITEM(LL_ID, TYPE_ENTITY_ID, LIST_ITEM_CODE, LIST_ITEM_DESCRIPTION) 
                        VALUES(V_LL_CAUSE_TRAJECTORY_ID,  (SELECT TYPE_ENTITY_ID FROM P_TYPE_ENTITY_NAME N WHERE N.TYPE_ENTITY_NAME = 'TRAJECTORY'), R.CAUSE_TRAJECTORY, R.CAUSE_TRAJECTORY);
                    
                END;

         BEGIN
                    SELECT L.LL_ID INTO V_LL_EFFECT_TRAJECTORY_ID 
                      FROM P_LIST_ITEM L
                    WHERE L.TYPE_ENTITY_ID= (SELECT TYPE_ENTITY_ID FROM P_TYPE_ENTITY_NAME N WHERE N.TYPE_ENTITY_NAME = 'TRAJECTORY')
                        AND L.LIST_ITEM_DESCRIPTION = R.EFFECT_TRAJECTORY;
               EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        SELECT SEQ_LL_ID.NEXTVAL INTO V_LL_EFFECT_TRAJECTORY_ID  FROM DUAL;
                        INSERT INTO P_LIST_ITEM(LL_ID, TYPE_ENTITY_ID, LIST_ITEM_CODE, LIST_ITEM_DESCRIPTION) 
                        VALUES(V_LL_EFFECT_TRAJECTORY_ID,  (SELECT TYPE_ENTITY_ID FROM P_TYPE_ENTITY_NAME N WHERE N.TYPE_ENTITY_NAME = 'TRAJECTORY'), R.EFFECT_TRAJECTORY, R.EFFECT_TRAJECTORY);
                    
                END;
    --V_STATE_ENTITY_TYPE_ID
        SELECT TYPE_ENTITY_ID INTO V_STATE_ENTITY_TYPE_ID FROM P_TYPE_ENTITY_NAME N WHERE N.TYPE_ENTITY_NAME = 'STATE';
        SELECT TYPE_ENTITY_ID INTO V_ENTITY_TYPE_ID FROM P_TYPE_ENTITY_NAME N WHERE N.TYPE_ENTITY_NAME = 'COUNTRY';
    
                
            BEGIN
                SELECT S.STANDARD_TERM_ID INTO V_CAUSE_TERM_ID 
                  FROM P_STANDARD_TERM S
                WHERE S.STANDARD_TERM =  R.CAUSE_TERM;
           EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    SELECT SEQ_STANDARD_TERM_ID.NEXTVAL INTO V_CAUSE_TERM_ID  FROM DUAL;
                    INSERT INTO P_STANDARD_TERM(STANDARD_TERM_ID, STANDARD_TERM, IS_EEL_TERM, STANDARD_TERM_DESC, IS_APPROVED, CREATE_USER ) 
                    VALUES(V_CAUSE_TERM_ID,  R.CAUSE_TERM, 'Y', R.CAUSE_TERM, 'Y', 'CADDIS_DEV');
                            
            END;
            
             
         BEGIN
                SELECT S.STANDARD_TERM_ID INTO V_EFFECT_TERM_ID 
                  FROM P_STANDARD_TERM S
                WHERE S.STANDARD_TERM =   R.EFFECT_TERM;
            EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    SELECT SEQ_STANDARD_TERM_ID.NEXTVAL INTO V_EFFECT_TERM_ID  FROM DUAL;
                   
                   INSERT INTO P_STANDARD_TERM(STANDARD_TERM_ID, STANDARD_TERM, IS_EEL_TERM, STANDARD_TERM_DESC, IS_APPROVED, CREATE_USER) 
                        VALUES(V_EFFECT_TERM_ID,  R.EFFECT_TERM, 'Y', R.EFFECT_TERM, 'Y', 'CADDIS_DEV');
                    
                END;
                
         
          DBMS_OUTPUT.PUT_LINE('AUTHOR IS ' || R.AUTHOR);
         INSERT INTO  K_CAUSE_EFFECT(CAUSE_EFFECT_ID
                                                         , DATASET_ID
                                                         , CAUSE_ID
                                                         , EFFECT_ID
                                                         ,LL_CAUSE_TRAJECTORY_ID
                                                         , LL_EFFECT_TRAJECTORY_ID
                                                         , CAUSE_COMMENT
                                                         , EFFECT_COMMENT
                                                         , LINKAGE_COMMENT
                                                         , EVIDENCE_DOCUMENTATION
                                                         , CREATE_USER)
             VALUES(SEQ_CAUSE_EFFECT_ID.NEXTVAL, V_DATASET_ID, V_CAUSE_TERM_ID, V_EFFECT_TERM_ID, V_LL_CAUSE_TRAJECTORY_ID, V_LL_EFFECT_TRAJECTORY_ID, R.CAUSE_COMMENT, R.EFFECT_COMMENT, R.LINKAGE_COMMENT, R.LINKAGE_DOCUMENTATION, 'CADDIS_DEV');
         
        IF R.STATE IS NOT NULL THEN    
          INSERT INTO K_LOCATION(LL_LOCATION_ID, DATASET_ID, LOC_TEXT, LL_TYPE_ENTITY_ID) 
            VALUES(SEQ_LOCATION_ID.NEXTVAL, V_DATASET_ID, R.STATE, V_STATE_ENTITY_TYPE_ID);
        END IF;
        
        IF R.COUNTRY IS NOT NULL THEN    
          INSERT INTO K_LOCATION(LL_LOCATION_ID, DATASET_ID, LOC_TEXT, LL_TYPE_ENTITY_ID) 
            VALUES(SEQ_LOCATION_ID.NEXTVAL, V_DATASET_ID, R.COUNTRY, V_ENTITY_TYPE_ID);
        END IF;
        
        
    END LOOP;
    
   -- COMMIT;
EXCEPTION
WHEN NO_DATA_FOUND THEN
       V_ERROR := V_ERROR ||  ' \n An error was encountered - '|| SQLCODE ;
        DBMS_OUTPUT.PUT_LINE(V_ERROR);
--   raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);

END UPLOAD_DATAENTRY;

