CREATE OR REPLACE PACKAGE cx_cvciq_v3.cvc_bi_conv_master
AS

PROCEDURE log_error (out_chr_err_code       OUT    VARCHAR2,
                            out_chr_err_msg        OUT    VARCHAR2,
                            in_procedure_name      IN     VARCHAR2,
                            in_error_loc           IN     VARCHAR2,
                            in_error_code          IN     VARCHAR2,
                            in_error_desc          IN     VARCHAR2);
                            
FUNCTION fn_day_light_dt(in_date IN DATE)
   RETURN DATE;
   
FUNCTION fn_day_light_ts(in_ts IN TIMESTAMP)
   RETURN TIMESTAMP;                               
     
FUNCTION derivefn (in_chr_column1 IN VARCHAR2,in_chr_column2 IN VARCHAR2,in_chr_column3 IN VARCHAR2,in_chr_tab IN VARCHAR2)
   RETURN VARCHAR2;
                               
FUNCTION distinctfn (in_chr_column IN VARCHAR2)
   RETURN VARCHAR2;                            

FUNCTION decodefn ( in_fnvalid_id IN VARCHAR2)
   RETURN VARCHAR2;

FUNCTION date_to_ts_conv (inp_str IN VARCHAR2)
      RETURN VARCHAR2;

FUNCTION char_to_time (inp_str IN VARCHAR2)
      RETURN VARCHAR2;
      
FUNCTION replacefn  (inp_str IN VARCHAR2)
      RETURN VARCHAR2;

   --  cur_get_note_data sys_refcursor;
FUNCTION getcolumnlistfn (tabid IN VARCHAR2,bitabid IN VARCHAR2)
      RETURN VARCHAR2;

PROCEDURE main (out_chr_err_code   OUT VARCHAR2,
                    out_chr_err_msg    OUT VARCHAR2,
                     in_chr_trunc_table   IN VARCHAR2,                    
                     in_req_id         IN VARCHAR2,
                     in_inp_start_date   IN DATE,
                     in_inp_end_Date     IN DATE,
                     in_chr_status       IN VARCHAR2,
                     in_chr_bm_email   IN VARCHAR2);

PROCEDURE init_procedure   
                         (out_chr_err_code   OUT VARCHAR2,
                          out_chr_err_msg    OUT VARCHAR2,
                          in_chr_trunc_table IN VARCHAR2,                          
                          in_req_id        IN VARCHAR2,
                          in_inp_start_date   IN DATE,
                          in_inp_end_Date     IN DATE,
                          in_chr_status       IN VARCHAR2,
                          in_chr_bm_email   IN VARCHAR2);

PROCEDURE cvc_bi_conv_proc (out_chr_err_code      OUT VARCHAR2,
                               out_chr_err_msg       OUT VARCHAR2,
                                in_chr_srcstgtab   IN     VARCHAR2,
                               in_chr_biqtab      IN     VARCHAR2,
                               in_chr_srctab      IN     VARCHAR2,
                               in_chr_bistagtab   IN     VARCHAR2,
							   in_chr_trunc_tab   IN     VARCHAR2,
							   in_table_id        IN     NUMBER,
							   in_fntab_validid   IN     VARCHAR2 ,
							   in_req_id        IN     VARCHAR2 ,
                               in_inp_start_date  IN     DATE,
                               in_inp_end_date    IN     DATE,
                               in_chr_status       IN VARCHAR2 ,
                               in_chr_bm_email   IN VARCHAR2);
                               
PROCEDURE  bi_cvc_location_gen (out_chr_err_code   OUT VARCHAR2,
                                out_chr_err_msg    OUT VARCHAR2 
                               );                             

PROCEDURE  bi_cvc_Agenda_gen (out_chr_err_code   OUT VARCHAR2,
                                out_chr_err_msg    OUT VARCHAR2,
                                inp_request_id IN NUMBER,
                                inp_start_date IN DATE,
                                inp_end_date IN DATE
                               );              
                               
PROCEDURE bi_cvc_presenter_gen;
                     
PROCEDURE fetch_insert_proc (l_chr_sql VARCHAR2, l_chr_tablename VARCHAR2,l_num_tabid NUMBER);
 
PROCEDURE truncate_tables  (   in_chr_tablename VARCHAR2    ) ;
    
PROCEDURE insert_user;
    
PROCEDURE update_biq_lookup;

PROCEDURE ins_opp_num;

PROCEDURE BIQ_POPULATE_DAY_ROOM;
   
END cvc_bi_conv_master;
/