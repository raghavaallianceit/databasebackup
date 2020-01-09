CREATE OR REPLACE PACKAGE cx_cvciq_v3.bi_report_gen_pkg
IS

FUNCTION fn_timestamp_to_time_dt(in_date IN TIMESTAMP,in_loc_timezone VARCHAR2,in_duration NUMBER)
   RETURN VARCHAR2;
   
  PROCEDURE operations_rep(
      out_chr_err_code OUT VARCHAR2,
      out_chr_err_msg OUT VARCHAR2,
      out_oper_rep_tab OUT return_arr_result ,
      in_from_date IN date,
      in_to_date IN date,
      in_sort_column IN VARCHAR2,
      in_order_by IN VARCHAR2,
      in_location IN VARCHAR2 );
--
--PROCEDURE  catering_rep(
--      out_chr_err_code OUT VARCHAR2,
--      out_chr_err_msg OUT VARCHAR2,
--      out_oper_rep_tab OUT return_arr_result ,
--      in_from_date IN date,
--      in_to_date IN date,
--      in_sort_column IN VARCHAR2,
--      in_order_by IN VARCHAR2,
--      in_location IN VARCHAR2 );
--

 PROCEDURE security_rep 
             (out_chr_err_code   OUT VARCHAR2,
              out_chr_err_msg    OUT VARCHAR2,
              out_security_tab   OUT return_security_arr_result   ,
              in_from_date IN date,
              in_to_date IN date,
              in_sort_column IN VARCHAR2,
              in_order_by IN VARCHAR2,
             in_location IN VARCHAR2

             );
   
END ;
/