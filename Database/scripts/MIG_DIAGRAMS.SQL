DECLARE
V_COUNT NUMBER;
BEGIN

   SAVEPOINT start_tran;

   FOR D IN  ( SELECT * FROM CADDIS.ICD_DIAGRAM P WHERE P.DIAGRAM_ID NOT IN ( SELECT DIAGRAM_ID FROM ICD_DIAGRAM ) )
   LOOP 
    
    INSERT INTO ICD_DIAGRAM VALUES(D.DIAGRAM_ID, 
                                                          D.DIAGRAM_NAME,
                                                          D.DIAGRAM_COLOR, 
                                                          D.CREATED_DT, 
                                                          D.CREATED_BY,
                                                          D.LAST_UPDATED_DT, 
                                                          D.LAST_UPDATED_BY,
                                                          D.DIAGRAM_WIDTH, 
                                                          D.DIAGRAM_HEIGHT,
                                                          D.DIAGRAM_DESC, 
                                                          D.LL_DIAGRAM_STATUS_ID,
                                                          D.IS_GOLD_SEAL,
                                                          D.LOCKED_BY_USER_ID,
                                                          D.IS_PUBLIC,
                                                          D.KEYWORDS,
                                                          D.LOCATION );
                                                          
    FOR S IN (SELECT * FROM CADDIS.ICD_DIAGRAM_SHAPE_JOIN WHERE DIAGRAM_ID = D.DIAGRAM_ID)
    LOOP


         INSERT INTO ICD_SHAPE (SHAPE_ID, SHAPE_LABEL, SHAPE_COLOR, SHAPE_WIDTH, SHAPE_HEIGHT, SHAPE_THICKNESS, SHAPE_TYPE, LL_LEGEND_FILTER_ID, TOP_LEFT_CORNER_PT_X, TOP_LEFT_CORNER_PT_Y, SHAPE_BIN_INDEX, LL_SHAPE_LABEL_SYMBOL_ID) 
                 SELECT SHAPE_ID, SHAPE_LABEL, SHAPE_COLOR, SHAPE_WIDTH, SHAPE_HEIGHT, SHAPE_THICKNESS, SHAPE_TYPE, LL_LEGEND_FILTER_ID, TOP_LEFT_CORNER_PT_X, TOP_LEFT_CORNER_PT_Y, SHAPE_BIN_INDEX, LL_SHAPE_LABEL_SYMBOL_ID
                  FROM CADDIS.ICD_SHAPE
                 WHERE SHAPE_ID = S.SHAPE_ID;
          
         INSERT INTO ICD_SHAPE_ATTRIBUTE ( SHAPE_ATTRIBUTE_ID, SHAPE_ID, LL_ATTRIBUTE_TYPE_ID, LL_DISPLAY_DIAGRAM_FILTER_ID )
                SELECT SHAPE_ATTRIBUTE_ID, SHAPE_ID, LL_ATTRIBUTE_TYPE_ID, LL_DISPLAY_DIAGRAM_FILTER_ID
                FROM CADDIS.ICD_SHAPE_ATTRIBUTE 
                WHERE SHAPE_ID = S.SHAPE_ID;
                
         INSERT INTO ICD_DIAGRAM_SHAPE_JOIN (DIAGRAM_SHAPE_JOIN_ID, DIAGRAM_ID, SHAPE_ID) VALUES (S.DIAGRAM_SHAPE_JOIN_ID, S.DIAGRAM_ID, S.SHAPE_ID );
     END LOOP;
     
    FOR L IN (SELECT * FROM CADDIS.ICD_DIAGRAM_LINE_JOIN WHERE DIAGRAM_ID = D.DIAGRAM_ID)
    LOOP 

             INSERT INTO ICD_LINE(LINE_ID, LINE_TYPE, LINE_COLOR, LINE_THICKNESS)
                    SELECT LINE_ID, LINE_TYPE, LINE_COLOR, LINE_THICKNESS
                     FROM CADDIS.ICD_LINE
                    WHERE LINE_ID = L.LINE_ID;
                    
         INSERT INTO ICD_DIAGRAM_LINE_JOIN (DIAGRAM_LINE_JOIN_ID, DIAGRAM_ID, LINE_ID) VALUES (L.DIAGRAM_LINE_JOIN_ID, L.DIAGRAM_ID, L.LINE_ID);
       
        FOR LP IN (SELECT * FROM CADDIS.ICD_LINE_POINT_JOIN WHERE LINE_ID = L.LINE_ID) LOOP
            INSERT INTO ICD_POINT ( POINT_ID, PT_X, PT_Y )
                SELECT  POINT_ID, PT_X, PT_Y 
                 FROM CADDIS.ICD_POINT
                WHERE POINT_ID = LP.POINT_ID;
                
             INSERT INTO ICD_LINE_POINT_JOIN (LINE_POINT_JOIN_ID, LINE_ID, POINT_ID ) VALUES (LP.LINE_POINT_JOIN_ID, LP.LINE_ID, LP.POINT_ID );
             
        END LOOP;
        
     END LOOP;

     INSERT INTO ICD_SHAPE_LINE_JOIN ( SHAPE_LINE_JOIN_ID, DIAGRAM_ID, SHAPE_ID,LINE_ID, EDGE_INDEX, START_PT)
                 SELECT  SHAPE_LINE_JOIN_ID, DIAGRAM_ID, SHAPE_ID,LINE_ID, EDGE_INDEX, START_PT FROM CADDIS.ICD_SHAPE_LINE_JOIN WHERE DIAGRAM_ID = D.DIAGRAM_ID;
     
    
     FOR LK IN(  SELECT DISTINCT SHAPE_LINKAGE_ID, SHAPE_FROM_ID, SHAPE_TO_ID
            FROM CADDIS.ICD_SHAPE_LINKAGE 
            WHERE SHAPE_FROM_ID IN (SELECT SHAPE_ID FROM CADDIS.ICD_DIAGRAM_SHAPE_JOIN WHERE DIAGRAM_ID = D.DIAGRAM_ID )
                AND  SHAPE_TO_ID IN (SELECT SHAPE_ID FROM CADDIS.ICD_DIAGRAM_SHAPE_JOIN WHERE DIAGRAM_ID = D.DIAGRAM_ID ) )
           LOOP
            INSERT INTO ICD_SHAPE_LINKAGE (SHAPE_LINKAGE_ID, SHAPE_FROM_ID, SHAPE_TO_ID) VALUES (LK.SHAPE_LINKAGE_ID, LK.SHAPE_FROM_ID, LK.SHAPE_TO_ID );

                 
            FOR A IN (  SELECT LINKAGE_CITATION_JOIN_ID, SHAPE_LINKAGE_ID, CASE CITATION_ID WHEN 2729 THEN 2701 
                                                                                                                            WHEN 2725 THEN 2706
                                                                                                                            WHEN 1947 THEN 724
                                                                                                                            ELSE CITATION_ID
                                                                                                                   END AS CITATION_ID
                                                                                                                            
                  FROM CADDIS.ICD_LINKAGE_CITATION_JOIN
                 WHERE SHAPE_LINKAGE_ID = LK.SHAPE_LINKAGE_ID ) LOOP
                 
                 SELECT COUNT(LINKAGE_CITATION_JOIN_ID) INTO V_COUNT  FROM ICD_LINKAGE_CITATION_JOIN
                  WHERE SHAPE_LINKAGE_ID = A.SHAPE_LINKAGE_ID
                   AND  CITATION_ID = A.CITATION_ID;
                   
                 IF ( V_COUNT = 0) THEN 
                  INSERT INTO ICD_LINKAGE_CITATION_JOIN (    LINKAGE_CITATION_JOIN_ID, SHAPE_LINKAGE_ID, CITATION_ID )
                    VALUES( A.LINKAGE_CITATION_JOIN_ID, A.SHAPE_LINKAGE_ID, A.CITATION_ID );
                 END IF;
            END LOOP;
     END LOOP;
     
     
     INSERT INTO ICD_NON_COLLAPSIBLE_BIN (NON_COLLAPSIBLE_BIN_ID, DIAGRAM_ID, DIAGRAM_BIN_INDEX) 
        SELECT NON_COLLAPSIBLE_BIN_ID, DIAGRAM_ID, DIAGRAM_BIN_INDEX 
        FROM CADDIS.ICD_NON_COLLAPSIBLE_BIN 
        WHERE DIAGRAM_ID = D.DIAGRAM_ID;
     
     INSERT INTO ICD_DIAGRAM_USER_JOIN (DIAGRAM_USER_JOIN_ID, DIAGRAM_ID, USER_ID )
        SELECT DIAGRAM_USER_JOIN_ID, DIAGRAM_ID, USER_ID
        FROM CADDIS.ICD_DIAGRAM_USER_JOIN 
        WHERE DIAGRAM_ID = D.DIAGRAM_ID;
     
     END LOOP;
     
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_tran;
    RAISE;

END;