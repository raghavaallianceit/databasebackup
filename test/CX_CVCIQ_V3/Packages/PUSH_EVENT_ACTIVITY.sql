CREATE OR REPLACE PACKAGE cx_cvciq_v3."PUSH_EVENT_ACTIVITY" 
AS
PROCEDURE main_proc(    
                           out_chr_err_code   OUT VARCHAR2,
                           out_chr_err_msg    OUT VARCHAR2,
                           p_activity_day_id  IN NUMBER,
                           p_req_act_id       IN NUMBER,
                           p_room             IN NUMBER  ,
                           p_source_time      IN TIMESTAMP,
                           p_target_time      IN TIMESTAMP,
                           p_duration         IN NUMBER
                           );
                           
PROCEDURE push_activity(    
                           out_chr_err_code   OUT VARCHAR2,
                           out_chr_err_msg    OUT VARCHAR2,
                           p_activity_day_id  IN NUMBER,
                           p_req_act_id       IN NUMBER,
                           p_room             IN NUMBER,
                           p_source_time      IN TIMESTAMP,
                           p_target_time      IN TIMESTAMP,
                           p_duration         IN NUMBER
                           );
                           
PROCEDURE push_activity_upd(    
                           out_chr_err_code   OUT VARCHAR2,
                           out_chr_err_msg    OUT VARCHAR2,
                           p_activity_day_id  IN NUMBER,
                           p_req_act_id       IN NUMBER,
                   --        p_room             IN NUMBER,
                           p_source_time      IN TIMESTAMP,
                           p_target_time      IN TIMESTAMP,
                           p_duration         IN NUMBER
                           );                           
end;
/