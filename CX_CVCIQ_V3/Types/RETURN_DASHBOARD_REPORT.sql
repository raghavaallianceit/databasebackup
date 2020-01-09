CREATE OR REPLACE TYPE cx_cvciq_v3.return_dashboard_report AS OBJECT (
   count    NUMBER,
   value   VARCHAR2(30),
--   viewType VARCHAR2(30),
   CONSTRUCTOR FUNCTION return_dashboard_report RETURN SELF AS RESULT
);


/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_dashboard_report AS
   CONSTRUCTOR FUNCTION return_dashboard_report RETURN SELF AS RESULT AS
   BEGIN
       self.count := NULL;
       self.value := NULL;
       return;
   END;
END;
/