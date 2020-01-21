CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_compliance_report (
    out_chr_err_code     OUT                  VARCHAR2,
    out_chr_err_msg      OUT                  VARCHAR2,
    out_compliance_tab   OUT                  return_compliance_arr_result,
    in_from_date         IN                   VARCHAR2,
    in_to_date           IN                   VARCHAR2,
    in_sort_column       IN                   VARCHAR2,
    in_order_by          IN                   VARCHAR2,
    in_location          IN                   VARCHAR2,
    l_start_row_num      IN                   NUMBER,
    l_end_row_num        IN                   NUMBER
) IS

    l_chr_srcstage          VARCHAR2(200);
    l_chr_biqtab            VARCHAR2(200);
    l_chr_srctab            VARCHAR2(200);
    l_chr_bistagtab         VARCHAR2(200);
    l_chr_err_code          VARCHAR2(255);
    l_chr_err_msg           VARCHAR2(255);
    l_out_chr_errbuf        VARCHAR2(2000);
    lrec                    return_compliance_report;
    l_num_counter           NUMBER := 0;
    l_start_date            DATE := TO_DATE(in_from_date, 'dd-mm-yyyy hh24:mi:ss');
    l_end_date              DATE := TO_DATE(in_to_date, 'dd-mm-yyyy hh24:mi:ss');
    l_sort_column           VARCHAR2(30) := lower(in_sort_column);
    l_order_by              VARCHAR2(10) := lower(in_order_by);
    l_location_id           VARCHAR2(256) := in_location;
    l_start_row             NUMBER := l_start_row_num;
    l_end_row               NUMBER := l_end_row_num;
    CURSOR cur_compliance_data IS
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
                        r.id                    requestid,
                        TO_CHAR(d.event_date, 'MM/DD/YYYY') event_date,
                        (
                            SELECT
                                name
                            FROM
                                bi_location
                            WHERE
                                id = c.room
                        ) room,
                        r.customer_name         company,
                        r.country               companycountry,
                        r.duration              duration,
                        (
                            SELECT
                                u.user_name
                            FROM
                                bi_user u
                            WHERE
                                u.id = r.briefing_manager
                        ) briefingmanager,
                        r.host_email            host,
                        DECODE(r.is_compliant, 1, 'Yes', 'No') compliance,
                        nvl(r.no_of_gifts, 0) giftcount,
                        r.gift_type             gifttype,
                        c.catering_type         cateringtype,
                        c.notes                 notes,
                        a.company               custcompanyname,
                        a.first_name            extfirstname,
                        a.first_name            upper_extfirstname,
                        a.last_name             extlastname,
                        a.last_name             upper_extlastname,
                        a.designation           exttitle,
                        c.activity_start_time   activity_start_time,
                        c.id                    cateringactivityid
                    FROM
                        bi_request r
                        LEFT JOIN bi_request_attendees a ON a.request_id = r.id
                                                            AND a.attendee_type = 'externalattendees'
                        JOIN bi_request_activity_day d ON d.request_id = r.id
                        LEFT JOIN bi_request_catering_activity c ON c.request_activity_day_id = d.id
                    WHERE
                        r.state = 'CONFIRMED'
                        AND d.event_date BETWEEN l_start_date AND l_end_date
                        AND r.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = l_location_id
                        )
                    ORDER BY
                        d.event_date,
                        room,
                        company,
                        cateringtype,
                        upper_extfirstname,
                        upper_extlastname,
                        cateringactivityid,
                        activity_start_time,
                        CASE l_order_by
                            WHEN 'asc'   THEN CASE l_sort_column
                                WHEN 'companycountry'   THEN companycountry
                                WHEN 'startdate'        THEN event_date
                            END
                        END,
                        CASE l_order_by
                            WHEN 'desc'   THEN CASE l_sort_column
                                WHEN 'companycountry'   THEN companycountry
                                WHEN 'startdate'        THEN event_date
                            END
                        END DESC
                ) a
            WHERE
                ROWNUM <= l_end_row
        )
    WHERE
        rn >= l_start_row;

    TYPE rec_compliance_data IS
        TABLE OF cur_compliance_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_compliance_data   rec_compliance_data;
BEGIN
    out_compliance_tab := return_compliance_arr_result();
    OPEN cur_compliance_data;
    LOOP
        FETCH cur_compliance_data BULK COLLECT INTO l_cur_compliance_data LIMIT 1000;
        EXIT WHEN l_cur_compliance_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_compliance_report();
        out_compliance_tab := return_compliance_arr_result(return_compliance_report());
        out_compliance_tab.DELETE;
        FOR i IN 1..l_cur_compliance_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_compliance_report();
                lrec.requestid := l_cur_compliance_data(i).requestid;
                lrec.startdate := l_cur_compliance_data(i).event_date;
                lrec.room := l_cur_compliance_data(i).room;
                lrec.company := l_cur_compliance_data(i).company;
                lrec.companycountry := l_cur_compliance_data(i).companycountry;
                lrec.duration := l_cur_compliance_data(i).duration;
                lrec.briefingmanager := l_cur_compliance_data(i).briefingmanager;
                lrec.compliance := l_cur_compliance_data(i).compliance;
                lrec.host := l_cur_compliance_data(i).host;
                lrec.giftcount := l_cur_compliance_data(i).giftcount;
                lrec.gifttype := l_cur_compliance_data(i).gifttype;
                lrec.cateringtype := l_cur_compliance_data(i).cateringtype;
                lrec.notes := l_cur_compliance_data(i).notes;
                lrec.custcompanyname := l_cur_compliance_data(i).custcompanyname;
                lrec.extfirstname := l_cur_compliance_data(i).extfirstname;
                lrec.extlastname := l_cur_compliance_data(i).extlastname;
                lrec.exttitle := l_cur_compliance_data(i).exttitle;
                IF l_num_counter > 1 THEN
                    out_compliance_tab.extend();
                    out_compliance_tab(l_num_counter) := return_compliance_report();
                ELSE
                    out_compliance_tab := return_compliance_arr_result(return_compliance_report());
                END IF;

                out_compliance_tab(l_num_counter) := lrec;
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