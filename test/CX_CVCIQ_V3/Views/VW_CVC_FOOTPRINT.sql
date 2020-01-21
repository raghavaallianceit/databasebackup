CREATE OR REPLACE FORCE VIEW cx_cvciq_v3.vw_cvc_footprint (object_type,request_id,audit_event_type,additional_info,activity_time,status_code,user_email,created_by,created_date,updated_by,updated_date,"ID",user_name) AS
select 'REQUEST' OBJECT_TYPE,request_id , 'state_transition' AUDIT_EVENT_TYPE,
concat(concat('{"targetStatus":"',STATUS_DESC),'"}')    ADDITIONAL_INFO,
Cast(date_made as timestamp ) ACTIVITY_TIME,
'200' status_code,
USER_ID USER_EMAIL,
CREATED_BY,
Cast(date_made as timestamp ) CREATED_DATE,
UPDATED_BY,
Cast(date_made as timestamp ) UPDATED_DATE,
ID,
Replace(SUBSTR (USER_ID,1, INSTR(USER_ID,'@') -1),'.',' ') as USER_NAME
 from cx_cvc.cvc_footprint where TYPE = 'REQUEST';