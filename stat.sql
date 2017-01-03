exec dbms_stats.gather_schema_stats(ownname=>'SCOTT',estimate_percent => 100,method_opt => 'for all columns size auto',options => 'Gather' ,cascade => true,degree => 4)
