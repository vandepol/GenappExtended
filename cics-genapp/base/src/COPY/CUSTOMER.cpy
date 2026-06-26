      ******************************************************************
      * DCLGEN TABLE(GENADB0.CUSTOMER)                                 *
      *        LIBRARY(NATHAN.ZUNIT.DEMO.BATCH.COPY(CUSTOMER))         *
      *        ACTION(REPLACE)                                         *
      *        LANGUAGE(COBOL)                                         *
      *        NAMES(DCL-)                                             *
      *        QUOTE                                                   *
      *        COLSUFFIX(YES)                                          *
      *        INDVAR(YES)                                             *
      * ... IS THE DCLGEN COMMAND THAT MADE THE FOLLOWING STATEMENTS   *
      ******************************************************************
           EXEC SQL DECLARE GENADB1.CUSTOMER TABLE
           ( CUSTOMERNUMBER                 INTEGER NOT NULL,
             FIRSTNAME                      CHAR(10),
             LASTNAME                       CHAR(20),
             DATEOFBIRTH                    DATE,
             HOUSENAME                      CHAR(20),
             HOUSENUMBER                    CHAR(4),
             POSTCODE                       CHAR(8),
             PHONEHOME                      CHAR(20),
             PHONEMOBILE                    CHAR(20),
             EMAILADDRESS                   CHAR(100)
           ) END-EXEC.
      ******************************************************************
      * COBOL DECLARATION FOR TABLE GENADB0.CUSTOMER                   *
      ******************************************************************
       01  DCLCUSTOMER.
      *                       CUSTOMERNUMBER
           10 DCL-CUSTOMERNUMBER   PIC S9(9) USAGE COMP.
      *                       FIRSTNAME
           10 DCL-FIRSTNAME        PIC X(10).
      *                       LASTNAME
           10 DCL-LASTNAME         PIC X(20).
      *                       DATEOFBIRTH
           10 DCL-DATEOFBIRTH      PIC X(10).
      *                       HOUSENAME
           10 DCL-HOUSENAME        PIC X(20).
      *                       HOUSENUMBER
           10 DCL-HOUSENUMBER      PIC X(4).
      *                       POSTCODE
           10 DCL-POSTCODE         PIC X(8).
      *                       PHONEHOME
           10 DCL-PHONEHOME        PIC X(20).
      *                       PHONEMOBILE
           10 DCL-PHONEMOBILE      PIC X(20).
      *                       EMAILADDRESS
           10 DCL-EMAILADDRESS     PIC X(100).
      ******************************************************************
      * INDICATOR VARIABLE STRUCTURE                                   *
      ******************************************************************
       01  ICUSTOMER.
           10 INDSTRUC           PIC S9(4) USAGE COMP OCCURS 10 TIMES.
      ******************************************************************
      * THE NUMBER OF COLUMNS DESCRIBED BY THIS DECLARATION IS 10      *
      ******************************************************************
