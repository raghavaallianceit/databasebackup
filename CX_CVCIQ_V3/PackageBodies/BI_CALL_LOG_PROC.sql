CREATE OR REPLACE PACKAGE BODY cx_cvciq_v3."BI_CALL_LOG_PROC" 
AS
 PROCEDURE call_log_proc (out_chr_err_code     OUT    VARCHAR2,
                            out_chr_err_msg    OUT    VARCHAR2,
                            p_procid            IN     NUMBER,
                            p_id1               IN     NUMBER,
                            p_id2               IN     NUMBER,
                            in_chr_err_code     IN     VARCHAR2,
                            in_chr_err_msg      IN     VARCHAR2,
                            in_chr_add_msg      IN     VARCHAR2)
   IS
      l_err_message   VARCHAR2 (300);
      l_err_code      VARCHAR2 (300);
      l_procname      VARCHAR2 (300);
      
      
   BEGIN
      DBMS_OUTPUT.PUT_LINE ('INSIDE call_log_proc: ');
      l_err_message := in_chr_err_msg;
      l_err_code := in_chr_err_code;
      DBMS_OUTPUT.PUT_LINE ('Before insert bi_procedure_log: ');

      BEGIN
      
      
      IF p_procid = 11
      THEN
      
        l_procname := 'alter_request_activity';
        DBMS_OUTPUT.PUT_LINE('l_procname' || SQLERRM);
      ELSIF p_procid = 12
      THEN
      
        l_procname := 'push_event_activity';
        DBMS_OUTPUT.PUT_LINE('l_procname' || SQLERRM);
      ELSIF p_procid = 13
      THEN
      
        l_procname := 'reschedule_event_activity';
        DBMS_OUTPUT.PUT_LINE('l_procname' || SQLERRM);
      END IF;
      
         INSERT INTO bi_procedure_log (id,
                                       proc_name,
                                       attribute1,
                                       attribute2,
                                       error_message,
                                       error_code,
                                       date_time,
                                       additional_info)
              VALUES (p_procid,
                      l_procname,
                      p_id1,
                      p_id2,
                      l_err_code,
                      l_err_message,
                      CURRENT_TIMESTAMP,
                      in_chr_add_msg);
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE ('Error in insert bi_procedure_log: ');
            out_chr_err_code := SUBSTR (SQLERRM, 1, 255);
            out_chr_err_msg := 'Unable to insert into bi_procedure_log';
      END;

      COMMIT;
      l_err_message := NULL;
      l_err_code := NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
      DBMS_OUTPUT.PUT_LINE('in when others' || SQLERRM);
        -- NULL;
   END;
END;
/