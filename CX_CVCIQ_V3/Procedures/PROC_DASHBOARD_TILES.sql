CREATE OR REPLACE PROCEDURE cx_cvciq_v3.proc_dashboard_tiles (
    out_chr_err_code    OUT                 VARCHAR2,
    out_chr_err_msg     OUT                 VARCHAR2,
    out_dashboard_tab   OUT                 return_dashboard_arr,
    in_from_date        IN                  DATE,
    in_to_date          IN                  DATE,
--    in_groupby_column   IN                  VARCHAR2,
    in_location         IN                  VARCHAR2
) IS

    l_chr_srcstage         VARCHAR2(200);
    l_chr_biqtab           VARCHAR2(200);
    l_chr_srctab           VARCHAR2(200);
    l_chr_bistagtab        VARCHAR2(200);
    l_chr_err_code         VARCHAR2(255);
    l_chr_err_msg          VARCHAR2(255);
    l_out_chr_errbuf       VARCHAR2(2000);
    lrec                   return_dashboard_report;
    l_num_counter          NUMBER := 0;
    l_start_date           DATE := in_from_date;
    l_end_date             DATE := in_to_date + 1;
--    l_groupby_column     VARCHAR2(30) := upper(in_groupby_column);
    l_location_id          VARCHAR2(256) := in_location;
    CURSOR cur_dashboard_data IS
    SELECT
        COUNT(*) count,
        'Other visits' value,
        3 r_num
    FROM
        bi_request
    WHERE
        ( customer_tier NOT IN (
            1,
            2
        )
          OR customer_tier IS NULL )
        AND start_date BETWEEN l_start_date AND l_end_date
        AND state = 'CONFIRMED'
        AND request_type_id = 1
        AND location_id = (
            SELECT UNIQUE
                ( id )
            FROM
                bi_location
            WHERE
                unique_id = l_location_id
        )
    UNION
    SELECT
        COUNT(*) count,
        concat(concat('Tier ', customer_tier), ' Meetings') value,
        ROW_NUMBER() OVER(
            ORDER BY
                customer_tier
        ) r_num
    FROM
        bi_request
    WHERE
        customer_tier IN (
            1,
            2
        )
        AND state = 'CONFIRMED'
        AND request_type_id = 1
        AND start_date BETWEEN l_start_date AND l_end_date
        AND location_id = (
            SELECT UNIQUE
                ( id )
            FROM
                bi_location
            WHERE
                unique_id = l_location_id
        )
    GROUP BY
        customer_tier
    UNION
    SELECT
        SUM(c) count,
        'Unique Tier 1 visits' value,
        4 r_num
    FROM
        (
            SELECT
                COUNT(DISTINCT tenant_account_id) c
            FROM
                bi_request
            WHERE
                customer_tier = 1
                AND request_type_id = 1
                AND start_date BETWEEN l_start_date AND l_end_date
                AND state = 'CONFIRMED'
                AND location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
            GROUP BY
                customer_tier
        )
    UNION
    SELECT
        SUM(c) count,
        'Unique Tier 2 visits' value,
        5 r_num
    FROM
        (
            SELECT
                COUNT(DISTINCT tenant_account_id) c
            FROM
                bi_request
            WHERE
                customer_tier = 2
                AND request_type_id = 1
                AND start_date BETWEEN l_start_date AND l_end_date
                AND state = 'CONFIRMED'
                AND location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
            GROUP BY
                customer_tier
        )
    UNION
    SELECT
        COUNT(*) count,
        'Total Participants' value,
        6 r_num
    FROM
        bi_request_attendees
    WHERE
        attendee_type = 'externalattendees'
        AND request_id IN (
            SELECT
                id
            FROM
                bi_request
            WHERE
                start_date BETWEEN l_start_date AND l_end_date
                AND state = 'CONFIRMED'
                AND request_type_id = 1
                AND location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
        )
    UNION
    SELECT
        SUM(count) count,
        'Total Meetings' value,
        0 r_num
    FROM
        (
            SELECT
                COUNT(*) count
            FROM
                bi_request
            WHERE
                start_date BETWEEN l_start_date AND l_end_date
                AND state = 'CONFIRMED'
                AND request_type_id = 1
                AND location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
        )
    UNION
    SELECT
        COUNT(*) count,
        'Executives' value,
        7 r_num
    FROM
        bi_request_attendees
    WHERE
        corporate_title IS NOT NULL
        AND request_id IN (
            SELECT
                id
            FROM
                bi_request
            WHERE
                start_date BETWEEN l_start_date AND l_end_date
                AND state = 'CONFIRMED'
                AND request_type_id = 1
                AND location_id = (
                    SELECT UNIQUE
                        ( id )
                    FROM
                        bi_location
                    WHERE
                        unique_id = l_location_id
                )
        )
    ORDER BY
        r_num;

    TYPE rec_dashboard_data IS
        TABLE OF cur_dashboard_data%rowtype INDEX BY PLS_INTEGER;
    l_cur_dashboard_data   rec_dashboard_data;
BEGIN
    out_dashboard_tab := return_dashboard_arr();
    OPEN cur_dashboard_data;
--    dbms_output.put_line('l_groupby_column :-' || l_groupby_column);
    LOOP
        FETCH cur_dashboard_data BULK COLLECT INTO l_cur_dashboard_data;
        EXIT WHEN l_cur_dashboard_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_dashboard_report();
        out_dashboard_tab := return_dashboard_arr(return_dashboard_report());
        out_dashboard_tab.DELETE;
        FOR i IN 1..l_cur_dashboard_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_dashboard_report();
                lrec.count := l_cur_dashboard_data(i).count;
                lrec.value := l_cur_dashboard_data(i).value;
--                lrec.viewType := l_cur_dashboard_data(i).viewType;
                IF l_num_counter > 1 THEN
                    out_dashboard_tab.extend();
                    out_dashboard_tab(l_num_counter) := return_dashboard_report();
                ELSE
                    out_dashboard_tab := return_dashboard_arr(return_dashboard_report());
                END IF;

                out_dashboard_tab(l_num_counter) := lrec;
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