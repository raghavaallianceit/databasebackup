CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_visit_overview_report (
    out_chr_err_code         OUT                      VARCHAR2,
    out_chr_err_msg          OUT                      VARCHAR2,
    out_visit_overview_tab   OUT                      return_visit_arr_result,
    in_from_date             IN                       VARCHAR2,
    in_to_date               IN                       VARCHAR2,
    in_sort_column           IN                       VARCHAR2,
    in_order_by              IN                       VARCHAR2,
    in_location              IN                       VARCHAR2,
    l_start_row_num          IN                       NUMBER,
    l_end_row_num            IN                       NUMBER
) IS

    l_chr_srcstage              VARCHAR2(200);
    l_chr_biqtab                VARCHAR2(200);
    l_chr_srctab                VARCHAR2(200);
    l_chr_bistagtab             VARCHAR2(200);
    l_chr_err_code              VARCHAR2(255);
    l_chr_err_msg               VARCHAR2(255);
    l_out_chr_errbuf            VARCHAR2(2000);
    lrec                        return_visit_overview_report;
    l_num_counter               NUMBER := 0;
    l_start_date                DATE := TO_DATE(in_from_date, 'dd-mm-yyyy hh24:mi:ss');
    l_end_date                  DATE := TO_DATE(in_to_date, 'dd-mm-yyyy hh24:mi:ss');
    l_sort_column               VARCHAR2(30) := lower(in_sort_column);
    l_order_by                  VARCHAR2(10) := lower(in_order_by);
    l_location_id               VARCHAR2(256) := in_location;
    l_start_row                 NUMBER := l_start_row_num;
    l_end_row                   NUMBER := l_end_row_num;
    CURSOR cur_visit_overview_data IS
    SELECT
        *
    FROM
        (
            SELECT
                a.*,
                ROWNUM rn
            FROM
                (
                    SELECT DISTINCT
                        r.id                    request_id,
                        TO_CHAR(b.event_date, 'MM/DD/YYYY') startdate,
                        r.start_date            start_date,
                        (
                            SELECT
                                name
                            FROM
                                bi_location
                            WHERE
                                id = c.room
                        ) room,
                        r.customer_name         customer_name,
                        fn_code_to_lookup(r.visit_focus, l_location_id, 'VISIT_FOCUS') visit_focus,
                        fn_code_to_lookup(r.industry, l_location_id, 'CUSTOMER_INDUSTRY') industry,
                        fn_code_to_lookup(r.customer_tier, l_location_id, 'TIER') customer_tier,
                        r.host_email            host_email,
                        r.opportunity_revenue   opportunity_revenue,
                        r.visit_objective       meeting_objective,
                        r.sensitive_issues      sensitive_issues,
                        r.business_case         business_case
                    FROM
                        bi_request r
                        LEFT JOIN bi_request_activity_day b ON b.request_id = r.id
                        LEFT JOIN bi_request_catering_activity c ON c.request_activity_day_id = b.id
                        LEFT JOIN bi_request_act_day_room rm ON b.id = rm.request_activity_day_id
                                                                AND c.room = rm.room
                    WHERE
                        r.state = 'CONFIRMED'
                        AND request_type_id = 1
                        AND b.event_date BETWEEN l_start_date AND l_end_date
                        AND r.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = in_location
                        )
                        AND rm.room_type = 'MAIN_ROOM'
                    ORDER BY
                        start_date,
                        room
                ) a
            WHERE
                ROWNUM <= l_end_row
        )
    WHERE
        rn >= l_start_row;

    TYPE rec_visit_overview_data IS
        TABLE OF cur_visit_overview_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_visit_overview_data   rec_visit_overview_data;
BEGIN
    out_visit_overview_tab := return_visit_arr_result();
    OPEN cur_visit_overview_data;
    LOOP
        FETCH cur_visit_overview_data BULK COLLECT INTO l_cur_visit_overview_data;
        EXIT WHEN l_cur_visit_overview_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_visit_overview_report();
        out_visit_overview_tab := return_visit_arr_result(return_visit_overview_report());
        out_visit_overview_tab.DELETE;
        FOR i IN 1..l_cur_visit_overview_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_visit_overview_report();
                lrec.requestid := l_cur_visit_overview_data(i).request_id;
                lrec.startdate := l_cur_visit_overview_data(i).startdate;
                lrec.room := l_cur_visit_overview_data(i).room;
                lrec.company := l_cur_visit_overview_data(i).customer_name;
                lrec.visitfocus := l_cur_visit_overview_data(i).visit_focus;
                lrec.industry := l_cur_visit_overview_data(i).industry;
                lrec.tier := l_cur_visit_overview_data(i).customer_tier;
                lrec.host := l_cur_visit_overview_data(i).host_email;
                lrec.opprevenue := l_cur_visit_overview_data(i).opportunity_revenue;
                lrec.objectives := l_cur_visit_overview_data(i).meeting_objective;
                lrec.sensitiveissues := l_cur_visit_overview_data(i).sensitive_issues;
                lrec.businesscase := l_cur_visit_overview_data(i).business_case;
                IF l_num_counter > 1 THEN
                    out_visit_overview_tab.extend();
                    out_visit_overview_tab(l_num_counter) := return_visit_overview_report();
                ELSE
                    out_visit_overview_tab := return_visit_arr_result(return_visit_overview_report());
                END IF;

                out_visit_overview_tab(l_num_counter) := lrec;
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