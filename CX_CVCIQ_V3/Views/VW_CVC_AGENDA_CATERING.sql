CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.vw_cvc_agenda_catering ("ID",cost_center,catering_type,number_attendees,created_by,created_date,updated_by,updated_date,special_instruction,request_id,dietary_restrictions,start_time,end_time,duration,request_type_activity_id,entry_date,room_id) AS
SELECT
    agt."ID",
    agt."COST_CENTER",
    agt."CATERING_TYPE",
    agt."NUMBER_ATTENDEES",
    agt."CREATED_BY",
    agt."CREATED_DATE",
    agt."UPDATED_BY",
    agt."UPDATED_DATE",
    agt."SPECIAL_INSTRUCTION",
    ag.request_id,
    special.cnt  AS DIETARY_RESTRICTIONS,
    to_timestamp ( concat ( to_char(ag.entry_date, 'dd-mm-yyyy'), to_char(ag.time_from, ' HH24:MI:SS')), 'dd-mm-yyyy HH24:MI:SS') start_time,
    to_timestamp ( concat ( to_char(ag.entry_date, 'dd-mm-yyyy'), to_char(ag.time_to, ' HH24:MI:SS')), 'dd-mm-yyyy HH24:MI:SS') end_time,
    round(
        ( (ag.time_to - ag.time_from) * 24 * 60),
        0
    ) duration,
    '2' request_type_activity_id,
    ag.entry_date,
    ag.room_id
FROM
    cx_cvc.cvc_agenda ag,
    cx_cvc.cvc_agenda_catering agt,
    (select CATERING_ID,  listagg(special_dietary,',') within group (order by special_dietary) cnt from cx_cvc.cvc_agenda_cat_sp group by CATERING_ID ) special
WHERE
        ag.catering_id IS NOT NULL
    AND 
        agt.id  = special.catering_id (+)
    AND
        ag.catering_id = agt.id;