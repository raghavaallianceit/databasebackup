CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_gcp_report (
    out_chr_err_code   OUT                VARCHAR2,
    out_chr_err_msg    OUT                VARCHAR2,
    out_gcp_tab        OUT                return_gcp_arr_result,
    in_from_date       IN                 VARCHAR2,
    in_to_date         IN                 VARCHAR2,
    in_sort_column     IN                 VARCHAR2,
    in_order_by        IN                 VARCHAR2,
    in_location        IN                 VARCHAR2,
    l_start_row_num    IN                 NUMBER,
    l_end_row_num      IN                 NUMBER
) IS

    l_chr_srcstage     VARCHAR2(200);
    l_chr_biqtab       VARCHAR2(200);
    l_chr_srctab       VARCHAR2(200);
    l_chr_bistagtab    VARCHAR2(200);
    l_chr_err_code     VARCHAR2(255);
    l_chr_err_msg      VARCHAR2(255);
    l_out_chr_errbuf   VARCHAR2(2000);
    lrec               return_gcp_report;
    l_num_counter      NUMBER := 0;
    l_start_date       DATE := TO_DATE(in_from_date, 'dd-mm-yyyy hh24:mi:ss');
    l_end_date         DATE := TO_DATE(in_to_date, 'dd-mm-yyyy hh24:mi:ss');
    l_sort_column      VARCHAR2(30) := lower(in_sort_column);
    l_order_by         VARCHAR2(10) := lower(in_order_by);
    l_location_id      VARCHAR2(256) := in_location;
    l_start_row        NUMBER := l_start_row_num;
    l_end_row          NUMBER := l_end_row_num;
    CURSOR cur_gcp_data IS
    SELECT
        *
    FROM
        (
            SELECT
                a.*,
                ROWNUM rn
            FROM
                (
                    SELECT
                        r.id              requestid,
                        TO_CHAR(d.event_date, 'MM/DD/YYYY') startdate,
                        r.customer_name   company,
                        r.country         country,
                        fn_code_to_lookup(r.visit_focus, l_location_id, 'VISIT_FOCUS') visit_focus,
                        (
                            SELECT
                                d.user_name
                            FROM
                                bi_user d
                            WHERE
                                d.id = r.briefing_manager
                        ) briefing_manager,
                        r.host_email      host_email,
                        a.first_name      first_name,
                        a.last_name       last_name,
                        a.designation     title
                    FROM
                        bi_request r
                        LEFT OUTER JOIN bi_request_activity_day d ON r.id = d.request_id
                        LEFT OUTER JOIN bi_request_attendees a ON a.request_id = r.id
                                                                  AND a.attendee_type = 'externalattendees'
                    WHERE
                        r.state = 'CONFIRMED'
                        AND r.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = l_location_id
                        )
                        AND request_type_id = 1
                        AND d.event_date BETWEEN l_start_date AND l_end_date
                    ORDER BY
                        d.event_date,
                        customer_name,
                        a.first_name,
                        a.last_name,
                        CASE l_order_by
                            WHEN 'asc'   THEN CASE l_sort_column
                                WHEN 'companycountry'   THEN country
                                WHEN 'startdate'        THEN startdate
                            END
                        END,
                        CASE l_order_by
                            WHEN 'desc'   THEN CASE l_sort_column
                                WHEN 'companycountry'   THEN country
                                WHEN 'startdate'        THEN startdate
                            END
                        END DESC
                ) a
            WHERE
                ROWNUM <= l_end_row
        )
    WHERE
        rn >= l_start_row;

    TYPE rec_gcp_data IS
        TABLE OF cur_gcp_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_gcp_data     rec_gcp_data;
BEGIN
    out_gcp_tab := return_gcp_arr_result();
    OPEN cur_gcp_data;
    LOOP
        FETCH cur_gcp_data BULK COLLECT INTO l_cur_gcp_data;
        EXIT WHEN l_cur_gcp_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_gcp_report();
        out_gcp_tab := return_gcp_arr_result(return_gcp_report());
        out_gcp_tab.DELETE;
        FOR i IN 1..l_cur_gcp_data.count LOOP
--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_gcp_report();
                lrec.requestid := l_cur_gcp_data(i).requestid;
                lrec.startdate := l_cur_gcp_data(i).startdate;
                lrec.company := l_cur_gcp_data(i).company;
                lrec.companycountry := l_cur_gcp_data(i).country;
                lrec.visitfocus := l_cur_gcp_data(i).visit_focus;
                lrec.briefingmanager := l_cur_gcp_data(i).briefing_manager;
                lrec.host := l_cur_gcp_data(i).host_email;
                lrec.extfirstname := l_cur_gcp_data(i).first_name;
                lrec.extlastname := l_cur_gcp_data(i).last_name;
                lrec.exttitle := l_cur_gcp_data(i).title;
                IF l_num_counter > 1 THEN
                    out_gcp_tab.extend();
                    out_gcp_tab(l_num_counter) := return_gcp_report();
                ELSE
                    out_gcp_tab := return_gcp_arr_result(return_gcp_report());
                END IF;

                out_gcp_tab(l_num_counter) := lrec;
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