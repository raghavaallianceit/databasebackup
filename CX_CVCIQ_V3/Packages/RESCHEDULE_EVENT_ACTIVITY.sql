CREATE OR REPLACE PACKAGE cx_cvciq_v3."RESCHEDULE_EVENT_ACTIVITY" 
AS
                           
PROCEDURE reschedule_event_day(    
                           out_chr_err_code   OUT VARCHAR2,
                           out_chr_err_msg    OUT VARCHAR2,
                           p_status           OUT VARCHAR2,
                           p_activity_day_id  IN NUMBER,
                           p_arrival          IN TIMESTAMP,
                           p_adjorn           IN TIMESTAMP
                           );                    
end;
/