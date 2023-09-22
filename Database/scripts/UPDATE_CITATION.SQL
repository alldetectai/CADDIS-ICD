--alter session set current_schema = caddis_dev;
declare 
v_citationId number;
v_code  NUMBER;
  v_errm  VARCHAR2(64);

begin

    for e in (select * from tmp_citation_update)
    loop
        v_citationId := e.Citation_id;
        if e.TOBEDELETE is not null  then --AND e.TOBEDELETE = 'Y' 
       -- LOOP P_DATASET 
          IF E.CADLIT IS NOT NULL THEN
                FOR D IN (SELECT DATASET_ID
                   FROM P_DATASET
                  WHERE CITATION_ID = E.CITATION_ID )
                LOOP
                   
                  --LOOP P_CLASS_DESCRIPTOR
                   FOR C IN (SELECT CLASS_DESCRIPTOR_ID 
                                    FROM   P_CLASS_DESCRIPTOR 
                                   WHERE  DATASET_ID = D.DATASET_ID )
                           LOOP
                               DELETE P_CLASS_DETAILS
                                WHERE CLASS_DESCRIPTOR_ID = C.CLASS_DESCRIPTOR_ID;
                               
                               DELETE P_CLASS_DETAILS_TEMP
                                WHERE CLASS_DESCRIPTOR_ID = C.CLASS_DESCRIPTOR_ID;
                           END LOOP;
                   
                   DELETE P_CLASS_DESCRIPTOR
                   WHERE  DATASET_ID = D.DATASET_ID;
                   
                    DELETE P_LOCATION
                    WHERE DATASET_ID = D.DATASET_ID;
                    
                    FOR F IN (SELECT CAUSE_EFFECT_ID FROM P_CAUSE_EFFECT
                                    WHERE DATASET_ID = D.DATASET_ID )
                           LOOP
                               DELETE P_ANALYSIS_DETAILS
                               WHERE CAUSE_EFFECT_ID = F.CAUSE_EFFECT_ID;
                               
                               DELETE P_EFFECT_MEASURED
                               WHERE CAUSE_EFFECT_ID = F.CAUSE_EFFECT_ID;
                               
                               DELETE P_CAUSE_MEASURED
                               WHERE CAUSE_EFFECT_ID = F.CAUSE_EFFECT_ID;
                               
                               FOR SI IN ( SELECT SI_SIGNIFICANT_ID 
                                                  FROM P_SI_SIGNIFICANTS
                                                 WHERE CAUSE_EFFECT_ID = F.CAUSE_EFFECT_ID )
                                        LOOP
                                            DELETE P_SI_SIGNIFICANTS_EVIDENCE
                                             WHERE SI_SIGNIFICANT_ID = SI.SI_SIGNIFICANT_ID;
                                        END LOOP;
                                        
                                 DELETE P_SI_SIGNIFICANTS
                                  WHERE CAUSE_EFFECT_ID = F.CAUSE_EFFECT_ID;      
                                
                           END LOOP;
                           
                    DELETE P_CAUSE_EFFECT
                     WHERE DATASET_ID = D.DATASET_ID;
                END LOOP;  
          
                    
                   DELETE P_DATASET
                    WHERE CITATION_ID = E.CITATION_ID;
               END IF;
               
                IF E.CADLINK IS NOT NULL THEN
                   DELETE K_DATASET WHERE CITATION_ID = E.CITATION_ID;
               END IF;
               
                 IF E.ICD IS NOT NULL THEN
                   DELETE P_CAUSE_EFFECT_LINKAGE
                    WHERE CITATION_ID = E.CITATION_ID;
                    
                   DELETE ICD_LINKAGE_CITATION_JOIN
                   WHERE CITATION_ID = E.CITATION_ID;
                   
                      DELETE ICD_LINKAGE_CITATION_JOIN_REV
                   WHERE CITATION_ID = E.CITATION_ID;
                   
               END IF;
               

                IF E.CADDIS IS NOT NULL THEN
                   DELETE P_CADDIS_PAGE_CITATION_JOIN
                    WHERE CITATION_ID = E.CITATION_ID;
               END IF;
               
            DELETE P_CITATION
              WHERE CITATION_ID = E.CITATION_ID;
            DBMS_OUTPUT.PUT_LINE (
              'Delete CitationId  ' || e.CITATION_ID || '.'
             );      
        elsif e.ReplaceCitationId is not null then
            -- REPLEACE P_DATASET
          --     IF E.CADLIT IS NOT NULL THEN
                   UPDATE P_DATASET
                        SET CITATION_ID = E.ReplaceCitationId
                    WHERE CITATION_ID = E.CITATION_ID;
          --     END IF;
               
          --      IF E.CADLINK IS NOT NULL THEN
                   UPDATE K_DATASET
                        SET CITATION_ID = E.ReplaceCitationId
                    WHERE CITATION_ID = E.CITATION_ID;
          --     END IF;
               
           --      IF E.ICD IS NOT NULL THEN
                   UPDATE P_CAUSE_EFFECT_LINKAGE
                        SET CITATION_ID = E.ReplaceCitationId
                    WHERE CITATION_ID = E.CITATION_ID;
                    
                    UPDATE ICD_LINKAGE_CITATION_JOIN_REV
                    SET  CITATION_ID = E.ReplaceCitationId
                    WHERE CITATION_ID = E.CITATION_ID;
                    
                    UPDATE ICD_LINKAGE_CITATION_JOIN
                    SET  CITATION_ID = E.ReplaceCitationId
                    WHERE CITATION_ID = E.CITATION_ID;
           --    END IF;
               

            --    IF E.CADDIS IS NOT NULL THEN
                   UPDATE P_CADDIS_PAGE_CITATION_JOIN
                        SET CITATION_ID = E.ReplaceCitationId
                    WHERE CITATION_ID = E.CITATION_ID;
             --  END IF;
               
                DELETE P_CITATION
              WHERE CITATION_ID = E.CITATION_ID;
              
            DBMS_OUTPUT.PUT_LINE (
              'Replace Citation Id   ' ||  e.CITATION_ID || 
              ' with  ' || e.ReplaceCitationId || '.'
            );
       ELSE
            DBMS_OUTPUT.PUT_LINE (
              'SKIP Citation Id   ' ||  e.CITATION_ID ||  '.'
           );
        end if;   
    end loop;
           commit;
exception
    when others then 
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1, 64);
     DBMS_OUTPUT.PUT_LINE (
              'can not Delete CitationId  ' || v_citationId || '. ' || v_code || ': ' || v_errm);
             
 --rollback;
end;