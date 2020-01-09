CREATE OR REPLACE TYPE cx_cvciq_v3.return_revenue_report AS OBJECT (
   noofrecords    NUMBER,
   param   VARCHAR2(30),
   revenue NUMBER,
   CONSTRUCTOR FUNCTION return_revenue_report RETURN SELF AS RESULT
);


/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_revenue_report AS
   CONSTRUCTOR FUNCTION return_revenue_report RETURN SELF AS RESULT AS
   BEGIN
       self.noofrecords := NULL;
       self.param := NULL;
       self.revenue := NULL;
       return;
   END;
END;

/