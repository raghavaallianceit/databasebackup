CREATE OR REPLACE PROCEDURE cx_cvciq_v3.test_safe_report (
    out_chr_err_code   OUT                VARCHAR2,
    out_chr_err_msg    OUT                VARCHAR2,
    out_safe_rep_tab   OUT                return_safe_arr_result,
    in_from_date       IN                 DATE,
    in_to_date         IN                 DATE,
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
    lrec               return_safe_report;
    l_num_counter      NUMBER := 0;
    l_start_date       DATE := in_from_date;
    l_end_date         DATE := in_to_date + 1;
    l_sort_column      VARCHAR2(30) := lower(in_sort_column);
    l_order_by         VARCHAR2(10) := lower(in_order_by);
    l_location_id      VARCHAR2(256) := in_location;
    l_start_row        NUMBER := l_start_row_num;
    l_end_row          NUMBER := l_end_row_num;
    CURSOR cur_safe_data IS
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
                        r.id              request_id,
                        TO_CHAR(a.event_date, 'MM-DD-YYYY') startdate,
                        (
                            SELECT
                                address2
                            FROM
                                bi_location
                            WHERE
                                id = b.room
--                                AND b.room_type = 'MAIN_ROOM'
                        ) building,
                        fn_ts_to_time(a.arrival_ts, in_location, 0) starttime,
                        fn_ts_to_time(a.adjourn_ts, in_location, 0) endtime,
                        (
                            SELECT
                                name
                            FROM
                                bi_location
                            WHERE
                                id = b.room
--                                AND b.room_type = 'MAIN_ROOM'
                        ) room,
                        r.customer_name   customer_name,
                        r.host_name       host_name,
                        c.company         ext_att_customer_company,
                        c.first_name      ext_att_first_name,
                        c.last_name       ext_att_last_name,
                        c.email           ext_att_email,
                        c.designation     ext_att_title
                    FROM
                        bi_request r,
                        bi_request_activity_day a,
                        bi_request_act_day_room b,
                        bi_request_attendees c
                    WHERE
                        r.state = 'CONFIRMED'
                        AND r.id IN (
                            SELECT
                                request_id
                            FROM
                                bi_request_activity_day
                            WHERE
                                event_date BETWEEN l_start_date AND l_end_date
                        )
                        AND a.event_date BETWEEN l_start_date AND l_end_date
                        AND r.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = in_location
                        )
                        AND a.request_id = r.id
                        AND b.request_activity_day_id = a.id
                        AND r.id = c.request_id
                        AND c.attendee_type = 'externalattendees'
                    ORDER BY
                        r.start_date,
                        building,
                        starttime,
                        room,
                        ext_att_first_name,
                        ext_att_last_name
                ) a
            WHERE
                ROWNUM <= l_end_row
        )
    WHERE
        rn >= l_start_row;

    TYPE rec_safe_data IS
        TABLE OF cur_safe_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_safe_data    rec_safe_data;
BEGIN
    out_safe_rep_tab := return_safe_arr_result();
    OPEN cur_safe_data;
    LOOP
        FETCH cur_safe_data BULK COLLECT INTO l_cur_safe_data;
        EXIT WHEN l_cur_safe_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_safe_report();
        out_safe_rep_tab := return_safe_arr_result(return_safe_report());
        out_safe_rep_tab.DELETE;
        FOR i IN 1..l_cur_safe_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_safe_report();
                lrec.requestid := l_cur_safe_data(i).request_id;
                lrec.startdate := l_cur_safe_data(i).startdate;
                lrec.building := l_cur_safe_data(i).building;
                lrec.starttime := l_cur_safe_data(i).starttime;
                lrec.endtime := l_cur_safe_data(i).endtime;
                lrec.room := l_cur_safe_data(i).room;
                lrec.companyname := l_cur_safe_data(i).customer_name;
                lrec.host := l_cur_safe_data(i).host_name;
                lrec.company := l_cur_safe_data(i).ext_att_customer_company;
                lrec.firstname := l_cur_safe_data(i).ext_att_first_name;
                lrec.lastname := l_cur_safe_data(i).ext_att_last_name;
                lrec.email := l_cur_safe_data(i).ext_att_email;
                lrec.title := l_cur_safe_data(i).ext_att_title;
                IF l_num_counter > 1 THEN
                    out_safe_rep_tab.extend();
                    out_safe_rep_tab(l_num_counter) := return_safe_report();
                ELSE
                    out_safe_rep_tab := return_safe_arr_result(return_safe_report());
                END IF;

                out_safe_rep_tab(l_num_counter) := lrec;
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