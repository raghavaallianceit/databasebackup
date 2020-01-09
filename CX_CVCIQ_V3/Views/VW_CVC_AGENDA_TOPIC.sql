CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.vw_cvc_agenda_topic ("ID",topic_id,topic,topic_objective,optional_topic,suggested_presenter,suggested_presenter_status,created_by,updated_by,weekly_report,suggested_presenter_title,created_date,updated_date,request_id,start_time,end_time,duration,entry_date,request_type_activity_id,room_id) AS
SELECT
    agt."ID",
    ag."TOPIC_ID",
    ag.entry_name as TOPIC,
    agt."TOPIC_OBJECTIVE",
    agt."OPTIONAL_TOPIC",
    agt."SUGGESTED_PRESENTER",
    agt."SUGGESTED_PRESENTER_STATUS",
    agt."CREATED_BY",
    agt."UPDATED_BY",
    agt."WEEKLY_REPORT",
    agt."SUGGESTED_PRESENTER_TITLE",
    agt."CREATED_DATE",
    agt."UPDATED_DATE",
    ag.request_id,
    to_timestamp ( concat ( to_char(ag.entry_date, 'dd-mm-yyyy'), to_char(ag.time_from, ' HH24:MI:SS')), 'dd-mm-yyyy HH24:MI:SS') start_time,
    to_timestamp ( concat ( to_char(ag.entry_date, 'dd-mm-yyyy'), to_char(ag.time_to, ' HH24:MI:SS')), 'dd-mm-yyyy HH24:MI:SS') end_time,
    round(
        ( (ag.time_to - ag.time_from) * 24 * 60),
        0
    ) duration,
    ag.entry_date,
    '3' request_type_activity_id,
    ag.room_id
FROM
    cx_cvc.cvc_agenda ag,
    cx_cvc.cvc_agenda_topic agt
WHERE
        ag.topic_id IS NOT NULL
    AND
        ag.topic_id = agt.id;