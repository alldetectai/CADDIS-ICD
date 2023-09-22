DECLARE
V_COUNT NUMBER;
v_count2 number;
BEGIN
  v_count2 := 0;
  FOR A IN   (  SELECT    LINKAGE_CITATION_JOIN_ID, SHAPE_LINKAGE_ID, CASE CITATION_ID WHEN 2729 THEN 2701 
                                                                                                                            WHEN 2725 THEN 2706
                                                                                                                            WHEN 1947 THEN 724
                                                                                                                            ELSE CITATION_ID
                                                                                                                   END AS CITATION_ID 
                   FROM CADDIS.ICD_LINKAGE_CITATION_JOIN
                   WHERE LINKAGE_CITATION_JOIN_ID NOT IN ( SELECT LINKAGE_CITATION_JOIN_ID FROM  ICD_LINKAGE_CITATION_JOIN)
                      AND CITATION_ID NOT IN (2665, 1903 ))
   LOOP
   
    SELECT COUNT(REV_LINKAGE_CITATION_JOIN_ID) INTO V_COUNT  FROM ICD_LINKAGE_CITATION_JOIN
                  WHERE REV_SHAPE_LINKAGE_ID = A.REV_SHAPE_LINKAGE_ID
                   AND  CITATION_ID = A.CITATION_ID;
             
      
                 IF  V_COUNT > 0 THEN 
                 v_count2 := v_count2 + V_COUNT;
                 else
                 
                  INSERT INTO ICD_LINKAGE_CITATION_JOIN_REV(REV_LINKAGE_CITATION_JOIN_ID, REV_SHAPE_LINKAGE_ID, CITATION_ID)
                    VALUES( A.REV_LINKAGE_CITATION_JOIN_ID, A.REV_SHAPE_LINKAGE_ID, A.CITATION_ID );  
                    
                 END IF;
      
   END LOOP;
           
  DBMS_OUTPUT.PUT_LINE('Total skiped: '||v_count2 );
  
  End;