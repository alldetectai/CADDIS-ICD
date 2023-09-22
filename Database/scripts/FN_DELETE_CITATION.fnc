CREATE OR REPLACE FUNCTION CADDIS_DEV.fn_delete_citation (
      citationId   IN   Number DEFAULT NULL
     )
      RETURN VARCHAR2
  IS
    TYPE row_cursor IS REF CURSOR;
    retstr varchar2(10);
    tempId    Number default 0;
    temp_row row_cursor;


  BEGIN
    dbms_output.PUT_LINE('in delete');
    retstr := 'success';

    delete ICD_CITATION_FILTER_JOIN
    where CITATION_ID = citationId;
    
    delete ICD_CITATION_FILTER_JOIN_REV
    where CITATION_ID = citationId;
    
    delete ICD_LINKAGE_CITATION_JOIN
    where CITATION_ID = citationId;
    
    delete ICD_LINKAGE_CITATION_JOIN_REV
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
/
