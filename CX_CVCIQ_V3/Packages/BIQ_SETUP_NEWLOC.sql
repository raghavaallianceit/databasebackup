CREATE OR REPLACE PACKAGE cx_cvciq_v3.biq_setup_newloc 
AS
PROCEDURE biq_create_new_loc(
    copyFromLocationId IN NUMBER,
    toLocationId       IN NUMBER ,
    out_chr_errbuf   OUT VARCHAR2,
    out_chr_err_code OUT VARCHAR2,
    out_chr_err_msg  OUT VARCHAR2 );


PROCEDURE biq_create_new_loc_calendar 
(  copyFromLocationId IN VARCHAR2,
   toLocationId  IN VARCHAR2 ,
   out_chr_errbuf OUT VARCHAR2,
   out_chr_err_code OUT VARCHAR2,
   out_chr_err_msg  OUT VARCHAR2
   );

     PROCEDURE biq_delete_data(
      copyFromLocationId IN NUMBER);

END;
/