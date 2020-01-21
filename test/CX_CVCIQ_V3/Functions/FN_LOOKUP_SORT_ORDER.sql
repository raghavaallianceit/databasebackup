CREATE OR REPLACE FUNCTION cx_cvciq_v3.fn_lookup_sort_order (
    in_code VARCHAR2,
    in_loc_timezone VARCHAR2,
    in_lookup_type VARCHAR2
) RETURN VARCHAR2 IS
    l_lookup_value   VARCHAR2(500);
    l_lookup_type VARCHAR2(500) := in_lookup_type;
    l_code           VARCHAR2(100) := in_code;
BEGIN
    BEGIN
--         select distinct value into l_lookup_value from bi_lookup_value where code = l_code and location_id = 4300;
        SELECT
            LISTAGG(str, ',') WITHIN GROUP(
                ORDER BY
                    str
            ) into l_lookup_value
        FROM
            (
                SELECT
                    *
                FROM
                    (
                        SELECT DISTINCT
                            sort_order str
                        FROM
                            bi_lookup_value
                        WHERE
                            location_id = (
                        SELECT
                         id
                        FROM
                        BI_LOCATION
                        WHERE
                        UNIQUE_ID = in_loc_timezone
                        )
                            AND IS_ACTIVE = 1
                            AND  LOOKUP_TYPE_ID = (
                            select id from bi_lookup_type where CODE = l_lookup_type
                            )
                            AND code IN (
                                WITH data AS (
                                    SELECT
                                        l_code str
                                    FROM
                                        dual
                                )
                                SELECT
                                    TRIM(regexp_substr(str, '[^,]+', 1, level)) str
                                FROM
                                    data
                                CONNECT BY
                                    regexp_substr(str, '[^,]+', 1, level) IS NOT NULL
                            )
                    )
            );
--dbms_output.put_line('in_lookup_type:- '||in_lookup_type||'  in_code :- '||in_code ||'  l_lookup_value:-'||l_lookup_value);

    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error getting the Time' || sqlerrm);
    END;

    RETURN l_lookup_value;
END fn_lookup_sort_order;
/