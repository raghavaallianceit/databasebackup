CREATE OR REPLACE PACKAGE BODY cx_cvciq_v3.cvc_bi_conv_master
IS

l_global_reqtab VARCHAR2(255)     := 'CVC_REQUEST';
l_global_bitab VARCHAR2(255)      := 'BI_REQUEST';
l_global_act_Tab  VARCHAR2(255)   := 'BI_REQUEST_ACTIVITY_DAY';
l_global_loc_Tab  VARCHAR2(255)   := 'BI_LOCATION';
l_global_cust_tab VARCHAR2(255)   := 'CVC_CUSTOMER';
l_global_cvc_lookup VARCHAR2(255) := 'CVC_LOOKUP_VALUES';
l_global_bi_lookup VARCHAR2(255)  := 'BI_LOOKUP_VALUE';
l_global_bi_doc VARCHAR2(255)     := 'BI_REQUEST_DOCUMENTS';
l_global_bi_pres VARCHAR2(255)    := 'BI_REQUEST_PRESENTER';
l_global_note VARCHAR2(255)       := 'BI_NOTE';
l_global_reqid NUMBER;
l_global_params VARCHAR2(255);
l_global_st_date DATE;
l_global_end_date DATE;
l_global_status VARCHAR2(255)     := NULL;
l_global_bm_email VARCHAR2(255)   := NULL;
l_gbl_trunc VARCHAR2(255)         := NULL;
   
