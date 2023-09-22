CREATE OR REPLACE function CADDIS_DEV.get_search_condition (p_str in varchar2, p_delim in varchar2 default ' ', p_field in varchar2)
return varchar2
is
    l_str varchar2(4000) default null;
    l_n number;
    l_data varchar2(4000) default null;
    l_ct number;
begin 
    l_str := p_str || p_delim;
    l_ct := 0;
    loop
        l_n := instr(l_str, p_delim);
        exit when (nvl(l_n,0) = 0);
            l_data :=  l_data || 'LOWER(' || p_field || ')' || ' like LOWER( ''%' || ltrim(rtrim(substr(l_str,1,l_n-1))) || '%'') ';
        l_str := substr( l_str, l_n+length(p_delim) );
        if (nvl(instr(l_str, p_delim),0) <> 0) then
            l_data := l_data || ' and ';
        end if;
        l_ct := l_ct +1;
    end loop;
    return '(' ||  l_data || ')';
end;
/