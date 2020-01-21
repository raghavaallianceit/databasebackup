CREATE OR REPLACE PACKAGE cx_cvciq_v3."BI_CALL_LOG_PROC" 
AS
 PROCEDURE call_log_proc (out_chr_err_code     OUT    VARCHAR2,
                            out_chr_err_msg    OUT    VARCHAR2,
                            p_procid            IN     NUMBER,
                            p_id1               IN     NUMBER,
                            p_id2               IN     NUMBER,
                            in_chr_err_code     IN     VARCHAR2,
                            in_chr_err_msg      IN     VARCHAR2,
                            in_chr_add_msg      IN     VARCHAR2);
END;
/