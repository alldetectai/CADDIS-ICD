CREATE OR REPLACE PACKAGE BODY CADDIS2.CADDIS_PG AS

-------------------------------------------------------------------------------------------
FUNCTION fn_delete_citation (
      citationId   IN   Number
     )
      RETURN VARCHAR2
  IS
    TYPE row_cursor IS REF CURSOR;
    retstr varchar2(10);
    tempId    Number default 0;
    temp_row row_cursor;
    cursor linkage_cursor is
       SELECT shape_linkage_id
        FROM icd_linkage_citation_join
        WHERE shape_linkage_id IN (SELECT shape_linkage_id
                                FROM icd_linkage_citation_join
                               WHERE CITATION_ID = citationid)
        GROUP BY shape_linkage_id
        HAVING COUNT (shape_linkage_id) = 1;


  BEGIN
    dbms_output.PUT_LINE('in delete');
    retstr := 'success';

    delete ICD_CITATION_FILTER_JOIN
    where CITATION_ID = citationId;
    
    --DELETE LINAKGE BETWEEN SHAPES IF citation deleting is the only one 
    FOR c1 in linkage_cursor
    LOOP
        delete ICD_LINKAGE_CITATION_JOIN
        WHERE SHAPE_LINKAGE_ID = c1.SHAPE_LINKAGE_ID;
        
        DELETE ICD_SHAPE_LINKAGE
        WHERE SHAPE_LINKAGE_ID = c1.SHAPE_LINKAGE_ID;
        
    END LOOP;
    --delete if linkages have additional ciations
    delete ICD_LINKAGE_CITATION_JOIN
    where CITATION_ID = citationId;
    
    delete P_CADDIS_PAGE_CITATION_JOIN
    where CITATION_ID = citationId;
    
    delete P_LOCATION
    where DATASET_ID in (select DATASET_ID
    from P_DATASET
    where CITATION_ID = citationId
    );
    
    open temp_row for 
      SELECT EXPOSURE_SET_ID FROM P_EXPOSURE_SET
      where DATASET_ID in (select DATASET_ID
    from P_DATASET
    where CITATION_ID = citationId
    );
    
     loop
        exit when temp_row%notfound;
        fetch temp_row into tempId;
   
        
        DELETE P_EXPOSURE_PARAMETERS
        WHERE EXPOSURE_SET_ID  = tempId;

      end loop;
   close temp_row;
   

    open temp_row for 
      SELECT REVIEW_ID FROM P_REVIEW
      where DATASET_ID in (select DATASET_ID
    from P_DATASET
    where CITATION_ID = citationId
    );
    
     loop
        exit when temp_row%notfound;
        fetch temp_row into tempId;
   
        
        DELETE P_REVIEW_STATUS
        WHERE REVIEW_ID  = tempId;

      end loop;
   close temp_row;

    delete P_REVIEW
    where DATASET_ID in (select DATASET_ID
    from P_DATASET
    where CITATION_ID = citationId
    );
    
    open temp_row for 
      SELECT CLASS_DESCRIPTOR_ID FROM P_CLASS_DESCRIPTOR
      where DATASET_ID in (select DATASET_ID
    from P_DATASET
    where CITATION_ID = citationId
    );
    
     loop
        exit when temp_row%notfound;
        fetch temp_row into tempId;
   
        
        DELETE P_CLASS_DETAILS
        WHERE CLASS_DESCRIPTOR_ID  = tempId;

      end loop;
   close temp_row;
   
    delete P_CLASS_DESCRIPTOR
    where DATASET_ID in (select DATASET_ID
    from P_DATASET
    where CITATION_ID = citationId
    );
    
    
   open temp_row for 
      SELECT RESPONSE_PARAM_ID FROM P_RESPONSE_MEASURED
      where RESPONSE_SET_ID in (select RESPONSE_SET_ID
    from P_RESPONSE_SET rs, P_DATASET d
    where d.CITATION_ID = citationId
    and d.DATASET_ID = rs.DATASET_ID
    );
    
     loop
        exit when temp_row%notfound;
        fetch temp_row into tempId;
   
        
        DELETE P_RESPONSE_STRESSOR_RELATIONSH
        WHERE RESPONSE_PARAM_ID  = tempId;

      end loop;
   close temp_row;
   
    open temp_row for 
      SELECT RESPONSE_SET_ID FROM P_RESPONSE_SET
      where DATASET_ID in (select DATASET_ID
    from P_DATASET
    where CITATION_ID = citationId
    );
    
     loop
        exit when temp_row%notfound;
        fetch temp_row into tempId;
   
        
        DELETE P_RESPONSE_MEASURED
        WHERE RESPONSE_SET_ID  = tempId;

      end loop;
   close temp_row;
   

           
    delete P_EXPOSURE_RESPONSE_ASSOC
    where DATASET_ID in (select DATASET_ID
    from P_DATASET
    where CITATION_ID = citationId
    );
    
    delete P_EXPOSURE_SET
    where DATASET_ID in (select DATASET_ID
    from P_DATASET
    where CITATION_ID = citationId
    );
    
    delete P_RESPONSE_SET
    where DATASET_ID in (select DATASET_ID
    from P_DATASET
    where CITATION_ID = citationId
    );
    
    delete P_SOURCES
    where DATASET_ID in (select DATASET_ID
    from P_DATASET
    where CITATION_ID = citationId
    );
    /*
    delete P_SI_SIGNIFICANTS
    where DATASET_ID in (select DATASET_ID
    from P_DATASET
    where CITATION_ID = citationId
    );

    */
    delete P_DATASET
    where CITATION_ID = citationId;
    
    
    delete P_CITATION
    where CITATION_ID = citationId;
    
    --COMMIT;

    RETURN retstr;

    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RAISE_APPLICATION_ERROR(-20000,SQLERRM);
        RETURN 'EXCEPTION';


