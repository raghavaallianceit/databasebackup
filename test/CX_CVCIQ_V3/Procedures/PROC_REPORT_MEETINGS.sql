CREATE OR REPLACE PROCEDURE cx_cvciq_v3.proc_report_meetings (
    out_chr_err_code   OUT                VARCHAR2,
    out_chr_err_msg    OUT                VARCHAR2,
    out_meeting_tab    OUT                return_meeting_arr,
    in_type            IN                 VARCHAR2,
    in_year            IN                 NUMBER,
    in_month           IN                 NUMBER,
    in_quarter         IN                 NUMBER,
    in_group_by        IN                 VARCHAR2,
    in_location        IN                 VARCHAR2
) IS

    l_chr_srcstage       VARCHAR2(200);
    l_chr_biqtab         VARCHAR2(200);
    l_chr_srctab         VARCHAR2(200);
    l_chr_bistagtab      VARCHAR2(200);
    l_chr_err_code       VARCHAR2(255);
    l_chr_err_msg        VARCHAR2(255);
    l_out_chr_errbuf     VARCHAR2(2000);
    lrec                 return_meeting_report;
    l_num_counter        NUMBER := 0;
    l_year               NUMBER := in_year;
    l_type               VARCHAR2(256) := upper(in_type);
    l_group_by           VARCHAR2(256) :=
        CASE in_group_by
            WHEN 'total' THEN '0'
            WHEN 'TOTAL' THEN '0'
            ELSE in_group_by
        END;
    l_month              NUMBER :=
        CASE l_type
            WHEN 'MONTH' THEN in_month
            ELSE 0
        END;
    l_quarter            NUMBER :=
        CASE l_type
            WHEN 'QUARTER' THEN in_quarter
            ELSE 0
        END;
    l_location_id        VARCHAR2(256) := in_location;
    CURSOR cur_meeting_data IS
    SELECT
        noofrecords,
        TRIM(CASE l_type
            WHEN 'YEAR'      THEN initcap(TO_CHAR(TO_DATE(order_by, 'MM'), 'mon'))
            WHEN 'MONTH'     THEN TO_CHAR(order_by)
            WHEN 'QUARTER'   THEN TO_CHAR(order_by)
        END) value
    FROM
        (
            SELECT
                COUNT(*) noofrecords,
                CASE l_type
                    WHEN 'YEAR'      THEN EXTRACT(MONTH FROM start_date)
                    WHEN 'MONTH'     THEN EXTRACT(DAY FROM start_date)
                    WHEN 'QUARTER'   THEN to_number(TO_CHAR(start_date, 'WW'))
                END order_by
            FROM
                bi_request
            WHERE
                state = 'CONFIRMED'
                AND request_type_id = 1
                AND EXTRACT(YEAR FROM start_date) = l_year
                AND CASE l_type
                    WHEN 'MONTH'   THEN EXTRACT(MONTH FROM start_date)
                    ELSE 0
                END = l_month
                AND CASE l_type
                    WHEN 'QUARTER'   THEN to_number(TO_CHAR(start_date, 'Q'))
                    ELSE 0
                END = l_quarter
                AND CASE l_group_by
                    WHEN '0'   THEN '0'
                    ELSE customer_tier
                END = l_group_by
                AND location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = in_location
                )
            GROUP BY
                CASE l_type
                    WHEN 'YEAR'      THEN EXTRACT(MONTH FROM start_date)
                    WHEN 'MONTH'     THEN EXTRACT(DAY FROM start_date)
                    WHEN 'QUARTER'   THEN to_number(TO_CHAR(start_date, 'WW'))
                END
            ORDER BY
                order_by
        );

    TYPE rec_groupby_data IS
        TABLE OF cur_meeting_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_meeting_data   rec_groupby_data;
BEGIN
    out_meeting_tab := return_meeting_arr();
    OPEN cur_meeting_data;
--    dbms_output.put_line('l_type :-'
--                         || l_type
--                         || ', l_month :-'
--                         || l_month);
    LOOP
        FETCH cur_meeting_data BULK COLLECT INTO l_cur_meeting_data;
        EXIT WHEN l_cur_meeting_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_meeting_report();
        out_meeting_tab := return_meeting_arr(return_meeting_report());
        out_meeting_tab.DELETE;
        FOR i IN 1..l_cur_meeting_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_meeting_report();
                lrec.value := l_cur_meeting_data(i).noofrecords;
                lrec.name := l_cur_meeting_data(i).value;
                IF l_num_counter > 1 THEN
                    out_meeting_tab.extend();
                    out_meeting_tab(l_num_counter) := return_meeting_report();
                ELSE
                    out_meeting_tab := return_meeting_arr(return_meeting_report());
                END IF;

                out_meeting_tab(l_num_counter) := lrec;
            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line('Error occurred : ' || sqlerrm);
            END;
        END LOOP;

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('HERE INSIIDE OTHERS' || sqlerrm);
END;
/