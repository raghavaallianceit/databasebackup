CREATE OR REPLACE PACKAGE cx_cvciq_v3."ALTER_REQUEST_ACTIVITY" 
AS

PROCEDURE main( out_chr_err_code   OUT VARCHAR2,
                out_chr_err_msg    OUT VARCHAR2,
                p_request_id       IN NUMBER,
                p_newevent_date    IN DATE,
                p_duration         IN NUMBER
               );
               
/*PROCEDURE get_arr_adj_workday( out_chr_err_code   OUT VARCHAR2,
                                out_chr_err_msg    OUT VARCHAR2,
                                out_chr_arr        OUT VARCHAR2,
                                out_chr_adj        OUT VARCHAR2,
                                out_event_date     OUT DATE,
                                p_newevent_date    IN DATE,
                                p_request_id       IN NUMBER
                               )     ;          */

PROCEDURE extend_dates    ( out_chr_err_code   OUT VARCHAR2,
                            out_chr_err_msg    OUT VARCHAR2,
                            p_request_id       IN NUMBER,
                            p_event_date       IN DATE,
                            p_diff             IN NUMBER,
                            p_actual_duration  IN NUMBER
                           );
                           
PROCEDURE alter_dates   ( out_chr_err_code   OUT VARCHAR2,
                          out_chr_err_msg    OUT VARCHAR2,
                           p_request_id       IN NUMBER,
                           p_start_date       IN DATE,
                           p_duration         IN NUMBER,
                           p_actual_duration  IN NUMBER
                           );       
                           
PROCEDURE call_log_proc( out_chr_err_code   OUT VARCHAR2,
                         out_chr_err_msg    OUT VARCHAR2,
                         p_duration          IN NUMBER,
                         p_request_id        IN NUMBER,                         
                         in_chr_err_code     IN VARCHAR2,
                         in_chr_err_msg      IN VARCHAR2
                        )        ;                                  
END;
/