END fn_delete_citation;
-------------------------------------------------------------------------------------------
FUNCTION levenstein (p_source_string IN VARCHAR2,
                             p_target_string IN VARCHAR2)
       RETURN NUMBER DETERMINISTIC
    AS
       v_length_of_source NUMBER := NVL (LENGTH (p_source_string), 0);
       v_length_of_target NUMBER := NVL (LENGTH (p_target_string), 0);
       TYPE mytabtype IS  TABLE OF NUMBER INDEX BY BINARY_INTEGER;
       column_to_left     mytabtype;
       current_column     mytabtype;
       v_cost             NUMBER := 0;
    BEGIN
       IF v_length_of_source = 0 THEN
          RETURN v_length_of_target;
       ELSIF v_length_of_target = 0 THEN
          RETURN v_length_of_source;
       ELSE
          FOR j IN 0 .. v_length_of_target LOOP
             column_to_left(j) := j;
          END LOOP;
          FOR i IN 1.. v_length_of_source LOOP
             current_column(0) := i;
             FOR j IN 1 .. v_length_of_target LOOP
                IF SUBSTR (p_source_string, i, 1) =
                   SUBSTR (p_target_string, j, 1)
                THEN v_cost := 0;
                ELSE v_cost := 1;
                END IF;
                current_column(j) := LEAST (current_column(j-1) + 1,
                                            column_to_left(j) + 1,
                                            column_to_left(j-1) + v_cost);
             END LOOP;
             FOR j IN 0 .. v_length_of_target LOOP
                column_to_left(j) := current_column(j);
             END LOOP;
          END LOOP;
       END IF;
       RETURN current_column(v_length_of_target);
    END levenstein;
    
    
-------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------- 
FUNCTION percent_match (
   p_source_string   IN   VARCHAR2,
   p_target_string   IN   VARCHAR2
)
   RETURN NUMBER
AS
   v_length_of_source   NUMBER    := NVL (LENGTH (TRIM (p_source_string)), 0);
   v_length_of_target   NUMBER    := NVL (LENGTH (TRIM (p_target_string)), 0);
   v_source             VARCHAR2 (4000);
   v_target             VARCHAR2 (4000);
BEGIN
   v_source := UPPER (TRIM (p_source_string));
   v_target := UPPER (TRIM (p_target_string));

   IF v_length_of_source = 0 OR v_length_of_target = 0
   THEN
      RETURN 0;
   END IF;

   IF v_length_of_source > v_length_of_target
   THEN
      RETURN   100
             - (levenstein (v_source, v_target) * 100 / v_length_of_source);
   ELSE
      RETURN   100
             - (levenstein (v_target, v_source) * 100 / v_length_of_target);
   END IF;
END percent_match;

END CADDIS_PG;
/
