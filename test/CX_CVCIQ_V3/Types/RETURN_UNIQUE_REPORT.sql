CREATE OR REPLACE TYPE cx_cvciq_v3.return_unique_report AS OBJECT (
   value   VARCHAR2(3000),
   CONSTRUCTOR FUNCTION return_unique_report RETURN SELF AS RESULT
);


/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_unique_report AS
   CONSTRUCTOR FUNCTION return_unique_report RETURN SELF AS RESULT AS
   BEGIN
       self.value := NULL;
       return;
   END;
END;

/