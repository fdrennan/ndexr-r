drop view public.instance_main;
create view public.instance_main as
(
with instance_status as (
    select x.*
    from (
             select *,
                    row_number() over (partition by id order by time desc) as row_id
             from public.instance_status
             order by id
         ) x
    where row_id = 1
),
     keyfiles as (
         select kf.*
         from (
                  select *,
                         row_number() over (partition by key_file_name order by created_at desc) as row_id
                  from keyfiles
              ) kf
         where row_id = 1
     ),
     created_at as (
         select *
         from public.instance_created
     ),
     joined as (
         select ca.user_id,
                ca.id,
                ins.status,
                ins.time,
                ca.creation_time,
                ca.key_name,
                ca.instance_type,
                ca.image_id,
                ca.security_group_id,
                ca.instance_storage,
                kf.keyfile
         from instance_status ins
                  left join created_at ca on ins.id = ca.id
                  left join keyfiles kf on kf.key_file_name = ca.key_name
     )

select *
from joined
    );