PROCEDURE log_error(out_chr_err_code       OUT    VARCHAR2,
                    out_chr_err_msg        OUT    VARCHAR2,
                    in_procedure_name      IN     VARCHAR2,
                    in_error_loc           IN     VARCHAR2,
                    in_error_code          IN     VARCHAR2,
                    in_error_desc          IN     VARCHAR2)
   IS
      l_err_message   VARCHAR2 (300);
      l_err_code      VARCHAR2 (300);
      l_procname      VARCHAR2 (300);
      
      
   BEGIN   
 
     -- DBMS_OUTPUT.PUT_LINE ('Before insert bi_procedure_log: ');

         
               BEGIN
              
                 INSERT INTO cvc_bi_conv_log  (id,
                                               procedure_name,
                                              message_location,
                                               message,
                                               code,
                                               created_ts)
                      VALUES (BI_ERR_SEQ.nextval ,
                              in_procedure_name,
                              in_error_loc,
                              in_error_code,
                              in_error_desc,
                              CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT'
                              );
              EXCEPTION
                 WHEN OTHERS
                 THEN
                  DBMS_OUTPUT.PUT_LINE (
                        ' Error while inserting values into cvc_bi_conv_log--'
                     || SQLERRM
                     || '--'
                     || SQLCODE);
              END; 

      COMMIT;
      
      
   EXCEPTION
      WHEN OTHERS
      THEN
      DBMS_OUTPUT.PUT_LINE('in when others' || SQLERRM);
        -- NULL;
   END;
   
   FUNCTION fn_day_light_dt(in_date IN DATE)
   RETURN DATE
   IS
   
       l_given_year NUMBER;
       l_march_date DATE;
       l_nov_date DATE;
       l_out_dt TIMESTAMP ;

   BEGIN
            
         BEGIN
           
           IF in_date IS NOT NULL
           THEN
           
             SELECT EXTRACT(YEAR FROM in_date) 
               INTO l_given_year 
               FROM dual;  --to excract year from given date
           END IF;    
               
         EXCEPTION
           WHEN OTHERS
           THEN
             DBMS_OUTPUT.PUT_LINE ('Error getting the year' || SQLERRM);
         END ;
         
       --   DBMS_OUTPUT.PUT_LINE ('l_given_year : ' || l_given_year  || 'in_date : ' || in_date);
         
         BEGIN
           
          IF l_given_year IS NOT NULL
          THEN
          
           SELECT NEXT_DAY(TRUNC(TO_DATE(TO_CHAR(l_given_year||'/03/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday')+7 ,
                  NEXT_DAY(TRUNC(TO_DATE(TO_CHAR(l_given_year||'/11/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday')
             INTO l_march_date,
                  l_nov_date 
             FROM DUAL;    --to get date of march and nov dst dates
          END IF;   
         EXCEPTION
           WHEN OTHERS
           THEN
             DBMS_OUTPUT.PUT_LINE ('Error getting the march and nov dates for an year in DATE' || SQLERRM);
         END ;
         
          --  DBMS_OUTPUT.PUT_LINE ('l_march_date' || l_march_date ); 
         --   DBMS_OUTPUT.PUT_LINE ('l_nov_date' || l_nov_date ); 
         
            IF in_date IS NOT NULL
            THEN
            
                IF in_date >= l_march_date  AND in_date <= l_nov_date
                THEN
                
                    BEGIN
                      SELECT in_date - interval '1' hour 
                        INTO l_out_dt 
                        FROM dual;
                    EXCEPTION
                      WHEN OTHERS
                      THEN
                         DBMS_OUTPUT.PUT_LINE ('Error getting o/p' || SQLERRM);
                    END ; 
                                     
                ELSE
                
                    BEGIN
                     SELECT in_date 
                       INTO l_out_dt 
                       FROM dual;
                    EXCEPTION
                      WHEN OTHERS
                      THEN
                         DBMS_OUTPUT.PUT_LINE ('Error getting the march and nov dates for an year' || SQLERRM);
                    END ;  
                                  
                END IF; 
         END IF;
         
        RETURN l_out_dt;
        
    END fn_day_light_dt;
    
   FUNCTION fn_day_light_ts(in_ts IN TIMESTAMP)
   RETURN TIMESTAMP
   IS
   
       l_given_year NUMBER;
       l_march_date DATE;
       l_nov_date DATE;
       l_out_ts TIMESTAMP ;

   BEGIN
            
         BEGIN
          
           IF in_ts IS NOT NULL
           THEN
           
             SELECT EXTRACT(YEAR FROM in_ts) 
               INTO l_given_year 
               FROM dual;  --to excract year from given date
            END IF;   
               
         EXCEPTION
           WHEN OTHERS
           THEN
             DBMS_OUTPUT.PUT_LINE ('Error getting the year' || SQLERRM);
         END ;
         
         BEGIN
         
          IF l_given_year IS NOT NULL
          THEN
         
           SELECT NEXT_DAY(TRUNC(TO_DATE(TO_CHAR(l_given_year||'/03/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday')+7 ,
                  NEXT_DAY(TRUNC(TO_DATE(TO_CHAR(l_given_year||'/11/01'), 'YYYY/MM/DD'),'MM')-1,'Sunday')
             INTO l_march_date,
                  l_nov_date 
             FROM DUAL;    --to get date of march and nov dst dates
             
          END IF;   
         EXCEPTION
           WHEN OTHERS
           THEN
             DBMS_OUTPUT.PUT_LINE ('Error getting the march and nov dates for an year' || SQLERRM);
         END ;
         
        IF in_ts IS NOT NULL
        THEN  
                IF in_ts >= TO_TIMESTAMP(l_march_date,'DD-MM-YY HH24:MI:SS.FF') AND in_ts <= TO_TIMESTAMP(l_nov_date,'DD-MM-YY HH24:MI:SS.FF')
                THEN
                
                    BEGIN
                      SELECT in_ts - interval '1' hour 
                        INTO l_out_ts 
                        FROM dual;
                    EXCEPTION
                      WHEN OTHERS
                      THEN
                         DBMS_OUTPUT.PUT_LINE ('Error getting o/p' || SQLERRM);
                    END ; 
                                     
                ELSE
                
                    BEGIN
                     SELECT in_ts 
                       INTO l_out_ts 
                       FROM dual;
                    EXCEPTION
                      WHEN OTHERS
                      THEN
                         DBMS_OUTPUT.PUT_LINE ('Error getting the march and nov dates for an year' || SQLERRM);
                    END ;  
                                  
                END IF;
         END IF;
         
        RETURN l_out_ts;

    END fn_day_light_ts;
      
   FUNCTION derivefn (in_chr_column1 IN VARCHAR2 ,in_chr_column2 IN VARCHAR2 ,in_chr_column3 IN VARCHAR2 ,in_chr_tab IN VARCHAR2)
   RETURN VARCHAR2
   
   IS
   
         l_newchr_sql    LONG;
         l_col1          VARCHAR2 (200);
         l_col2          VARCHAR2 (200);
         l_final_val     VARCHAR2 (200);
         l_latter_str    VARCHAR2 (2000);
         l_former_str    VARCHAR2 (2000);
         l_chr_err_code  VARCHAR2 (255);
         l_chr_err_msg   VARCHAR2 (255);  
         l_out_chr_errbuf  VARCHAR2 (2000);
         l_chr_fn_name   VARCHAR2(50) := 'distinctfn';        
                
   BEGIN 
   
      BEGIN
       
         DBMS_OUTPUT.PUT_LINE (in_chr_column1);  
         
          IF in_chr_tab LIKE 'CVC%' 
          THEN      
      
               l_newchr_sql := ' SELECT ' ||in_chr_column1;                                       
               l_newchr_sql := l_newchr_sql || ' FROM '|| in_chr_tab ||'@dblink_to_cvc_new';
               l_newchr_sql := l_newchr_sql || ' WHERE ' || in_chr_column2;
               l_newchr_sql := l_newchr_sql || ' = '|| in_chr_column3;
          
          ELSE
          
               l_newchr_sql := ' SELECT ' ||in_chr_column1;                                       
               l_newchr_sql := l_newchr_sql || ' FROM '|| in_chr_tab  ;
               l_newchr_sql := l_newchr_sql || ' WHERE ' || in_chr_column2;
               l_newchr_sql := l_newchr_sql || ' = '|| in_chr_column3;
               
           END IF;    
               
         DBMS_OUTPUT.PUT_LINE (l_newchr_sql);
       
       RETURN l_newchr_sql;
           
      EXCEPTION
        WHEN OTHERS
         THEN
              DBMS_OUTPUT.PUT_LINE (
                    ' Error while adding Derive fn --'
                 || SQLERRM
                 || '--'
                 || SQLCODE);

              l_out_chr_errbuf :=
                    ' Error while adding Derive fn --'
                 || SQLERRM
                 || '--'
                 || SQLCODE;
              l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';

               log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_fn_name
                   , 'WHEN OTHERS - while adding Derive fn '
                   ,  SQLERRM
                   ,  SQLCODE
                   ); 
      END;

     
   END;      
   
   FUNCTION distinctfn (in_chr_column IN VARCHAR2)
   RETURN VARCHAR2
   
   IS
   
         l_newchr_sql    LONG;
         l_col1          VARCHAR2 (200);
         l_col2          VARCHAR2 (200);
         l_final_val     VARCHAR2 (200);
         l_latter_str    VARCHAR2 (2000);
         l_former_str    VARCHAR2 (2000);
         l_chr_err_code  VARCHAR2 (255);
         l_chr_err_msg   VARCHAR2 (255);  
         l_out_chr_errbuf  VARCHAR2 (2000);
         l_chr_fn_name   VARCHAR2(50) := 'distinctfn';        
                
   BEGIN 
   
      BEGIN
       
         DBMS_OUTPUT.PUT_LINE (in_chr_column);           
      
           l_newchr_sql := 'DISTINCT ' ||in_chr_column;                                       
           DBMS_OUTPUT.PUT_LINE (l_newchr_sql);
           l_newchr_sql := l_newchr_sql;

         DBMS_OUTPUT.PUT_LINE (l_newchr_sql);
       
       RETURN l_newchr_sql;
           
      EXCEPTION
        WHEN OTHERS
         THEN
              DBMS_OUTPUT.PUT_LINE (
                    ' Error while adding DISTINCT fn --'
                 || SQLERRM
                 || '--'
                 || SQLCODE);

              l_out_chr_errbuf :=
                    ' Error while adding DISTINCT fn --'
                 || SQLERRM
                 || '--'
                 || SQLCODE;
              l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';

               log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_fn_name
                   , 'WHEN OTHERS - while adding DISTINCT fn '
                   ,  SQLERRM
                   ,  SQLCODE
                   ); 
      END;

     
   END;      

   FUNCTION decodefn ( in_fnvalid_id IN VARCHAR2)
   RETURN VARCHAR2
   
   IS
   
         l_newchr_sql    LONG;
         l_col1          VARCHAR2 (200);
         l_col2          VARCHAR2 (200);
         l_col3          VARCHAR2 (200);
         l_table_name     VARCHAR2 (200);
         l_final_val     VARCHAR2 (200);
         l_latter_str    VARCHAR2 (2000);
         l_former_str    VARCHAR2 (2000);
         l_chr_err_code  VARCHAR2 (255);
         l_chr_err_msg   VARCHAR2 (255);  
         l_out_chr_errbuf  VARCHAR2 (2000);
         l_chr_fn_name VARCHAR2(50) := 'decodefn';        
                
  BEGIN 
   
      BEGIN
       
         DBMS_OUTPUT.PUT_LINE (in_fnvalid_id);
           
           BEGIN
             SELECT b.column1,
                    b.column2,
                    b.column3,
                    (SELECT tablename from CVC_BI_CONV_LOOKUP where tabid =b.tabid  )
               INTO l_col1,
                    l_col2  ,
                    l_col3,
                    l_table_name
               FROM cvc_bi_fn_validations b
              WHERE b.fn_validations = in_fnvalid_id
               AND b.validation_type = 'COLUMN';       
           EXCEPTION
            WHEN OTHERS
             THEN
              DBMS_OUTPUT.PUT_LINE (
                    ' Error while fetching values from cvc_bi_fn_validations--'
                 || SQLERRM
                 || '--'
                 || SQLCODE);

              l_out_chr_errbuf :=
                    ' Error while fetching values from cvc_bi_fn_validations--'
                 || SQLERRM
                 || '--'
                 || SQLCODE;
              l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';

               log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_fn_name
                   , 'WHEN OTHERS - while fetching values from cvc_bi_fn_Validations '
                   ,  SQLERRM
                   ,  SQLCODE
                   ); 
                   
           END;        

               l_newchr_sql := 'DECODE(' ||l_col1;
               l_newchr_sql := l_newchr_sql ||','|| l_col2;   
               l_newchr_sql := l_newchr_sql ||','|| l_col3;                                     
               l_newchr_sql := l_newchr_sql || ')';--- FROM '|| l_table_name ;
               l_newchr_sql := l_newchr_sql  ;
               DBMS_OUTPUT.PUT_LINE (l_newchr_sql);
           
       DBMS_OUTPUT.PUT_LINE ('l_newchr_sql in decode ' || l_newchr_sql );
       
       RETURN l_newchr_sql;
           
      EXCEPTION
        WHEN OTHERS
         THEN
          DBMS_OUTPUT.PUT_LINE (
                ' Error while fetching l_newchr_sql return value--'
             || SQLERRM
             || '--'
             || SQLCODE);

          l_out_chr_errbuf :=
                ' Error while fetching l_newchr_sql return value--'
             || SQLERRM
             || '--'
             || SQLCODE;
          l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';

               log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_fn_name
                   , 'WHEN OTHERS - inside char to time function '
                   ,  SQLERRM
                   ,  SQLCODE
                   ); 
      END;

     
  END;   
     
    FUNCTION date_to_ts_conv (inp_str IN VARCHAR2)
    RETURN VARCHAR2
   
    IS
     
     l_out_str        VARCHAR2(255);
     l_chr_err_code   VARCHAR2 (255);
     l_chr_err_msg    VARCHAR2 (255);  
     l_out_chr_errbuf VARCHAR2 (2000);
     l_chr_fn_name    VARCHAR2(50) := 'date_to_ts_conv';                     
       
    BEGIN
      
        BEGIN

          l_out_str := 'TO_TIMESTAMP('||inp_str|| ','''||'DD-MM-YY HH24:MI:SS.FF'')'; 
           
         DBMS_OUTPUT.PUT_LINE('Time_stamp_Col is:- ' || l_out_str );
        RETURN (l_out_str);
               
        EXCEPTION
           WHEN OTHERS
           THEN
              DBMS_OUTPUT.PUT_LINE (
                    ' Error while fetching l_num_instr value--'
                 || SQLERRM
                 || '--'
                 || SQLCODE);

              l_out_chr_errbuf :=
                    ' Error while fetching l_num_instr value--'
                 || SQLERRM
                 || '--'
                 || SQLCODE;
              l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';

               log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_fn_name
                   , 'WHEN OTHERS - while fetching l_num_instr value '
                   ,  SQLERRM
                   ,  SQLCODE
                   ); 
        END;
                                                        
    END;
   
   FUNCTION replacefn (inp_str IN VARCHAR2)
   RETURN VARCHAR2
   
   IS
     
     l_out_str        VARCHAR2(255);
     l_chr_err_code   VARCHAR2 (255);
     l_chr_err_msg    VARCHAR2 (255);  
     l_out_chr_errbuf VARCHAR2 (2000);
     l_chr_fn_name    VARCHAR2(50) := 'REPLACEFN';                     
       
    BEGIN
      
        BEGIN

          l_out_str := 'REPLCACE (';
          l_out_str :=  l_out_str ||inp_str;
          l_out_str :=  l_out_str || ',';
          l_out_str :=  l_out_str || '"-"' ;
          l_out_str :=  l_out_str || ')';

         DBMS_OUTPUT.PUT_LINE('Replace is:- ' || l_out_str );
         
        RETURN (l_out_str);
               
        EXCEPTION
           WHEN OTHERS
           THEN
              DBMS_OUTPUT.PUT_LINE (
                    ' Error while fetching l_num_instr value--'
                 || SQLERRM
                 || '--'
                 || SQLCODE);

              l_out_chr_errbuf :=
                    ' Error while fetching l_num_instr value--'
                 || SQLERRM
                 || '--'
                 || SQLCODE;
              l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';

               log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_fn_name
                   , 'WHEN OTHERS - while fetching l_num_instr value '
                   ,  SQLERRM
                   ,  SQLCODE
                   ); 
        END;
                                                        
    END;
    
   FUNCTION char_to_time (inp_str IN VARCHAR2)
   RETURN VARCHAR2
   
   IS
   
         l_num_instr      NUMBER;
         l_chr_former     VARCHAR2 (200);
         l_chr_latter     VARCHAR2 (200);
         l_final_val      VARCHAR2 (200);
         l_latter_str     VARCHAR2 (2000);
         l_former_str     VARCHAR2 (2000);
         l_chr_err_code   VARCHAR2 (255);
         l_chr_err_msg    VARCHAR2 (255);  
         l_out_chr_errbuf VARCHAR2 (2000);
         l_chr_fn_name    VARCHAR2(50) := 'char_to_time';       
   
    BEGIN
      
	  DBMS_OUTPUT.PUT_LINE ('inp_str in char_to_time : '|| inp_str);
	  
       BEGIN
        SELECT INSTR(inp_str, '-') 
          INTO l_num_instr
          FROM DUAL;
       EXCEPTION    
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  ' Error while fetching l_num_instr value--'
               || SQLERRM
               || '--'
               || SQLCODE);
                       
            l_out_chr_errbuf :=
                   ' Error while fetching l_num_instr value--'
               || SQLERRM
               || '--'
               || SQLCODE;
            l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
                    
               log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_fn_name
                   , 'WHEN OTHERS - while fetching l_num_instr value '
                   ,  SQLERRM
                   ,  SQLCODE
                   );       
       END;  
                
       BEGIN
        SELECT SUBSTR (inp_str,1,l_num_instr-1)
          INTO l_chr_former
          FROM DUAL;      
       EXCEPTION    
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  ' Error while fetching l_chr_former value--'
               || SQLERRM
               || '--'
               || SQLCODE);
                       
            l_out_chr_errbuf :=
                   ' Error while fetching l_chr_former value--'
               || SQLERRM
               || '--'
               || SQLCODE;
            l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
                    
               log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_fn_name
                   , 'WHEN OTHERS - while fetching l_chr_former value '
                   ,  SQLERRM
                   ,  SQLCODE
                   );      
       END;  
      
       BEGIN
         SELECT SUBSTR (inp_str,l_num_instr+1)
          INTO l_chr_latter
         FROM DUAL;
       EXCEPTION    
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  ' Error while fetching l_chr_latter value--'
               || SQLERRM
               || '--'
               || SQLCODE);
                       
            l_out_chr_errbuf :=
                   ' Error while fetching l_chr_latter value--'
               || SQLERRM
               || '--'
               || SQLCODE;
            l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
                    
               log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_fn_name
                   , 'WHEN OTHERS - whie fetching l_chr_latter value '
                   ,  SQLERRM
                   ,  SQLCODE
                   );       
       END;             
      
      l_former_str := ' TO_CHAR( ';
      l_former_str := l_former_str || l_chr_former ||',''fmhhfm:MI AM'') '; 
      l_former_str := l_former_str ;       
      
 
      l_latter_str := ' TO_CHAR( ';
      l_latter_str := l_latter_str || l_chr_latter ||',''fmhhfm:MI AM'') '; 
      l_latter_str := l_latter_str ;       
      
      
      l_final_val := l_former_str ||'||'|| '''-'''|| '||'|| l_latter_str;
      l_final_val := ','|| l_final_val;
      
      DBMS_OUTPUT.PUT_LINE ('l_final_val : '|| l_final_val);   
      
    
    RETURN l_final_val;
    
    EXCEPTION 
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  ' Error inside char to time function --'
               || SQLERRM
               || '--'
               || SQLCODE);
                       
            l_out_chr_errbuf :=
                  ' Error inside char to time function --'
               || SQLERRM
               || '--'
               || SQLCODE;
            l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
                    
                log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_fn_name
                   , 'WHEN OTHERS - inside char to time function '
                   ,  SQLERRM
                   ,  SQLCODE
                   );        
     END;               

   
   FUNCTION getcolumnlistfn (tabid IN VARCHAR2,bitabid IN VARCHAR2)
   RETURN VARCHAR2
   
   IS

      
      CURSOR getcolumn
      IS
        SELECT t.id, 
               t.tabid, 
               t.column_name ,
               t.data_type,
               t.fn_validations,
               t.utility_fn,
               t.additional_val
         FROM (
          SELECT id,
                 bi_conv_id tabid, 
                 bi_column column_name,
                 bi_datatype data_type ,
                 fn_validations,
                 utility_fn,
                 additional_val
             FROM cvc_bi_col_mapping
            WHERE bi_conv_id = tabid
              AND NVL(bitabid,src_table_id) = src_table_id
              AND conv_reqd ='Y'
         UNION ALL
           SELECT id, 
                  src_table_id tabid, 
                  CASE 
                       WHEN val_type ='DBSEQ' THEN default_val||'.NEXTVAL'
                       WHEN val_type ='DEFAULT' THEN default_val 
                    ELSE  source_column
                  END  column_name   , 
                  source_datatype data_type,
                  fn_validations,
                  utility_fn,
                  additional_val
             FROM cvc_bi_col_mapping
            WHERE src_table_id = tabid
              AND NVL(bitabid,bi_conv_id) = bi_conv_id
              AND conv_reqd ='Y'
            )t
            GROUP BY t.id,  
                     t.column_name ,
                     t.data_type,                     
                     t.tabid,
                     t.fn_validations,
                     t.utility_fn,
                     t.additional_val
            ORDER BY t.id;
            

      l_chr_err_code     VARCHAR2 (255);
      l_chr_err_msg      VARCHAR2 (255);
      v_insert_list      VARCHAR2 (16096);
      l_ref_cur_col      VARCHAR2 (16096) := NULL;
      v_ref_cur_output   VARCHAR2 (16000) := NULL;
      l_chr_column_name  VARCHAR2 (256);
      p_tab_name         VARCHAR2 (256);
      l_tab_id           VARCHAR2 (200);
      v_LoopCounter      NUMBER;
      v_MyTestCode       VARCHAR2 (200);
      v_SomeValue        VARCHAR2 (200);
      l_src_column       VARCHAR2 (200);
      l_bi_column        VARCHAR2 (200);
      l_tablename        VARCHAR2 (200);
      l_src_column1       VARCHAR2 (200);
      l_bi_column1        VARCHAR2 (200);
      l_tablename1        VARCHAR2 (200);
      l_ref_id            VARCHAR2 (200); 
      l_chr_col3          VARCHAR2 (200); 
      l_ref_id1           VARCHAR2 (200);  
      l_str              LONG; 
   --   l_der_str          LONG;
      refcur             SYS_REFCURSOR;      
      l_newchr_sql       LONG;
      l_col1             VARCHAR2 (200);
      l_col2             VARCHAR2 (200);
      l_final_val        VARCHAR2 (200);
      l_chr_column_list  VARCHAR2 (4096) := NULL;
      l_out_chr_errbuf   VARCHAR2 (2000);
      l_chr              VARCHAR2 (4096) := NULL;
      l_chr_After        VARCHAR2 (4096) := NULL;
      l_lt_hr            VARCHAR2 (4096) := NULL;
      l_fm_hr            VARCHAR2 (4096) := NULL;
	  l_fm_hr_val        VARCHAR2 (4096) := NULL;
	  l_fm_af_space      VARCHAR2 (4096) := NULL;
	  l_fm_bef_space     VARCHAR2 (4096) := NULL;
	  l_chr_default_val  VARCHAR2 (4096) := NULL;
      l_to_ts            VARCHAR2 (4096) := NULL;
      l_to_replace       VARCHAR2 (4096) := NULL;
      l_default_user     VARCHAR2 (200);
      l_default_ts       VARCHAR2 (200);
      l_init_column      VARCHAR2 (200);
      l_chr_fn_name      VARCHAR2(50) := 'getcolumnlistfn';           
      
      L_VAL_DER       VARCHAR2 (200);
      
   BEGIN
   
      
      FOR i IN getcolumn
      LOOP      
      
          IF i.fn_validations like '%COL%' AND i.tabid like 'SRC%'
          THEN  
            
                 DBMS_OUTPUT.PUT_LINE ('fn_validations inside : ' || i.fn_validations );
              
                   BEGIN
                     SELECT b.column1,
                            b.column2,
                            (SELECT tablename FROM cvc_bi_conv_lookup WHERE tabid = b.tabid) tablename,
                            'a.'||b.column3 ,
                            b.column3 
                       INTO l_src_column,
                            l_bi_column,
                            l_tablename   ,
                            l_ref_id,
                            l_chr_col3
                       FROM cvc_bi_fn_validations b
                      WHERE fn_validations = i.fn_validations 
                        --AND b.tabid = i.tabid
                        AND b.validation_type = 'COLUMN';              
                   EXCEPTION
                     WHEN OTHERS
                     THEN
                        DBMS_OUTPUT.PUT_LINE (
                              ' Error while fetching from cvc_bi_fn_validations --'
                           || SQLERRM
                           || '--'
                           || SQLCODE);
                               
                        l_out_chr_errbuf :=
                              ' Error while fetching from cvc_bi_fn_validations --'
                           || SQLERRM
                           || '--'
                           || SQLCODE;
                        l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
                            
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg
                       , l_chr_fn_name
                       , 'WHEN OTHERS - while fetching from cvc_bi_fn_validations'
                       ,  SQLERRM
                       ,  SQLCODE
                       ); 
                              
                   END;          
               
                /*  IF i.additional_val = 'decodefn'
                  THEN
                      DBMS_OUTPUT.PUT_LINE ('DECODE ');
                     l_src_column := decodefn(l_src_column,i.fn_validations );             
                  
                         
                  ELSIF i.additional_val = 'distinctfn'
                  THEN             
                           
                      DBMS_OUTPUT.PUT_LINE ('distinctfn : ' || l_src_column  );                 
                      l_src_column := distinctfn(l_src_column  );      
                 
                  ELSE          
                                        
                       l_chr_column_list :=  l_chr_column_list || l_chr ;                 
                  END IF;  */                
             
                IF  i.utility_fn = 'deriveval'
                THEN   
                  
                     --DBMS_OUTPUT.PUT_LINE ('deriveval : '   );  
                     
                     IF l_tablename LIKE 'CVC%'
                     THEN
                          l_str := ', ( SELECT ';
                          l_str := l_str || l_src_column ||'  FROM ';
                          l_str := l_str || l_tablename||'@dblink_to_cvc_new' ||' WHERE ';
                          l_str := l_str || l_bi_column ;
                     ELSE
                          l_str := ', ( SELECT ';
                          l_str := l_str || l_src_column ||'  FROM ';
                          l_str := l_str || l_tablename||' WHERE ';
                          l_str := l_str || l_bi_column ;                     
                     END IF; 
                     
                   -- DBMS_OUTPUT.PUT_LINE ('l_str before derivefn : ' || l_str  );
                       
                       
                            IF i.additional_val = 'derivefn'
                            THEN             
                              
                                   DBMS_OUTPUT.PUT_LINE ('DERIVE  : ' || l_ref_id  );      
                                  
                                     SELECT b.column1,
                                            b.column2,
                                            (SELECT tablename FROM cvc_bi_conv_lookup WHERE tabid = b.tabid) tablename,
                                            'a.'||b.column3 
                                       INTO l_src_column1,
                                            l_bi_column1,
                                            l_tablename1 ,
                                            l_ref_id1
                                       FROM cvc_bi_fn_validations b
                                      WHERE fn_validations = i.fn_validations 
                                        AND b.validation_type = 'DERIVEFN';     
                                        
 

                                     --DBMS_OUTPUT.PUT_LINE ('derivefn  YES  :' || l_src_column1 || l_bi_column1 || l_ref_id1||l_tablename1 );
                                    
                                     l_val_der := derivefn(l_src_column1 ,l_bi_column1, l_ref_id1,l_tablename1 );     
                                     l_val_der := l_str || ' IN  ( '|| l_val_der || ' ))';
                                                                    
                                    -- DBMS_OUTPUT.PUT_LINE ('derivefn op  :' || l_val_der);                                
               
                                     l_str  :=  l_val_der;
    
                              END IF; 
                               
                              IF i.additional_val = 'fn_val_col3'
                              THEN
                           --   DBMS_OUTPUT.PUT_LINE ('fn_val_col3 op  :' || l_chr_col3); 
                                     l_str := l_str || ' = '||  l_chr_col3;
                                     l_str := l_str ||  ' ) ';                              
                              END IF;
                      
                              IF i.additional_val IS NULL
                              THEN
                              
                                     l_str := l_str || ' = '||  l_ref_id;
                                     l_str := l_str ||  ' ) ';
                                  
                                     -- DBMS_OUTPUT.PUT_LINE ('l_der_str : ' || l_str  );  
                              
                             END IF;
                      
                 --    DBMS_OUTPUT.PUT_LINE ('l_str outside derive fn is  : ' || l_str  );                   
                       
                    l_chr_column_list := l_chr_column_list || l_str;
					
					-- DBMS_OUTPUT.PUT_LINE ('l_chr_column_list : ' || l_chr_column_list);
                      
                END IF;           
            

            ELSIF i.utility_fn = 'char_to_time' AND i.tabid like 'SRC%'
            THEN
             
                --  DBMS_OUTPUT.PUT_LINE ('char_to_time ');
                  
                   l_chr := char_to_time(i.column_name);
                  
                 --  l_chr        := 'SUBSTR (' || i.column_name ||',1, INSTR(' || i.column_name||','|| ''' '''||') -1)';
                  -- l_chr_After :=  'SUBSTR (' || i.column_name ||', INSTR(' || i.column_name||','|| ''' '''||') +1)';
                   
                  --  DBMS_OUTPUT.PUT_LINE ('char_to_time ' || l_chr  );

                  l_chr_column_list :=  l_chr_column_list || l_chr ;        
                    
            ELSIF i.utility_fn = 'str_before_space' AND i.tabid like 'SRC%'
            THEN
             
                ---  DBMS_OUTPUT.PUT_LINE ('string_before_space ' || i.column_name);
                  
                  l_fm_bef_space := 'SUBSTR (' || i.column_name ||',1, INSTR(' || i.column_name||','|| ''' '''||') -1)';
                  
                  l_fm_bef_space := ','|| l_fm_bef_space;
                  
                --  DBMS_OUTPUT.PUT_LINE ('string_before_space ' || l_fm_bef_space);
                  l_chr_column_list :=  l_chr_column_list || l_fm_bef_space ;    
            
            ELSIF i.utility_fn = 'default_value' AND i.tabid like 'SRC%'
            THEN
             
                ---  DBMS_OUTPUT.PUT_LINE ('default_value ' || i.column_name);
                  
                  l_chr_default_val  := 'DECODE(' || i.column_name ||','||'''.'''||',id||' ||'''_'''||'||'||'''convtopic'''||','||i.column_name||')';
                                       -- DECODE(NAME,'.',id||'_'||'convtopic',name)
                  l_chr_default_val := ','|| l_chr_default_val;
                  
                 -- DBMS_OUTPUT.PUT_LINE ('default_value ' || l_chr_default_val);
                  l_chr_column_list :=  l_chr_column_list || l_chr_default_val ;                               
                   
            ELSIF i.utility_fn = 'str_after_space' AND i.tabid like 'SRC%'
            THEN
             
                 --- DBMS_OUTPUT.PUT_LINE ('string_after_space ' || i.column_name);
                    
                     l_fm_af_space :=  'SUBSTR (' || i.column_name ||', INSTR(' || i.column_name||','|| ''' '''||') +1)';
                     l_fm_af_space := ','|| l_fm_af_space;
                     
                 --  DBMS_OUTPUT.PUT_LINE ('string_after_space ' || l_fm_af_space);
                  
                   l_chr_column_list :=  l_chr_column_list || l_fm_af_space ;                             
            
            ELSIF i.utility_fn = 'str_before_comma' AND i.tabid like 'SRC%'
            THEN
             
               ---   DBMS_OUTPUT.PUT_LINE ('string_before_comma ' || i.column_name);
                  
				   l_fm_hr_val := 'SUBSTR (' || i.column_name ||',1, INSTR(' || i.column_name||','|| ''','''||') -1)';
					
				   DBMS_OUTPUT.PUT_LINE ('l_fm_hr_val : '|| l_fm_hr_val);
                  
    			   l_fm_hr_val :=  ','|| l_fm_hr_val ;
    			 	  
                  -- DBMS_OUTPUT.PUT_LINE ('string_before_comma ' || l_fm_hr_val);
                  
                   l_chr_column_list :=  l_chr_column_list || l_fm_hr_val ;             
                   
            ELSIF i.utility_fn = 'str_after_comma' AND i.tabid like 'SRC%'
            THEN
             
                  ---DBMS_OUTPUT.PUT_LINE ('string_after_comma ' || i.column_name);
                  
                     l_lt_hr :=  'SUBSTR (' || i.column_name ||', INSTR(' || i.column_name||','|| ''' '''||') +1)';                 
                     l_lt_hr := ','|| l_lt_hr;
                                          
                   -- DBMS_OUTPUT.PUT_LINE ('string_after_comma ' || l_lt_hr);
					 
                     l_chr_column_list :=  l_chr_column_list || l_lt_hr ;   
                     
            ELSIF i.utility_fn = 'remove_space' AND i.tabid like 'SRC%'
            THEN
             
                  ---DBMS_OUTPUT.PUT_LINE ('string_after_comma ' || i.column_name);
                  
                     l_lt_hr :=  'REPLACE(INITCAP(lower(' || i.column_name ||')),'||'''_'''||','||''' ''' || ')';                 
                     l_lt_hr := ','|| l_lt_hr;
                                          
                   -- DBMS_OUTPUT.PUT_LINE ('string_after_comma ' || l_lt_hr);
					 
                     l_chr_column_list :=  l_chr_column_list || l_lt_hr ;                                             
              
          ELSIF i.utility_fn = 'date_to_ts' AND i.tabid like 'S%'
          THEN   
        
        
             l_to_ts := date_to_ts_conv(i.column_name);
             
            
             l_chr_column_list :=  l_chr_column_list  || ',' || l_to_ts ;   
                
           ELSIF i.utility_fn = 'replacefn' AND i.tabid like 'S%'
           THEN   
            
        
             l_to_replace := replacefn(i.column_name);
             
            
             l_chr_column_list :=  l_chr_column_list  || ',' || l_to_replace ;                             
          
            ELSE
         
              l_chr_column_list := l_chr_column_list || ',' || i.column_name;
             
         
         END IF;

                               
         IF i.additional_val = 'decodefn' AND i.tabid like 'SRC%'
         THEN
              -- DBMS_OUTPUT.PUT_LINE ('decodefn ');
            l_newchr_sql := decodefn( i.fn_validations );             
            l_chr_column_list :=  l_chr_column_list || ',' || l_newchr_sql ;                 
             
         ELSIF i.additional_val = 'distinctfn'
         THEN             
               
          --  DBMS_OUTPUT.PUT_LINE ('distinctfn : ' || l_chr_column_list || 'additional_val' || i.additional_val);                 
            l_newchr_sql := distinctfn(i.column_name  );                                
            l_chr_column_list :=  l_chr_column_list || ',' || l_newchr_sql ;                
            
                         
         END IF;              
        
        BEGIN 
      
             IF UPPER (i.data_type) LIKE 'NUMBER%'
             THEN
             
                l_chr_column_name := i.column_name;
                
             ELSIF UPPER (i.data_type) LIKE 'DATE%'
             THEN
             
                l_chr_column_name :=
                      CHR (39)
                   || 'to_date('
                   || CHR (39)
                   || '||chr(39)'
                   || '||to_char('
                   || i.column_name
                   || ','
                   || CHR (39)
                   || 'dd/mm/yyyy hh24:mi:ss'
                   || CHR (39)
                   || ')||chr(39)||'
                   || CHR (39)
                   || ', '
                   || CHR (39)
                   || '||chr(39)||'
                   || CHR (39)
                   || 'dd/mm/rrrr hh24:mi:ss'
                   || CHR (39)
                   || '||chr(39)||'
                   || CHR (39)
                   || ')'
                   || CHR (39);

                          
             ELSIF UPPER (i.data_type) LIKE 'VARCHAR2%' --AND i.fn_validations <> 'FN16'
             THEN
                -- Following line will hangle single quote in text data.
                l_chr_column_name :=
                      'CHR(39)||REPLACE('
                   || i.column_name
                   || ','''''''','''''''''''')||chr(39)';
                   
                
             ELSIF UPPER (i.data_type) LIKE 'CHAR%'
             THEN
                l_chr_column_name := 'chr(39)||' || i.column_name || '||chr(39)';
             END IF;
        
        EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  ' Error while creating column list inside the function --'
               || SQLERRM
               || '--'
               || SQLCODE);
                   
            l_out_chr_errbuf :=
                  ' Error while creating column list inside the function --'
               || SQLERRM
               || '--'
               || SQLCODE;
            l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
                
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_fn_name
               , 'WHEN OTHERS - while creating column list inside the function'
               ,  SQLERRM
               ,  SQLCODE
               );  
                     
        END;       
        
         l_ref_cur_col :=
               l_ref_cur_col
            || '||'
            || CHR (39)
            || ','
            || CHR (39)
            || '||'
            || l_chr_column_name;
            
        l_tab_id := i.tabid;
        
       -- i.additional_val := NULL;
            
      END LOOP;


      IF l_chr_column_list IS NULL
      THEN
         DBMS_OUTPUT.PUT_LINE ('--Table ' || l_tab_id || ' does not exist');
            
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_fn_name
               , 'Check the inputs passed to the getcolumnlistfn function, no rows returned'
               ,  SQLERRM
               ,  SQLCODE
               );         
      ELSE
      
    
         l_chr_column_list := LTRIM (l_chr_column_list, ',');
         l_ref_cur_col     := SUBSTR (l_ref_cur_col, 8);

      --   DBMS_OUTPUT.put_line ('l_chr_column_list at final  :' || l_chr_column_list);

      END IF;
               

      RETURN l_chr_column_list;
      
      
   EXCEPTION
    WHEN OTHERS
    THEN
        DBMS_OUTPUT.PUT_LINE (
              ' Error in the getcolumnlist function --'
           || SQLERRM
           || '--'
           || SQLCODE);
                       
        l_out_chr_errbuf :=
              ' Error in the getcolumnlist function --'
           || SQLERRM
           || '--'
           || SQLCODE;
        l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
                    
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_fn_name
               , 'WHEN OTHERS - error inside getcolumnlist function'
               ,  SQLERRM
               ,  SQLCODE
               );       
   END;  


    PROCEDURE main (out_chr_err_code   OUT VARCHAR2,
                    out_chr_err_msg    OUT VARCHAR2,
                    in_chr_trunc_table  IN VARCHAR2,                    
                    in_req_id           IN VARCHAR2,
                    in_inp_start_date   IN DATE,
                    in_inp_end_Date     IN DATE,
					in_chr_status       IN VARCHAR2,
                    in_chr_bm_email   IN VARCHAR2  )
    IS
    
      l_chr_err_code     VARCHAR2 (255);
      l_chr_err_msg      VARCHAR2 (255);
      l_out_chr_errbuf   VARCHAR2 (255); 
      l_chr_prc_name     VARCHAR2(50) := 'main';  
    
     BEGIN
        
           DBMS_OUTPUT.PUT_LINE ('in_req_id here ' || in_req_id);      
           DBMS_OUTPUT.PUT_LINE ('in_inp_start_date' || in_inp_start_date);
           DBMS_OUTPUT.PUT_LINE ('in_inp_end_date' || in_inp_end_date);
           DBMS_OUTPUT.PUT_LINE ('in_chr_trunc_table' || in_chr_trunc_table);
           
            EXECUTE IMMEDIATE 'TRUNCATE TABLE cvc_bi_conv_log';
           
             log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'Inside the main procedure'
               ,  null
               ,  null
               );  
           
           IF in_chr_trunc_table = 'Y' 
           THEN
           
               l_gbl_trunc := 'Y';
           
             UPDATE cvc_bi_conv_tab_master 
                SET process_flag = 'P',
                    trunc_table = 'Y'                   
               WHERE conv_Reqd ='Y' ;
               
                --to track data flow
               log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'Updated trunc flag to Y for master tables'
               ,  null
               ,  null
               );  
                   
               
           END IF;
           
           IF in_req_id IS NOT NULL
           THEN
		   
              l_global_reqid := in_req_id;	
 

               l_global_params := l_global_reqid;
 		  
			 
                 --to track data flow
                log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_prc_name
                   , 'Calling the init_procedure for request_id' 
                   ,  l_global_params
                   ,  NULL
                   );          
     
           END IF;
 

           IF in_inp_start_date IS NOT NULL AND in_inp_end_date IS NOT NULL
           THEN
           
                l_global_st_date := in_inp_start_date;
                l_global_end_date := in_inp_end_date;
                
                l_global_params := l_global_st_date||'-'||l_global_end_date;
              
               --to track data flow
                 log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_prc_name
                   , 'Calling the init_procedure for date params from :' 
                   ,  l_global_params
                   ,  NULL
                   );   
           END IF;
           
                 
           BEGIN          
                init_procedure(l_chr_err_code,l_chr_err_msg,in_chr_trunc_table,in_req_id,in_inp_start_date , in_inp_end_date ,in_chr_status,in_chr_bm_email );
           EXCEPTION
             WHEN OTHERS
             THEN
             DBMS_OUTPUT.PUT_LINE (
                          ' Error calling the init procedure --'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
           END;    
           

     EXCEPTION
      WHEN OTHERS
      THEN
        DBMS_OUTPUT.PUT_LINE (
              ' Error in the main procedure --'
           || SQLERRM
           || '--'
           || SQLCODE);
                       
        l_out_chr_errbuf :=
              ' Error in the main procedure --'
           || SQLERRM
           || '--'
           || SQLCODE;
        l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
                    
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'WHEN OTHERS - inside the main procedure'
               ,  SQLERRM
               ,  SQLCODE
               );  
     END;
     
   PROCEDURE init_procedure   
                         (out_chr_err_code   OUT VARCHAR2,
                          out_chr_err_msg    OUT VARCHAR2,
                          in_chr_trunc_table  IN VARCHAR2,                          
                          in_req_id           IN VARCHAR2,
                          in_inp_start_date   IN DATE,
                          in_inp_end_Date     IN DATE,
						  in_chr_status       IN VARCHAR2,
                          in_chr_bm_email   IN VARCHAR2  )
   IS
      l_chr_srcstage     VARCHAR2 (200);
      l_chr_biqtab       VARCHAR2 (200);
      l_chr_srctab       VARCHAR2 (200);
      l_chr_bistagtab    VARCHAR2 (200);
      l_chr_err_code     VARCHAR2 (255);
      l_chr_err_msg      VARCHAR2 (255);
      l_out_chr_errbuf   VARCHAR2 (2000);
      l_chr_prc_name     VARCHAR2(50) := 'init_procedure';  
       
   CURSOR cur_get_tab --- all setup tables
   IS
       SELECT b.trunc_table,
	          b.id,
			  b.fn_tab_validations,
             (SELECT a.tablename
                FROM CVC_BI_CONV_LOOKUP a
               WHERE a.tabid = b.src_table_id)
                srctable,       
             (SELECT a.staging_tab
                FROM CVC_BI_CONV_LOOKUP a
               WHERE a.tabid = b.src_table_id)
                srcstagingtable,
             (SELECT a.staging_tab
                FROM CVC_BI_CONV_LOOKUP a
               WHERE a.tabid = b.bi_conv_id)
                bistagingtable ,                
             (SELECT a.tablename
                FROM CVC_BI_CONV_LOOKUP a
               WHERE a.tabid = b.bi_conv_id)
                biqtable
        FROM CVC_BI_CONV_TAB_MASTER b
       WHERE b.bi_conv_id 
          IN (SELECT bi_conv_id FROM CVC_BI_CONV_LOOKUP)
          --  AND process_flag ='P'
          AND conv_reqd = 'Y'
        ORDER BY exec_seq;       
      
   
   CURSOR cur_get_data --- all transaction tables
   IS
       SELECT b.trunc_table,
	          b.id,
			  b.fn_tab_validations,
             (SELECT a.tablename
                FROM CVC_BI_CONV_LOOKUP a
               WHERE a.tabid = b.src_table_id)
                srctable,       
             (SELECT a.staging_tab
                FROM CVC_BI_CONV_LOOKUP a
               WHERE a.tabid = b.src_table_id)
                srcstagingtable,
             (SELECT a.staging_tab
                FROM CVC_BI_CONV_LOOKUP a
               WHERE a.tabid = b.bi_conv_id)
                bistagingtable ,                
             (SELECT a.tablename
                FROM CVC_BI_CONV_LOOKUP a
               WHERE a.tabid = b.bi_conv_id)
                biqtable
        FROM CVC_BI_CONV_TAB_DATA b
       WHERE b.bi_conv_id 
          IN (SELECT bi_conv_id FROM CVC_BI_CONV_LOOKUP)
       --  AND process_flag ='P'
          AND conv_reqd = 'Y'
        ORDER BY exec_seq;   
           
   v_rows_returned      NUMBER;
   v_rows_returned_data NUMBER;
   
   BEGIN
   
   
       DBMS_OUTPUT.PUT_LINE ('in_req_id'         || in_req_id);      
       DBMS_OUTPUT.PUT_LINE ('in_inp_start_date' || in_inp_start_date);
       DBMS_OUTPUT.PUT_LINE ('in_inp_end_date'   || in_inp_end_date);
	   DBMS_OUTPUT.PUT_LINE ('in_chr_status'     || in_chr_status);
   
        v_rows_returned := 0;
        v_rows_returned_data  := 0;
        
		    IF in_req_id IS NULL AND in_inp_start_date IS NULL
			THEN
        
				FOR rec_cur_get_tab IN cur_get_tab
				LOOP
				
				   v_rows_returned := v_rows_returned + 1;
				   
					  UPDATE cvc_bi_conv_tab_master 
						 SET process_flag ='P'
						 WHERE conv_reqd = 'Y';   
						 
						    --to track data flow
                               log_error (
                                 l_chr_err_code 
                               , l_chr_err_msg
                               , l_chr_prc_name
                               , 'Input params are null , trunc flag is Y'
                               ,  null
                               ,  null
                               );  
                   
					   
					   BEGIN
						   cvc_bi_conv_proc (l_chr_err_code,
										l_chr_err_msg,
										 rec_cur_get_tab.srcstagingtable,
										rec_cur_get_tab.biqtable,
										rec_cur_get_tab.srctable,
										rec_cur_get_tab.bistagingtable,
										in_chr_trunc_table,
										rec_cur_get_tab.id,
										rec_cur_get_tab.fn_tab_validations,
										in_req_id,
										in_inp_start_date ,
										in_inp_end_Date ,
										in_chr_status,
                                        in_chr_bm_email  );
					  EXCEPTION
						 WHEN OTHERS
						 THEN
							DBMS_OUTPUT.PUT_LINE (
								  ' Error while calling cvc_bi_conv_proc procedure --'
							   || SQLERRM
							   || '--'
							   || SQLCODE);
									   
							l_out_chr_errbuf :=
								 ' Error while calling cvc_bi_conv_proc procedure --'
							   || SQLERRM
							   || '--'
							   || SQLCODE;
							l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
									
						log_error (
							 l_chr_err_code 
						   , l_chr_err_msg
						   , l_chr_prc_name
						   , 'WHEN OTHERS - while calling cvc_bi_conv_proc procedure'
						   ,  SQLERRM
						   ,  SQLCODE
						   );  
								 
					  END;    
										  
				END LOOP;              
        
		END IF;
		
		----This runs for all masters and transaction data tables
		
        IF (in_chr_trunc_table IS NULL )
            AND (in_req_id IS NOT NULL OR in_inp_start_date IS NOT NULL)
        THEN
	             --This runs for all masters
				
			 	/*  DBMS_OUTPUT.PUT_LINE ('Update all master tables to Y ');
				   
				   BEGIN
					 UPDATE cvc_bi_conv_tab_master 
					   SET process_flag ='P'
					  WHERE conv_reqd = 'Y';    
				   EXCEPTION 
					 WHEN OTHERS
					 THEN
					 DBMS_OUTPUT.PUT_LINE ('here in error while updating the process flag for master');
				   END;
				   
					--to track data flow
						  log_error (
							 l_chr_err_code 
						   , l_chr_err_msg
						   , l_chr_prc_name
						   , 'Updating process to P for all masters'
						   ,  NULL
						   ,  NULL
						   );       
                     
		            
	        	    FOR rec_cur_get_tab IN cur_get_tab
                    LOOP
                        
                         
                        DBMS_OUTPUT.PUT_LINE ('Running process for all masters');
                        
  							  BEGIN
								   cvc_bi_conv_proc (l_chr_err_code,
													l_chr_err_msg,
													 rec_cur_get_tab.srcstagingtable,
													rec_cur_get_tab.biqtable,
													rec_cur_get_tab.srctable,
													rec_cur_get_tab.bistagingtable,
													'N',
													rec_cur_get_tab.id,
													rec_cur_get_tab.fn_tab_validations,
													in_req_id,
													in_inp_start_date ,
													in_inp_end_Date,
                                                    in_chr_status ,
                                                    in_chr_bm_email  );
							  EXCEPTION
								 WHEN OTHERS
								 THEN
									DBMS_OUTPUT.PUT_LINE (
										  ' Error while calling cvc_bi_conv_proc procedure --'
									   || SQLERRM
									   || '--'
									   || SQLCODE);
											   
									l_out_chr_errbuf :=
										 ' Error while calling cvc_bi_conv_proc procedure --'
									   || SQLERRM
									   || '--'
									   || SQLCODE;
									l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
											
									log_error (
										 l_chr_err_code 
									   , l_chr_err_msg
									   , l_chr_prc_name
									   , 'WHEN OTHERS - while calling cvc_bi_conv_proc procedure'
									   ,  SQLERRM
									   ,  SQLCODE
									   );  
										 
							  END;    
                                              
                    END LOOP;    */
        
                     DBMS_OUTPUT.PUT_LINE ('run for transaction'); 
         
                    FOR rec_cur_get_data IN cur_get_data
                    LOOP
                 
 
                        --  DBMS_OUTPUT.PUT_LINE ('before updating cvc_bi_conv_tab_data to P ');
                       
                               BEGIN                               
                                 UPDATE cvc_bi_conv_tab_data 
                                   SET process_flag ='P'
                                   WHERE conv_reqd = 'Y' ;             
                               EXCEPTION
                                WHEN OTHERS
                                THEN
                                    DBMS_OUTPUT.PUT_LINE (
                                          ' Error while updating cvc_bi_conv_tab_master --'
                                       || SQLERRM
                                       || '--'
                                       || SQLCODE);                
                               END;
                               
                              log_error (
                                     l_chr_err_code 
                                   , l_chr_err_msg
                                   , l_chr_prc_name
                                   , 'Updating the process flag to P for transaction tables'
                                   , NULL
                                   ,  l_global_params
                                   );   
                               
              DBMS_OUTPUT.PUT_LINE ('while calling' || rec_cur_get_data.fn_tab_validations);
                       
							   BEGIN
								   cvc_bi_conv_proc (l_chr_err_code,
												l_chr_err_msg,
												 rec_cur_get_data.srcstagingtable,
												rec_cur_get_data.biqtable,
												rec_cur_get_data.srctable,
												rec_cur_get_data.bistagingtable,
												'N',
												rec_cur_get_data.id,
												rec_cur_get_data.fn_tab_validations,
												in_req_id,
												in_inp_start_date ,
												in_inp_end_Date,
                                                in_chr_status ,
                                                in_chr_bm_email  );					
							  EXCEPTION
								 WHEN OTHERS
								 THEN
									DBMS_OUTPUT.PUT_LINE (
										  ' Error while calling cvc_bi_conv_proc procedure --'
									   || SQLERRM
									   || '--'
									   || SQLCODE);
											   
									l_out_chr_errbuf :=
										 ' Error while calling cvc_bi_conv_proc procedure --'
									   || SQLERRM
									   || '--'
									   || SQLCODE;
									l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
											
								log_error (
									 l_chr_err_code 
								   , l_chr_err_msg
								   , l_chr_prc_name
								   , 'WHEN OTHERS - while calling cvc_bi_conv_proc procedure'
								   ,  SQLERRM
								   ,  SQLCODE
								   );    
									
							  END;  
							  

                                          
                    END LOOP;    
					
        END IF;
		
        BEGIN
			BIQ_POPULATE_DAY_ROOM  ;					
	  EXCEPTION
		 WHEN OTHERS
		 THEN
			DBMS_OUTPUT.PUT_LINE (
				  ' Error while calling BIQ_POPULATE_DAY_ROOM procedure --'
			   || SQLERRM
			   || '--'
			   || SQLCODE);
					   
			l_out_chr_errbuf :=
				 ' Error while calling BIQ_POPULATE_DAY_ROOM procedure --'
			   || SQLERRM
			   || '--'
			   || SQLCODE;
			l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
					
		log_error (
			 l_chr_err_code 
		   , l_chr_err_msg
		   , l_chr_prc_name
		   , 'WHEN OTHERS - while calling BIQ_POPULATE_DAY_ROOM procedure'
		   ,  SQLERRM
		   ,  SQLCODE
		   );    
		
  END; 
     
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE ('HERE INSIIDE OTHERS' || SQLERRM);
   END;

   PROCEDURE cvc_bi_conv_proc (out_chr_err_code   OUT    VARCHAR2,
                               out_chr_err_msg    OUT    VARCHAR2,
                               in_chr_srcstgtab   IN     VARCHAR2,
                               in_chr_biqtab      IN     VARCHAR2,
                               in_chr_srctab      IN     VARCHAR2,
                               in_chr_bistagtab   IN     VARCHAR2,
							   in_chr_trunc_tab   IN     VARCHAR2,
							   in_table_id        IN     NUMBER,
							   in_fntab_validid   IN     VARCHAR2 ,
							   in_req_id          IN     VARCHAR2 ,
                               in_inp_start_date  IN     DATE,
                               in_inp_end_date    IN     DATE ,
							   in_chr_status      IN     VARCHAR2 ,
                               in_chr_bm_email   IN VARCHAR2  )
   IS
   
    CURSOR check_dependency (inp_bi_id VARCHAR2 ,inp_src_id VARCHAR2)
    IS
          SELECT DISTINCT parent_tabid parent_tabid
            FROM cvc_bi_dependency_tab 
           WHERE ID
              IN
                 (
                  SELECT bi_parent_id 
                    FROM cvc_bi_conv_tab_master
                   WHERE bi_conv_id = inp_bi_id
                     AND src_table_id = inp_src_id
                      AND conv_reqd = 'Y'
                   )               
           UNION ALL
           SELECT DISTINCT parent_tabid parent_tabid
             FROM cvc_bi_dependency_tab 
            WHERE ID
               IN
                (
                 SELECT bi_parent_id 
                    FROM cvc_bi_conv_tab_data
                   WHERE bi_conv_id = inp_bi_id
                     AND src_table_id = inp_src_id
                     AND conv_reqd = 'Y'
                 ) ;    
        
      CURSOR get_processed_flag (parent_tabid VARCHAR2)
      IS
           SELECT DISTINCT process_flag 
             FROM cvc_bi_conv_tab_master
            WHERE bi_conv_id = parent_tabid
             AND conv_reqd = 'Y'
         UNION ALL
            SELECT DISTINCT process_flag 
              FROM cvc_bi_conv_tab_data
             WHERE bi_conv_id = parent_tabid
               AND conv_reqd = 'Y';
               
      CURSOR truncate_table (master_tabid VARCHAR2)
      IS
        SELECT tablename,tabid
          FROM cvc_bi_conv_lookup
         WHERE tabid 
         IN
          ( SELECT tabid
           FROM cvc_bi_dependency_tab
          WHERE parent_tabid = master_tabid
          );
          
       CURSOR load_bm_info 
       IS
        SELECT DISTINCT  LOWER(briefing_manager_id) bm_id ,
               REPLACE (INITCAP (replace(lower(briefing_manager_id),'@briefingiq.com',' ')),'.',' ') full_name
          FROM cvc_customer@dblink_to_cvc_new 
         WHERE LOWER(briefing_manager_id) NOT IN (SELECT DISTINCT user_name FROM bi_user);   
         
       CURSOR load_notes_info
       IS
        SELECT DISTINCT  LOWER(user_id) user_id ,
           REPLACE (INITCAP (replace(lower(user_id),'@briefingiq.com',' ')),'.',' ') full_name
          FROM CVC_NOTES@dblink_to_cvc_new 
         WHERE LOWER(user_id) NOT IN (SELECT DISTINCT user_name FROM bi_user);           
                  
      
      CURSOR reqid_param
      IS
        SELECT tabname ,
               param_name 
          FROM cvc_bi_conv_params
         WHERE condition = 'request_id';
         
      l_num_note_seqid    NUMBER;
      l_out_chr_errbuf    VARCHAR2 (2000);
      l_chr_err_code      VARCHAR2 (2000);
      l_chr_err_msg       VARCHAR2 (2000);
      l_src_staging_tab   VARCHAR2 (200);
      p_tname             VARCHAR2 (80);
      cur_get_data        SYS_REFCURSOR;
      l_cursor            SYS_REFCURSOR;
      v_table_name        VARCHAR2 (30);
      ddl_str_src_stage   VARCHAR2 (4000);
      ddl_str_bi_stage    VARCHAR2 (4000);      
      l_src_data          VARCHAR2 (4000);
      l_query             VARCHAR2 (4000);
      p_str               VARCHAR2 (4000);
      l_outer_loop        VARCHAR2 (4000);
      l_chr_column_list   VARCHAR2 (4096) := NULL;
      v_insert_list       VARCHAR2 (16096);
      l_ref_cur_columns   VARCHAR2 (16096) := NULL;
      v_ref_cur_query     VARCHAR2 (16000);
      v_ref_cur_output    VARCHAR2 (16000) := NULL;
      l_chr_column_name   VARCHAR2 (256);
      p_tab_name1         VARCHAR2 (256);
      l_sql3              VARCHAR2 (2000);
      v_LoopCounter       NUMBER;
      v_MyTestCode        VARCHAR2 (200);
      v_SomeValue         VARCHAR2 (200);
      l_src_str           VARCHAR2 (4096) := NULL;
      l_biq_str           VARCHAR2 (4096) := NULL;
      l_ref_cur_columns   VARCHAR2 (4000);
      l_chr_subquery_map      VARCHAR2 (256);
      l_chr_column_name   VARCHAR2 (2000);
      l_chr_prc_name      VARCHAR2(50) := 'cvc_bi_conv_proc';
      v_inp_sql           VARCHAR2 (200);
      l_biq_str_id        VARCHAR2 (20);
      l_dnt_truncate VARCHAR2 (20) := 'N';
      l_src_str_id        VARCHAR2 (20);
      l_truncate_tableid  VARCHAR2 (20);
      l_fn_tabvalid       VARCHAR2 (50);
      l_chr_process_flag  VARCHAR2 (20);
      l_num_count          NUMBER;
      l_chr_column1       VARCHAR2 (1000);
      l_chr_column2       VARCHAR2 (1000);
      l_chr_column3       VARCHAR2 (1000);
      l_new_staging_tab   VARCHAR2 (100);
      l_chr_valid_type    VARCHAR2 (200);
      l_chr_code          VARCHAR2 (200);
      l_chr_value         VARCHAR2 (200);      
      l_chr_addtab_id     VARCHAR2 (50);
      l_is_master         VARCHAR2 (20);
      l_tab_masterid      NUMBER;
      l_tab_dataid        NUMBER;
      l_chr_trunc_flag    VARCHAR2 (5); 
      l_chr_exists       VARCHAR2 (5)  := 'N';
      l_child_tab         VARCHAR2 (50);
      l_child_table_name  VARCHAR2 (50);
      l_bi_cvc_loc        VARCHAR2 (50);
      l_bi_loc           VARCHAR2 (50);
      l_newchr_sql        VARCHAR2 (255);
      l_chr_cond1        VARCHAR2 (255);
      l_chr_equation     VARCHAR2 (255);
      l_chr_cond2        VARCHAR2 (255);
      in_chr_der_tab      LONG;
      in_chr_where_tab    LONG;
      refcur              SYS_REFCURSOR;
      program_exit        EXCEPTION;
      
   BEGIN
   
      DBMS_OUTPUT.PUT_LINE ('===================Procedure start =================');     
      DBMS_OUTPUT.PUT_LINE ('Process started for source table : '   || in_chr_srctab);
      --DBMS_OUTPUT.PUT_LINE ('Process started for source Staging : ' || in_chr_srcstgtab);
  --    DBMS_OUTPUT.PUT_LINE ('Process started for BI Staging : '  || in_chr_bistagtab);   
      DBMS_OUTPUT.PUT_LINE ('Process started for BI table : '    || in_chr_biqtab);       
      
    --  DBMS_OUTPUT.PUT_LINE ('=====Extract the BI tab and FN tab ids for transaction ===========');
      
   --   DBMS_OUTPUT.PUT_LINE ('in_req_id' || in_req_id);
      
   ---    DBMS_OUTPUT.PUT_LINE ('in_fntab_validid' || in_fntab_validid);
      
            --to track data flow
           log_error (
             l_chr_err_code 
           , l_chr_err_msg
           , l_chr_prc_name
           , 'Process started for BI table'
           ,  in_chr_biqtab
           ,  l_global_params
           ); 
     
      
       BEGIN
         SELECT tabid ,master
          INTO l_biq_str_id,
               l_is_master
          FROM cvc_bi_conv_lookup
        WHERE tablename = in_chr_biqtab;
       EXCEPTION
        WHEN OTHERS
        THEN               
        DBMS_OUTPUT.PUT_LINE (
                          ' Error while fetching the tabid for BIQ Table --'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                               
                    l_out_chr_errbuf :=
                          ' Error while fetching the tabid for BIQ Table --'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
                            
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'WHEN OTHERS - while fetching the tabid for BIQ Table'
               ,  SQLERRM
               ,  SQLCODE
               );                
       END ;
	   
	   
	  IF in_req_id IS NULL AND 
		 in_inp_start_date IS NULL AND 
		 in_inp_end_date IS NULL  -- Incase of masters 1=1
	  THEN
			l_chr_cond1 := 1;
			l_chr_equation := ' = ' ;
			l_chr_cond2 := 1;		  				

	  ELSIF in_req_id IS NOT NULL AND l_is_master = 'N' -- Incase of request_id param and select from a transaction
	  THEN	  
	  
            FOR rec_reqid_param IN reqid_param -- take the relevant column name from the params table
            LOOP
            
                 IF in_chr_srctab = rec_reqid_param.tabname
                 THEN                
                   l_chr_exists := 'Y';
                   l_chr_cond1:= rec_reqid_param.param_name;                 
                 END IF;    
                 
            END LOOP;    
                 
            IF l_chr_exists = 'N'
            THEN
              l_chr_cond1:= 'id';
            END IF;
         
 			 l_chr_equation := ' = ' ;         
			 l_chr_cond2 := in_req_id;
			 
			-- DBMS_OUTPUT.PUT_LINE ('insert_user for req : '); 
           IF l_global_bitab =   in_chr_biqtab
           THEN		 
 
				 BEGIN
				   insert_user();
				  EXCEPTION
				   WHEN OTHERS
				   THEN
						l_out_chr_errbuf :=
							  ' Error while calling insert_user for BI_REQUEST user insertion --'
						   || SQLERRM
						   || '--'
						   || SQLCODE;
									
						log_error (
							 l_chr_err_code 
						   , l_chr_err_msg
						   , l_chr_prc_name
						   , 'WHEN OTHERS - check the insert_user call'
						   ,  SQLERRM
						   ,  SQLCODE
						   );    		   
				   END;
				   
			  END IF;
			  
	  ELSIF in_req_id IS NOT NULL AND l_is_master = 'Y' -- Incase of request_id param and select from a transaction
	  THEN	  
	          
         ---  DBMS_OUTPUT.PUT_LINE ('l_is_master || in_req_id : '|| l_chr_cond1);   
 
			l_chr_cond1 := 1;
			l_chr_equation := ' = ' ;
			l_chr_cond2 := 1;		 
			
	  ELSIF in_inp_start_date IS NOT NULL 
	        AND	in_inp_end_date IS NOT NULL 
			AND l_is_master = 'N'
	  THEN
	     
			
           IF in_chr_srctab = l_global_reqtab     --status condition
           THEN
			 
 			 
			---  DBMS_OUTPUT.PUT_LINE ('in_chr_status : '|| in_chr_status);
		---	  DBMS_OUTPUT.PUT_LINE ('in_chr_bm_email : '|| in_chr_bm_email); 
            
             l_chr_cond1    := 'start_date';
             l_chr_equation := ' BETWEEN ' ;         
             
			 IF in_chr_status IS NOT NULL AND in_chr_bm_email IS NULL
			 THEN
			    l_chr_cond2 :=   ''''|| in_inp_start_date|| '''' || ' AND ' || ''''|| in_inp_end_date||  '''' || ' AND status_id = 14 '  ;  
			    l_global_status := in_chr_status;
			---    DBMS_OUTPUT.PUT_LINE ('in_chr_bm_email is null  : '|| l_chr_cond2);
			 ELSIF in_chr_status IS NULL AND in_chr_bm_email IS NOT NULL
			 THEN
			    l_chr_cond2 :=   ''''|| in_inp_start_date|| '''' || ' AND ' || ''''|| in_inp_end_date||  '''' || ' AND ac_id =  '|| ''''|| in_chr_bm_email|| ''''  ;  
			    l_global_bm_email := in_chr_bm_email;
            ---     DBMS_OUTPUT.PUT_LINE ('in_chr_status  is null : '|| l_chr_cond2);	 
             ELSE
                l_chr_cond2 :=   ''''|| in_inp_start_date|| '''' || ' AND ' || ''''|| in_inp_end_date||  '''' ;		                
           --      DBMS_OUTPUT.PUT_LINE ('l_chr_cond2 else : '|| l_chr_cond2);                    
             END IF;
              
			
          --   DBMS_OUTPUT.PUT_LINE ('in date params status_id : '); 
              IF l_global_bitab =   in_chr_biqtab
              THEN		 
             
				  BEGIN
					 insert_user();
				  EXCEPTION
				   WHEN OTHERS
				   THEN
						l_out_chr_errbuf :=
							  ' Error while calling insert_user for BI_REQUEST user insertion --'
						   || SQLERRM
						   || '--'
						   || SQLCODE;
									
						log_error (
							 l_chr_err_code 
						   , l_chr_err_msg
						   , l_chr_prc_name
						   , 'WHEN OTHERS - check the insert_user call'
						   ,  SQLERRM
						   ,  SQLCODE
						   );    		   
				   END;   
				   
              END IF; 
			  
            ELSE
			
               l_chr_cond1:= '1';
               l_chr_equation := ' = ' ;         
               l_chr_cond2 := '1';
               
            END IF;
			
            
      ELSIF in_inp_start_date IS NOT NULL 
	        AND	in_inp_end_date IS NOT NULL 
			AND l_is_master = 'Y'
	  THEN
 
      ---     DBMS_OUTPUT.PUT_LINE ('l_is_master || in_inp_start_date : '|| l_chr_cond1);   
 
			l_chr_cond1 := 1;
			l_chr_equation := ' = ' ;
			l_chr_cond2 := 1;		      
					
	  END IF;
      	   
	  
	  IF in_chr_srctab = l_global_cust_tab
	  THEN
	  
	   ---  DBMS_OUTPUT.PUT_LINE ( 'l_global_cust_tab' || l_global_cust_tab );
	     l_dnt_truncate := 'Y';
	     
	     FOR rec_load_bm_info IN load_bm_info
	     LOOP
              BEGIN
			  
			   INSERT INTO bi_user (id,first_name,last_name,user_name,created_ts,created_by,updated_ts,updated_by,unique_id,version) 
				  VALUES(
				  bi_user_seq.nextval,
				  substr(rec_load_bm_info.full_name,1, instr(rec_load_bm_info.full_name,' ')),
				  substr(rec_load_bm_info.full_name, instr(rec_load_bm_info.full_name, ' '), instr(rec_load_bm_info.full_name, ' ', 1, 2)-instr(rec_load_bm_info.full_name, ' ')),
				  rec_load_bm_info.bm_id  ,
				  CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
				  'cvcinfo_us@oracle.com',
				  CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
				  'cvcinfo_us@oracle.com',
				  regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
				  1);
					 
			   EXCEPTION
				   WHEN OTHERS
				   THEN
						DBMS_OUTPUT.PUT_LINE (
							  ' Error inside inserting request related users --'
						   || SQLERRM
						   || '--'
						   || SQLCODE);
								   
						l_out_chr_errbuf :=
							  ' Error inside inserting request related users --'
						   || SQLERRM
						   || '--'
						   || SQLCODE;
								
						log_error (
							 l_chr_err_code 
						   , l_chr_err_msg 
						   , l_chr_prc_name
						   , 'WHEN OTHERS - While inserting request related users'
						   ,  SQLERRM
						   ,  SQLCODE
						   );              
			   END;	         
	     
	     END LOOP;	     
	     
	     
	  END IF;
	  
	  IF in_chr_biqtab = l_global_note
	  THEN
	  
	---     DBMS_OUTPUT.PUT_LINE ( 'l_global_note' || l_global_note );
 	     
	     FOR rec_load_notes_info IN load_notes_info
	     LOOP
              BEGIN
			  
			   INSERT INTO bi_user (id,first_name,last_name,user_name,created_ts,created_by,updated_ts,updated_by,unique_id,version) 
				  VALUES(
				  bi_user_seq.nextval,
				  substr(rec_load_notes_info.full_name,1, instr(rec_load_notes_info.full_name,' ')),
				  substr(rec_load_notes_info.full_name, instr(rec_load_notes_info.full_name, ' '), instr(rec_load_notes_info.full_name, ' ', 1, 2)-instr(rec_load_notes_info.full_name, ' ')),
				  rec_load_notes_info.user_id  ,
				  CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
				  'cvcinfo_us@oracle.com',
				  CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
				  'cvcinfo_us@oracle.com',
				  regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
				  1);
					 
			   EXCEPTION
				   WHEN OTHERS
				   THEN
						DBMS_OUTPUT.PUT_LINE (
							  ' Error inside inserting request related users --'
						   || SQLERRM
						   || '--'
						   || SQLCODE);
								   
						l_out_chr_errbuf :=
							  ' Error inside inserting request related users --'
						   || SQLERRM
						   || '--'
						   || SQLCODE;
								
						log_error (
							 l_chr_err_code 
						   , l_chr_err_msg 
						   , l_chr_prc_name
						   , 'WHEN OTHERS - While inserting request related users'
						   ,  SQLERRM
						   ,  SQLCODE
						   );              
			   END;	         
	     
	     END LOOP;
	     
	  END IF;	  
	  
	  
	   IF in_chr_biqtab = l_global_bi_pres
	  THEN
	  
	  --   DBMS_OUTPUT.PUT_LINE ( 'l_global_bi_pres' || l_global_bi_pres );
	     bi_cvc_presenter_gen();
	     
	  END IF; 

       BEGIN
       
         SELECT tabid 
           INTO l_src_str_id
           FROM cvc_bi_conv_lookup
        WHERE tablename = in_chr_srctab;
        
       EXCEPTION
        WHEN OTHERS
        THEN               
        DBMS_OUTPUT.PUT_LINE (
                      ' Error while fetching the tabid for source Table --'
                   || SQLERRM
                   || '--'
                   || SQLCODE);
                               
                l_out_chr_errbuf :=
                      ' Error while fetching the tabid for source Table --'
                   || SQLERRM
                   || '--'
                   || SQLCODE;
                            
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'WHEN OTHERS - check the value l_src_str_id'
               ,  SQLERRM
               ,  SQLCODE
               );     
                             
       END ;      
       
      --  DBMS_OUTPUT.PUT_LINE ('in_fntab_validid' || in_fntab_validid);

        BEGIN  
		  SELECT fn_validations
			INTO l_fn_tabvalid		   
			FROM CVC_BI_FN_VALIDATIONS
		   WHERE fn_validations = in_fntab_validid
			 AND validation_type IN ('SUBQUERY','MAP_TABLES','ADD_CONDITION','TABLE') 
			 AND in_fntab_validid IS NOT NULL;                                
       EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
           NULL;
        WHEN OTHERS
        THEN               
        DBMS_OUTPUT.PUT_LINE (
                      ' Error while fetching the l_fn_tabvalid from master Table --'
                   || SQLERRM
                   || '--'
                   || SQLCODE);
                               
                l_out_chr_errbuf :=
                      ' Error while fetching the l_fn_tabvalid from master Table --'
                   || SQLERRM
                   || '--'
                   || SQLCODE;
                            
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'WHEN OTHERS - while fetching the l_fn_tabvalid for master Table'
               ,  SQLERRM
               ,  SQLCODE
               );     
                             
       END ;     
       
       IF l_fn_tabvalid IS NOT NULL
       THEN
         l_chr_subquery_map := 'Y';
       END IF ;

	   
      /*FOR rec_check_dependency IN check_dependency(l_biq_str_id,l_src_str_id)
      LOOP
       
         DBMS_OUTPUT.PUT_LINE('parent_tabid' || rec_check_dependency.parent_tabid );
       
          FOR rec_get_processed_flag IN get_processed_flag(rec_check_dependency.parent_tabid)
          LOOP
        
            l_chr_process_flag := rec_get_processed_flag.process_flag;
            
            DBMS_OUTPUT.PUT_LINE('l_chr_process_flag' || l_chr_process_flag );
            
            DBMS_OUTPUT.PUT_LINE (
                  ' Exception as the parent process is Pending or Errored out --'
               || SQLERRM
               || '--'
               || SQLCODE);
               
                 log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'Exception as the parent process is Pending or Errored out : ' 
               ,  SQLERRM
               ,  SQLCODE
               );           
                         
          END LOOP;
              
       END LOOP;      
    
      IF l_chr_process_flag IN ('P','E')
      THEN
    
        DBMS_OUTPUT.PUT_LINE (
              ' Raise Exception as the parent process is Pending or Errored out --'
           || SQLERRM
           || '--'
           || SQLCODE);
           
             log_error (
             l_chr_err_code 
           , l_chr_err_msg
           , l_chr_prc_name
           , 'Process terminated becauase the parent process is Pending or in Errored state for : ' || in_chr_biqtab
           ,  SQLERRM
           ,  SQLCODE
           );           
           
            --to track data flow
           log_error (
             l_chr_err_code 
           , l_chr_err_msg
           , l_chr_prc_name
           , 'Process exited since parent process is E or P for BI table : '
           ,  in_chr_biqtab
           ,  l_global_params
           ); 
           
           RAISE program_exit;
      
      END IF;
      */
      
      BEGIN
      
          --ddl_str_src_stage := 'TRUNCATE TABLE ' || in_chr_srcstgtab || '';
          ddl_str_bi_stage  := 'TRUNCATE TABLE ' || in_chr_bistagtab || '';
          
              --to track data flow
              log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'Truncating the BI staging table  '
               ,  in_chr_bistagtab
               ,  l_global_params
               );   


      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  ' Error while writing truncate table cvc_stage--'
               || SQLERRM
               || '--'
               || SQLCODE);
               
            l_out_chr_errbuf :=
                  ' Error while writing truncate table cvc_stage --'
               || SQLERRM
               || '--'
               || SQLCODE;
            
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'WHEN OTHERS - while truncating tables cvc_stage '
               ,  SQLERRM
               ,  SQLCODE
               ); 
                     
      END;
      
      BEGIN
            
          --EXECUTE IMMEDIATE ddl_str_src_stage;
          
          EXECUTE IMMEDIATE ddl_str_bi_stage;
          
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  ' Error while truncating tables cvc_stage,bi_stage --'
               || SQLERRM
               || '--'
               || SQLCODE);
               
            l_out_chr_errbuf :=
                   ' Error while truncating tables cvc_stage,bi_stage --'
               || SQLERRM
               || '--'
               || SQLCODE;
            
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'WHEN OTHERS - while truncating tables cvc_stage,bi_stage'
               ,  SQLERRM
               ,  SQLCODE
               ); 
                     
      END;
      

        
	--	 DBMS_OUTPUT.PUT_LINE ('l_biq_str_id before truncate table' || l_biq_str_id);
	 --    DBMS_OUTPUT.PUT_LINE ('l_dnt_truncate ' || l_dnt_truncate);

		
        IF in_chr_trunc_tab = 'Y' AND l_dnt_truncate ='N'
        THEN
        
               l_gbl_trunc := 'Y';
               
            --   DBMS_OUTPUT.PUT_LINE ('l_biq_str_id PASSED TO  truncate table' || l_biq_str_id);      
               
                    --to track data flow
                       log_error (
                         l_chr_err_code 
                       , l_chr_err_msg
                       , l_chr_prc_name
                       , 'l_biq_str_id passed to truncate table'
                       ,  l_biq_str_id
                       ,  NULL
                       );          
        
			  FOR rec_trunc_tab IN truncate_table(l_biq_str_id)
			  LOOP          
			 
				---   DBMS_OUTPUT.PUT_LINE ('child table in truncate table : ' || rec_trunc_tab.tabid );
					
					l_child_tab        := rec_trunc_tab.tabid ;
					l_child_table_name := rec_trunc_tab.tablename;
					
					  --to track data flow
                       log_error (
                         l_chr_err_code 
                       , l_chr_err_msg
                       , l_chr_prc_name
                       , 'Child table that gets truncated is : '
                       ,  l_child_table_name
                       ,  NULL
                       );   
					
				--	DBMS_OUTPUT.PUT_LINE ('======Call truncate procedure to truncate child tables ===='|| l_child_table_name);
					truncate_tables(l_child_table_name);
					
			  
			  END LOOP;      
			  
			   --  DBMS_OUTPUT.PUT_LINE ('====Call truncate procedure to truncate master  table ===' ||in_chr_biqtab);
			     
			           --to track data flow
                       log_error (
                         l_chr_err_code 
                       , l_chr_err_msg
                       , l_chr_prc_name
                       , 'Table that gets truncated is : '
                       ,  in_chr_biqtab
                       ,  NULL
                       );   

               truncate_tables(in_chr_biqtab);
              ---  DBMS_OUTPUT.PUT_LINE ('==============Tables truncated =====================');

 
        END IF;
        
	  
	  
	        IF in_chr_biqtab = l_global_loc_Tab
           THEN
        
             BEGIN 
                SELECT tabname ,
                       secondtab 
                  INTO l_bi_cvc_loc,
                       l_bi_loc
                  FROM cvc_bi_conv_params
                 WHERE proc_name = 'bi_cvc_location_gen';
              EXCEPTION
                WHEN OTHERS
                THEN
                    DBMS_OUTPUT.PUT_LINE (
                          ' Error while getting values from cvc_bi_conv_params --'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                       
                    l_out_chr_errbuf :=
                          ' Error while getting values from cvc_bi_conv_params --'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
                    l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
                    
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - while getting values from cvc_bi_conv_params'
                       ,  SQLERRM
                       ,  SQLCODE
                       );   
                END;   
          
            ---   DBMS_OUTPUT.PUT_LINE ('l_bi_cvc_loc :' || l_bi_cvc_loc);
            --  DBMS_OUTPUT.PUT_LINE ('l_bi_loc :' || l_bi_loc);
               
              IF in_chr_srctab = l_bi_cvc_loc
              AND in_chr_biqtab = l_bi_loc
               THEN
              
                    --to track data flow
                       log_error (
                         l_chr_err_code 
                       , l_chr_err_msg
                       , l_chr_prc_name
                       , 'Calling bi_cvc_location_gen for populating Location table'
                       ,  l_biq_str_id
                       ,  l_global_params
                       );         
                 --   DBMS_OUTPUT.PUT_LINE ('Calling bi_cvc_location_gen for populating Location table :' );             
                   bi_cvc_location_gen (l_chr_err_code  ,
                                         l_chr_err_msg   
                                         ) ;   
              END IF;
      
        END IF;

      
  /*    
        DBMS_OUTPUT.PUT_LINE ('===========insert into src staging table using fetch_insert_proc procedure========================');

      BEGIN

       v_inp_sql := ' SELECT * FROM ' || in_chr_srctab;
      
       fetch_insert_proc(v_inp_sql, in_chr_srcstgtab,in_table_id);

      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  ' Error while calling fetch_insert_proc from src to src_staging --'
               || SQLERRM
               || '--'
               || SQLCODE);
               
            l_out_chr_errbuf :=
                  ' Error while calling fetch_insert_proc src to src_staging --'
               || SQLERRM
               || '--'
               || SQLCODE;
            l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
            
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg 
               , l_chr_prc_name
               , 'WHEN OTHERS - while calling fetch_insert_proc src to src_staging'
               ,  SQLERRM
               ,  SQLCODE
               );    
      END;
*/

     --- DBMS_OUTPUT.PUT_LINE ('============before function call =====================');

    
       BEGIN
              
       --  DBMS_OUTPUT.PUT_LINE ('l_biq_str_id passing to getcolumnlist : ' || l_biq_str_id);
       --  DBMS_OUTPUT.PUT_LINE ('l_src_str_id passing to getcolumnlist : ' || l_src_str_id);
        
          l_biq_str := getcolumnlistfn (l_biq_str_id,l_src_str_id);
             
            --to track data flow
             log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'Calling getcolumnlistfn for column list and column level validations for BI Table' 
               , in_chr_biqtab
               , l_global_params
                );   

       
       EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  ' Error while calling columnlist function for BIQ Table --'
               || SQLERRM
               || '--'
               || SQLCODE);
               
            l_out_chr_errbuf :=
                  ' Error while calling columnlist function for BIQ Table --'
               || SQLERRM
               || '--'
               || SQLCODE;
            l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
            
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg 
               , l_chr_prc_name
               , 'WHEN OTHERS - while calling columnlist function for BIQ Table'
               ,  SQLERRM
               ,  SQLCODE
               );   
       
       END;       

      
       BEGIN
       
     --     DBMS_OUTPUT.PUT_LINE ('l_src_str_id passing to getcolumnlist : ' || l_src_str_id);
    --      DBMS_OUTPUT.PUT_LINE ('l_biq_str_id passing to getcolumnlist : ' || l_biq_str_id);
         
         l_src_str := getcolumnlistfn (l_src_str_id,l_biq_str_id);
           
            --to track data flow
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'Calling getcolumnlistfn for column list and column level validations  for source Table'
               , in_chr_srctab
               , l_global_params
                );   
         
       EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  ' Error while calling columnlist function for CVC Table --'
               || SQLERRM
               || '--'
               || SQLCODE);
               
            l_out_chr_errbuf :=
                  ' Error while calling columnlist function for CVC Table --'
               || SQLERRM
               || '--'
               || SQLCODE;
            l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
            
                    
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg 
               , l_chr_prc_name
               , 'WHEN OTHERS - while calling columnlist function for CVC Table'
               ,  SQLERRM
               ,  SQLCODE
               );  
       
       END;       
       
     --- DBMS_OUTPUT.PUT_LINE ('=================after function call ==================');
          
     
          IF in_chr_biqtab = l_global_act_Tab
          THEN
               
                --to track data flow
                log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_prc_name
                   , 'Calling bi_cvc_Agenda_gen for activity_day population'
                   , NULL
                   , l_global_params
                    );
             
               
               bi_cvc_Agenda_gen (l_chr_err_code  ,
                                 l_chr_err_msg  ,   
                                 in_req_id   ,
                                 in_inp_start_date ,
                                 in_inp_end_date
                                 ) ;  
                               
          END IF;
      
      
             BEGIN
             
               v_insert_list :=
                     'INSERT INTO '
                  || in_chr_bistagtab
                   || ' ('
                  || l_biq_str
                  || ')  ';
                  
                  
            ---    DBMS_OUTPUT.put_line ('l_chr_subquery_map' || l_fn_tabvalid  || l_chr_subquery_map);  
                

                IF l_chr_subquery_map IS NULL
                THEN  
                
                      IF in_chr_srctab like 'CVC%'
                      THEN 
                        
                            v_ref_cur_query :=
                              'SELECT ' || l_src_str || ' FROM ' || in_chr_srctab ||'@dblink_to_cvc_new'|| ' a' || ' WHERE ' || l_chr_cond1 || l_chr_equation || l_chr_cond2 ;
                      ELSE
                            v_ref_cur_query :=
                              'SELECT ' || l_src_str || ' FROM ' || in_chr_srctab || ' a' || ' WHERE ' || l_chr_cond1 || l_chr_equation || l_chr_cond2 ;
                       
                      END IF;        
                      
                ELSIF l_chr_subquery_map = 'Y'
                THEN
                     BEGIN
                        SELECT column1,
                               column2,
                               column3,
                               (SELECT tablename FROM cvc_bi_conv_lookup WHERE tabid = l_src_str_id) stagingtab,
                               validation_type  ,
                               code,
                               value,
                               (SELECT tablename FROM cvc_bi_conv_lookup WHERE tabid = add_tabid) add_tabid  
                          INTO  l_chr_column1,
                                l_chr_column2,
                                l_chr_column3    ,
                                l_new_staging_tab,
                                l_chr_valid_type,
                                l_chr_code,
                                l_chr_value,
                                l_chr_addtab_id
                          FROM cvc_bi_fn_validations
                         WHERE fn_validations = l_fn_tabvalid
						   AND validation_type IN ('SUBQUERY','MAP_TABLES' ,'ADD_CONDITION','TABLE');
                    EXCEPTION
                      WHEN OTHERS
                      THEN 
                          DBMS_OUTPUT.put_line ('Error getting the details from tabfn' || SQLERRM);
                    END;    
					
                        IF l_chr_valid_type = 'SUBQUERY'
                        THEN
                        
                           IF l_new_staging_tab like 'CVC%'
                           THEN
                        
                                in_chr_der_tab := '( SELECT ' || l_chr_column1||','||l_chr_column2||','|| l_chr_column3;
                                in_chr_der_tab := in_chr_der_tab || ' FROM ' || l_new_staging_tab ||'@dblink_to_cvc_new' ||' )';
                                in_chr_der_tab := in_chr_der_tab;
                                
                           ELSE
                                 in_chr_der_tab := '( SELECT ' || l_chr_column1||','||l_chr_column2||','|| l_chr_column3;
                                in_chr_der_tab := in_chr_der_tab || ' FROM ' || l_new_staging_tab ||' )';
                                in_chr_der_tab := in_chr_der_tab;                          
                           END IF;     
                                
                        --    DBMS_OUTPUT.put_line ('in_chr_der_tab' || in_chr_der_tab);
                             
                            v_ref_cur_query :=
                              'SELECT ' || l_src_str || ' FROM ' || in_chr_der_tab ||' a' || ' WHERE ' || l_chr_cond1 || l_chr_equation || l_chr_cond2 ;                        
 
                                                      
                        ELSIF l_chr_valid_type = 'ADD_CONDITION'
                        THEN
                        
                      --    DBMS_OUTPUT.put_line ('ADD_CONDITION :' || l_chr_addtab_id  || l_new_staging_tab );
                        
                            in_chr_where_tab := ' WHERE ' || l_chr_column1||' AND '||l_chr_column2||' AND '|| l_chr_column3; 
 
                             
                          -- DBMS_OUTPUT.put_line ('l_src_str :' || in_chr_where_tab);
                            
                            IF  l_chr_addtab_id like 'CVC%'
                            THEN
                                v_ref_cur_query :=
                                  'SELECT ' || l_src_str || ' FROM ' || l_chr_addtab_id ||'@dblink_to_cvc_new'||' a' ||    in_chr_where_tab || ' AND ' || l_chr_cond1 || l_chr_equation || l_chr_cond2 ;
                            ELSE
                            
                                 v_ref_cur_query :=
                                  'SELECT ' || l_src_str || ' FROM ' || l_chr_addtab_id ||' a' ||    in_chr_where_tab || ' AND ' || l_chr_cond1 || l_chr_equation || l_chr_cond2 ;
                            
                            END IF;
                                                
                        ELSIF l_chr_valid_type = 'TABLE'
                        THEN
                             --  DBMS_OUTPUT.put_line ('TABLE :'  );
                                   
                 
                                   IF l_chr_code IS NOT NULL
                                   THEN  
                                           
                                       l_newchr_sql := ' WHERE ';
                                       l_newchr_sql := l_newchr_sql || l_chr_code ||' = ';
                                       l_newchr_sql := l_newchr_sql || l_chr_value ;
                                       l_newchr_sql := l_newchr_sql ;
                                       
                                --   DBMS_OUTPUT.PUT_LINE ('l_newchr_sql inside else '||l_newchr_sql);
                                   END IF;
                                   
                           IF l_new_staging_tab like 'CVC%'
                           THEN
                                   
                                v_ref_cur_query :=
                                  'SELECT ' || l_src_str || ' FROM ' || l_new_staging_tab||'@dblink_to_cvc_new' ||' a' ||    l_newchr_sql || ' AND ' || l_chr_cond1 || l_chr_equation || l_chr_cond2 ;                                   
                           ELSE
                                 v_ref_cur_query :=
                                  'SELECT ' || l_src_str || ' FROM ' || l_new_staging_tab ||' a' ||    l_newchr_sql || ' AND ' || l_chr_cond1 || l_chr_equation || l_chr_cond2 ;                                   
                          
                           END IF;
                   END IF;
                   
                END IF;
                
                --to track data flow
                  log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_prc_name
                   , 'Applied tab level validations before biq staging insert : '
                   , NULL
                   , l_global_params
                    );                  

               v_ref_cur_query := v_insert_list || v_ref_cur_query;
               
                 DBMS_OUTPUT.put_line (v_ref_cur_query);
                
                EXECUTE IMMEDIATE v_ref_cur_query;
                
                   --to track data flow
                    log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_prc_name
                   , 'Inserted src data into biq stage table for : '
                   , NULL
                   , l_global_params
                    );  

             EXCEPTION
               WHEN OTHERS
               THEN               
                 IF l_is_master ='Y' 
                 THEN 
                   UPDATE cvc_bi_conv_tab_master 
                     SET process_flag ='E'  
                   WHERE bi_conv_id = l_biq_str_id
                     AND src_table_id = l_src_str_id
                      AND conv_reqd = 'Y'; 
                      
                   --to track data flow
                    log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_prc_name
                   , 'Update process flag to E for master table : '
                   , NULL
                   , l_global_params
                    );                        
                      
                 ELSE    
                   UPDATE cvc_bi_conv_tab_data 
                     SET process_flag ='E'  
                   WHERE bi_conv_id = l_biq_str_id
                     AND src_table_id = l_src_str_id
                     AND conv_reqd = 'Y';  
                     
                   --to track data flow
                    log_error (
                     l_chr_err_code 
                   , l_chr_err_msg
                   , l_chr_prc_name
                   , 'Update process flag to E for transaction table : '
                   , NULL
                   , l_global_params
                    );      
                                                         
                 END IF;
              END;  
 
     -- DBMS_OUTPUT.PUT_LINE ('===========insert into biq table using fetch_insert_proc procedure========================');
      
      BEGIN
 
               v_inp_sql := ' SELECT DISTINCT * FROM ' || in_chr_bistagtab;
              
               --to track data flow
                log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'Calling fetch_insert_proc to copy the data from BIQ Staging to BIQ : '
               , NULL
               , l_global_params
                );   
               
             BEGIN
               fetch_insert_proc(v_inp_sql, in_chr_biqtab,in_table_id);
             EXCEPTION
             WHEN OTHERS
             THEN
                DBMS_OUTPUT.PUT_LINE (
                      ' Error while calling fetch_insert_proc from bistaging to bi --'
                   || SQLERRM
                   || '--'
                   || SQLCODE);
                   
                l_out_chr_errbuf :=
                      ' Error while calling fetch_insert_proc  from bistaging to bi --'
                   || SQLERRM
                   || '--'
                   || SQLCODE;
                
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - while calling fetch_insert_proc , BI_staging to BI data move '
                       ,  SQLERRM
                       ,  SQLCODE
                       );                 
             END; 
 
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                           , 'Process complete for : '
                       ,  NULL
                       ,  l_global_params
                       );  
         
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE (
                  ' Error while calling fetch_insert_proc from bistaging to bi --'
               || SQLERRM
               || '--'
               || SQLCODE);
               
            l_out_chr_errbuf :=
                  ' Error while calling fetch_insert_proc  from bistaging to bi --'
               || SQLERRM
               || '--'
               || SQLCODE;
            
                log_error (
                     l_chr_err_code 
                   , l_chr_err_msg 
                   , l_chr_prc_name
                   , 'WHEN OTHERS - while calling fetch_insert_proc , BI_staging to BI data move '
                   ,  SQLERRM
                   ,  SQLCODE
                   );  
      END;

     
   EXCEPTION
    WHEN program_exit
    THEN
        DBMS_OUTPUT.PUT_LINE (
              ' Data conversion process terminated because the Master table has not been processed--'
           || SQLERRM
           || '--'
           || SQLCODE);
                   
        l_out_chr_errbuf :=
              ' Data conversion process terminated because the Master table has not been processed--'
           || SQLERRM
           || '--'
           || SQLCODE;
                
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg 
               , l_chr_prc_name
               , 'Data conversion process terminated  '
               ,  SQLERRM
               ,  SQLCODE
               );       
                
    WHEN OTHERS
     THEN
        DBMS_OUTPUT.PUT_LINE (
              ' Main program errored out due to  --'
           || SQLERRM
           || '--'
           || SQLCODE);
                   
        l_out_chr_errbuf :=
              ' Error while updating  processflag to Y in cvc_bi_conv_tab_master table --'
           || SQLERRM
           || '--'
           || SQLCODE;
        l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
                
        log_error (
             l_chr_err_code 
           , l_chr_err_msg 
           , l_chr_prc_name
           , 'WHEN OTHERS - Main program errored out '
           ,  SQLERRM
           ,  SQLCODE
           );  
                 
   END;
   
PROCEDURE  bi_cvc_location_gen (out_chr_err_code   OUT VARCHAR2,
                                out_chr_err_msg    OUT VARCHAR2 
                               )

 IS
l_loc_id NUMBER;
l_chr_val NUMBER:= BI_location_sEQ.NEXTVAL;
ddl_bi_cvc_loc LONG;
l_chr_err_code  VARCHAR2 (255);
l_chr_err_msg   VARCHAR2 (255); 
l_process_loc_flag VARCHAR2 (5) :='N' ;
l_cvc_loc_count NUMBER;
l_bi_loc_count NUMBER;
l_location_id NUMBER;
l_out_chr_errbuf  VARCHAR2 (2000);
l_chr_prc_name      VARCHAR2(50) := 'bi_cvc_location_gen';

CURSOR C1 
IS
SELECT DISTINCT ID from bi_cvc_location
WHERE location_id IS NULL 
AND process_flag ='N';


CURSOR C2  (locid  NUMBER)
IS
SELECT  ID id
FROM bi_cvc_location
WHERE id = locid
and location_id is null
AND process_flag ='N'
UNION ALL
SELECT  location_id id
FROM bi_cvc_location
WHERE location_id = locid
AND process_flag ='N';
  
BEGIN

DBMS_OUTPUT.PUT_LINE ('l_gbl_trunc is : ' ||l_gbl_trunc );
    
   BEGIN
        SELECT 
         ( SELECT COUNT(*) FROM cvc_location@dblink_to_cvc_new )
        + 
         ( SELECT COUNT(*) FROM cvc_location_room@dblink_to_cvc_new ) 
        AS 
           TOTAL_ROWS
        INTO l_cvc_loc_count
        FROM 
           DUAL;
    EXCEPTION
     WHEN OTHERS
     THEN
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg 
               , l_chr_prc_name
               , 'WHEN OTHERS - while getting l_cvc_loc_count '
               ,  SQLERRM
               ,  SQLCODE
               );     
    END;    

   BEGIN
        SELECT COUNT(1)
          INTO l_bi_loc_count
          FROM bi_location; 
    EXCEPTION
     WHEN OTHERS
     THEN
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg 
               , l_chr_prc_name
               , 'WHEN OTHERS - while getting l_bi_loc_count '
               ,  SQLERRM
               ,  SQLCODE
               );     
    END;    
    
    
    IF l_bi_loc_count > l_cvc_loc_count AND  l_gbl_trunc <> 'Y'
    THEN
    
         log_error (
             l_chr_err_code 
           , l_chr_err_msg 
           , l_chr_prc_name
           , 'BI_LOCATION has more locations than CVC_LOCATIONS'
           ,  SQLERRM
           ,  SQLCODE
           ); 
           
         DBMS_OUTPUT.PUT_LINE (
              ' BI_LOCATION has more locations than CVC_LOCATIONS ' );
           
     ELSIF  l_bi_loc_count = l_cvc_loc_count  AND l_gbl_trunc <> 'Y'   
     THEN
     
         log_error (
             l_chr_err_code 
           , l_chr_err_msg 
           , l_chr_prc_name
           , 'BI_LOCATION and CVC_LOCATIONS have same count'
           ,  SQLERRM
           ,  SQLCODE
           ); 

         DBMS_OUTPUT.PUT_LINE (
              ' BI_LOCATION and CVC_LOCATIONS have same count' );           
           
     ELSIF  l_bi_loc_count < l_cvc_loc_count  AND l_gbl_trunc <> 'Y' 
     THEN
     
         log_error (
             l_chr_err_code 
           , l_chr_err_msg 
           , l_chr_prc_name
           , 'CVC_LOCATION have extra locations than BI_LOCATION'
           ,  SQLERRM
           ,  SQLCODE
           );            
           
         DBMS_OUTPUT.PUT_LINE (
              'CVC_LOCATION have extra locations than BI_LOCATION' );   
              
         l_process_loc_flag :='Y'  ;                
           
      END IF;     
      
      IF l_gbl_trunc = 'Y'
      THEN
      
 

             INSERT INTO BI_LOCATION_TYPE (ID,UNIQUE_ID,NAME,DESCRIPTION,TENANT_ID,CREATED_BY,UPDATED_BY,IS_ACTIVE,VERSION,CREATED_TS,UPDATED_TS) 
             values (3,regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
             'ROOM','Room',null,'BIQDBUSER',null,null,0,CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT');

           
          ddl_bi_cvc_loc    := 'TRUNCATE TABLE BI_CVC_LOCATION' ;
               
          EXECUTE IMMEDIATE ddl_bi_cvc_loc;          

       
      END IF;   
      
      IF l_process_loc_flag ='Y'  OR l_gbl_trunc = 'Y'
      THEN 
        
         BEGIN

             INSERT INTO BI_CVC_LOCATION 
                (id,name,address,city,country,timezone,loc_type,
                 technical_setup,req_can_be_ac,req_can_book_rooms
                ,used_in_edr,time_from,time_to,contact_us,room_setup,organization,hotel,transportation,catering,special_days,sunday,
                saturday,self_service,created_by, 
                created_date, updated_by, updated_date,process_flag)
            SELECT a.id,a.name,a.address,a.city,a.country, 
                   (SELECT bi_timezone FROM  bi_cvc_tz_conv where cvc_timezone = timezone AND id = a.id),
                   a.loc_type,a.technical_setup,a.req_can_be_ac,a.req_can_book_rooms
                  ,a.used_in_edr,a.time_from,a.time_to,a.contact_us,a.room_setup,a.organization,
                   a.hotel,a.transportation,a.catering,a.special_days,
                  a.sunday,a.saturday,a.self_service,a.created_by, 
                  a.created_date, a.updated_by, a.updated_date ,'N'
             FROM cvc_location@dblink_to_cvc_new a
            WHERE id = 96--80
			  AND a.name NOT IN (SELECT b.name FROM BI_CVC_LOCATION b where b.name = a.name);
        EXCEPTION
         WHEN OTHERS
         THEN
                log_error (
                     l_chr_err_code 
                   , l_chr_err_msg 
                   , l_chr_prc_name
                   , 'WHEN OTHERS - insert into bi_cvc_location from cvc_location'
                   ,  SQLERRM
                   ,  SQLCODE
                   );     
        END;    
             
            BEGIN
                INSERT INTO BI_CVC_LOCATION (id,name,room_type,address,city,country,loc_type,technical_setup,req_can_be_ac,req_can_book_rooms
                ,used_in_edr,time_from,time_to,contact_us,room_setup,organization,hotel,transportation,catering,special_days,sunday,saturday,self_service,
                capacity,assignable,repository,location_id,created_by, 
                created_date, updated_by, updated_date ,private,additional_info,process_flag)
                SELECT id, code,room_type, room_location||' '||room_location_1 address ,
                (SELECT city from cvc_location@dblink_to_cvc_new where id = a.location_id) city,
                (SELECT country from cvc_location@dblink_to_cvc_new where id = a.location_id) country,
                ( SELECT 'ROOM' from bi_location_type where name ='ROOM')  loc_type,
                (SELECT technical_setup from cvc_location@dblink_to_cvc_new where id = a.location_id) technical_setup,
                (SELECT req_can_be_ac from cvc_location@dblink_to_cvc_new where id = a.location_id) req_can_be_ac,
                (SELECT req_can_book_rooms from cvc_location@dblink_to_cvc_new where id = a.location_id) req_can_book_rooms,
                (SELECT used_in_edr from cvc_location@dblink_to_cvc_new where id = a.location_id) used_in_edr,
                (SELECT time_from from cvc_location@dblink_to_cvc_new where id = a.location_id) time_from,
                (SELECT time_to from cvc_location@dblink_to_cvc_new where id = a.location_id) time_to,
                (SELECT contact_us from cvc_location@dblink_to_cvc_new where id = a.location_id) contact_us,
                (SELECT room_setup from cvc_location@dblink_to_cvc_new where id = a.location_id) room_setup,
                (SELECT organization from cvc_location@dblink_to_cvc_new where id = a.location_id) organization,
                (SELECT hotel from cvc_location@dblink_to_cvc_new where id = a.location_id) hotel,
                (SELECT transportation from cvc_location@dblink_to_cvc_new where id = a.location_id) transportation,
                (SELECT catering from cvc_location@dblink_to_cvc_new where id = a.location_id) catering,
                (SELECT special_days from cvc_location@dblink_to_cvc_new where id = a.location_id) special_days,
                (SELECT sunday from cvc_location@dblink_to_cvc_new where id = a.location_id) sunday,
                (SELECT saturday from cvc_location@dblink_to_cvc_new where id = a.location_id) saturday,
                (SELECT self_service from cvc_location@dblink_to_cvc_new where id = a.location_id) self_service,
                capacity,DECODE(assignable,'Y',1,NULL),repository,location_id,created_by, 
                created_date, updated_by, updated_date ,DECODE(private,'Y',1,NULL) ,room_type ,'N'
                FROM cvc_location_room@dblink_to_cvc_new a
              WHERE location_id = 96--80
				AND (code||room_location||' '||room_location_1) 
                NOT IN (Select (name||address) from BI_CVC_LOCATION );
            EXCEPTION
             WHEN OTHERS
             THEN
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - insert into bi_cvc_location from cvc_location_room'
                       ,  SQLERRM
                       ,  SQLCODE
                       );     
            END;  

            DBMS_OUTPUT.PUT_LINE ('inserted data into bi_cvc_location');

            FOR rec_c1 IN c1
            LOOP

               l_loc_id := rec_c1.id;
               
                 DBMS_OUTPUT.PUT_LINE ('l_loc_id : ' || l_loc_id );
               
               FOR rec_c2 IN c2 (l_loc_id)
               LOOP
               
                --  DBMS_OUTPUT.PUT_LINE ('rec_c2.name  :  ' || rec_c2.name );
                 -- DBMS_OUTPUT.PUT_LINE ('rec_c2.id  :  ' || rec_c2.id );
                   
               --   l_chr_val := l_chr_val+1;
                 
                 BEGIN 
                  UPDATE bi_cvc_location
                  SET id = l_chr_val 
                      ,process_flag = 'Y'
                  WHERE id = rec_c2.id
                   AND location_id IS NULL ;
                EXCEPTION
                 WHEN OTHERS
                 THEN
                        log_error (
                             l_chr_err_code 
                           , l_chr_err_msg 
                           , l_chr_prc_name
                           , 'WHEN OTHERS - update bi_cvc_location for id'
                           ,  SQLERRM
                           ,  SQLCODE
                           );     
                END;         
                
                BEGIN        
                  UPDATE bi_cvc_location
                  SET location_id = l_chr_val
                      ,process_flag = 'Y'
                  WHERE location_id = rec_c2.id
                   AND location_id IS NOT NULL;
                EXCEPTION
                 WHEN OTHERS
                 THEN
                        log_error (
                             l_chr_err_code 
                           , l_chr_err_msg 
                           , l_chr_prc_name
                           , 'WHEN OTHERS - update bi_cvc_location for location_id'
                           ,  SQLERRM
                           ,  SQLCODE
                           );     
                END;        
                    
             
                 
               END LOOP;

            END LOOP;
			
			
			   BEGIN        
                  UPDATE bi_cvc_location
                  SET id = BI_location_sEQ.NEXTVAL
                  WHERE location_id IS NOT NULL; 
               EXCEPTION
                 WHEN OTHERS
                 THEN
                        log_error (
                             l_chr_err_code 
                           , l_chr_err_msg 
                           , l_chr_prc_name
                           , 'WHEN OTHERS - update bi_cvc_location for location_id'
                           ,  SQLERRM
                           ,  SQLCODE
                           );     
                END;           
    
        END IF;
		
		
		IF l_gbl_trunc = 'Y'
        THEN
   
            BEGIN
			   SELECT id 
			     INTO l_location_id
			     FROM bi_cvc_location 
				WHERE NAME = '-Redwood Shores - HQ' ;
			EXCEPTION
			 WHEN OTHERS
			 THEN
			  DBMS_OUTPUT.PUT_LINE('Error gettting loc id' ||  SQLERRM);
			END;
			
           DBMS_OUTPUT.PUT_LINE ('l_location_id' ||l_location_id);
          
            
              BEGIN          
                 INSERT INTO BI_LOCATION_CALENDAR (id,additional_info,start_date,end_date,location_id,created_by,created_ts,
                         updated_by,updated_ts,unique_id,version)
                  SELECT bi_location_calendar_seq.NEXTVAL,t.name , t.date_from, t.date_to,t.loc, t.created_by, 
                    CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',t.updated_by ,
                    CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
                    regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
                    0  
                    FROM
                    (
                   SELECT  name ,
                        FN_DAY_LIGHT_TS(NEW_TIME(TO_TIMESTAMP( date_from ,'DD-MON-YY HH24:MI:SS'), 'PST' ,'GMT')) date_from,
                         FN_DAY_LIGHT_TS(NEW_TIME(TO_TIMESTAMP( date_TO ,'DD-MON-YY HH24:MI:SS'), 'PST' ,'GMT')) + INTERVAL '23:59' HOUR TO MINUTE date_to,
                         l_location_id loc,created_by,updated_by
                        FROM cvc_special_date@dblink_to_cvc_new 
                        WHERE location_id = 96--80   
                         AND date_from <> date_to                    
                    UNION     
                    SELECT   name ,
                         FN_DAY_LIGHT_TS(NEW_TIME(TO_TIMESTAMP( date_from ,'DD-MON-YY HH24:MI:SS'), 'PST' ,'GMT'))  date_from,
                         FN_DAY_LIGHT_TS(NEW_TIME(TO_TIMESTAMP( date_TO ,'DD-MON-YY HH24:MI:SS'), 'PST' ,'GMT')) + INTERVAL '23:59' HOUR TO MINUTE date_to,
                         l_location_id loc,created_by,updated_by
                    FROM cvc_special_date@dblink_to_cvc_new 
                    WHERE location_id is null 
                    AND date_from <> date_to     
                    ) t;                      
             EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                 NULL;
               WHEN OTHERS
               THEN
                    DBMS_OUTPUT.PUT_LINE (
                          ' Error inside bi_location_calendar insert --'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                           
                    l_out_chr_errbuf :=
                          ' Error inside bi_location_calendar insert --'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
                        
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - Check for bi_location_calendar insert'
                       ,  SQLERRM
                       ,  SQLCODE
                       );
            END;    
            
            BEGIN          
                 INSERT INTO BI_LOCATION_CALENDAR (id,additional_info,start_date,end_date,location_id,created_by,created_ts,
                         updated_by,updated_ts,unique_id,version)
                  SELECT bi_location_calendar_seq.NEXTVAL,t.name , t.date_from, t.date_to,t.loc, t.created_by, 
                    CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',t.updated_by ,
                    CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
                    regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
                    0  
                    FROM
                    (
                   SELECT  name ,
                          FN_DAY_LIGHT_TS(NEW_TIME(TO_TIMESTAMP( date_from ,'DD-MON-YY HH24:MI:SS'), 'PST' ,'GMT')) date_from,
                          FN_DAY_LIGHT_TS(NEW_TIME(TO_TIMESTAMP( date_TO ,'DD-MON-YY HH24:MI:SS'), 'PST' ,'GMT')) + INTERVAL '23:59' HOUR TO MINUTE  date_to, 
                         l_location_id loc,created_by,updated_by
                         FROM cvc_special_date@dblink_to_cvc_new 
                        WHERE location_id = 96--80   
                          AND date_from = date_to                    
                    UNION     
                    SELECT   name ,
                         FN_DAY_LIGHT_TS(NEW_TIME(TO_TIMESTAMP( date_from ,'DD-MON-YY HH24:MI:SS'), 'PST' ,'GMT')) date_from,
                         FN_DAY_LIGHT_TS(NEW_TIME(TO_TIMESTAMP( date_TO ,'DD-MON-YY HH24:MI:SS'), 'PST' ,'GMT')) + INTERVAL '23:59' HOUR TO MINUTE  date_to, 
                          l_location_id loc,created_by,updated_by
                     FROM cvc_special_date@dblink_to_cvc_new 
                    WHERE location_id is null 
                      AND date_from = date_to     
                    ) t;                      
             EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                 NULL;
               WHEN OTHERS
               THEN
                    DBMS_OUTPUT.PUT_LINE (
                          ' Error inside bi_location_calendar insert --'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                           
                    l_out_chr_errbuf :=
                          ' Error inside bi_location_calendar insert --'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
                        
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - Check for bi_location_calendar insert'
                       ,  SQLERRM
                       ,  SQLCODE
                       );
            END;                
			
			 DBMS_OUTPUT.PUT_LINE ('l_location_id' ||l_location_id);
          
            BEGIN          
               UPDATE bi_location_calendar 
                 SET location_id = l_location_id
                 WHERE location_id IS NULL;  
             EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                 NULL;
               WHEN OTHERS
               THEN
                    DBMS_OUTPUT.PUT_LINE (
                          ' Error inside bi_location_calendar update --'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                           
                    l_out_chr_errbuf :=
                          ' Error inside bi_location_calendar update --'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
                        
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - Check for bi_location_calendar update'
                       ,  SQLERRM
                       ,  SQLCODE
                       );
         END;    
       
      END IF;   
      
    

      COMMIT;
  
        EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.PUT_LINE ('Error due to  :  ' || SQLERRM );

        END;
   
 PROCEDURE  bi_cvc_Agenda_gen (out_chr_err_code   OUT VARCHAR2,
                                out_chr_err_msg    OUT VARCHAR2,
                                inp_request_id IN NUMBER,
                                inp_start_date IN DATE,
                                inp_end_date IN DATE
                               )

 IS

l_str LONG;
l_bi_Req_id NUMBER  ;
l_chr_entry_date DATE;
l_cvc_reqid NUMBER;
l_num_id NUMBER := 100;
l_main_room_end NUMBER;
l_main_room_start NUMBER;
l_new_reqact_id NUMBER;
l_Start_id NUMBER;
l_end_id NUMBER;
l_bi_req_act_id number ;
l_chr_err_code  VARCHAR2 (255);
l_chr_err_msg   VARCHAR2 (255); 
l_multiple_st_exists NUMBER;
l_multiple_end_exists NUMBER;
l_id_already_exists NUMBER;
l_create_opp_num  VARCHAR2(50) ;
l_chr_cost_center  VARCHAR2 (200);
l_out_chr_errbuf VARCHAR2 (2000);
NO_REQUEST_FOUND EXCEPTION;
l_chr_prc_name      VARCHAR2(50) := 'bi_cvc_Agenda_gen';

CURSOR C1 (inp_id NUMBER,inp_st DATE,inp_end DATE)
IS
SELECT id ,company_name,host_name,NEW_TIME(start_Date, 'PST', 'GMT') start_date ,NEW_TIME(alternative_date, 'PST', 'GMT') alternative_date,status_id
FROM CVC_REQUEST@dblink_to_cvc_new
WHERE ID = inp_id
AND location_id = 96--80
AND id NOT IN (SELECT cvc_request_id FROM bi_cvc_Agenda)
UNION
SELECT id ,company_name,host_name,NEW_TIME(start_Date, 'PST', 'GMT') start_date  ,NEW_TIME(alternative_date, 'PST', 'GMT') alternative_date,status_id
FROM CVC_REQUEST@dblink_to_cvc_new
WHERE start_Date BETWEEN inp_st AND inp_end
AND location_id = 96--80
AND status_id  = DECODE(upper(l_global_status),'CONFIRMED',14,status_id)
AND NVL(UPPER(ac_id),'ABC') = DECODE(l_global_bm_email,NULL,NVL(UPPER(ac_id),'ABC'),l_global_bm_email)
AND id NOT IN (SELECT cvc_request_id FROM bi_cvc_Agenda);

CURSOR c1_upd
IS
select DISTINCT q1.id id,q1.request_activity_day_id, q1.time_from,q2.time_to,(q2.time_to-q1.time_from) *24*60 mins
  FROM
(SELECT  id,request_activity_day_id ,entry_date,
  ( SELECT time_from  FROM bi_cvc_Agenda 
       WHERE id = a.id 
         AND entry_type = 'SELF_SERVICE'--'START_MARK' 
         AND request_activity_day_id = a.request_activity_day_id) time_from
     FROM bi_cvc_Agenda   a
    WHERE  entry_type IN ('SELF_SERVICE'--'START_MARK' 
	)
	  AND  req_pr_flag IN ( 'Y','NA') 
  ) q1
LEFT JOIN
(SELECT  id,request_activity_day_id ,entry_date,
   ( SELECT time_from FROM bi_cvc_Agenda 
       WHERE id = a.id 
         AND entry_type = 'SELF_SERVICE'--'END_MARK'  
         AND request_activity_day_id = a.request_activity_day_id) time_to
    FROM bi_cvc_Agenda   a
    WHERE entry_type IN ( 'SELF_SERVICE'--'END_MARK' 
	)
 	 AND req_pr_flag IN ( 'Y','NA') 
 ) q2
 ON q1.request_activity_day_id = q2.request_activity_day_id
 ORDER BY
  q1.id  ;
  
CURSOR c_upd_reqact(inp_request_id NUMBER,inp_st DATE,inp_end DATE)
IS
 SELECT DISTINCT a.bi_Request_id,a.entry_date,a.request_activity_day_id   
  FROM  bi_cvc_agenda a,cvc_request@dblink_to_cvc_new b
  WHERE a.cvc_request_id = inp_request_id
    AND a.entry_type = 'SELF_SERVICE'--'START_MARK' 
    AND a.cvc_request_id = b.id  
   UNION ALL
 SELECT DISTINCT a.bi_Request_id,a.entry_date,a.request_activity_day_id   
  FROM  bi_cvc_agenda a,cvc_request@dblink_to_cvc_new b
  WHERE a.cvc_request_id = b.id
    AND a.entry_type = 'SELF_SERVICE'--'START_MARK' 
     AND b.start_Date BETWEEN inp_st AND inp_end
    ORDER BY 1;

CURSOR c_upd_duration(bi_id NUMBER)
IS
 SELECT ((MAX(entry_Date)-MIN(entry_DAte))+1 ) duration
  FROM  bi_cvc_agenda 
  WHERE bi_request_id = bi_id;
  
CURSOR get_cost_center(inp_id NUMBER,inp_st DATE,inp_end DATE)
IS  
SELECT DISTINCT REPLACE(REPLACE(a.cost_center,CHR(9),''),' ','')  
 FROM cvc_agenda_catering@dblink_to_cvc_new a,
      bi_cvc_agenda  b
 WHERE a.id =  b.catering_id   
  AND b.entry_type = 'Catering' 
  AND b.cvc_request_id = inp_id
  AND b.cvc_request_id 
   IN (SELECT id 
         FROM cvc_request@dblink_to_cvc_new 
        WHERE location_id = 96--80  
          AND id = inp_id) 
UNION ALL
SELECT DISTINCT REPLACE(REPLACE(a.cost_center,CHR(9),''),' ','')  
 FROM cvc_agenda_catering@dblink_to_cvc_new a,
      bi_cvc_agenda  b
 WHERE a.id =  b.catering_id   
  AND b.entry_type = 'Catering' 
   AND b.cvc_request_id 
   IN (SELECT id 
         FROM cvc_request@dblink_to_cvc_new 
        WHERE location_id = 96--80  
          AND start_date BETWEEN inp_st AND inp_end)       ;
  
CURSOR c_cost_center 
IS
SELECT DISTINCT bi_request_id,cvc_request_id
from bi_cvc_agenda 
WHERE bi_Request_id in (SELECT id FROM bi_request WHERE cost_center IS NULL);

CURSOR c_opp
IS
SELECT DISTINCT bi_Request_id , opp_number
FROM bi_cvc_Agenda
WHERE cvc_request_id = l_global_reqid
UNION ALL
SELECT DISTINCT bi_Request_id , opp_number
FROM bi_cvc_Agenda
WHERE cvc_request_id 
   IN (SELECT id 
         FROM cvc_request@dblink_to_cvc_new 
        WHERE location_id = 96--80  
          AND start_date BETWEEN l_global_st_date AND  l_global_end_date  ) 
AND bi_Request_id NOT IN (select request_id from bi_Request_opportunity)  ;


CURSOR c_get_req_details 
IS
SELECT DISTINCT bi_request_id,entry_DAte,request_activity_day_id,entry_type,req_pr_flag
FROM bi_cvc_agenda
WHERE entry_type ='SELF_SERVICE'--IN ( 'START_MARK','END_MARK')  
AND req_pr_flag IS NULL
AND cvc_request_id = NVL(inp_request_id,cvc_request_id)
ORDER by bi_request_id,entry_DAte;

CURSOR c_req_upd_start(inp_id NUMBER,inp_entry_date DATE)
IS
SELECT id,trunc(entry_Date) entry_Date,time_from FROM bi_cvc_Agenda
 WHERE entry_type = 'SELF_SERVICE'--'START_MARK'
  AND bi_request_id = inp_id	
  AND entry_Date =  inp_entry_date 
  AND trunc(entry_Date) 
   IN (SELECT trunc(entry_Date)
 				 FROM bi_Cvc_agenda
				WHERE entry_type = 'SELF_SERVICE'--'START_MARK' 
				AND bi_request_id = inp_id		
				AND entry_Date =  inp_entry_date
				group by  trunc(entry_Date)
				having count(1) > 1)				
   AND to_char(time_from, 'HH12:MI:SS AM') 
   IN (SELECT  to_char(min(time_from), 'HH12:MI:SS AM')
 FROM bi_cvc_Agenda
 WHERE entry_type = 'SELF_SERVICE'--'START_MARK'
  AND bi_request_id = inp_id	
  AND entry_Date =  inp_entry_date
  AND trunc(entry_Date) 
   IN (SELECT trunc(entry_Date)
 				 FROM bi_Cvc_agenda
				WHERE entry_type = 'SELF_SERVICE'--'START_MARK'
				AND entry_Date =  inp_entry_date
				AND bi_request_id = inp_id				
				group by  trunc(entry_Date)
				having count(1) > 1))
AND ROWNUM <2 ;	

CURSOR c_req_upd_end(inp_id NUMBER,inp_exit_date DATE)
IS
SELECT id,trunc(entry_Date) entry_Date,time_to FROM bi_cvc_Agenda
 WHERE entry_type = 'SELF_SERVICE'--'END_MARK'  
  AND bi_request_id = inp_id	
  AND entry_Date =  inp_exit_date
  AND trunc(entry_Date) 
   IN (SELECT trunc(entry_Date)
 				 FROM bi_Cvc_agenda
				WHERE entry_type ='SELF_SERVICE'--'END_MARK'   
				AND bi_request_id = inp_id		
				 AND entry_Date =  inp_exit_date		
				group by  trunc(entry_Date)
				having count(1) > 1)				
   AND to_char(time_to, 'HH12:MI:SS AM') 
   IN (SELECT  to_char(max(time_to), 'HH12:MI:SS AM')
 FROM bi_cvc_Agenda
 WHERE entry_type = 'SELF_SERVICE'--'END_MARK'  
  AND bi_request_id = inp_id	
  AND entry_Date =  inp_exit_date
  AND trunc(entry_Date) 
   IN (SELECT trunc(entry_Date)
 				 FROM bi_Cvc_agenda
				WHERE entry_type = 'SELF_SERVICE'--'END_MARK'  
				AND bi_request_id = inp_id		
				AND entry_Date =  inp_exit_date		
				group by  trunc(entry_Date)
				having count(1) > 1))				
 AND ROWNUM <2 ;
 
/*CURSOR c_create_topic
IS
SELECT DISTINCT cvc_request_id ,request_activity_day_id,entry_date,bi_request_id ,company_name,room_id
FROM bi_cvc_agenda 
WHERE entry_type IN ('Catering','END_MARK','START_MARK')
 AND cvc_request_id 
 NOT IN 
 (SELECT cvc_request_id 
    FROM bi_cvc_agenda 
    WHERE entry_type = 'Topic' ) ;*/

CURSOR c_upd_req_type
IS
 SELECT DISTINCT cvc_request_id
    FROM bi_cvc_agenda;
       
BEGIN

-- EXECUTE IMMEDIATE  'TRUNCATE TABLE  bi_cvc_agenda ' ;

  --  dbms_output.put_line ('Before opening cursor' || inp_request_id);

    FOR rec_c1 IN c1(inp_request_id,inp_start_date,inp_end_date)
    LOOP

            l_cvc_reqid := rec_c1.id;

             --   dbms_output.put_line ('Inside first ' || l_cvc_reqid);
                
                  /* IF rec_c1.alternative_date IS NOT NULL
                   THEN
                
                        BEGIN
                            SELECT DISTINCT a.id
                             INTO l_bi_Req_id
                             FROM bi_request a
                            WHERE a.customer_name = rec_c1.company_name
                              AND a.host_email = lower(rec_c1.host_name) 
                              AND trunc(a.start_date) = trunc(rec_c1.start_date) 
                              AND trunc(a.alternative_date) =   trunc(rec_c1.alternative_date)
                               AND a.status = rec_c1.status_id	  ;
                        EXCEPTION
                          WHEN OTHERS
                          THEN
                            DBMS_OUTPUT.PUT_LINE ('Error fetching id from bi_request: ' ||l_cvc_reqid ||  SQLERRM); 
                            INSERT INTO bi_failed_req VALUES (l_cvc_reqid);
                            RAISE NO_REQUEST_FOUND;                            
                        END;
                    ELSE      
                          BEGIN
                            SELECT DISTINCT a.id
                             INTO l_bi_Req_id
                             FROM bi_request a
                            WHERE a.customer_name = rec_c1.company_name
                              AND a.host_email = lower(rec_c1.host_name) 
                              AND trunc(a.start_date) = trunc(rec_c1.start_date)  
                              AND a.status = rec_c1.status_id;
                        EXCEPTION
                          WHEN OTHERS
                          THEN
                            DBMS_OUTPUT.PUT_LINE ('Error fetching id from bi_request: ' || SQLERRM); 
                            INSERT INTO bi_failed_req VALUES (l_cvc_reqid);
                            RAISE NO_REQUEST_FOUND;
                        END;   
                END IF;*/
				
				        BEGIN
                            SELECT DISTINCT a.id
                             INTO l_bi_Req_id
                             FROM bi_request a
                            WHERE a.status = rec_c1.id ;
                        EXCEPTION
                          WHEN OTHERS
                          THEN
                            DBMS_OUTPUT.PUT_LINE ('Error fetching id from bi_request: ' || SQLERRM); 
                            INSERT INTO bi_failed_req VALUES (l_cvc_reqid);
                           -- RAISE NO_REQUEST_FOUND;
                        END;  
                
               -- dbms_output.put_line ('l_bi_Req_id  : ' || l_bi_Req_id);
                
                l_cvc_reqid := l_bi_Req_id;
                
                -- dbms_output.put_line ('l_cvc_reqid now : ' || l_cvc_reqid);
                 
                 BEGIN
                               INSERT INTO bi_cvc_agenda  
                                      (  id, entry_date  
                                          ,cvc_request_id              
                                          ,bi_request_id 
                                          ,request_activity_day_id
                                          ,request_type_activity_id
                                          ,company_name           
                                          ,entry_type             
                                          ,entry_name             
                                          ,topic_id               
                                          ,catering_id 
                                          ,no_attendees 
                                          ,agenda_topic_id        
                                          ,topic_objective        
                                          ,optional_topic         
                                          ,catering_type          
                                          ,other_dietary_opt      
                                          ,special_instruction    
                                          ,special_dietary    
                                          ,digital_signage 
                                          ,entry_day              
                                          , time_from                 
                                          , time_to                
                                          ,location_id            
                                          ,room_id                
                                          ,created_by             
                                          ,created_date           
                                          ,updated_by             
                                          ,updated_date           
                                          ,room_main    ) 
                 SELECT bi_cvc_agenda_seq.nextval, 
                        NEW_TIME(entry_date, 'PST', 'GMT'),
                        rec_c1.id,
                        l_cvc_reqid,
                        1 request_activity_day_id,
                        (SELECT DECODE(a.entry_type,'Topic',3,'Catering',2,1) FROM DUAL )request_type_activity_id,
                        (SELECT company_name from cvc_request@dblink_to_cvc_new where id = a.request_id )company_name,
                         entry_type,
                         decode (entry_type,'Catering',(SELECT value from BI_LOOKUP_vALUE WHERE lookup_type_id in (SELECT id from BI_LOOKUP_TYPE  WHERE code ='CATERING_TYPE' ) and code = entry_name ), entry_name) entry_name,
                         topic_id,catering_id,
                        (SELECT number_attendees from cvc_agenda_catering@dblink_to_cvc_new where id = a.catering_id) no_attendees,
                        (SELECT distinct id from bi_topic where name = a.entry_name and rownum<2) agenda_topic_id ,
                        (SELECT topic_objective from cvc_agenda_topic@dblink_to_cvc_new where id = a.topic_id) topic_objective,
                        (SELECT optional_topic from cvc_agenda_topic@dblink_to_cvc_new where id = a.topic_id) optional_topic,
                        (SELECT catering_type from cvc_agenda_catering@dblink_to_cvc_new where id = a.catering_id) catering_type,
                        (SELECT other_dietary_opt from cvc_agenda_catering@dblink_to_cvc_new where id = a.catering_id) other_dietary_opt,
                        (SELECT other_dietary_opt from cvc_agenda_catering@dblink_to_cvc_new where id = a.catering_id) special_instruction,
                        (SELECT listagg(special_dietary,',') within group (order by special_dietary) cnt 
                            from cvc_agenda_cat_sp@dblink_to_cvc_new 
                            WHERE catering_id =  a.catering_id) special_dietary,
                        NVL(digital_signage,'FULL_AGENDA'),                   
                         entry_day
                         --,to_char( time_from, 'HH12:MI:SS AM')   
						 --, to_char( time_to, 'HH12:MI:SS AM'),
						, time_from,
						 time_to,
						 (SELECT id  from bi_location where name in (SELECT name from cvc_location@dblink_to_cvc_new where id = location_id ) )
                         ,( SELECT c.id
                                from bi_location c,
                                cvc_location_room@dblink_to_cvc_new b
                                where c.name = b.code
                                and c.address1 = b.room_location||' '|| b.room_location_1
                                and b.id = a.room_id)
                        ,created_by,created_date,updated_by,updated_Date,room_main 
                        FROM cvc_agenda@dblink_to_cvc_new a 
                        WHERE request_id =   rec_c1.id  
                          AND request_id NOT IN (SELECT cvc_request_id FROM bi_cvc_agenda)
                          AND entry_type IN ('Catering');---,'Topic','SELF_SERVICE');--'START_MARK,END_MARK');
                EXCEPTION
                 WHEN OTHERS
                 THEN
                        log_error (
                             l_chr_err_code 
                           , l_chr_err_msg 
                           , l_chr_prc_name
                           , 'WHEN OTHERS - insert into bi_cvc_agenda'
                           ,  SQLERRM
                           ,  SQLCODE
                           );     
                END;     

            ---    DBMS_OUTPUT.PUT_LINE ( ' rec_c1.id  ' ||rec_c1.id || 'l_cvc_reqid :' || l_cvc_reqid );
         
                       
           /* BEGIN
                  Insert into cvc_request_process
                       (request_id,
  					    company_name, 
						event_start_date, 
						host_name, 
						location, 
						status,
						start_date,
						end_date,
						cvc_status)
                     Values
                       (rec_c1.id ,
					    rec_c1.company_name, 
						rec_c1.start_date, 
						rec_c1.host_name,
						'-Redwood Shores - HQ', 
						'INIT',
						CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
						CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
						(select state from bi_request where id = l_bi_Req_id)
					);
                EXCEPTION
                 WHEN OTHERS
                 THEN
                 DBMS_OUTPUT.PUT_LINE ( 'When others' || l_bi_Req_id );
                   log_error (
                             l_chr_err_code 
                           , l_chr_err_msg 
                           , l_chr_prc_name
                           , 'WHEN OTHERS - insert into bi_cvc_agenda'
                           ,  SQLERRM
                           ,  SQLCODE
                           );   
                END;  */
                   
      END LOOP; 
        
         
	 FOR rec_upd_reqact IN c_upd_reqact(inp_request_id,inp_start_date,inp_end_date)
	 LOOP
				
       --      dbms_output.put_line ('--parms----  : ' || l_cvc_reqid || inp_start_date || inp_end_date || rec_upd_reqact.bi_Request_id);    
			   
				   SELECT DISTINCT COUNT(1)
					 INTO l_id_already_exists
					 FROM bi_cvc_agenda
					WHERE bi_Request_id = rec_upd_reqact.bi_Request_id
					 AND request_activity_day_id = 1;
				   
					--dbms_output.put_line ('--l_id_already_exists----  : ' || l_id_already_exists );

					IF l_id_already_exists >= 1 
					THEN
					
							BEGIN
							   SELECT bi_request_activity_day_seq.nextval
								 INTO l_bi_req_act_id
								 FROM DUAL;
							 EXCEPTION
							 WHEN OTHERS
							 THEN
									log_error (
										 l_chr_err_code 
									   , l_chr_err_msg 
									   , l_chr_prc_name
									   , 'WHEN OTHERS - getting the sequence'
									   ,  SQLERRM
									   ,  SQLCODE
									   );     
							END;      
							
			----	  	  dbms_output.put_line ('--parms again----  : ' || l_bi_req_act_id || rec_upd_reqact.bi_Request_id || rec_upd_reqact.entry_date );   
							
							BEGIN
							  UPDATE bi_cvc_agenda
								SET request_activity_day_id =  l_bi_req_act_id 
							  WHERE bi_Request_id = rec_upd_reqact.bi_Request_id
								AND TO_DATE(entry_date,'DD-Mon-YY')   =  TO_DATE(rec_upd_reqact.entry_date,'DD-Mon-YY')  ;
							EXCEPTION
							  WHEN OTHERS
							  THEN
								dbms_output.put_line ('Update failed for  : ' || rec_upd_reqact.bi_Request_id || 'due to :' || SQLERRM);
							END;
							
							
						
					END IF;
					
			  
				  FOR rec_upd_duration IN c_upd_duration (rec_upd_reqact.bi_Request_id)
				  LOOP
				  
						BEGIN
							UPDATE bi_request
							   SET duration = ROUND(rec_upd_duration.duration) 
							  WHERE id = rec_upd_reqact.bi_Request_id
							   AND rec_upd_duration.duration is not null ;
						EXCEPTION
						 WHEN OTHERS
						 THEN
								log_error (
									 l_chr_err_code 
								   , l_chr_err_msg 
								   , l_chr_prc_name
								   , 'WHEN OTHERS - updating duration'
								   ,  SQLERRM
								   ,  SQLCODE
								   );     
						END;  
						
						log_error (
							 l_chr_err_code 
						   , l_chr_err_msg 
						   , l_chr_prc_name
						   , 'Updating breakrooms'
						   ,  NULL
						   ,  l_global_params
						   );   
						
 
						
					   BEGIN
						   INSERT INTO bi_request_act_day_break_room (request_activity_day_id,break_rooms)           
                            SELECT DISTINCT request_activity_day_id,room_id 
                              FROM bi_cvc_Agenda a 
                             WHERE 1=1--a.entry_type IN ('Topic','Catering')
                               AND a.bi_request_id =  rec_upd_reqact.bi_Request_id
                               AND 1=1--AND a.request_type_activity_id in (3,2)
                               AND a.room_id IS NOT NULL
                               AND NVL(a.room_main,'N') = 'N'
                               AND a.request_activity_day_id <> 1
                               AND a.room_id NOT IN 
                               (SELECT b.room_id FROM bi_cvc_Agenda b WHERE 1=1
                                    -- b.entry_type IN ('Topic','Catering') 
                                   --  AND b.request_type_activity_id in (3,2)
                                   AND b.room_main = 'Y' AND b.room_id IS NOT NULL  AND b.request_activity_day_id <> 1 
                                   AND b.request_activity_day_id = a.request_activity_day_id AND b.room_id = a.room_id )
                               AND a.request_activity_day_id NOT IN (SELECT c.request_activity_day_id FROM bi_request_act_day_break_room c WHERE c.request_activity_day_id = a.request_activity_day_id);
					  EXCEPTION
					   WHEN OTHERS
					   THEN   
							log_error (
								 l_chr_err_code 
							   , l_chr_err_msg 
							   , l_chr_prc_name
							   , 'WHEN OTHERS - updating bi_request_act_day_break_room'
							   ,  SQLERRM
							   ,  SQLCODE
							   );                        
					   END;  
					   
						COMMIT;
					END LOOP;
        
				  log_error (
							 l_chr_err_code 
						   , l_chr_err_msg 
						   , l_chr_prc_name
						   , 'Updating cost_center'
						   ,  NULL
						   ,  l_global_params
						   );   
						
		
		
             FOR rec_cost_center IN c_cost_center
             LOOP
              
                 --   dbms_output.put_line ('--cost_center----  : '     );
					
				   BEGIN
				       SELECT REPLACE(replace( a.cost_center ,chr(9),' '),' ','') 
					     INTO l_chr_cost_center
						 FROM cvc_agenda_catering@dblink_to_cvc_new a,
							  bi_cvc_agenda  b
						 WHERE a.id =  b.catering_id   
						  AND b.entry_type = 'Catering' 
						  AND b.cvc_request_id = rec_cost_center.cvc_request_id
						  AND a.cost_center IS NOT NULL    
						  AND ROWNUM = 1;   
                    EXCEPTION
                     WHEN OTHERS
                     THEN
						log_error (
							 l_chr_err_code 
						   , l_chr_err_msg 
						   , l_chr_prc_name
						   , 'WHEN OTHERS - getting cost_center'
						   ,  SQLERRM
						   ,  SQLCODE
						   );     
                    END; 										   
				   
				   
				   
                    BEGIN
                        UPDATE bi_request
                           SET cost_center = REPLACE(replace( l_chr_cost_center ,chr(9),' '),' ','') 
                          WHERE id = rec_cost_center.bi_request_id ;
                    EXCEPTION
                     WHEN OTHERS
                     THEN
                            log_error (
                                 l_chr_err_code 
                               , l_chr_err_msg 
                               , l_chr_prc_name
                               , 'WHEN OTHERS - updating cost_center'
                               ,  SQLERRM
                               ,  SQLCODE
                               );     
                    END; 
					 
					
              END LOOP;
			   
          
             --   l_chr_entry_date := trunc(rec_upd_reqact.entry_date);
              --  dbms_output.put_line ('l_chr_entry_date here is ' || l_chr_entry_date);
              

        
    END LOOP; --end of c2
	
	
				log_error (
				 l_chr_err_code 
			   , l_chr_err_msg 
			   , l_chr_prc_name
			   , 'Updating  multiple arrivals'
			   ,  NULL
			   ,  l_global_params
			   );   
			


	FOR rec_get_details IN c_get_req_details  
    LOOP
	
	       -- dbms_output.put_line (' BEFORE l_multiple_st_exists l_cvc_reqid :  ' || rec_get_details.bi_request_id);
	 	 --   dbms_output.put_line (' BEFORE l_multiple_st_exists for :  ' || rec_get_details.request_activity_day_id);
	 	  --  dbms_output.put_line (' BEFORE l_multiple_st_exists for :  ' || rec_get_details.entry_date);
    
       
            BEGIN	
              SELECT COUNT(1) 
               INTO l_multiple_st_exists
                FROM bi_Cvc_agenda a,
                     bi_Cvc_agenda b
                WHERE a.entry_type = 'SELF_SERVICE'--'START_MARK' 
               -- AND b.entry_type  = 'START_MARK' 
                AND a.entry_type = b.entry_type
                AND a.entry_Date = b.entry_Date
				AND TRUNC(a.entry_Date) =  TRUNC(rec_get_details.entry_date)
                AND a.request_activity_day_id = b.request_activity_day_id
                AND a.id <> b.id
                AND a.bi_request_id = b.bi_request_id
                AND a.bi_request_id = rec_get_details.bi_request_id
                HAVING COUNT(1) > 1
                GROUP BY a.bi_request_id;
            EXCEPTION
              WHEN NO_DATA_FOUND
              THEN
               --  dbms_output.put_line (' INSIDE NO_dATA_FOUND START FOR :  '|| rec_get_details.bi_request_id);
                 UPDATE bi_cvc_Agenda
                          SET req_pr_flag = 'NA'
                         WHERE bi_request_id = rec_get_details.bi_request_id
						  AND request_activity_day_id = rec_get_details.request_activity_day_id
                          AND entry_type = 'SELF_SERVICE'--'START_MARK'
                          AND TRUNC(entry_Date) =  TRUNC(rec_get_details.entry_date)
                          AND req_pr_flag IS NULL ;   	
              WHEN OTHERS
              THEN
                dbms_output.put_line ('no_Data_found ' || SQLERRM);
              END;
        
           
             
		 IF l_multiple_st_exists > 1
		 THEN
		 
			-- dbms_output.put_line ('l_multiple_st_exists ' || l_multiple_st_exists);
		  
				  FOR rec_c_req_upd_start IN c_req_upd_start (rec_get_details.bi_request_id,rec_get_details.entry_date )
				  LOOP
				 	-- ---  dbms_output.put_line (' rec_get_details.bi_Request_id   : ' ||  rec_get_details.bi_request_id );
				 	---   dbms_output.put_line (' rec_c_req_upd_start.id : ' ||  rec_c_req_upd_start.id  );
				 	--   dbms_output.put_line (' rec_c_req_upd_start.entry_Date   : ' ||  rec_c_req_upd_start.entry_Date  );
					   
					   BEGIN					   
						SELECT DISTINCT room_id
						 INTO l_main_room_start
					  	  FROM bi_cvc_Agenda
						 WHERE request_activity_day_id 
						  IN 
						 (SELECT DISTINCT request_activity_day_id
						    FROM bi_cvc_agenda
						   WHERE id = rec_c_req_upd_start.id)
						AND room_main ='Y'
						AND entry_type = 'SELF_SERVICE'--'START_MARK' 
						AND rownum < 2;											   
					   EXCEPTION
						  WHEN OTHERS
						  THEN
							dbms_output.put_line ('no_Data_found ' || SQLERRM);
					   END;
								  
					   UPDATE bi_cvc_Agenda
						  SET req_pr_flag = 'Y',
						      pick_main_room = l_main_room_start
						 WHERE  id = rec_c_req_upd_start.id
						  AND entry_type = 'SELF_SERVICE'--'START_MARK'
						  AND TRUNC(entry_Date)=  TRUNC(rec_c_req_upd_start.entry_Date)
						  AND bi_Request_id = rec_get_details.bi_request_id
						  AND req_pr_flag IS NULL ; 	
						 
						 UPDATE bi_cvc_Agenda
						   SET req_pr_flag = 'N'
						 WHERE  id <> rec_c_req_upd_start.id
						   AND entry_type ='SELF_SERVICE'--'START_MARK'
						   AND TRUNC(entry_Date)=  TRUNC(rec_c_req_upd_start.entry_Date)
						   AND bi_Request_id = rec_get_details.bi_request_id
						   AND req_pr_flag IS NULL ; 
			 
		 
				  END LOOP;
		   
		 END IF;	
             
	     BEGIN
		   SELECT COUNT(1) 
		   INTO l_multiple_end_exists
			FROM bi_Cvc_agenda a,
				 bi_Cvc_agenda b
			WHERE a.entry_type = 'SELF_SERVICE'--'END_MARK' 
			AND b.entry_type  = 'SELF_SERVICE'--'END_MARK'
			AND a.entry_type = b.entry_type
			AND a.entry_Date = b.entry_Date
			AND a.entry_DAte = rec_get_details.entry_Date
			AND a.request_activity_day_id = b.request_activity_day_id
			AND a.id <> b.id
			AND a.bi_request_id = b.bi_request_id
			AND a.bi_request_id = rec_get_details.bi_request_id
			HAVING COUNT(1) > 1
			GROUP BY a.bi_request_id;	
		EXCEPTION
		  WHEN NO_DATA_FOUND
		  THEN
		    -- dbms_output.put_line (' INSIDE NO_dATA_FOUND START FOR :  '|| rec_get_details.bi_request_id);
			  UPDATE bi_cvc_Agenda
				  SET req_pr_flag ='NA'
				 WHERE bi_request_id = rec_get_details.bi_request_id
				  AND request_activity_day_id = rec_get_details.request_activity_day_id
				  AND entry_type ='SELF_SERVICE'--'END_MARK'
				  AND TRUNC(entry_Date) =  TRUNC(rec_get_details.entry_Date)
				  AND req_pr_flag IS NULL ; 	              
		 WHEN OTHERS
		 THEN
		   dbms_output.put_line ('l_multiple_end_exists' || SQLERRM);
		END;
		 
          ---       dbms_output.put_line ('l_multiple_end_exists for :  ' || rec_get_details.bi_request_id);
                 
		 IF l_multiple_end_exists >1
		 THEN
                  
			--- 	 dbms_output.put_line ('l_multiple_end_exists ' || l_multiple_end_exists);
				 
				  FOR rec_c_req_upd_end IN c_req_upd_end (rec_get_details.bi_request_id,rec_get_details.entry_Date)
				  LOOP
				 --	  dbms_output.put_line ('--rec_get_details.bi_Request_id----  : ' ||  rec_get_details.bi_request_id  );
				---	  dbms_output.put_line ('--rec_c_req_upd_end.id----  : ' ||  rec_c_req_upd_end.id  );
				---	  dbms_output.put_line ('--rec_c_req_upd_end.entry_Date----  : ' ||  rec_c_req_upd_end.entry_Date  );
					  
					   BEGIN					   
						SELECT DISTINCT room_id
						  INTO l_main_room_end
					  	  FROM bi_cvc_Agenda
						 WHERE request_activity_day_id 
						  IN 
						 (SELECT DISTINCT request_activity_day_id
						    FROM bi_cvc_agenda
						   WHERE id = rec_c_req_upd_end.id)
						AND room_main = 'Y'
						AND entry_type = 'SELF_SERVICE'--'END_MARK'
						AND rownum < 2;											   
					   EXCEPTION
						  WHEN OTHERS
						  THEN
							dbms_output.put_line ('l_main_room_end data nt found ' || SQLERRM);
					   END;
								
					   BEGIN
					    UPDATE bi_cvc_Agenda
						  SET req_pr_flag ='Y',
						    pick_main_room = l_main_room_end
						 WHERE id = rec_c_req_upd_end.id
						  AND entry_type ='SELF_SERVICE'--'END_MARK'
						  AND TRUNC(entry_Date)  =  TRUNC(rec_c_req_upd_end.entry_Date)
						  AND bi_request_id = rec_get_details.bi_request_id 
						  AND req_pr_flag IS NULL ; 	
						EXCEPTION
						  WHEN OTHERS
						  THEN
							dbms_output.put_line ('req_pr_flag to Y ' || SQLERRM);
					   END; 			  
						
					  BEGIN  
					   UPDATE bi_cvc_Agenda
						 SET req_pr_flag ='N'
						 WHERE  id <> rec_c_req_upd_end.id
						  AND entry_type ='SELF_SERVICE'--'END_MARK'
						 AND TRUNC(entry_Date)  =  TRUNC(rec_c_req_upd_end.entry_Date)
						 AND bi_request_id = rec_get_details.bi_request_id 
						 AND req_pr_flag IS NULL ; 	
					   EXCEPTION
						  WHEN OTHERS
						  THEN
							dbms_output.put_line ('req_pr_flag to N ' || SQLERRM);
					   END;						 
			 
			 
				  END LOOP;
			  
        END IF;
    
    END LOOP;
	
			log_error (
			 l_chr_err_code 
		   , l_chr_err_msg 
		   , l_chr_prc_name
		   , 'Updating location calendar'
		   ,  NULL
		   ,  l_global_params
		   );   
		
		 
	  FOR rec_c1_upd IN c1_upd
	  LOOP
	  
		  --  dbms_output.put_line ('--rec_c1_upd.time_to----  : ' ||  rec_c1_upd.time_to  );
		   --  dbms_output.put_line ('--rec_c1_upd.id----  : ' ||  rec_c1_upd.id  );
		  --    dbms_output.put_line ('--rec_c1_upd.mins----  : ' ||  rec_c1_upd.mins  );

         BEGIN
			UPDATE bi_cvc_Agenda
			  SET time_to =  time_from + rec_c1_upd.mins /1440,
				  process_flag = 'Y'
			 WHERE id = rec_c1_upd.id
			  AND entry_type = 'SELF_SERVICE'--'START_MARK'
			  AND process_flag IS NULL ;	 
        EXCEPTION
          WHEN OTHERS
          THEN
            dbms_output.put_line ('Error updating time_to in bi_cvc_Agenda  ' || SQLERRM);
       END;						 
			 
	  END LOOP;
	  
 
	 /*FOR rec_create_topic IN c_create_topic
     LOOP
 
        INSERT INTO BI_CVC_AGENDA
           (id, entry_date, cvc_request_id, bi_request_id, request_activity_day_id, 
            request_type_activity_id, company_name, entry_type, entry_name, topic_id, 
            no_attendees,   topic_objective, optional_topic, 
              time_from, time_to, location_id,  
            created_by, created_date, updated_by, updated_date
            ) VALUES
           ( bi_cvc_agenda_seq.nextval, rec_create_topic.entry_date, rec_create_topic.cvc_request_id, rec_create_topic.bi_request_id,
           rec_create_topic.request_activity_day_id, 
            3, rec_create_topic.company_name, 'Topic', 'Test_Topic', 999999, 
            1,   'Conversion Test Topic', 'Conversion Test Topic', 
            rec_create_topic.entry_date, rec_create_topic.entry_date, (select id from bi_location where name  = '-Redwood Shores - HQ' ),  
            'CX_CVC', rec_create_topic.entry_date, 'CX_CVC', 
            rec_create_topic.entry_date
            );
        
      END LOOP;*/
    
         BEGIN
            INSERT INTO BI_LOCATION_CALENDAR (id,start_date,end_date,location_id,request_id,created_by,created_ts,updated_by,updated_ts,unique_id,version)        
                 SELECT bi_location_calendar_seq.NEXTVAL, 
                        FN_DAY_LIGHT_DT(NEW_TIME(TO_DATE( trunc(t.entry_date)||' '||TO_CHAR (t.time_from, 'HH24:MI:SS'),'DD-MON-YY HH24:MI:SS'), 'PST' ,'GMT')) ,
                        FN_DAY_LIGHT_DT(NEW_TIME(TO_DATE( trunc(t.entry_date)||' '||TO_CHAR (t.time_to, 'HH24:MI:SS'),'DD-MON-YY HH24:MI:SS'), 'PST' ,'GMT')),
                        t.room_id,
                        t.bi_Request_id,
                        'CX_CVC' ,
                        CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
                        'CX_CVC' ,
                        CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
                        regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
                        0   
            FROM           
             (
             SELECT DISTINCT   (
                   SELECT DISTINCT MIN(a.time_From)   
                    FROM bi_cvc_Agenda a
                    WHERE  a.entry_type = 'SELF_SERVICE'--'START_MARK'
                    AND a.bi_request_id = b.bi_request_id
                    AND a.request_activity_day_id = b.request_activity_day_id 
              ) time_from,
             (
                   SELECT DISTINCT MAX(a.time_to)   
                    FROM bi_cvc_Agenda a
                    WHERE  a.entry_type = 'SELF_SERVICE'--'END_MARK'
                    AND a.bi_request_id = b.bi_request_id
                    AND a.request_activity_day_id = b.request_activity_day_id 
               ) time_to  ,b.room_id,b.bi_request_id,b.entry_date,room_main
             FROM bi_cvc_Agenda b
            WHERE 1=1--b.bi_request_id = 23442
            AND b.entry_type IN ('Topic','Catering')
            AND NVL(room_main,'N') ='N'
            AND b.room_id NOT IN (SELECT a.room_id FROM bi_cvc_agenda a WHERE a.request_activity_day_id =b.request_activity_day_id and room_main ='Y' )
            AND b.bi_request_id NOT IN (SELECT c.request_id FROM BI_LOCATION_CALENDAR c where c.request_id = b.bi_Request_id)
            AND b.cvc_request_id IN ( SELECT  id
										 FROM cvc_request@dblink_to_cvc_new b
										WHERE id =  l_global_reqid
										 AND location_id = 96--80  			
									  UNION
										SELECT id
										 FROM cvc_request@dblink_to_cvc_new b
										WHERE start_Date BETWEEN  l_global_st_date AND  l_global_end_date  
										  AND location_id = 96)--80)
			AND b.room_id IS NOT NULL
            )
            t ;
          EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                 NULL;
               WHEN OTHERS
               THEN
                    DBMS_OUTPUT.PUT_LINE (
                          ' Error inside bi_location_calendar insert --'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                           
                    l_out_chr_errbuf :=
                          ' Error inside bi_location_calendar insert --'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
                        
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - Check for bi_location_calendar insert'
                       ,  SQLERRM
                       ,  SQLCODE
                       );
           END;  
		   
		   
		   
	  	  FOR rec_upd_req_type IN c_upd_req_type
		   LOOP
		   
		      BEGIN
 				 UPDATE cvc_request_process
				  SET status ='Completed'
				      ,bi_Request_id = (select distinct bi_request_id from bi_cvc_Agenda where cvc_request_id = rec_upd_req_type.cvc_request_id )
				      ,ac_id = (select distinct ac_id from cvc_request@dblink_to_cvc_new where id = rec_upd_req_type.cvc_request_id )
				      ,start_Date = CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT'
				      ,end_date  = CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT'
				 WHERE request_id = rec_upd_req_type.cvc_request_id;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                    dbms_output.put_line ('Error updating cvc_request_process ' || SQLERRM);
               END;						 
			 				 
 	          BEGIN
                 UPDATE bi_request
                   SET status = NULL
                  WHERE id IN (SELECT distinct bi_request_id FROM bi_Cvc_Agenda WHERE cvc_request_id = rec_upd_req_type.cvc_request_id );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                    dbms_output.put_line ('Error updating bi_request status to null ' || SQLERRM);
               END;		                  
                   
	      END LOOP; 
 
COMMIT;
  
EXCEPTION
WHEN NO_REQUEST_FOUND
THEN
   DBMS_OUTPUT.PUT_LINE ('Failed to process the requestid ,check bi_failed_req table ' || SQLERRM ) ;
WHEN OTHERS
THEN
   DBMS_OUTPUT.PUT_LINE ('Error due to  : ' || SQLERRM ) ;
END;

PROCEDURE bi_cvc_presenter_gen
IS

l_chr_err_code  VARCHAR2 (255);
l_chr_err_msg   VARCHAR2 (255); 
l_out_chr_errbuf VARCHAR2 (2000);
l_exist_count NUMBER;
l_chr_prc_name      VARCHAR2(50) := 'bi_cvc_presenter_gen';

 

CURSOR c_int_presenter 
IS
SELECT DISTINCT b.cvc_RequesT_id,
       b.request_activity_day_id,
       b.entry_name,
       b.optional_topic,
       a.topic_id,
       a.presenter,
        b.topic_objective,
       'internal' type,
       a.first_name ,
       a.last_name ,
      a.primary_email,
      null secondary_email,
       a.presenter_status,
       a.designation,
       a.created_by,
       a.updated_by,
	   b.time_from,
       b.entry_date
FROM bi_cvc_presenter_info a,
     bi_cvc_Agenda b
WHERE  a.topic_id = b.topic_id
 AND b.cvc_request_id = a.cvc_request_id
 AND a.cvc_request_id IN ( SELECT  id
							 FROM cvc_request@dblink_to_cvc_new b
							WHERE id =  l_global_reqid
							 AND location_id = 96--80  			
						  UNION
							SELECT id
							 FROM cvc_request@dblink_to_cvc_new b
							WHERE start_Date BETWEEN  l_global_st_date AND  l_global_end_date  
							  AND location_id = 96 );--80);
   
BEGIN 

				log_error (
					 l_chr_err_code 
				   , l_chr_err_msg 
				   , l_chr_prc_name
				   , 'Updating presenter info'
				   ,  NULL
				   ,  l_global_params
				   );   
				

          
              FOR rec_c_int_presenter IN c_int_presenter 
              LOOP
              
             --  DBMS_OUTPUT.PUT_LINE ('Here cvc_Request_id Is :' || rec_c_int_presenter.cvc_Request_id );
           ---    DBMS_OUTPUT.PUT_LINE ('================='   );
				  BEGIN 
					 INSERT INTO bi_cvc_agenda_presenter (id,topic_id,type,first_name,last_name,primary_email,secondary_email,presenter_status,suggested_presenter_title,
										  request_activity_day_id,topic,topic_activity_id,created_by,updated_by)
					  SELECT DISTINCT rec_c_int_presenter.cvc_Request_id,
							 rec_c_int_presenter.topic_id,
							 rec_c_int_presenter.type ,
							 rec_c_int_presenter.first_name ,
							 rec_c_int_presenter.last_name ,
							 rec_c_int_presenter.primary_email,
							 rec_c_int_presenter.secondary_email, 
							 rec_c_int_presenter.presenter_status ,
							 rec_c_int_presenter.designation,
							 rec_c_int_presenter.request_activity_day_id,
							 rec_c_int_presenter.entry_name,
							 (SELECT id FROM bi_request_topic_activity
							   WHERE request_activity_day_id = rec_c_int_presenter.request_activity_day_id 
								 AND topic = rec_c_int_presenter.entry_name
								 AND NVL(optional_topic,'abc') =  NVL(rec_c_int_presenter.optional_topic,'abc')
								 AND dbms_lob.compare(notes,'abc') = dbms_lob.compare(rec_c_int_presenter.topic_objective,'abc')
								 AND activity_start_time = FN_DAY_LIGHT_TS(NEW_TIME(TO_DATE( trunc(rec_c_int_presenter.entry_date)||' '||TO_CHAR (rec_c_int_presenter.time_from, 'HH24:MI:SS'),'DD-MON-YY HH24:MI:SS'), 'PST' ,'GMT'))
							   ) ,
							  rec_c_int_presenter.created_by,
							  rec_c_int_presenter.updated_by   
						FROM DUAL ;
				 EXCEPTION		
					WHEN OTHERS
					THEN
						DBMS_OUTPUT.PUT_LINE (
							  ' Error inside bi_cvc_agenda_presenter procedure --'
						   || SQLERRM
						   || '--'
						   || SQLCODE);
							   
						l_out_chr_errbuf :=
							  ' Error inside bi_cvc_agenda_presenter procedure --'
						   || SQLERRM
						   || '--'
						   || SQLCODE;
							
						log_error (
							 l_chr_err_code 
						   , l_chr_err_msg 
						   , l_chr_prc_name
						   , 'WHEN OTHERS - Check for bi_cvc_agenda_presenter value'
						   ,  SQLERRM
						   ,  SQLCODE
						   );
				  END;   
        
              END LOOP;  
 
        
        COMMIT;

    EXCEPTION
    WHEN OTHERS
    THEN
                  log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - Check for bi_cvc_agenda_presenter insert'
                       ,  SQLERRM
                       ,  SQLCODE
                       );
     
END;
   
 PROCEDURE fetch_insert_proc
  (l_chr_sql       VARCHAR2, 
   l_chr_tablename VARCHAR2,
   l_num_tabid     NUMBER) 
  
  IS
    
      table_copy_str    LONG;
      l_array_type      VARCHAR2(255);
      l_chr_dml         VARCHAR2(255);
      l_chr_err_code    VARCHAR2 (255);
      l_atotal_str      LONG;
      l_btotal_str      LONG;
      l_num_lookup_exists NUMBER;
      l_insert_flag     VARCHAR2 (255);  
      l_diff            NUMBER;
      l_chr_err_msg     VARCHAR2 (255);    
      l_out_chr_errbuf  VARCHAR2 (2000); 
      l_chr_code        VARCHAR2 (255); 
      l_chr_value       VARCHAR2 (255); 
      l_tabid           VARCHAR2 (255);
      l_newchr_sql      VARCHAR2 (255);
      l_unique_val      VARCHAR2(100);
      l_atotal NUMBER;
      l_atotal_count number;
      l_btotal_count number;
      l_btotal NUMBER;
      l_is_master  VARCHAR2(10);
      l_chr_tab_validation  VARCHAR2(100);
      l_str  LONG;
      l_unique_cond LONG;
      l_chr_prc_name    VARCHAR2(50) := 'fetch_insert_proc';
 

     BEGIN
     
          
       -- DBMS_OUTPUT.PUT_LINE ('l_chr_sql :  ' || l_chr_sql  || '  l_chr_tablename:  ' || l_chr_tablename || '  l_num_tabid :  ' || l_num_tabid);
             
              BEGIN
                SELECT tabid ,master
                  INTO l_tabid,
                       l_is_master
                  FROM cvc_bi_conv_lookup
                 WHERE l_chr_tablename IN (staging_tab,tablename);            
              EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                 NULL;
               WHEN OTHERS
               THEN
                    DBMS_OUTPUT.PUT_LINE (
                          ' Error inside fetch_insert_proc procedure --'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                           
                    l_out_chr_errbuf :=
                          ' Error inside fetch_insert_proc procedure --'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
                        
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - Check for l_tab_id value'
                       ,  SQLERRM
                       ,  SQLCODE
                       );
              END;           
                   
           --   DBMS_OUTPUT.PUT_LINE ('l_tabid : ' ||l_tabid);
              
              BEGIN
                SELECT fn_tab_validations
                  INTO l_chr_tab_validation
                  FROM CVC_BI_CONV_TAB_master
                WHERE id = l_num_tabid
                 AND conv_reqd = 'Y';
              EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    SELECT fn_tab_validations
                      INTO l_chr_tab_validation
                      FROM CVC_BI_CONV_TAB_DATA
                    WHERE id = l_num_tabid
                     AND conv_reqd = 'Y';       
               WHEN OTHERS               
               THEN
                    DBMS_OUTPUT.PUT_LINE (
                          ' Error fetching fn_validations for tableid --'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                           
                    l_out_chr_errbuf :=
                          ' Error fetching fn_validations for tableid--'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
 
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - Check for l_chr_tab_validation value'
                       ,  SQLERRM
                       ,  SQLCODE
                       );                
              END;
              
            --- DBMS_OUTPUT.PUT_LINE ('l_chr_tab_validation : ' ||l_chr_tab_validation);

                
 
					      
					  IF l_is_master ='Y'  
					  THEN
 
                           
                          BEGIN						   
                            SELECT unique_cond
                              INTO l_unique_cond
                              FROM cvc_bi_unique_validations
                             WHERE bi_conv_id = l_tabid;                             
						   EXCEPTION    
						   WHEN OTHERS               
						   THEN
								DBMS_OUTPUT.PUT_LINE (
									  ' Error fetching l_unique_cond for tableid --'
								   || SQLERRM
								   || '--'
								   || SQLCODE);
									   
								l_out_chr_errbuf :=
									  ' Error fetching l_unique_cond for tableid--'
								   || SQLERRM
								   || '--'
								   || SQLCODE;
			 
								log_error (
									 l_chr_err_code 
								   , l_chr_err_msg 
								   , l_chr_prc_name
								   , 'WHEN OTHERS - Check for l_unique_cond value'
								   ,  SQLERRM
								   ,  SQLCODE
								   ); 
                          END;  
                            l_newchr_sql := l_unique_cond;
                             
                            l_insert_flag := 'Y';
                            
                     ---        DBMS_OUTPUT.PUT_LINE ('First condition' || l_newchr_sql || l_tabid); 
                             
                             l_newchr_sql := l_chr_sql ||' '|| l_newchr_sql;
                             
                   ---           DBMS_OUTPUT.PUT_LINE ('  l_chr_sql in master : ' || l_chr_sql || l_chr_sql); 
                            
                     ELSIF l_is_master = 'N'
                     THEN
                     
                        l_newchr_sql := l_chr_sql;
                        l_insert_flag := 'Y';
                        
                     --     DBMS_OUTPUT.PUT_LINE ('Second condition' );                       
                     END IF;
                                     
                           -- DBMS_OUTPUT.PUT_LINE ('l_newchr_sql inside unique '||l_newchr_sql);                          
                    IF l_global_bi_doc = l_chr_tablename
                    THEN
                       l_newchr_sql := 'SELECT * FROM BIDOC_GLOB_TEMP WHERE document_content_type IS NOT NULL ';
                    END IF;

 
         BEGIN
         
         
                table_copy_str := 'DECLARE '|| CHR(10);
                table_copy_str := table_copy_str || 'TYPE t_cursor IS REF CURSOR; '|| CHR(10);        
                table_copy_str := table_copy_str || 'i t_cursor; '|| CHR(10);

                l_array_type :=  'TYPE array_data IS TABLE OF ' || l_chr_tablename || '%ROWTYPE; '|| CHR(10);
                l_chr_dml :=  ' INSERT INTO ' || l_chr_tablename ||  '  VALUES p_array_data(x);  '|| CHR(10);
                    
                
                table_copy_str := table_copy_str || l_array_type;
                table_copy_str := table_copy_str || 'p_array_data array_data; '|| CHR(10);

                table_copy_str := table_copy_str || 'BEGIN '|| CHR(10);

                table_copy_str := table_copy_str || '        OPEN i FOR ' || l_newchr_sql || ';'|| CHR(10);
                table_copy_str := table_copy_str || '        LOOP '|| CHR(10);
                table_copy_str := table_copy_str || '        FETCH i BULK COLLECT INTO p_array_data LIMIT 10000;  '|| CHR(10);
                    
                table_copy_str := table_copy_str || '        FORALL x IN 1..p_array_data.COUNT  '|| CHR(10);
                    
                table_copy_str := table_copy_str ||             l_chr_dml|| CHR(10);        
                table_copy_str := table_copy_str || '            COMMIT; '|| CHR(10);   
                
                table_copy_str := table_copy_str || '            EXIT WHEN i%NOTFOUND; '|| CHR(10);
                table_copy_str := table_copy_str || '        END LOOP; '|| CHR(10);

                table_copy_str := table_copy_str || '        COMMIT; '|| CHR(10);
                table_copy_str := table_copy_str || '        CLOSE i; '|| CHR(10);
                table_copy_str := table_copy_str || 'END; ';
                
                -- DBMS_OUTPUT.PUT_LINE (table_copy_str);

                 
                EXECUTE IMMEDIATE table_copy_str;
                
                table_copy_str := null;
                
                  
        EXCEPTION
          WHEN OTHERS
          THEN
           NULL;
        END;
        
               --to track data flow
                log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'Data inserted into BIQ table for : '
               , NULL
               , l_global_params
                );      
                
        BEGIN        
          ins_opp_num();  
        EXCEPTION
          WHEN OTHERS
          THEN
                DBMS_OUTPUT.PUT_LINE (
                      ' Error while CALLING ins_opp_num --'
                   || SQLERRM
                   || '--'
                   || SQLCODE);
                       
                l_out_chr_errbuf :=
                      '  Error while CALLING ins_opp_num --'
                   || SQLERRM
                   || '--'
                   || SQLCODE;
                l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
                    
                log_error (
                     l_chr_err_code 
                   , l_chr_err_msg 
                   , l_chr_prc_name
                   , 'WHEN OTHERS - Error while CALLING ins_opp_num '
                   ,  SQLERRM
                   ,  SQLCODE
                   );
        END;
                      
	      /*  BEGIN			 
				INSERT INTO bi_request_opportunity(request_id,opportunity_id)	
				WITH DATA AS
					( SELECT  (select  distinct bi_request_id from bi_cvc_Agenda where cvc_RequesT_id =627626 and bi_request_id not in (select request_id from bi_Request_opportunity)) id,opp_number FROM cvc_request@dblink_to_cvc_new where id = 627626
					)
				  SELECT  (select  distinct bi_request_id from bi_cvc_Agenda where cvc_RequesT_id =627626 ),trim(COLUMN_VALUE) opp_number
				   FROM DATA, xmltable(('"' || REPLACE(opp_number, '&', '","') || '"'))
				   WHERE id not in (select request_id from bi_Request_opportunity);
							 EXCEPTION
			  WHEN OTHERS
			  THEN
				DBMS_OUTPUT.PUT_LINE ('Error INSERTING bi_request_opportunity FOR 627626  : ' ||SQLERRM);
			END;	*/			  
    
	  IF  l_global_bi_lookup = l_chr_tablename
 	  THEN
         
        DBMS_OUTPUT.PUT_LINE ('l_num_lookup_exists : ' || l_num_lookup_exists);

	       update_biq_lookup();
              --to track data flow
              log_error (
                 l_chr_err_code 
               , l_chr_err_msg
               , l_chr_prc_name
               , 'Calling update_biq_lookup for lookup customizations '
               ,  NULL
               ,  l_global_params
               );   
	     END IF;
 
                                   
        
       IF l_is_master ='Y' 
       THEN 
           BEGIN
            UPDATE cvc_bi_conv_tab_master 
               SET process_flag = 'Y',               
                   trunc_table = NULL,
                   last_processed_at = CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT'
               WHERE bi_conv_id IN (SELECT tabid FROM cvc_bi_conv_lookup  WHERE TABLENAME = l_chr_tablename)
                  AND conv_reqd = 'Y';
           EXCEPTION
            WHEN OTHERS
             THEN
                DBMS_OUTPUT.PUT_LINE (
                      ' Error while updating processflag to Y in cvc_bi_conv_tab_master table --'
                   || SQLERRM
                   || '--'
                   || SQLCODE);
                       
                l_out_chr_errbuf :=
                      ' Error while updating  processflag to Y in cvc_bi_conv_tab_master table --'
                   || SQLERRM
                   || '--'
                   || SQLCODE;
                l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
                    
                log_error (
                     l_chr_err_code 
                   , l_chr_err_msg 
                   , l_chr_prc_name
                   , 'WHEN OTHERS - while updating  processflag to Y '
                   ,  SQLERRM
                   ,  SQLCODE
                   );        
           END;      
      ELSE 
           BEGIN
            UPDATE cvc_bi_conv_tab_data 
               SET process_flag = 'Y',               
                   trunc_table = NULL,
                   last_processed_at = CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT'
               WHERE bi_conv_id IN (SELECT tabid FROM cvc_bi_conv_lookup  WHERE TABLENAME = l_chr_tablename)
                 AND conv_reqd = 'Y';
           EXCEPTION
            WHEN OTHERS
             THEN
                DBMS_OUTPUT.PUT_LINE (
                      ' Error while updating processflag to Y in cvc_bi_conv_tab_data table --'
                   || SQLERRM
                   || '--'
                   || SQLCODE);
                       
                l_out_chr_errbuf :=
                      ' Error while updating  processflag to Y in cvc_bi_conv_tab_data table --'
                   || SQLERRM
                   || '--'
                   || SQLCODE;
                l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';
                    
                log_error (
                     l_chr_err_code 
                   , l_chr_err_msg 
                   , l_chr_prc_name
                   , 'WHEN OTHERS - while updating  processflag to Y '
                   ,  SQLERRM
                   ,  SQLCODE
                   );        
           END;           
     END IF;
        

     COMMIT;
        
     EXCEPTION
       WHEN OTHERS
       THEN
            DBMS_OUTPUT.PUT_LINE (
                  ' Error inside fetch_insert_proc procedure --'
               || SQLERRM
               || '--'
               || SQLCODE);
                       
            l_out_chr_errbuf :=
                  ' Error inside fetch_insert_proc procedure --'
               || SQLERRM
               || '--'
               || SQLCODE;
                    
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg 
               , l_chr_prc_name
               , 'WHEN OTHERS - While copying into table_copy_str'
               ,  SQLERRM
               ,  SQLCODE
               );       
     END;
     
  PROCEDURE truncate_tables
  ( in_chr_tablename VARCHAR2  ) 
  
  IS    
  
  l_chr_err_code  VARCHAR2 (255);
  l_chr_err_msg   VARCHAR2 (255);  
  l_out_chr_errbuf  VARCHAR2 (2000);
  l_child_tabid VARCHAR2 (55);
  ddl_str_bi_tab LONG;
  l_del_tab varchar2(255);
  l_count NUMBER;
  l_chr_prc_name  VARCHAR2 (2000) := 'truncate_tables';
 

  BEGIN
   
      BEGIN
        SELECT 1 
         INTO l_count
        FROM DUAL WHERE in_chr_tablename IN (SELECT DISTINCT tabname
                                                FROM cvc_bi_conv_params
                                                WHERE condition = 'NO_TRUNC');

      EXCEPTION
        WHEN NO_DATA_FOUND 
        THEN
         l_count:=0;
      END;
          
      IF l_count =1 
      THEN
         
          l_del_tab := 'DELETE FROM '|| in_chr_tablename;
          
          DBMS_OUTPUT.PUT_LINE ('EXECUTE IMMEDIATE l_del_tab');
          
          EXECUTE IMMEDIATE l_del_tab;
           
      ELSIF l_count =0
      THEN
          
         DBMS_OUTPUT.PUT_LINE ('Before truncating ' || in_chr_tablename);     
     
         ddl_str_bi_tab    := 'TRUNCATE TABLE ' || in_chr_tablename || '';
         
         DBMS_OUTPUT.PUT_LINE ('EXECUTE IMMEDIATE ddl_str_bi_tab');  
         
         EXECUTE IMMEDIATE ddl_str_bi_tab;
            
      END IF;
          
   EXCEPTION
       WHEN OTHERS
       THEN
            DBMS_OUTPUT.PUT_LINE (
                  ' Error inside truncate_tables procedure --'
               || SQLERRM
               || '--'
               || SQLCODE);
                       
            l_out_chr_errbuf :=
                  ' Error inside truncate_tables procedure --'
               || SQLERRM
               || '--'
               || SQLCODE;
                    
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg 
               , l_chr_prc_name
               , 'WHEN OTHERS - While truncating master and child tables'
               ,  SQLERRM
               ,  SQLCODE
               );  
     
   END;  

PROCEDURE insert_user
IS

   l_out_chr_errbuf  VARCHAR2 (2000);
   l_chr_err_code  VARCHAR2 (2000);
   l_chr_err_msg  VARCHAR2 (2000);
   l_chr_prc_name  VARCHAR2 (2000) := 'insert_user';
   l_num_ten_acct NUMBER;
   l_num_ten_acct_user NUMBER;
   l_role_count NUMBER;
   l_user_count NUMBER;
   l_id NUMBER;
   l_loc_id NUMBER;
   
 CURSOR c_req_user
 IS
 SELECT distinct REPLACE(replace(lower(host_name),chr(9),' '),' ','')  host_name ,REPLACE (INITCAP (replace(lower(host_name),'@briefingiq.com',' ')),'.',' ') full_name
 FROM cvc_request@dblink_to_cvc_new b
WHERE id =  l_global_reqid
AND lower(host_name) not in(select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.host_name)) 
 UNION
SELECT distinct REPLACE(replace(lower(host_name),chr(9),' '),' ','')  host_name ,REPLACE (INITCAP (replace(lower(host_name),'@briefingiq.com',' ')),'.',' ') full_name
 FROM cvc_request@dblink_to_cvc_new b
WHERE start_Date BETWEEN  l_global_st_date AND  l_global_end_date  
  AND location_id = 96--80
--  AND status_id  = DECODE(upper(l_global_status),'CONFIRMED',14,status_id) 
 -- AND UPPER(ac_id) = UPPER(l_global_bm_email) 
  AND lower(host_name) not in(select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.host_name)) ;
  
CURSOR c_requestor
IS
SELECT DISTINCT REPLACE(replace(lower(requestor_id),chr(9),' '),' ','') requestor_id ,REPLACE (INITCAP (replace(lower(requestor_id),'@briefingiq.com',' ')),'.',' ') full_name
 FROM cvc_request@dblink_to_cvc_new b
WHERE id =  l_global_reqid
AND lower(requestor_id) not in(select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.requestor_id)) 
 UNION
SELECT DISTINCT REPLACE(replace(lower(requestor_id),chr(9),' '),' ','') requestor_id ,REPLACE (INITCAP (replace(lower(requestor_id),'@briefingiq.com',' ')),'.',' ') full_name
 FROM cvc_request@dblink_to_cvc_new b
WHERE start_Date BETWEEN  l_global_st_date AND   l_global_end_date   
  AND location_id = 96--80
 -- AND status_id  = DECODE(upper(l_global_status),'CONFIRMED',14,status_id)    
--  AND UPPER(ac_id) = UPPER(l_global_bm_email)
  AND lower(requestor_id) not in(select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.requestor_id)) ;  
  
 CURSOR c_req_bm
 IS
SELECT DISTINCT REPLACE(REPLACE(LOWER(ac_id),chr(9),' '),' ','') ac_id ,
       REPLACE (INITCAP (replace(lower(ac_id),'@briefingiq.com',' ')),'.',' ') full_name
  FROM cvc_request@dblink_to_cvc_new b
WHERE id =  l_global_reqid
-- AND lower(ac_id) not in(select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.ac_id)) 
 AND ac_id IS NOT NULL
 UNION
SELECT DISTINCT REPLACE(REPLACE(LOWER(ac_id),chr(9),' '),' ','') ac_id ,
       REPLACE (INITCAP (replace(lower(ac_id),'@briefingiq.com',' ')),'.',' ') full_name
  FROM cvc_request@dblink_to_cvc_new b
WHERE start_Date BETWEEN  l_global_st_date AND  l_global_end_date     
  AND location_id = 96--80
 -- AND status_id  = DECODE(upper(l_global_status),'CONFIRMED',14,status_id)    
 -- AND UPPER(ac_id) = UPPER(l_global_bm_email)
 -- AND lower(ac_id) not in(select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.ac_id))
  AND ac_id IS NOT NULL	 ;
 
 CURSOR c_ins_bm_locuser(usrname VARCHAR2)
 IS
SELECT DISTINCT id
 FROM bi_user
WHERE user_name = usrname;
 
 CURSOR c_set_color
 IS
 SELECT color ,lower(user_id ) user_id FROM cvc_user_role@dblink_to_cvc_new
 WHERE lower(user_id ) IN (SELECT user_name FROM bi_user)
 AND color is not NULL;

   
    BEGIN
    
 			   
			   
            DBMS_OUTPUT.PUT_LINE ('INSIDE insert user' || l_global_st_date);
            DBMS_OUTPUT.PUT_LINE ('l_global_end_date' || l_global_end_date);
            DBMS_OUTPUT.PUT_LINE ('l_global_params : ' || l_global_params);
			
		 FOR rec_c_req_bm IN c_req_bm
		 LOOP
		      
		   -- DBMS_OUTPUT.PUT_LINE ('rec_c_req_bm.ac_id : ' || rec_c_req_bm.ac_id);
		 
			  SELECT COUNT(1)
			   INTO l_user_count
			   FROM bi_user
			  WHERE user_name = rec_c_req_bm.ac_id ;
			  
			 --  DBMS_OUTPUT.PUT_LINE ('l_user_count' || l_user_count);
			  
			  IF l_user_count =0   -- no user existing then create one 
			  THEN
			  
		        ---  DBMS_OUTPUT.PUT_LINE ('l_user_count is null'); 
  
					BEGIN
					  
					   INSERT INTO bi_user (id,first_name,last_name,user_name,created_ts,created_by,updated_ts,updated_by,unique_id,version) 
						  VALUES(
						  bi_user_seq.nextval,
						  substr(rec_c_req_bm.full_name,1, instr(rec_c_req_bm.full_name,' ')),
						  substr(rec_c_req_bm.full_name, instr(rec_c_req_bm.full_name, ' '), instr(rec_c_req_bm.full_name, ' ', 1, 2)-instr(rec_c_req_bm.full_name, ' ')),
						  REPLACE(REPLACE(LOWER(rec_c_req_bm.ac_id),chr(9),' '),' ','') ,
						  CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
						  'cvcinfo_us@oracle.com',
						  CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
						  'cvcinfo_us@oracle.com',
						  regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
						  1);
							 
					   EXCEPTION
						   WHEN OTHERS
						   THEN
								DBMS_OUTPUT.PUT_LINE (
									  ' Error inside inserting request related users --'
								   || SQLERRM
								   || '--'
								   || SQLCODE);
										   
								l_out_chr_errbuf :=
									  ' Error inside inserting request related users --'
								   || SQLERRM
								   || '--'
								   || SQLCODE;
										
								log_error (
									 l_chr_err_code 
								   , l_chr_err_msg 
								   , l_chr_prc_name
								   , 'WHEN OTHERS - While inserting request related users'
								   ,  SQLERRM
								   ,  SQLCODE
								   );              
					  END;
					   
					  BEGIN           
						   INSERT INTO bi_user_role(user_id,role_id)     
							SELECT DISTINCT (SELECT id FROM bi_user WHERE user_name = lower(ac_id) ),2  
							  FROM cvc_request@dblink_to_cvc_new b
							 WHERE id =   l_global_reqid
							  AND lower(ac_id) in(select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.ac_id)) 
							  AND (SELECT id||2  FROM bi_user WHERE user_name = lower(ac_id) ) NOT IN (select user_id||2 from bi_user_role)
							UNION  
							SELECT DISTINCT (SELECT id FROM bi_user WHERE user_name = lower(ac_id) ),2  
							  FROM cvc_request@dblink_to_cvc_new b
							 WHERE start_Date BETWEEN  l_global_st_date AND  l_global_end_date     
							   AND location_id = 96--80
							 --  AND status_id  = DECODE(upper(l_global_status),'CONFIRMED',14,status_id)    	
							--   AND UPPER(ac_id) = UPPER(l_global_bm_email)			 
							   AND lower(ac_id)  in (select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.ac_id)) 
							   AND (SELECT id||2  FROM bi_user WHERE user_name = lower(ac_id) ) NOT IN (select user_id||2 from bi_user_role);
					   EXCEPTION
						   WHEN OTHERS
						   THEN
								DBMS_OUTPUT.PUT_LINE (
									  ' Error inside inserting request related BM --'
								   || SQLERRM
								   || '--'
								   || SQLCODE);
										   
								l_out_chr_errbuf :=
									  ' Error inside inserting request related BM --'
								   || SQLERRM
								   || '--'
								   || SQLCODE;
										
								log_error (
									 l_chr_err_code 
								   , l_chr_err_msg 
								   , l_chr_prc_name
								   , 'WHEN OTHERS - While inserting request related BM'
								   ,  SQLERRM
								   ,  SQLCODE
								   );              
					  END; 					  
					   
					   
		        ELSE  -- user already there , check for the role.
				
					 SELECT COUNT(1)
					  INTO l_role_count
					  FROM bi_user_role
					  WHERE user_id IN (SELECT id FROM bi_user WHERE user_name = rec_c_req_bm.ac_id );
                     
					-- DBMS_OUTPUT.PUT_LINE ('l_role_count is not null'); 
					 
					  IF l_role_count IS NULL -- if role is null then insert as 2
					  THEN
					       -- DBMS_OUTPUT.PUT_LINE ('l_role_count is   null'); 
					  
						  BEGIN           
							   INSERT INTO bi_user_role(user_id,role_id)     
								SELECT DISTINCT (SELECT id FROM bi_user WHERE user_name = lower(ac_id) ),2  
								  FROM cvc_request@dblink_to_cvc_new b
								 WHERE id =   l_global_reqid
								  AND lower(ac_id) in(select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.ac_id)) 
								  AND (SELECT id||2  FROM bi_user WHERE user_name = lower(ac_id) ) NOT IN (select user_id||2 from bi_user_role)
								UNION  
								SELECT DISTINCT (SELECT id FROM bi_user WHERE user_name = lower(ac_id) ),2  
								  FROM cvc_request@dblink_to_cvc_new b
								 WHERE start_Date BETWEEN  l_global_st_date AND  l_global_end_date     
								   AND location_id = 96--80
								 --  AND status_id  = DECODE(upper(l_global_status),'CONFIRMED',14,status_id)    	
								--   AND UPPER(ac_id) = UPPER(l_global_bm_email)			 
								   AND lower(ac_id)  in (select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.ac_id)) 
								   AND (SELECT id||2  FROM bi_user WHERE user_name = lower(ac_id) ) NOT IN (select user_id||2 from bi_user_role);
						   EXCEPTION
							   WHEN OTHERS
							   THEN
									DBMS_OUTPUT.PUT_LINE (
										  ' Error inside inserting request related BM --'
									   || SQLERRM
									   || '--'
									   || SQLCODE);
											   
									l_out_chr_errbuf :=
										  ' Error inside inserting request related BM --'
									   || SQLERRM
									   || '--'
									   || SQLCODE;
											
									log_error (
										 l_chr_err_code 
									   , l_chr_err_msg 
									   , l_chr_prc_name
									   , 'WHEN OTHERS - While inserting request related BM'
									   ,  SQLERRM
									   ,  SQLCODE
									   );              
						  END; 					  
					  
					  ELSE 
					  
					     --- DBMS_OUTPUT.PUT_LINE ('l_role_id is NOT 2'); 
					       
						   BEGIN
            
							   UPDATE bi_user_role               
								   SET role_id = 2
							     WHERE user_id IN (SELECT id FROM bi_user WHERE user_name = rec_c_req_bm.ac_id );
							   EXCEPTION
								   WHEN OTHERS
								   THEN
										DBMS_OUTPUT.PUT_LINE (
											  ' Error inside updating ac_id  users --'
										   || SQLERRM
										   || '--'
										   || SQLCODE);
												   
										l_out_chr_errbuf :=
											  ' Error inside updating ac_id  users --'
										   || SQLERRM
										   || '--'
										   || SQLCODE;
												
										log_error (
											 l_chr_err_code 
										   , l_chr_err_msg 
										   , l_chr_prc_name
										   , 'WHEN OTHERS - While updating ac_id  users'
										   ,  SQLERRM
										   ,  SQLCODE
										   );              
							  END;   
							  
					  END IF;
					 
               END IF;				
			   
			--   DBMS_OUTPUT.PUT_LINE ('rec_c_req_bm.ac_id  : '|| rec_c_req_bm.ac_id);
			   
			   FOR rec_ins_bm_locuser IN c_ins_bm_locuser(rec_c_req_bm.ac_id)
			   LOOP 
 				       
					l_id := rec_ins_bm_locuser.id;
					---DBMS_OUTPUT.PUT_LINE ('l_id is  : '|| l_id);
						
					   
					   SELECT DISTINCT count(1)
					     INTO l_loc_id
					     FROM BI_LOCATION_USER
					     WHERE user_id = l_id
						   AND role_id = 2;
						   
						-- DBMS_OUTPUT.PUT_LINE ('l_loc_id is  : '|| l_loc_id);   
						   
						IF l_loc_id = 1
						THEN
						  DBMS_OUTPUT.PUT_LINE ('l_loc_id count is  : '|| l_loc_id);
						ELSE
						
							   BEGIN
									
									INSERT INTO BI_LOCATION_USER  (id,unique_id,location_id,user_id,role_id,created_by,created_ts,updated_by,updated_ts,is_Active,version)
									SELECT BI_LOCATION_USER_SEQ.NEXTVAL,
										   regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
										   (select id from bi_location where name  = '-Redwood Shores - HQ' ) location_id,
										   l_id,
										   2,
										   'cx_cvc',
											CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
										   'cx_cvc',CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
										   1,
										   0 FROM DUAL;

										  
							   EXCEPTION
								   WHEN OTHERS
								   THEN
										DBMS_OUTPUT.PUT_LINE (
											  ' Error inside inserting request related BM --'
										   || SQLERRM
										   || '--'
										   || SQLCODE);
												   
										l_out_chr_errbuf :=
											  ' Error inside inserting request related BM  --'
										   || SQLERRM
										   || '--'
										   || SQLCODE;
												
										log_error (
											 l_chr_err_code 
										   , l_chr_err_msg 
										   , l_chr_prc_name
										   , 'WHEN OTHERS - While inserting request related BM'
										   ,  SQLERRM
										   ,  SQLCODE
										   );   
							   END;   
							   
						END IF;
							 
						

			    END LOOP;
			   
		   
		   END LOOP;    			
         
		 FOR rec_c_req_user IN c_req_user
		 LOOP
		   
  
			  BEGIN
			  
			   INSERT INTO bi_user (id,first_name,last_name,user_name,created_ts,created_by,updated_ts,updated_by,unique_id,version) 
				  VALUES(
				  bi_user_seq.nextval,
				  substr(rec_c_req_user.full_name,1, instr(rec_c_req_user.full_name,' ')),
				  substr(rec_c_req_user.full_name, instr(rec_c_req_user.full_name, ' '), instr(rec_c_req_user.full_name, ' ', 1, 2)-instr(rec_c_req_user.full_name, ' ')),
				  REPLACE(REPLACE(LOWER(rec_c_req_user.host_name),chr(9),' '),' ','') ,
				  CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
				  'cvcinfo_us@oracle.com',
				  CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
				  'cvcinfo_us@oracle.com',
				  regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
				  1);
					 
			   EXCEPTION
				   WHEN OTHERS
				   THEN
						DBMS_OUTPUT.PUT_LINE (
							  ' Error inside inserting request related users --'
						   || SQLERRM
						   || '--'
						   || SQLCODE);
								   
						l_out_chr_errbuf :=
							  ' Error inside inserting request related users --'
						   || SQLERRM
						   || '--'
						   || SQLCODE;
								
						log_error (
							 l_chr_err_code 
						   , l_chr_err_msg 
						   , l_chr_prc_name
						   , 'WHEN OTHERS - While inserting request related users'
						   ,  SQLERRM
						   ,  SQLCODE
						   );              
			   END;
		   
		 END LOOP;

		 FOR rec_requestor IN c_requestor
		 LOOP		   
  
			  BEGIN
			  
			   INSERT INTO bi_user (id,first_name,last_name,user_name,created_ts,created_by,updated_ts,updated_by,unique_id,version) 
				  VALUES(
				  bi_user_seq.nextval,
				  substr(rec_requestor.full_name,1, instr(rec_requestor.full_name,' ')),
				  substr(rec_requestor.full_name, instr(rec_requestor.full_name, ' '), instr(rec_requestor.full_name, ' ', 1, 2)-instr(rec_requestor.full_name, ' ')),
				  REPLACE(REPLACE(LOWER(rec_requestor.requestor_id),chr(9),' '),' ','') , 
				  CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
				  'cvcinfo_us@oracle.com',
				  CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
				  'cvcinfo_us@oracle.com',
				  regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
				  1);
					 
			   EXCEPTION
				   WHEN OTHERS
				   THEN
						DBMS_OUTPUT.PUT_LINE (
							  ' Error inside inserting request related users --'
						   || SQLERRM
						   || '--'
						   || SQLCODE);
								   
						l_out_chr_errbuf :=
							  ' Error inside inserting request related users --'
						   || SQLERRM
						   || '--'
						   || SQLCODE;
								
						log_error (
							 l_chr_err_code 
						   , l_chr_err_msg 
						   , l_chr_prc_name
						   , 'WHEN OTHERS - While inserting request related users'
						   ,  SQLERRM
						   ,  SQLCODE
						   );              
			   END;
		   
		 END LOOP;		 
		   
          
          --to track data flow
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg 
               , l_chr_prc_name
               , 'Inserting the request related users,updating BM and tenant account users'
               ,  NULL
               ,  l_global_params
               );                    
 
            

          --to track data flow
            log_error (
                 l_chr_err_code 
               , l_chr_err_msg 
               , l_chr_prc_name
               , 'Inserting the request related users and BM into bi_user_role table'
               ,  NULL
               ,  l_global_params
               );     
                                          
           

		   -------To update the Briefingmanager ids in bi_user_role and bi_location_user------
		   
		       BEGIN
          
                INSERT INTO BI_USER_CONTACT (user_id,value,contact_type) 
					   SELECT DISTINCT id  ,
					            user_name,
					            'email'  
					       FROM BI_USER a
					      WHERE id NOT IN (SELECT b.user_id FROM BI_USER_CONTACT b WHERE b.user_id = a.id AND contact_type ='email')  ;
			   EXCEPTION
				   WHEN OTHERS
				   THEN
						DBMS_OUTPUT.PUT_LINE (
							  ' Error inserting into BI_USER_CONTACT--'
						   || SQLERRM
						   || '--'
						   || SQLCODE);
								   
						l_out_chr_errbuf :=
							  ' Error inserting into BI_USER_CONTACT--'
						   || SQLERRM
						   || '--'
						   || SQLCODE;
								
						log_error (
							 l_chr_err_code 
						   , l_chr_err_msg 
						   , l_chr_prc_name
						   , 'WHEN OTHERS - Error inserting into BI_USER_CONTACT'
						   ,  SQLERRM
						   ,  SQLCODE
						   );              
			   END;    

           BEGIN
            
             UPDATE bi_user_role               
               SET role_id = 2
			   WHERE user_id in (SELECT distinct id  from bi_user where user_name in (select lower(email) FROM cvc_briefing_mgr_info@dblink_to_cvc_new));
           EXCEPTION
               WHEN OTHERS
               THEN
                    DBMS_OUTPUT.PUT_LINE (
                          ' Error inside updating BM related users --'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                               
                    l_out_chr_errbuf :=
                          ' Error inside updating BM related users --'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
                            
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - While updating BM related users'
                       ,  SQLERRM
                       ,  SQLCODE
                       );              
          END;   		   
           
           BEGIN 
             
			  UPDATE bi_location_user
			    SET role_id = 2
				WHERE user_id in (SELECT distinct id  from bi_user where user_name in (select lower(email) FROM cvc_briefing_mgr_info@dblink_to_cvc_new))
				  AND location_id in (SELECT id FROM bi_location where name ='-Redwood Shores - HQ');
         	  
           EXCEPTION
               WHEN OTHERS
               THEN
                    DBMS_OUTPUT.PUT_LINE (
                          ' Error inside updating BM into BI_LOCATION_USER--'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                               
                    l_out_chr_errbuf :=
                          '  Error inside updating BM into BI_LOCATION_USER--'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
                            
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - While updating BM into BI_LOCATION_USER'
                       ,  SQLERRM
                       ,  SQLCODE
                       );   
           END;      
           
		   -------To update the tenant account ids in bi_user_role and bi_location_user------
		   
           BEGIN
            
             UPDATE bi_user_role               
               SET role_id = 2
			   WHERE user_id in (SELECT distinct id  from bi_user where user_name in (select lower(briefing_manager_id) FROM cvc_customer@dblink_to_cvc_new));
           EXCEPTION
               WHEN OTHERS
               THEN
                    DBMS_OUTPUT.PUT_LINE (
                          ' Error inside updating tenant accts bi_user_role--'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                               
                    l_out_chr_errbuf :=
                          ' Error inside updating tenant accts bi_user_role --'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
                            
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - While updating tenant accts bi_user_role'
                       ,  SQLERRM
                       ,  SQLCODE
                       );              
          END;   

              
		   BEGIN                           
			 UPDATE bi_location_user   
			 SET role_id = 2
			 WHERE user_id IN
			   (SELECT id 
			     FROM bi_user  a
			    WHERE a.user_name in (select lower(briefing_manager_id) FROM cvc_customer@dblink_to_cvc_new)) ;                     
		   EXCEPTION
			   WHEN OTHERS
			   THEN
					DBMS_OUTPUT.PUT_LINE (
						  ' Error inside updating tenant accts bi_location_user --'
					   || SQLERRM
					   || '--'
					   || SQLCODE);
							   
					l_out_chr_errbuf :=
						  '  Error inside updating tenant accts bi_location_user --'
					   || SQLERRM
					   || '--'
					   || SQLCODE;
							
					log_error (
						 l_chr_err_code 
					   , l_chr_err_msg 
					   , l_chr_prc_name
					   , 'WHEN OTHERS - Error inside updating tenant accts bi_location_user --'
					   ,  SQLERRM
					   ,  SQLCODE
					   );   
		   END;          
		    

          BEGIN           
               INSERT INTO bi_user_role(user_id,role_id)     
                SELECT DISTINCT (SELECT id FROM bi_user WHERE user_name = lower(ac_id) ),2  
                  FROM cvc_request@dblink_to_cvc_new b
                 WHERE id =   l_global_reqid
                  AND lower(ac_id) in(select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.ac_id)) 
                  AND (SELECT id||2  FROM bi_user WHERE user_name = lower(ac_id) ) NOT IN (select user_id||2 from bi_user_role)
                UNION  
                SELECT DISTINCT (SELECT id FROM bi_user WHERE user_name = lower(ac_id) ),2  
                  FROM cvc_request@dblink_to_cvc_new b
                 WHERE start_Date BETWEEN  l_global_st_date AND  l_global_end_date     
				   AND location_id = 96--80
				 --  AND status_id  = DECODE(upper(l_global_status),'CONFIRMED',14,status_id)    	
				--   AND UPPER(ac_id) = UPPER(l_global_bm_email)			 
                   AND lower(ac_id)  in (select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.ac_id)) 
                   AND (SELECT id||2  FROM bi_user WHERE user_name = lower(ac_id) ) NOT IN (select user_id||2 from bi_user_role);
           EXCEPTION
               WHEN OTHERS
               THEN
                    DBMS_OUTPUT.PUT_LINE (
                          ' Error inside inserting request related BM --'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                               
                    l_out_chr_errbuf :=
                          ' Error inside inserting request related BM --'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
                            
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - While inserting request related BM'
                       ,  SQLERRM
                       ,  SQLCODE
                       );              
          END; 		  
		  
		  BEGIN           
                INSERT INTO bi_user_role(user_id,role_id)                    
                SELECT (SELECT id FROM bi_user WHERE user_name = lower(host_name) ),4  
                  FROM cvc_request@dblink_to_cvc_new b
                 WHERE id =  l_global_reqid
                  AND lower(host_name) in(select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.host_name)) 
                  AND (SELECT id||4 FROM bi_user WHERE user_name = lower(host_name) ) NOT in (select user_id||4 from bi_user_role)
				  AND (SELECT id||2 FROM bi_user WHERE user_name = lower(host_name) ) NOT in (select user_id||2 from bi_user_role)
                UNION  
                SELECT (SELECT id FROM bi_user WHERE user_name = lower(host_name) ),4  
                  FROM cvc_request@dblink_to_cvc_new b
                 WHERE start_Date BETWEEN  l_global_st_date AND  l_global_end_date   
				   AND location_id =  96--80
				--   AND status_id  = DECODE(upper(l_global_status),'CONFIRMED',14,status_id)    	
			    --	 AND UPPER(ac_id) = UPPER(l_global_bm_email)			 
                   AND lower(host_name)  in (select lower(user_name) FROM bi_user a where lower(a.user_name)= lower(b.host_name)) 
                   AND (SELECT id||4  FROM bi_user WHERE user_name = lower(host_name) ) NOT in (select user_id||4  from bi_user_role)
				   AND (SELECT id||2 FROM bi_user WHERE user_name = lower(host_name) ) NOT in (select user_id||2 from bi_user_role);
           EXCEPTION
               WHEN OTHERS
               THEN
                    DBMS_OUTPUT.PUT_LINE (
                          ' Error inside inserting request related users --'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                               
                    l_out_chr_errbuf :=
                          ' Error inside inserting request related users --'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
                            
                    log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_prc_name
                       , 'WHEN OTHERS - While inserting request related users'
                       ,  SQLERRM
                       ,  SQLCODE
                       );              
          END;  
          
  
        FOR rec_c_set_color IN c_set_color
        LOOP
          UPDATE bi_user
            SET color_code = rec_c_set_color.color
			    ,first_name = REPLACE(REPLACE( first_name ,chr(9),' '),' ','')
				,last_name  = REPLACE(REPLACE( last_name ,chr(9),' '),' ','')
          WHERE user_name = rec_c_set_color.user_id;
        
        END LOOP;  
		  
        BEGIN
           UPDATE bi_user
             SET color_code = '#c4c2c2'
			    ,first_name = REPLACE(REPLACE( first_name ,chr(9),' '),' ','')
				,last_name  = REPLACE(REPLACE( last_name ,chr(9),' '),' ','')			 
           WHERE color_code IS NULL;
        EXCEPTION
          WHEN OTHERS
          THEN
           NULL;   
        END;
 END;
     
PROCEDURE update_biq_lookup
IS

   l_out_chr_errbuf  VARCHAR2 (2000);
   l_chr_err_code  VARCHAR2 (2000);
   l_chr_err_msg  VARCHAR2 (2000);
   l_chr_exists    VARCHAR2 (20);
   l_topic_id   NUMBER;
   l_count_arr NUMBER;
   l_count_adj  NUMBER;
   l_chr_prc_name  VARCHAR2 (2000) := 'update_biq_lookup';
  
CURSOR c1 
IS
SELECT tabname,param_name,condition,secondtab 
FROM cvc_bi_conv_params
WHERE tabname = 'BI_LOOKUP_TYPE'
AND secondtab = 'CVC_LOOKUP_VALUES'; 
 
BEGIN


SELECT DISTINCT COUNT(1) 
 INTO l_chr_exists
FROM BI_LOOKUP_VALUE
WHERE code ='DEAL_FINAL';
 
     
IF l_chr_exists = 0 
THEN

 DBMS_OUTPUT.PUT_LINE ('executing ');

    FOR rec_c1 IN c1
    LOOP
     
          BEGIN
            UPDATE bi_lookup_type
            SET code = rec_c1.condition,
                 name = rec_c1.condition,
                 description = REPLACE(INITCAP(lower(rec_c1.condition)),'_',' ') 
            WHERE code <> 'VISIT_TYPE' 
              AND code = rec_c1.param_name ;
          EXCEPTION
            WHEN OTHERS
             THEN
                  DBMS_OUTPUT.PUT_LINE (
                        ' Error while updating BI_LOOKUP_TYPE --'
                     || SQLERRM
                     || '--'
                     || SQLCODE);

                  l_out_chr_errbuf :=
                        ' Error while updating BI_LOOKUP_TYPE ---'
                     || SQLERRM
                     || '--'
                     || SQLCODE;
                  l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';

                   cvc_bi_conv_master.log_error (
                         l_chr_err_code 
                       , l_chr_err_msg
                       , l_chr_prc_name
                       , 'WHEN OTHERS - while updating BI_LOOKUP_TYPE -- '
                       ,  SQLERRM
                       ,  SQLCODE
                       ); 
            END;
                
          --  DBMS_OUTPUT.PUT_LINE ('rec_c1.condition: ' ||rec_c1.condition);
               
            BEGIN  
             UPDATE bi_lookup_type
                SET is_active = 1
             WHERE code = rec_c1.condition;
           ---    DBMS_OUTPUT.PUT_LINE (rec_c1.condition);
          EXCEPTION
            WHEN OTHERS
             THEN
                  DBMS_OUTPUT.PUT_LINE (
                        ' Error while updating BI_LOOKUP_TYPE --'
                     || SQLERRM
                     || '--'
                     || SQLCODE);

                  l_out_chr_errbuf :=
                        ' Error while updating BI_LOOKUP_TYPE ---'
                     || SQLERRM
                     || '--'
                     || SQLCODE;
                  l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';

                   cvc_bi_conv_master.log_error (
                         l_chr_err_code 
                       , l_chr_err_msg
                       , l_chr_prc_name
                       , 'WHEN OTHERS - while updating BI_LOOKUP_TYPE -- '
                       ,  SQLERRM
                       ,  SQLCODE
                       ); 
                END;  
                
    ---    DBMS_OUTPUT.PUT_LINE ('rec_c1.condition: ' ||rec_c1.condition);
                
        BEGIN
            UPDATE bi_lookup_value
             SET is_active = 1
              WHERE lookup_type_id
             IN (SELECT ID FROM bi_lookup_type
            WHERE name = rec_c1.condition);
          EXCEPTION
            WHEN OTHERS
             THEN
                  DBMS_OUTPUT.PUT_LINE (
                        ' Error while updating BI_LOOKUP_TYPE --'
                     || SQLERRM
                     || '--'
                     || SQLCODE);

                  l_out_chr_errbuf :=
                        ' Error while updating BI_LOOKUP_TYPE ---'
                     || SQLERRM
                     || '--'
                     || SQLCODE;
                  l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';

                   cvc_bi_conv_master.log_error (
                         l_chr_err_code 
                       , l_chr_err_msg
                       , l_chr_prc_name
                       , 'WHEN OTHERS - while updating BI_LOOKUP_TYPE -- '
                       ,  SQLERRM
                       ,  SQLCODE
                       ); 
            END;
            
            BEGIN 
            UPDATE bi_lookup_type 
            SET code = rec_c1.condition 
            WHERE code = rec_c1.param_name 
             AND code = 'VISIT_TYPE';
          EXCEPTION
            WHEN OTHERS
             THEN
                  DBMS_OUTPUT.PUT_LINE (
                        ' Error while updating BI_LOOKUP_TYPE --'
                     || SQLERRM
                     || '--'
                     || SQLCODE);

                  l_out_chr_errbuf :=
                        ' Error while updating BI_LOOKUP_TYPE ---'
                     || SQLERRM
                     || '--'
                     || SQLCODE;
                  l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';

                   cvc_bi_conv_master.log_error (
                         l_chr_err_code 
                       , l_chr_err_msg
                       , l_chr_prc_name
                       , 'WHEN OTHERS - while updating BI_LOOKUP_TYPE -- '
                       ,  SQLERRM
                       ,  SQLCODE
                       ); 
             END;	  
                     
      END LOOP;
      
       
        
     BEGIN      
	 
       INSERT INTO bi_lookup_type
           (id,code,name,description,created_by,created_ts,updated_by,updated_ts,is_active,unique_id,version) 
          Values
           (BI_LOOKUP_TYPE_SEQ.NEXTVAL, 'DEAL_STATUS', 'DEAL_STATUS', 'Deal Status', 'CX_CVC',CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT','CX_CVC',
           CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',1,regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),0); 

        INSERT INTO BI_LOOKUP_VALUE
           (ID, UNIQUE_ID, CODE, VALUE, IS_ACTIVE, 
            LOOKUP_TYPE_ID, CREATED_BY, UPDATED_BY, VERSION, CREATED_TS, 
            UPDATED_TS, ACTIVE_TO)
         Values
           (bi_lookup_value_seq.nextval,regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'), 'DEAL_FINAL', 'Deal Finalized', '1', 
            (SELECT DISTINCT id FROM bi_lookup_type WHERE code ='DEAL_STATUS'), 'cx_cvc@oracle.com', 'cx_cvc@oracle.com', 1,
             CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT', 
            CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
            CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT' + 360);
            
        INSERT INTO BI_LOOKUP_VALUE
           (ID, UNIQUE_ID, CODE, VALUE, IS_ACTIVE, 
            LOOKUP_TYPE_ID, CREATED_BY, UPDATED_BY, VERSION, CREATED_TS, 
            UPDATED_TS, ACTIVE_TO)
         Values
           (bi_lookup_value_seq.nextval,regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'), 'FIN_TALKS_IN_PROGRESS', 'Finance Talks in Progress', '1', 
              (SELECT DISTINCT id FROM bi_lookup_type WHERE code ='DEAL_STATUS'), 'cx_cvc@oracle.com', 'cx_cvc@oracle.com', 1,
               CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT', 
            CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
            CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT' + 360);
            
        INSERT INTO BI_LOOKUP_VALUE
           (ID, UNIQUE_ID, CODE, VALUE, IS_ACTIVE, 
            LOOKUP_TYPE_ID, CREATED_BY, UPDATED_BY, VERSION, CREATED_TS, 
            UPDATED_TS, ACTIVE_TO)
         Values
           (bi_lookup_value_seq.nextval, regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'), 'POST_SALES', 'Post Sales', '1', 
              (SELECT DISTINCT id FROM bi_lookup_type WHERE code ='DEAL_STATUS'), 'cx_cvc@oracle.com', 'cx_cvc@oracle.com', 1, CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT', 
            CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
            CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT' + 360);
            
        INSERT INTO BI_LOOKUP_VALUE
           (ID, UNIQUE_ID, CODE, VALUE, IS_ACTIVE, 
            LOOKUP_TYPE_ID, CREATED_BY, UPDATED_BY, VERSION, CREATED_TS, 
            UPDATED_TS, ACTIVE_TO)
         Values
           (bi_lookup_value_seq.nextval, regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'), 'PRE_SALE_DISCUSSION', 'Pre Sales Discussion', '1', 
             (SELECT DISTINCT id FROM bi_lookup_type WHERE code ='DEAL_STATUS'), 'cx_cvc@oracle.com', 'cx_cvc@oracle.com', 1, CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT', 
            CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
            CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT' + 360);
			
        INSERT INTO BI_LOOKUP_VALUE
           (ID, UNIQUE_ID, CODE, VALUE, IS_ACTIVE, 
            LOOKUP_TYPE_ID, CREATED_BY, UPDATED_BY, VERSION, CREATED_TS, 
            UPDATED_TS, ACTIVE_TO)
         Values
           (bi_lookup_value_seq.nextval, regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'), 'FULL_AGENDA', 'Full Agenda', '1', 
             (SELECT DISTINCT id FROM bi_lookup_type WHERE code ='DIGITAL_SIGN_OPTION'), 'cx_cvc@oracle.com', 'cx_cvc@oracle.com', 1, CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT', 
            CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
            CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT' + 360);			
          
          BEGIN
           INSERT INTO bi_lookup_type
               (id,code,name,description,created_by,created_ts,updated_by,updated_ts,is_active,unique_id,version) 
              Values
               (BI_LOOKUP_TYPE_SEQ.NEXTVAL, 'NCV_VISIT_TYPE', 'NCV_VISIT_TYPE', 'NCV Visit Type','CX_CVC',CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT','CX_CVC',
               CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',1,regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),0); 
           EXCEPTION
             WHEN OTHERS
             THEN
              DBMS_OUTPUT.PUT_LINE ('Error executing lookup delete ' ||SQLERRM);
           END;     
           
           BEGIN
			INSERT INTO BI_LOOKUP_VALUE
			   (ID, UNIQUE_ID, CODE, VALUE, IS_ACTIVE, 
				LOOKUP_TYPE_ID, CREATED_BY, UPDATED_BY, VERSION, CREATED_TS, 
				UPDATED_TS)
			 Values
			   (bi_lookup_value_seq.nextval, regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
			    'COMMUNITY_RELATION', 'Community Relation', '1', 
				(SELECT DISTINCT id FROM bi_lookup_type WHERE code ='NCV_VISIT_TYPE'), 'cx_cvc@oracle.com',
				'cx_cvc@oracle.com', 1, 
				CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT',
				CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT' );		

			EXCEPTION
             WHEN OTHERS
             THEN
              DBMS_OUTPUT.PUT_LINE ('Error executing COMMUNITY_RELATION   ' ||SQLERRM);
           END; 

		    BEGIN
			INSERT INTO BI_LOOKUP_VALUE
			   (ID, UNIQUE_ID, CODE, VALUE, IS_ACTIVE, 
				LOOKUP_TYPE_ID, CREATED_BY, UPDATED_BY, VERSION, CREATED_TS, 
				UPDATED_TS )
			 Values
			   (bi_lookup_value_seq.nextval, regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
			    'ANALYST', 'Analyst', '1', 
				(SELECT DISTINCT id FROM bi_lookup_type WHERE code ='NCV_VISIT_TYPE'), 'cx_cvc@oracle.com',
				'cx_cvc@oracle.com', 1, 
				CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT', 
				CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT' );		

			EXCEPTION
             WHEN OTHERS
             THEN
              DBMS_OUTPUT.PUT_LINE ('Error executing ANALYST lookup   ' ||SQLERRM);
           END;  
		   
		    BEGIN
			INSERT INTO BI_LOOKUP_VALUE
			   (ID, UNIQUE_ID, CODE, VALUE, IS_ACTIVE, 
				LOOKUP_TYPE_ID, CREATED_BY, UPDATED_BY, VERSION, CREATED_TS, 
				UPDATED_TS )
			 Values
			   (bi_lookup_value_seq.nextval, regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
			    'INVESTOR_RELATION', 'Investor Relations', '1', 
				(SELECT DISTINCT id FROM bi_lookup_type WHERE code ='NCV_VISIT_TYPE'), 'cx_cvc@oracle.com',
				'cx_cvc@oracle.com', 1,
				CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT', 
				CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT'
				);		

			EXCEPTION
             WHEN OTHERS
             THEN
              DBMS_OUTPUT.PUT_LINE ('Error executing INVESTOR_RELATION lookup   ' ||SQLERRM);
           END;  

		   BEGIN
			INSERT INTO BI_LOOKUP_VALUE
			   (ID, UNIQUE_ID, CODE, VALUE, IS_ACTIVE, 
				LOOKUP_TYPE_ID, CREATED_BY, UPDATED_BY, VERSION, CREATED_TS, 
				UPDATED_TS )
			 Values
			   (bi_lookup_value_seq.nextval, regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
			    'INTERNAL', 'Internal', '1', 
				(SELECT DISTINCT id FROM bi_lookup_type WHERE code ='NCV_VISIT_TYPE'), 'cx_cvc@oracle.com',
				'cx_cvc@oracle.com', 1, CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT', CURRENT_TIMESTAMP(0) AT TIME ZONE 'GMT');		

			EXCEPTION
             WHEN OTHERS
             THEN
              DBMS_OUTPUT.PUT_LINE ('Error executing INTERNAL lookup   ' ||SQLERRM);
           END;  
		   
           BEGIN
            UPDATE bi_lookup_value
             SET is_active = 0,
			     active_from = ADD_MONTHS(CURRENT_TIMESTAMP,-12),
				 active_to   = ADD_MONTHS(CURRENT_TIMESTAMP,-12)
              WHERE lookup_type_id
             IN (SELECT DISTINCT id FROM bi_lookup_type WHERE code = 'VISIT_TYPE')
			 AND code NOT IN ('EXISTING_CUSTOMER','PROSPECT','PARTNER');
          EXCEPTION
            WHEN OTHERS
             THEN
                  DBMS_OUTPUT.PUT_LINE (
                        ' Error while updating BI_LOOKUP_TYPE --'
                     || SQLERRM
                     || '--'
                     || SQLCODE);

                  l_out_chr_errbuf :=
                        ' Error while updating BI_LOOKUP_TYPE ---'
                     || SQLERRM
                     || '--'
                     || SQLCODE;
                  l_chr_err_msg := 'IN WHEN OTHERS EXCEPTION';

                   cvc_bi_conv_master.log_error (
                         l_chr_err_code 
                       , l_chr_err_msg
                       , l_chr_prc_name
                       , 'WHEN OTHERS - while updating BI_LOOKUP_TYPE -- '
                       ,  SQLERRM
                       ,  SQLCODE
                       ); 
            END;		   
             
          BEGIN
            DELETE FROM bi_lookup_type where code is null;
           EXCEPTION
             WHEN OTHERS
             THEN
              DBMS_OUTPUT.PUT_LINE ('Error executing lookup delete ' ||SQLERRM);
          END; 
		  
          BEGIN
			  DELETE FROM BI_TEN_ACCOUNT_USER
				WHERE tenant_account_id IN (SELECT tenant_account_id  
				FROM BI_TEN_ACCOUNT_USER
				GROUP BY tenant_account_id
				HAVING COUNT(1) > 1
				)
				AND ROWNUM < 2;
           EXCEPTION
             WHEN OTHERS
             THEN
              DBMS_OUTPUT.PUT_LINE ('Error deleting duplicate records from BI_TEN_ACCOUNT_USER ' ||SQLERRM);
          END;  	
		  
 
		  BEGIN
				 UPDATE bi_Tenant_account
				   SET tier =1
					where account_name in (
					'BAE Systems Plc','Bundesministerium der Finanzen','Department of Defence','Department of Social Services','European Commission EMCDDA',
					'Ministero Dell'||''''||'Economia E Delle Finanze','Ministry Of Defence - UK','NHS (National Health Services)','Poste Italiane SPA','Security Services',
					'Hyundai Motor','KT','Samsung Electronics','Samsung Group','SK Group','America Movil','Deutsche Bahn AG','Deutsche Post AG','Ferrovie Dello Stato S.P.A.',
					'Mapfre SA','Tata Group','BP','Centrica Plc','Enel Servizi Srl','Engie (Formerly GDF Suez)','Gas Natural Fenosa','Royal Dutch Shell','Scottish and Southern Energy',
					'Shenzhen Huawei Investment And Holding Co., Ltd.','AT&'||'T Corp','BT Group Plc','Deutsche Telekom AG','JSFC Sistema','Koninklijke Kpn N.V.',
					'Liberty Global','Mobile Telephone Networks (Pty) Ltd','Orange','Swisscom AG','Telecom Italia S.P.A.','Telefonica, SA','Telstra Corporation Limited',
					'Veon (Previously Vimpelcom Ltd.)','Verizon','Vodafone Limited','Apple Inc.','Daimler AG','Ericsson AB','Fiat Auto S.P.A.','Gemalto N.V.',
					'General Electric Company (GE)','Michelin','Nokia Corporation','Novartis Pharma AG','Robert Bosch GmbH','Sanofi (Formerly Sanofi-Aventis)',
					'Siemens Aktiengesellschaft','Volkswagen AG','Amazon.com Inc','Anheuser-Busch InBev NV','eBay, Inc','Groupe Auchan','J Sainsbury Plc','John Lewis Partnership Plc',
					'Royal Ahold','Tesco Plc','Unilever Plc','Assicurazioni Generali S.P.A.','Australia And New Zealand Banking Group','Banco Bilbao Vizcaya Argentaria, S.A.',
					'Banco Bradesco','Banco Santander Central Hispano, S.A.','Bank Of America','BNP Paribas SA','CAIXABANK (Formerly Caixa D'||''''||'Estalvis I Pensions De Barcelona)',
					'Credit Agricole SA','Credit Suisse','Deutsche Bank AG','Groupe BPCE','HSBC Holdings Plc','ING Group','Intesa Sanpaolo','Itausa-Investimentos Itau',
					'Lloyds Banking Group plc','National Australia Bank Limited','Nordea Bank AB','PPF','Rabobank Group','Royal Bank Of Scotland Plc','Sberbank Rossii OAO',
					'Societe Generale','Standard Chartered Plc','UBS AG','Unicredit Servizi Informativi S.P.A.','Wells Fargo &'||' Company','Westpac Banking Corporation',
					'A.P. Moller - Maersk A/S','Bundesagentur Fur Arbeit','JP Morgan Chase &'||' Company','Barclays Bank Plc','EDF SA','ABN Amro Bank NV',
					'LG Electronics Inc','Rolls Royce Plc','F.Hoffmann - la Roche','Bayerische Motoren Werke AG','Sky Plc.','Inter IKEA Systems B.V.',
					'Societe Nationale Des Chemins De Fer Francais S N C F','Allianz'
					);
		   EXCEPTION
			WHEN OTHERS
			THEN
			 DBMS_OUTPUT.PUT_LINE ('Error updating tier1 '|| SQLERRM);
		   END;
 
		  BEGIN
			 UPDATE bi_Tenant_account
			   SET tier = 2
				where account_name in (
					'ANZ Councils','ANZ Higher Education','Boeing Company','Defense Health Agency (DHA). (Previously Tricare Management Activity)',
					'Department of Homeland Security','General Dynamics Corporation','Lockheed Martin Corporation','National Security - ANZ',
					'New Zealand Government','Northrop Grumman Corporation','Parliament Of New South Wales','United Technologies Corporation',
					'US Air Force','US Army','US Department of Defense','US Department of Health &'||' Human Services','US Department of Transportation',
					'Victoria, Tasmanian Government','Canon','Fujitsu','Hana Financial Group Inc','Hitachi Limited','KDDI Corporation','Korea Deposit Insurance Corporation',
					'Lotte Shopping','Mazda Motor','Mitsubishi UFJ Financial Group','Mizuho Financial Group',' Agricultural Cooperative Federation',
					'Nippon Telegraph And Telephone','Nomura Holdings','NTT Docomo','Panasonic','Posco Company Ltd','Rakuten, Inc.','Ricoh',
					'Seven &'||' I Holdings','Softbank','Sompo Japan Nipponkoa Holdings, Inc. (Previously NKSJ Holdings, Inc.)',
					'Sumitomo Mitsui Financial Group, Inc.','Toyota Motor','Aditya Birla Group','American Airlines Group, Inc.',
					'Cencosud','Comision Federal De Electricidad','FedEx','Femsa Comercio, S.A. De C.V.','Grupo Bimbo S.A.B. de C.V.','Grupo Televisa SAB',
					' Airlines Group S.A.','Lojas Renner S/A','Ministerio da Saude','Ministerio de Salud - Chile','Oi Participacoes',
					'Petroleo Brasileiro S/A - Petrobras','Petroleos Mexicanos Pemex','Servicio De Administracion Tributaria',
					'Telecom Argentina','United Continental Holdings, Inc.','ADNOC','Alcoa Inc','American Electric Power','Chevron Corporation',
					'CK Hutchison Holdings Limited ','DBS Bank Ltd','Duke Energy','Enbridge Inc.','Exelon Corporation','Exxon Mobil Corporation',
					'Halliburton','Phil. Long Distance Telephone Company (PLDT)','PT Telekomunikasi Indonesia Tbk','Reliance Industries Limited',
					'Schlumberger N.V.','Singapore Telecommunications Limited','Southern Company','Suncor Energy','Bell Canada','Bharat Sanchar Nigam Limited',
					'Bharti Group','Centurylink','Charter Communications (Previously Time Warner Cable Inc)','Comcast Corporation',
					'Cox Enterprises Incorporated','Etisalat','NBN CO LIMITED','Ooredoo Q.S.C. (Formerly Qatar Telecom)','Rogers Communications Inc.',
					'Saudi Telecom Company - STC','Shaw Communications Inc.','Sprint Corporation','T-Mobile USA Inc','Anthem, Inc',
					'Baxter International','Cardinal Health','Cigna','Cisco Systems Inc','Cummins Inc','DowDuPont (Formerly Dow Chemical Company)',
					'Eaton Corporation','Emerson Electric Co','Ford Motor Company','General Motors Corporation','Glaxosmithkline Plc','Humana',
					'Intel Corporation','Kaiser Foundation Health Plan','McKesson Corporation','Novo Nordisk A/S','Pfizer Corporation','Qualcomm Incorporated',
					'Thermo Fisher Scientific','Unitedhealth Group','Xerox Corporation','Albertsons','Alphabet','Archer Daniels Midland','Gap',
					'George Weston','Kohl'||''''||'s','Kroger','Macy'||''''||'s','Nestle Operational Services Worldwide (NOSW) Ltd','PepsiCo',
					'Procter &'||' Gamble Company','S&'||'P Global','Starbucks Corporation','Target Corporation','The Home Depot','The Walt Disney Company',
					'Thomson Company Inc','Wal-Mart Stores, Inc','Walgreens','American Express','American International Group','Banco De Chile',
					'Banco Do Brasil S/A','Banco Nacion','Bank Of Montreal','Bank Of New York Mellon Corp.','Caixa Economica Federal','Canadian Imperial Bank Of Commerce',
					'Capital One Financial Corp.','Citigroup','Commonwealth Bank Of Australia','Credicorp','EQUITY BANK LTD','Federation Des Caisses Desjardins Du Quebec',
					'Grupo Aval Acciones Y Valores S A','Grupo de Inversiones Suramericana','Grupo Empresarial Bolivar','Hartford Financial Services Group',
					'ICICI Bank Limited','KeyCorp','Liberty Mutual Insurance Group','Marsh &'||' McLennan Companies, Inc.','Metlife',
					'Ministerio de Hacienda','Nationwide Mutual Insurance Company','PNC Financial Services Group','Power Corp. Of Canada','Regions Financial',
					'Royal Bank Of Canada','Standard Bank Group Limited','State Bank Of India','State Street Corp.','Suntrust Banks',
					'TIAA','Toronto-Dominion Bank','U.S. Bancorp','Visa International','National Agricultural Cooperative Federation',
					'Latam Airlines Group S.A.','CVS Caremark Corporation','Charter Communications','Merck &'||' Company Inc','Pacific Gas &'||' Electric',
					'Telus Communications Inc.','JC Penney Corporation Inc','Ultrapar Holdings','First Data Holdings Inc.','National Council of Women (NCW) - WA/SA/NT',
					'Johnson &'||' Johnson','Bank Of Nova Scotia','HDFC Group'
				);
 		   EXCEPTION
			WHEN OTHERS
			THEN
			 DBMS_OUTPUT.PUT_LINE ('Error updating tier2 '|| SQLERRM);
		   END;
 
          
		   BEGIN          
                INSERT INTO BI_USER_CONTACT (user_id,value,contact_type) 
					   SELECT DISTINCT id  ,
					            user_name,
					            'email'  
					       FROM BI_USER a
					      WHERE id NOT IN (SELECT b.user_id FROM BI_USER_CONTACT b WHERE b.user_id = a.id AND contact_type ='email')  ;
			   EXCEPTION
				   WHEN OTHERS
				   THEN
						DBMS_OUTPUT.PUT_LINE (
							  ' Error inserting into BI_USER_CONTACT--'
						   || SQLERRM
						   || '--'
						   || SQLCODE);
								   
						l_out_chr_errbuf :=
							  ' Error inserting into BI_USER_CONTACT--'
						   || SQLERRM
						   || '--'
						   || SQLCODE;
								
						log_error (
							 l_chr_err_code 
						   , l_chr_err_msg 
						   , l_chr_prc_name
						   , 'WHEN OTHERS - Error inserting into BI_USER_CONTACT'
						   ,  SQLERRM
						   ,  SQLCODE
						   );              
			   END; 

              BEGIN
			   SELECT count(1)  
			     INTO l_count_arr
				 FROM bi_topic
				WHERE name = 'Arrival';               			  
              EXCEPTION
               WHEN OTHERS
               THEN
                DBMS_OUTPUT.PUT_LINE ('Error getting the l_name_arrival ' ||SQLERRM);
              END;      
    
	           --DBMS_OUTPUT.PUT_LINE ('l_count_arr' ||l_count_arr);
	
              IF l_count_arr = 0
			  THEN
			  
				  BEGIN         
					   INSERT INTO BI_TOPIC
						   (ID, UNIQUE_ID, NAME, DESCRIPTION, TOPIC_TYPE_ID, 
							IS_ACTIVE, CREATED_TS, CREATED_BY, UPDATED_TS, UPDATED_BY, 
							VERSION)
						 VALUES
						   (BI_TOPIC_SEQ.NEXTVAL, 
						   regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
						   'Arrival',
						   'Arrival',
						   (SELECT id FROM BI_TOPIC_TYPE WHERE type = 'Applications' ), 
							 1  ,
							CURRENT_TIMESTAMP,'CX_CVC' ,CURRENT_TIMESTAMP ,'CX_CVC' , 0);
				   EXCEPTION
				   WHEN OTHERS
				   THEN
					DBMS_OUTPUT.PUT_LINE ('Error inserting into bi_topic for Arrival ' ||SQLERRM);
				  END; 
			  
			  END IF;
			  
			  
			 -- 	DBMS_OUTPUT.PUT_LINE ('l_count_adj' ||l_count_adj);
			  
              BEGIN
			   SELECT count(1)  
			     INTO l_count_adj
				 FROM bi_topic
				WHERE name = 'Adjourn';                 			  
              EXCEPTION
               WHEN OTHERS
               THEN
                DBMS_OUTPUT.PUT_LINE ('Error getting the l_name_arrival ' ||SQLERRM);
              END;      

              IF l_count_adj = 0
			  THEN			  
			  
				  BEGIN         
					   INSERT INTO BI_TOPIC
						   (ID, UNIQUE_ID, NAME, DESCRIPTION, TOPIC_TYPE_ID, 
							IS_ACTIVE, CREATED_TS, CREATED_BY, UPDATED_TS, UPDATED_BY, 
							VERSION)
						 VALUES
						   (BI_TOPIC_SEQ.NEXTVAL, 
						   regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
						   'Adjourn',
						   'Adjourn',
						   (SELECT id FROM BI_TOPIC_TYPE WHERE type = 'Applications' ), 
							 1  ,
							CURRENT_TIMESTAMP,'CX_CVC' ,CURRENT_TIMESTAMP ,'CX_CVC' , 0);
				   EXCEPTION
				   WHEN OTHERS
				   THEN
					DBMS_OUTPUT.PUT_LINE ('Error inserting into bi_topic for adjourn ' ||SQLERRM);
				  END;
				  
			   END IF; 
   
     EXCEPTION
   WHEN OTHERS
   THEN
    DBMS_OUTPUT.PUT_LINE ('Error executing ' ||SQLERRM);
  END;
        
    
     COMMIT;
END IF;	   
EXCEPTION
WHEN OTHERS
THEN
 DBMS_OUTPUT.PUT_LINE ('inside lookup params' ||SQLERRM);
END;
       
PROCEDURE ins_opp_num
IS
         l_chr_err_code  VARCHAR2 (255);
         l_chr_err_msg   VARCHAR2 (255);  
         l_out_chr_errbuf  VARCHAR2 (2000);
         l_chr_fn_name   VARCHAR2(50) := 'create_opp_num';      
         l_stg_opp1 VARCHAR2(255) := NULL;
         l_stg_opp12 VARCHAR2(255) := NULL;
         l_stg_opp13 VARCHAR2(255) := NULL;
		 l_bi_request_id number;
         
CURSOR C1
IS   
 SELECT DISTINCT cvc_Request_id ,bi_request_id
   FROM bi_cvc_agenda
   WHERE bi_request_id not in (select request_id from bi_Request_opportunity)   ;
   
CURSOR C2 ( cvcreqid2 NUMBER,bi_reqdid2 NUMBER)
IS    
 WITH DATA AS
    ( SELECT bi_reqdid2, opp_number FROM cvc_request@dblink_to_cvc_new where id = cvcreqid2    
    )
  SELECT bi_reqdid2,trim(COLUMN_VALUE) opp_number
   FROM DATA, xmltable(('"' || REPLACE(opp_number, ',', '","') || '"'));
   
   
CURSOR c3(opp_number3 VARCHAR2)
IS 
 WITH DATA AS
    ( SELECT  opp_number3 FROM DUAL
    )
  SELECT trim(COLUMN_VALUE) opp_number3
   FROM DATA, xmltable(('"' || REPLACE(opp_number3, ' ', '","') || '"'));

CURSOR c4(opp_number4 VARCHAR2)
IS 
 WITH DATA AS
    ( SELECT  opp_number4 FROM DUAL
    )
  SELECT trim(COLUMN_VALUE) opp_number4
   FROM DATA, xmltable(('"' || REPLACE(opp_number4, ';', '","') || '"'));
 
 BEGIN
 
		  FOR rec_c1 IN c1
		  LOOP
		     --- DBMS_OUTPUT.PUT_LINE ( ' rec_c1.cvc_Request_id  ' ||rec_c1.cvc_Request_id   );
		   
			 FOR rec_c2 IN c2(rec_c1.cvc_Request_id ,rec_c1.bi_request_id)
			 LOOP
			   
				---DBMS_OUTPUT.PUT_LINE ( ' rec_c2.bi_reqdid2  ' ||rec_c2.bi_reqdid2   );
				---DBMS_OUTPUT.PUT_LINE ( ' rec_c2.opp_number  ' ||rec_c2.opp_number   );
			 
				FOR rec_c3 IN C3(rec_c2.opp_number)
				 LOOP   
				 
					 --DBMS_OUTPUT.PUT_LINE ( ' rec_c2.opp_number  ' || rec_c2.opp_number   );
				   
					 FOR rec_c4 IN c4(rec_c3.opp_number3)
					 LOOP    
					 
						BEGIN           
						   INSERT INTO bi_request_opportunity(request_id,opportunity_id)
						   VALUES (rec_c1.bi_request_id ,rec_c4.opp_number4 );          
						EXCEPTION
						  WHEN OTHERS
						  THEN
							DBMS_OUTPUT.PUT_LINE ('Error inserting into bi_request_opportunity  : ' ||SQLERRM);
						END;  
						   
						END LOOP;     
				 END LOOP; 
			   
			   END LOOP;
	  	
		    END LOOP;
    
			 BEGIN
				DELETE FROM bi_request_opportunity where opportunity_id IS NULL;
					   
			 EXCEPTION
			  WHEN OTHERS
			  THEN
				DBMS_OUTPUT.PUT_LINE ('Error deleting bi_request_opportunity  : ' ||SQLERRM);
			 END;		
			
           COMMIT;

           EXCEPTION
               WHEN OTHERS
               THEN
                    DBMS_OUTPUT.PUT_LINE (
                          ' Error inserting into BI_REQUEST_OPPORTUNITY --'
                       || SQLERRM
                       || '--'
                       || SQLCODE);
                           
                    l_out_chr_errbuf :=
                          '  Error inserting into BI_REQUEST_OPPORTUNITY --'
                       || SQLERRM
                       || '--'
                       || SQLCODE;
                        
                    cvc_bi_conv_master.log_error (
                         l_chr_err_code 
                       , l_chr_err_msg 
                       , l_chr_fn_name
                       , 'WHEN OTHERS -  Error inserting into BI_REQUEST_OPPORTUNITY'
                       ,  SQLERRM
                       ,  SQLCODE
                       );

 
 END;
 
 PROCEDURE "BIQ_POPULATE_DAY_ROOM" 
IS

   CURSOR cur_extract_main_room
   IS
	SELECT a.id,
		a.main_room,
		a.arrival_ts,
		a.adjourn_ts,
		a.created_by,
		a.updated_by,
		a.request_id		
	FROM bi_request_activity_day a
 WHERE a.main_room IS NOT NULL;
	
	CURSOR cur_get_main_room_data
	IS  
	  SELECT a.id,
	         a.request_id,
           a.start_time,
           a.end_time ,
			     a.room
	   FROM bi_request_act_day_room  a,
          bi_location_calendar b
      WHERE a.request_id = b.request_id 
         AND a.room_type ='MAIN_ROOM'
    ---     AND a.id <> b.activity_day_room_id
         AND TRUNC(b.start_date) =  TRUNC(a.start_time) 
         AND TRUNC(b.end_date) = TRUNC(a.end_time)
         AND b.location_id = a.room;
		

    CURSOR cur_extract_break_room
    IS
      SELECT a.id,
		b.break_rooms,
 		a.arrival_ts,
		a.adjourn_ts,
		a.created_by,
		a.updated_by,
		a.request_id		
	FROM bi_request_activity_day a,
	     bi_request_act_day_break_room b
	WHERE a.id = b.request_activity_day_id
      AND b.break_rooms IS NOT NULL; 	
      
	CURSOR cur_get_break_room_data
	IS  
	  SELECT a.id,
	         a.request_id,
           a.start_time,
           a.end_time ,
			     a.room
	   FROM bi_request_act_day_room  a,
          bi_location_calendar b
      WHERE a.request_id = b.request_id 
         AND a.room_type = 'BREAKOUT_ROOM'
       --  AND a.id <> b.activity_day_room_id
         AND TRUNC(b.start_date) =  TRUNC(a.start_time) 
         AND TRUNC(b.end_date) = TRUNC(a.end_time)
         AND b.location_id = a.room;      
	 

   TYPE cur_get_room_data_main IS TABLE OF cur_extract_main_room%ROWTYPE
   INDEX BY PLS_INTEGER;
   l_cur_extract_main_room   cur_get_room_data_main;  
   
   TYPE cur_get_room_data_break IS TABLE OF cur_extract_break_room%ROWTYPE
   INDEX BY PLS_INTEGER;
   l_cur_extract_break_room   cur_get_room_data_break; 
    
   l_out_chr_errbuf                VARCHAR2 (2000);   
   l_chr_err_code                  VARCHAR2(2000);
   l_chr_err_msg                   VARCHAR2(2000);
   
BEGIN

   BEGIN
   
 	  
      OPEN cur_extract_main_room;

      LOOP
      
         FETCH cur_extract_main_room
            BULK COLLECT INTO l_cur_extract_main_room
            LIMIT 1000;

         EXIT WHEN l_cur_extract_main_room.COUNT = 0;

		   --  DBMS_OUTPUT.PUT_LINE ('here in first insert');

				 FOR i IN 1 .. l_cur_extract_main_room.COUNT
				 LOOP
					BEGIN
					   INSERT INTO bi_request_act_day_room
												 (id,
												  request_activity_day_id,
												  room,
												  room_type,
												  start_time,
												  end_time,
												  unique_id,
												  tenant_id,
												  version,										  
												  created_by,
												  created_ts,
												  updated_by,
												  updated_ts,
												  request_id)
							VALUES (bi_request_act_day_room_seq.NEXTVAL,
									l_cur_extract_main_room (i).id,
									l_cur_extract_main_room (i).main_room,
									'MAIN_ROOM',
									l_cur_extract_main_room (i).arrival_ts,
									l_cur_extract_main_room (i).adjourn_ts,
									regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
									NULL,
									0,
									l_cur_extract_main_room(i).created_by,
									CURRENT_TIMESTAMP,
									l_cur_extract_main_room(i).updated_by,
									CURRENT_TIMESTAMP,
									l_cur_extract_main_room (i).request_id);
						EXCEPTION
						   WHEN OTHERS
						   THEN
						   DBMS_OUTPUT.PUT_LINE (
							  ' Error while inserting into bi_request_act_day_room table for main_room --'
						   || SQLERRM
						   || '--'
						   || SQLCODE);
						   
						l_out_chr_errbuf :=
							 ' Error while inserting into bi_request_act_day_room  table for main_room --'
						   || SQLERRM
						   || '--'
						   || SQLCODE;
						l_chr_err_msg := 'IN OTHERs EXCEPTION';
						END;
					
					END LOOP;
					
        END LOOP; 					
					
		FOR rec_get_main_room_data IN cur_get_main_room_data
		LOOP
		
	    ---	DBMS_OUTPUT.PUT_LINE ('here in update');
				
				BEGIN
        
       --    DBMS_OUTPUT.PUT_LINE ('request_id  :' || rec_get_main_room_data.request_id);
       --    DBMS_OUTPUT.PUT_LINE ('room :' || rec_get_main_room_data.room);
 
 
				
				 UPDATE bi_location_calendar
					SET activity_day_room_id = rec_get_main_room_data.id
             ,updated_ts = CURRENT_TIMESTAMP
				 WHERE request_id = rec_get_main_room_data.request_id
					AND TRUNC(start_date) =  TRUNC(rec_get_main_room_data.start_time) 
					AND TRUNC(end_date) = TRUNC(rec_get_main_room_data.end_time)
					AND location_id = rec_get_main_room_data.room;
				
				EXCEPTION
				   WHEN OTHERS
				   THEN
				   DBMS_OUTPUT.PUT_LINE (
					  ' Error while updating  bi_location_calendar table for main_room --'
				   || SQLERRM
				   || '--'
				   || SQLCODE);
				   
				l_out_chr_errbuf :=
					 ' Error while updating  bi_location_calendar table for main_room --'
				   || SQLERRM
				   || '--'
				   || SQLCODE;
				l_chr_err_msg := 'IN OTHERs EXCEPTION';
				END;

	 END LOOP;
	 
      OPEN cur_extract_break_room;

      LOOP
      
         FETCH cur_extract_break_room
            BULK COLLECT INTO l_cur_extract_break_room
            LIMIT 1000;

         EXIT WHEN l_cur_extract_break_room.COUNT = 0;
		 
		 --    DBMS_OUTPUT.PUT_LINE ('here in seond insert');
		 
				 FOR i IN 1 .. l_cur_extract_break_room.COUNT
				 LOOP
					BEGIN
					   INSERT INTO bi_request_act_day_room 
												 (id,
												  request_activity_day_id,
												  room,
												  room_type,
												  start_time,
												  end_time,
												  unique_id,
												  tenant_id,
												  version,										  
												  created_by,
												  created_ts,
												  updated_by,
												  updated_ts,
												  request_id)
							VALUES (bi_request_act_day_room_seq.NEXTVAL,
									l_cur_extract_break_room (i).id,
									l_cur_extract_break_room (i).break_rooms,
									'BREAKOUT_ROOM',
									l_cur_extract_break_room (i).arrival_ts,
									l_cur_extract_break_room (i).adjourn_ts,
									regexp_replace(rawtohex(sys_guid()) , '([A-F0-9]{8})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{12})', '\1-\2-\3-\4-\5'),
									NULL,
									0,
									l_cur_extract_break_room(i).created_by,
									CURRENT_TIMESTAMP,
									l_cur_extract_break_room(i).updated_by,
									CURRENT_TIMESTAMP,
									l_cur_extract_break_room (i).request_id);
						EXCEPTION
						   WHEN OTHERS
						   THEN
						   DBMS_OUTPUT.PUT_LINE (
							  ' Error while inserting into bi_request_act_day_room table for main_room --'
						   || SQLERRM
						   || '--'
						   || SQLCODE);
						   
						l_out_chr_errbuf :=
							 ' Error while inserting into bi_request_act_day_room  table for main_room --'
						   || SQLERRM
						   || '--'
						   || SQLCODE;
						l_chr_err_msg := 'IN OTHERs EXCEPTION';
						END;
					
					END LOOP;
					
        END LOOP; 					
		 
		FOR rec_get_break_room_data IN cur_get_break_room_data
		LOOP
		
	    ---	DBMS_OUTPUT.PUT_LINE ('here in second update');
				
				BEGIN
        
         ---  DBMS_OUTPUT.PUT_LINE ('request_id  :' || rec_get_break_room_data.request_id);
        ---   DBMS_OUTPUT.PUT_LINE ('room :' || rec_get_break_room_data.room);
  
				
				 UPDATE bi_location_calendar
					SET activity_day_room_id = rec_get_break_room_data.id
             ,updated_ts = CURRENT_TIMESTAMP
				 WHERE request_id = rec_get_break_room_data.request_id
					AND TRUNC(start_date) =  TRUNC(rec_get_break_room_data.start_time) 
 					AND TRUNC(end_date) = TRUNC(rec_get_break_room_data.end_time)
					AND location_id = rec_get_break_room_data.room;
				
				EXCEPTION
				   WHEN OTHERS
				   THEN
				   DBMS_OUTPUT.PUT_LINE (
					  ' Error while updating  bi_location_calendar table for breakout_room --'
				   || SQLERRM
				   || '--'
				   || SQLCODE);
				   
				l_out_chr_errbuf :=
					 ' Error while updating  bi_location_calendar table for breakout_room --'
				   || SQLERRM
				   || '--'
				   || SQLCODE;
				l_chr_err_msg := 'IN OTHERs EXCEPTION';
				END;

	 END LOOP;     

     COMMIT;


  EXCEPTION
     WHEN OTHERS
     THEN
     DBMS_OUTPUT.PUT_LINE (
      ' Error in main --'
     || SQLERRM
     || '--'
     || SQLCODE);
     
  l_out_chr_errbuf :=
     ' Error in main --'
     || SQLERRM
     || '--'
     || SQLCODE;
  END;

END;
         
END;
/