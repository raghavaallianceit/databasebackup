CREATE OR REPLACE FUNCTION cx_cvciq_v3.fn_json_to_array (
    json_doc    IN          VARCHAR2,
    in_column   IN          VARCHAR2
) RETURN char_array AS

    x               char_array;
    company_array   VARCHAR2(100);
    varpath         VARCHAR2(30);
    v_query_str     VARCHAR2(4000);
BEGIN
    varpath := in_column;
    v_query_str := 'SELECT
        JSON_VALUE('''
                   || json_doc
                   || ''',  ''$.'
                   || varpath
                   || ''')
    FROM
        dual';
    EXECUTE IMMEDIATE v_query_str
    INTO company_array;
    SELECT
        fn_varchar_to_array(company_array)
    INTO x
    FROM
        dual;

    RETURN x;
END fn_json_to_array;
/