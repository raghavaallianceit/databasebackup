CREATE OR REPLACE TYPE cx_cvciq_v3.return_topic_report AS OBJECT (                  
				requestId          		NUMBER  ,                    
				requestActivityDayId          		NUMBER  ,                    
				startDate                	VARCHAR2(50) ,
				company      	 		VARCHAR2(500),
                visitFocus	                VARCHAR2(256),
				briefingManager			VARCHAR2(500),
				hostName					VARCHAR2(60),
                companyCountry						VARCHAR2(500),
                topic                       VARCHAR2(4000),
                presenterName              VARCHAR2(60),
       CONSTRUCTOR FUNCTION return_topic_report RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY cx_cvciq_v3.return_topic_report AS
      CONSTRUCTOR FUNCTION return_topic_report RETURN SELF AS RESULT AS
      BEGIN
               SELF.requestId          := NULL;
               SELF.requestActivityDayId          := NULL;
               SELF.startDate          := NULL;
               SELF.company       := NULL;
               SELF.visitFocus         := NULL;
               SELF.briefingManager    := NULL;
               SELF.hostName          := NULL;
               SELF.companyCountry             := NULL;
               SELF.topic               := NULL;
               SELF.presenterName      := NULL;
         RETURN;
      END;
END;
/