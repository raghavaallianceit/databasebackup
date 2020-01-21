CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_security_report (
    out_chr_err_code   OUT                VARCHAR2,
    out_chr_err_msg    OUT                VARCHAR2,
    out_security_tab   OUT                return_security_arr_result,
    in_from_date       IN                 VARCHAR2,
    in_to_date         IN                 VARCHAR2,
    in_sort_column     IN                 VARCHAR2,
    in_order_by        IN                 VARCHAR2,
    in_location        IN                 VARCHAR2,
    l_start_row_num    IN                 NUMBER,
    l_end_row_num      IN                 NUMBER
) IS

    l_chr_srcstage        VARCHAR2(200);
    l_chr_biqtab          VARCHAR2(200);
    l_chr_srctab          VARCHAR2(200);
    l_chr_bistagtab       VARCHAR2(200);
    l_chr_err_code        VARCHAR2(255);
    l_chr_err_msg         VARCHAR2(255);
    l_out_chr_errbuf      VARCHAR2(2000);
    lrec                  return_security_report;
    l_num_counter         NUMBER := 0;
    l_start_date          DATE := TO_DATE(in_from_date, 'dd-mm-yyyy hh24:mi:ss');
    l_end_date            DATE := TO_DATE(in_to_date, 'dd-mm-yyyy hh24:mi:ss');
    l_sort_column         VARCHAR2(30) := lower(in_sort_column);
    l_order_by            VARCHAR2(10) := lower(in_order_by);
    l_location_id         VARCHAR2(256) := in_location;
    l_start_row           NUMBER := l_start_row_num;
    l_end_row             NUMBER := l_end_row_num;
    CURSOR cur_security_data IS
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
                        TO_CHAR(a.event_date, 'MM/DD/YYYY') event_date,
                        fn_ts_to_time(c.start_time, l_location_id, 0) starttime,
                        fn_ts_to_time(c.end_time, l_location_id, 0) endtime,
                        c.start_time      sort_start_time,
                        c.end_time        sort_end_time,
                        r.customer_name   customer_name,
                        r.host_email      host_email,
                        (
                            SELECT
                                d.user_name
                            FROM
                                bi_user d
                            WHERE
                                d.id = r.briefing_manager
                        ) briefingmanager,
                        (
                            SELECT
                                name
                            FROM
                                bi_location
                            WHERE
                                id = c.room
                        ) room,
                        (
                            SELECT
                                code
                            FROM
                                bi_location
                            WHERE
                                id = c.room
                        ) building,
                        r.country         country,
                        b.company         custcompanyname,
                        b.first_name      first_name,
                        b.last_name       lastname,
                        b.designation     title,
                        DECODE(b.attendee_type, 'externalattendees', 'External', 'Internal') attendeetype
                    FROM
                        bi_request r
                        LEFT OUTER JOIN bi_request_activity_day a ON a.request_id = r.id
                        LEFT OUTER JOIN bi_request_attendees b ON b.request_id = r.id
--                                                                  AND b.attendee_type = 'externalattendees'
                        LEFT OUTER JOIN bi_request_act_day_room c ON c.request_activity_day_id = a.id
                                                                     AND c.room_type = 'MAIN_ROOM'
                    WHERE
                        r.state = 'CONFIRMED'
                        AND a.event_date BETWEEN l_start_date AND l_end_date
                        AND b.attendee_type = 'externalattendees'
                        AND r.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = l_location_id
                        )
                    ORDER BY
                        a.event_date,
                        starttime,
                        c.room_type DESC,
                        room,
                        attendeetype,
                        b.first_name,
                        b.last_name,
                        CASE l_order_by
                            WHEN 'asc'   THEN CASE l_sort_column
                                WHEN 'room'      THEN room
                                WHEN 'company'   THEN customer_name
                            END
                        END,
                        CASE l_order_by
                            WHEN 'asc'   THEN CASE l_sort_column
                                WHEN 'endtime'   THEN sort_end_time
                            END
                        END,
                        CASE l_order_by
                            WHEN 'desc'   THEN CASE l_sort_column
                                WHEN 'endtime'   THEN sort_end_time
                            END
                        END DESC,
                        CASE l_order_by
                            WHEN 'desc'   THEN CASE l_sort_column
                                WHEN 'room'      THEN room
                                WHEN 'company'   THEN customer_name
                            END
                        END DESC
                ) a
            WHERE
                ROWNUM <= l_end_row
        )
    WHERE
        rn >= l_start_row;

    TYPE rec_security_data IS
        TABLE OF cur_security_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_security_data   rec_security_data;
BEGIN
    out_security_tab := return_security_arr_result();
    OPEN cur_security_data;
    LOOP
        FETCH cur_security_data BULK COLLECT INTO l_cur_security_data;
        EXIT WHEN l_cur_security_data.count = 0;
        dbms_output.put_line('here in first insert');
--		     DBMS_OUTPUT.PUT_LINE ('l_start_date'|| ' ' ||l_start_date || ' end :- '|| l_end_date ||' l_sort_column ' ||l_sort_column);
        lrec := return_security_report();
        out_security_tab := return_security_arr_result(return_security_report());
        out_security_tab.DELETE;
        FOR i IN 1..l_cur_security_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_security_report();
                lrec.requestid := l_cur_security_data(i).requestid;
                lrec.startdate := l_cur_security_data(i).event_date;
                lrec.starttime := l_cur_security_data(i).starttime;
                lrec.endtime := l_cur_security_data(i).endtime;
                lrec.room := l_cur_security_data(i).room;
                lrec.company := l_cur_security_data(i).customer_name;
                lrec.building := l_cur_security_data(i).building;
                lrec.host := l_cur_security_data(i).host_email;
                lrec.briefingmanager := l_cur_security_data(i).briefingmanager;
                lrec.country := l_cur_security_data(i).country;
                lrec.custcompanyname := l_cur_security_data(i).custcompanyname;
                lrec.firstname := l_cur_security_data(i).first_name;
                lrec.lastname := l_cur_security_data(i).lastname;
                lrec.title := l_cur_security_data(i).title;
                lrec.attendeetype := l_cur_security_data(i).attendeetype;
                IF l_num_counter > 1 THEN
                    out_security_tab.extend();
                    out_security_tab(l_num_counter) := return_security_report();
                ELSE
                    out_security_tab := return_security_arr_result(return_security_report());
                END IF;

                out_security_tab(l_num_counter) := lrec;
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