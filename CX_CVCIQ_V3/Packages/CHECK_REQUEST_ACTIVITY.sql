CREATE OR REPLACE PACKAGE cx_cvciq_v3."CHECK_REQUEST_ACTIVITY" 
AS
PROCEDURE return_avail_msg(    
                           out_chr_err_code   OUT VARCHAR2,
                           out_chr_err_msg    OUT VARCHAR2,
                           p_status           OUT VARCHAR2,
                           p_activity_day_id  IN NUMBER,
                           p_arrival          IN VARCHAR2,
                           p_adjorn           IN VARCHAR2
                           );
                           
/*PROCEDURE reschedule_event_day(    
                           out_chr_err_code   OUT VARCHAR2,
                           out_chr_err_msg    OUT VARCHAR2,
                           p_status           OUT VARCHAR2,
                           p_activity_day_id  IN NUMBER,
                           p_arrival          IN VARCHAR2,
                           p_adjorn           IN VARCHAR2
                           );     */                      
end;
/