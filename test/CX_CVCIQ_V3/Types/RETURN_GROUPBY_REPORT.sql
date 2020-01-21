CREATE OR REPLACE TYPE cx_cvciq_v3.return_groupby_report AS OBJECT (
   noofrecords    NUMBER,
   param   VARCHAR2(30),
   opportunityrevenue   NUMBER,
   CONSTRUCTOR FUNCTION return_groupby_report RETURN SELF AS RESULT
);

/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_groupby_report AS
   CONSTRUCTOR FUNCTION return_groupby_report RETURN SELF AS RESULT AS
   BEGIN
       self.noofrecords := NULL;
       self.param := NULL;
       self.opportunityrevenue := NULL;
       return;
   END;
END;

/