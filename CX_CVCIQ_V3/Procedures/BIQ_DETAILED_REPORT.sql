CREATE OR REPLACE PROCEDURE cx_cvciq_v3.biq_detailed_report (
    out_chr_err_code       OUT                    VARCHAR2,
    out_chr_err_msg        OUT                    VARCHAR2,
    out_detailed_rep_tab   OUT                    return_detailed_arr_result,
    in_from_date           IN                     VARCHAR2,
    in_to_date             IN                     VARCHAR2,
    in_sort_column         IN                     VARCHAR2,
    in_order_by            IN                     VARCHAR2,
    in_location            IN                     VARCHAR2,
    l_start_row_num        IN                     NUMBER,
    l_end_row_num          IN                     NUMBER
) IS

    l_chr_srcstage        VARCHAR2(200);
    l_chr_biqtab          VARCHAR2(200);
    l_chr_srctab          VARCHAR2(200);
    l_chr_bistagtab       VARCHAR2(200);
    l_chr_err_code        VARCHAR2(255);
    l_chr_err_msg         VARCHAR2(255);
    l_out_chr_errbuf      VARCHAR2(2000);
    lrec                  return_detailed_report;
    l_num_counter         NUMBER := 0;
    l_start_date          DATE := TO_DATE(in_from_date, 'dd-mm-yyyy hh24:mi:ss');
    l_end_date            DATE := TO_DATE(in_to_date, 'dd-mm-yyyy hh24:mi:ss');
    l_sort_column         VARCHAR2(30) := lower(in_sort_column);
    l_order_by            VARCHAR2(10) := lower(in_order_by);
    l_location_id         VARCHAR2(256) := in_location;
    l_start_row           NUMBER := l_start_row_num;
    l_end_row             NUMBER := l_end_row_num;
    CURSOR cur_detailed_data IS
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
                        r.id               requestid,
                        TO_CHAR(d.event_date, 'MM/DD/YYYY') startdate,
                        TO_DATE(d.event_date, 'dd-mm-yyyy') r_date,
                        (
                            SELECT
                                name
                            FROM
                                bi_location
                            WHERE
                                id = b.room
                        ) room,
                        b.room_type        r_type,
                        r.customer_name    company,
                        r.country          companycountry,
                        fn_code_to_lookup(r.industry, in_location, 'CUSTOMER_INDUSTRY') industry,
                        fn_code_to_lookup(r.customer_tier, in_location, 'TIER') tier,
                        fn_code_to_lookup(r.visit_type, in_location, CASE r.request_type_id
                            WHEN 1   THEN 'VISIT_TYPE'
                            WHEN 3   THEN 'NCV_VISIT_TYPE'
                        END) visittype,
                        fn_code_to_lookup(r.visit_focus, in_location, 'VISIT_FOCUS') visitfocus,
                        (
                            SELECT
                                u.user_name
                            FROM
                                bi_user u
                            WHERE
                                u.id = r.briefing_manager
                        ) briefingmanager,
                        r.host_email       host,
                        (
                            SELECT
                                u.user_name
                            FROM
                                bi_user u
                            WHERE
                                u.id = r.requestor
                        ) requestor,
                        p.opportunity_id   oppnumber,
                        CASE
                            WHEN TRIM(translate(replace(r.opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN replace
                            (r.opportunity_revenue, ',', '')
                            ELSE '0'
                        END opprevenue,
                        a.first_name       first_name,
                        upper(a.first_name) upper_first_name,
                        a.last_name        last_name,
                        upper(a.last_name) upper_last_name,
                        a.designation      title,
                        DECODE(a.attendee_type, 'externalattendees', 'External', 'Internal') attendee_type,
                        r.cost_center      costcenter,
                        r.duration         duration
                    FROM
                        bi_request r
                        LEFT JOIN bi_request_attendees a ON a.request_id = r.id
                        LEFT JOIN bi_request_activity_day d ON d.request_id = r.id
                        LEFT JOIN bi_request_opportunity p ON p.request_id = r.id
                        LEFT JOIN bi_request_act_day_room b ON b.request_activity_day_id = d.id
                    WHERE
                        r.state = 'CONFIRMED'
                        AND d.event_date BETWEEN l_start_date AND l_end_date
                        AND r.location_id = (
                            SELECT UNIQUE
                                ( id )
                            FROM
                                bi_location
                            WHERE
                                unique_id = in_location
                        )
                    ORDER BY
                        r_date,
                        requestid,
                        b.room_type DESC,
                        room,
                        customer_name,
                        oppnumber,
                        attendee_type,
                        upper_first_name,
                        upper_last_name,
                        CASE l_order_by
                            WHEN 'asc'   THEN CASE l_sort_column
                                WHEN 'companycountry'   THEN country
                            END
                        END,
                        CASE l_order_by
                            WHEN 'desc'   THEN CASE l_sort_column
                                WHEN 'companycountry'   THEN country
                            END
                        END DESC
                ) a
            WHERE
                ROWNUM <= l_end_row
        )
    WHERE
        rn >= l_start_row;

    TYPE rec_detailed_data IS
        TABLE OF cur_detailed_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_detailed_data   rec_detailed_data;
BEGIN
    out_detailed_rep_tab := return_detailed_arr_result();
    OPEN cur_detailed_data;
    LOOP
        FETCH cur_detailed_data BULK COLLECT INTO l_cur_detailed_data LIMIT 1000;
        EXIT WHEN l_cur_detailed_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_detailed_report();
        out_detailed_rep_tab := return_detailed_arr_result(return_detailed_report());
        out_detailed_rep_tab.DELETE;
        FOR i IN 1..l_cur_detailed_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_detailed_report();
                lrec.requestid := l_cur_detailed_data(i).requestid;
                lrec.startdate := l_cur_detailed_data(i).startdate;
                lrec.room := l_cur_detailed_data(i).room;
                lrec.company := l_cur_detailed_data(i).company;
                lrec.companycountry := l_cur_detailed_data(i).companycountry;
                lrec.industry := l_cur_detailed_data(i).industry;
                lrec.tier := l_cur_detailed_data(i).tier;
                lrec.visittype := l_cur_detailed_data(i).visittype;
                lrec.visitfocus := l_cur_detailed_data(i).visitfocus;
                lrec.briefingmanager := l_cur_detailed_data(i).briefingmanager;
                lrec.host := l_cur_detailed_data(i).host;
                lrec.requestor := l_cur_detailed_data(i).requestor;
                lrec.oppnumber := l_cur_detailed_data(i).oppnumber;
                lrec.opprevenue := l_cur_detailed_data(i).opprevenue;
                lrec.firstname := l_cur_detailed_data(i).first_name;
                lrec.lastname := l_cur_detailed_data(i).last_name;
                lrec.title := l_cur_detailed_data(i).title;
                lrec.attendeetype := l_cur_detailed_data(i).attendee_type;
                lrec.costcenter := l_cur_detailed_data(i).costcenter;
                lrec.duration := l_cur_detailed_data(i).duration;
                IF l_num_counter > 1 THEN
                    out_detailed_rep_tab.extend();
                    out_detailed_rep_tab(l_num_counter) := return_detailed_report();
                ELSE
                    out_detailed_rep_tab := return_detailed_arr_result(return_detailed_report());
                END IF;

                out_detailed_rep_tab(l_num_counter) := lrec;
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