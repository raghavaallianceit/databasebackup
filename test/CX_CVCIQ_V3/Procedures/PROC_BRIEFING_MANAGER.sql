CREATE OR REPLACE PROCEDURE cx_cvciq_v3.proc_briefing_manager (
    out_chr_err_code    OUT                 VARCHAR2,
    out_chr_err_msg     OUT                 VARCHAR2,
    out_tab             OUT                 return_briefing_manager_arr,
    in_from_date        IN                  DATE,
    in_to_date          IN                  DATE,
    in_groupby_column   IN                  VARCHAR2,
    in_location         IN                  VARCHAR2
) IS

    l_chr_srcstage     VARCHAR2(200);
    l_chr_biqtab       VARCHAR2(200);
    l_chr_srctab       VARCHAR2(200);
    l_chr_bistagtab    VARCHAR2(200);
    l_chr_err_code     VARCHAR2(255);
    l_chr_err_msg      VARCHAR2(255);
    l_out_chr_errbuf   VARCHAR2(2000);
    lrec               return_briefing_manager_report;
    l_num_counter      NUMBER := 0;
    l_start_date       DATE := in_from_date;
    l_end_date         DATE := in_to_date + 1;
--    l_groupby_column     VARCHAR2(30) := upper(in_groupby_column);
    l_location_id      VARCHAR2(256) := in_location;
    CURSOR cursor_data IS
    SELECT
        COUNT(*) noofrecords,
        (
            SELECT
                concat(first_name, last_name)
            FROM
                bi_user
            WHERE
                id = briefing_manager
        ) groupbycolumn,
        nvl(SUM(CASE
            WHEN TRIM(translate(replace(opportunity_revenue, ',', ''), '0123456789-,.', ' ')) IS NULL THEN replace(opportunity_revenue
            , ',', '')
            ELSE '0'
        END), 0) opportunityrevenue,
        ROW_NUMBER() OVER(
            ORDER BY
                (
                    SELECT
                        concat(first_name, last_name)
                    FROM
                        bi_user
                    WHERE
                        id = briefing_manager
                )
        ) sort_order
    FROM
        bi_request
    WHERE
        briefing_manager IS NOT NULL
        AND location_id = (
            SELECT UNIQUE
                ( id )
            FROM
                bi_location
            WHERE
                unique_id = l_location_id
        )
        AND start_date BETWEEN l_start_date AND l_end_date
        AND state = 'CONFIRMED'
        AND request_type_id = 1
    GROUP BY
        briefing_manager
    ORDER BY
        sort_order;

    TYPE rec_groupby_data IS
        TABLE OF cursor_data%rowtype INDEX BY PLS_INTEGER;
    l_cursor_data      rec_groupby_data;
BEGIN
    out_tab := return_briefing_manager_arr();
    OPEN cursor_data;
--    dbms_output.put_line('l_groupby_column :-' || l_groupby_column);
    LOOP
        FETCH cursor_data BULK COLLECT INTO l_cursor_data;
        EXIT WHEN l_cursor_data.count = 0;
        dbms_output.put_line('here in first insert');
        lrec := return_briefing_manager_report();
        out_tab := return_briefing_manager_arr(return_briefing_manager_report());
        out_tab.DELETE;
        FOR i IN 1..l_cursor_data.count LOOP

--						 dbms_output.put_line('Inside cursor   '  );
            BEGIN
                l_num_counter := l_num_counter + 1;
                lrec := return_briefing_manager_report();
                lrec.noofrecords := l_cursor_data(i).noofrecords;
                lrec.param := l_cursor_data(i).groupbycolumn;
                lrec.opportunityrevenue := l_cursor_data(i).opportunityrevenue;
--                dbms_output.put_line('sort_order :-' || l_cursor_data(i).sort_order);
                IF l_num_counter > 1 THEN
                    out_tab.extend();
                    out_tab(l_num_counter) := return_briefing_manager_report();
                ELSE
                    out_tab := return_briefing_manager_arr(return_briefing_manager_report());
                END IF;

                out_tab(l_num_counter) := lrec;
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