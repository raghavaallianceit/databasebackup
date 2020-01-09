CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_topic_report (
    out_chr_err_code    OUT                 VARCHAR2,
    out_chr_err_msg     OUT                 VARCHAR2,
    out_topic_rep_tab   OUT                 return_topic_arr_result,
    in_from_date        IN                  VARCHAR2,
    in_to_date          IN                  VARCHAR2,
    in_sort_column      IN                  VARCHAR2,
    in_order_by         IN                  VARCHAR2,
    in_location         IN                  VARCHAR2,
    l_start_row_num     IN                  NUMBER,
    l_end_row_num       IN                  NUMBER
) IS

    l_chr_srcstage     VARCHAR2(200);
    l_chr_biqtab       VARCHAR2(200);
    l_chr_srctab       VARCHAR2(200);
    l_chr_bistagtab    VARCHAR2(200);
    l_chr_err_code     VARCHAR2(255);
    l_chr_err_msg      VARCHAR2(255);
    l_out_chr_errbuf   VARCHAR2(2000);
    lrec               return_topic_report;
    l_num_counter      NUMBER := 0;
    l_start_date       DATE := TO_DATE(in_from_date, 'dd-mm-yyyy hh24:mi:ss');
    l_end_date         DATE := TO_DATE(in_to_date, 'dd-mm-yyyy hh24:mi:ss');
    l_sort_column      VARCHAR2(30) := lower(in_sort_column);
    l_order_by         VARCHAR2(10) := lower(in_order_by);
    l_location_id      VARCHAR2(256) := in_location;
    l_start_row        NUMBER := l_start_row_num;
    l_end_row          NUMBER := l_end_row_num;
    CURSOR cur_topic_data IS
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
                        a.*,
                        concat(concat(p.first_name, ' '), p.last_name) presenter_name
                    FROM
                        (
                            SELECT
                                r.id              request_id,
                                a.id              request_activity_day_id,
                                TO_CHAR(a.event_date, 'MM/DD/YYYY') event_date,
                                a.event_date      eventdate,
                                r.customer_name   customer_name,
                                fn_code_to_lookup(r.visit_focus, l_location_id, 'VISIT_FOCUS') visit_focus,
                                (
                                    SELECT
                                        u.user_name
                                    FROM
                                        bi_user u
                                    WHERE
                                        u.id = r.briefing_manager
                                ) briefing_manager,
                                r.host_email      host_email,
                                r.country         country,
                                CASE
                                    WHEN t.optional_topic IS NOT NULL THEN t.optional_topic
                                    ELSE t.topic
                                END topic,
                                t.id              topic_activity_id
--                        concat(concat(p.first_name, ' '), p.last_name) presenter_name
                            FROM
                                bi_request r,
                                bi_request_activity_day a,
                                bi_request_topic_activity t
--                        bi_request_presenter p
                            WHERE
                                r.state = 'CONFIRMED'
                                AND a.event_date BETWEEN l_start_date AND l_end_date
                                AND r.location_id = (
                                    SELECT UNIQUE
                                        ( id )
                                    FROM
                                        bi_location
                                    WHERE
                                        unique_id = l_location_id
                                )
                                AND r.id = a.request_id
                                AND t.request_activity_day_id = a.id
                        ) a
                        LEFT JOIN bi_request_presenter p ON p.bi_request_topic_activity_id = a.topic_activity_id
                                                            AND p.status = 'Accepted'
                    ORDER BY
                        eventdate,
                        customer_name,
                        topic,
                        presenter_name
                ) a
            WHERE
                ROWNUM <= l_end_row
        )
    WHERE
        rn >= l_start_row;

    TYPE rec_topic_data IS
        TABLE OF cur_topic_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_topic_data   rec_topic_data;
BEGIN
    out_topic_rep_tab := return_topic_arr_result();
    OPEN cur_topic_data;
    LOOP
        FETCH cur_topic_data BULK COLLECT INTO l_cur_topic_data;
        EXIT WHEN l_cur_topic_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_topic_report();
        out_topic_rep_tab := return_topic_arr_result(return_topic_report());
        out_topic_rep_tab.DELETE;
        FOR i IN 1..l_cur_topic_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_topic_report();
                lrec.requestid := l_cur_topic_data(i).request_id;
                lrec.requestactivitydayid := l_cur_topic_data(i).request_id;
                lrec.startdate := l_cur_topic_data(i).event_date;
                lrec.company := l_cur_topic_data(i).customer_name;
                lrec.visitfocus := l_cur_topic_data(i).visit_focus;
                lrec.briefingmanager := l_cur_topic_data(i).briefing_manager;
                lrec.hostname := l_cur_topic_data(i).host_email;
                lrec.companycountry := l_cur_topic_data(i).country;
                lrec.topic := l_cur_topic_data(i).topic;
                lrec.presentername := l_cur_topic_data(i).presenter_name;
                IF l_num_counter > 1 THEN
                    out_topic_rep_tab.extend();
                    out_topic_rep_tab(l_num_counter) := return_topic_report();
                ELSE
                    out_topic_rep_tab := return_topic_arr_result(return_topic_report());
                END IF;

                out_topic_rep_tab(l_num_counter) := lrec;
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