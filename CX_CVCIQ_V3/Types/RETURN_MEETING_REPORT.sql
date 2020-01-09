CREATE OR REPLACE TYPE cx_cvciq_v3.return_meeting_report AS OBJECT (
   value    NUMBER,
   name   VARCHAR2(30),
   CONSTRUCTOR FUNCTION return_meeting_report RETURN SELF AS RESULT
);

/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_meeting_report AS
   CONSTRUCTOR FUNCTION return_meeting_report RETURN SELF AS RESULT AS
   BEGIN
       self.value := NULL;
       self.name := NULL;
       return;
   END;
END;
/