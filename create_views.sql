set role lokbiradari_prakalp;

drop view if exists lokbiradari_prakalp_catchments_new cascade;
create view lokbiradari_prakalp_catchments_new as
  select *
  from catchment
  where name not ilike '%old%';

drop view if exists lokbiradari_prakalp_catchments_old cascade;
create view lokbiradari_prakalp_catchments_old as
  select *
  from catchment
  where name ilike '%old%';













SELECT grant_all_on_all(a.rolname)
FROM pg_roles a
WHERE pg_has_role('openchs', a.oid, 'member')
  and a.rolsuper is false
  and a.rolname not like 'pg%'
  and a.rolname not like 'rds%'
order by a.rolname;
