set head off
Column C1 format 9
Column C2 format 9999999.9 just left
Column C4 format 9999
Column C5 format 999.9
Column C6 format 99999999
select t.inst_id C1, t.value C2, q.value C2, (select count(u.username) from gv$session u  where u.username like 'SCOTT' and t.inst_id=u.inst_id ) C4, c.value C5, substr (i.host_name,1,8) C6 from gv$sysmetric t, gv$sysmetric q, gv$sysmetric c, gv$session u, gv$instance i
where t.metric_id=2121 
and q.metric_id=2004
and c.metric_id=2057
and t.group_id=3
and q.group_id=3
and c.group_id=3
and t.inst_id=q.inst_id
and t.inst_id=c.inst_id
and t.inst_id=i.inst_id
group by t.inst_id, t.value, q.value, c.value, i.host_name
order by t.inst_id
/
exit
