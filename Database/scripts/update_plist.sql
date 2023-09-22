begin

    for e in (select * from tmp_plist_update)
    loop
        update p_list_item
         set UPDATE_QUERY = e.UPDATE_QUERY
        where LL_ID = e.LL_ID;
        
    end loop;
    
end;

select * from p_list_item where type_entity_id = 36 and update_query is null