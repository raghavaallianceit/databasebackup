CREATE OR REPLACE PROCEDURE cx_cvciq_v3.SURYA_TEST (
   var1 IN VARCHAR2,
   in_sort_column  varchar2,
   in_sort_order varchar)  AS
   sqlquery varchar2(4000);
BEGIN
     sqlquery:= 'select * from bi_request order by ' || in_sort_column || ' ' || in_sort_order;
      dbms_output.put_line('Constructed query from SQL : ' || sqlquery);
     EXECUTE IMMEDIATE sqlquery;
END;
/