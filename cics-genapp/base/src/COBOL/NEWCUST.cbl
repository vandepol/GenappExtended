       IDENTIFICATION DIVISION.
       PROGRAM-ID. NEWCUST.
      *****************************************************************
      *                                                               *
      *   Test program to write into a Db2 table                      *
      *                                                               *
      *****************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      ******************************************************************
      *                  INPUT MAIN                                    *
      ******************************************************************
           SELECT INPUT01-FILE ASSIGN TO INFILE
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS FS-INPUT01.


       DATA DIVISION.
       FILE SECTION.
      ******************************************************************
      *                  INPUT SECONDARY                               *
      ******************************************************************
       FD  INPUT01-FILE
           RECORDING MODE IS F
           LABEL RECORDS STANDARD
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 140 CHARACTERS
           DATA RECORD IS IN-REC.
      ******************************************************************
      *                    COPY OF INPUT FILE 2                        *
      ******************************************************************
       01 IN-REC                            PIC X(140).



       WORKING-STORAGE SECTION.

       01 FS-FILE-STATUS.
          05 FS-INPUT01                     PIC X(02) VALUE SPACES.
             88 INP-OK                                VALUE '00'.

       01 WS-SWITCHES.
          05 WS-EOF-INP                     PIC X(01) VALUE ' '.
            88 END-OF-INP                             VALUE 'Y'.

       01 WS-IN-REC.
          05 IN-CUST-NUMBER                PIC 9(10).
          05 IN-CUST-FNAME                 PIC X(10) VALUE SPACES.
          05 IN-CUST-LNAME                 PIC X(10) VALUE SPACES.
          05 IN-CUST-DOB                   PIC X(10) VALUE SPACES.
          05 IN-CUST-HOUSENAME             PIC X(20) VALUE SPACES.
          05 IN-CUST-HOUSENBR              PIC X(04) VALUE SPACES.
          05 IN-CUST-POSTCODE              PIC X(08) VALUE SPACES.
          05 IN-CUST-PHONEHOME             PIC X(10) VALUE SPACES.
          05 IN-CUST-PHONEMOBILE           PIC X(10) VALUE SPACES.
          05 IN-CUST-EMAIL                 PIC X(40) VALUE SPACES.
          05 FILLER                        PIC X(08) VALUE SPACES.

       01 WS-DISPLAY-STATUS-PGM            PIC X(08) VALUE 'DISPSTAT'.
       01 WS-STATUS-CODE                   PIC 9(04) VALUE 0000.

          EXEC SQL
            INCLUDE CUSTOMER
           END-EXEC.

          EXEC SQL
            INCLUDE SQLCA
           END-EXEC.


       PROCEDURE DIVISION.
       0001-MAIN.

           DISPLAY 'START OF PROGRAM'
           PERFORM 1000-INITIALIZATION
              THRU 1000-EXIT
           PERFORM 1500-READ-INPUT
              THRU 1500-EXIT

           IF NOT END-OF-INP
              PERFORM 2000-MAIN-PARA
                 THRU 2000-EXIT
           END-IF

           PERFORM 9000-END-PARA
           .
       0001-MAIN-EXIT.
           EXIT.

       1000-INITIALIZATION.
           INITIALIZE WS-SWITCHES
           PERFORM 1100-OPEN-FILES
              THRU 1100-EXIT
           .
       1000-EXIT.
           EXIT.

       1100-OPEN-FILES.

           OPEN INPUT INPUT01-FILE

           IF NOT INP-OK
              DISPLAY '1100-OPEN-FILES:'
              DISPLAY 'INVALID FILE STATUS ON OPEN INPUT:' FS-INPUT01
              PERFORM 9000-END-PARA
           END-IF
           .
       1100-EXIT.
           EXIT.

       1500-READ-INPUT.

           READ INPUT01-FILE INTO WS-IN-REC
                AT END SET END-OF-INP TO TRUE.

           IF NOT INP-OK AND NOT END-OF-INP
              DISPLAY 'INVALID FILE STATUS ON READ:' FS-INPUT01
              PERFORM 9000-END-PARA
           END-IF
           .
       1500-EXIT.
           EXIT.

       2000-MAIN-PARA.

           INITIALIZE DCLCUSTOMER.
           MOVE IN-CUST-NUMBER   TO DCL-CUSTOMERNUMBER
           MOVE IN-CUST-FNAME    TO DCL-FIRSTNAME
           MOVE IN-CUST-LNAME    TO DCL-LASTNAME
           MOVE IN-CUST-DOB      TO DCL-DATEOFBIRTH
           MOVE IN-CUST-HOUSENAME
                                 TO DCL-HOUSENAME
           MOVE IN-CUST-HOUSENBR TO DCL-HOUSENUMBER
           MOVE IN-CUST-POSTCODE TO DCL-POSTCODE
           MOVE IN-CUST-PHONEHOME
                                 TO DCL-PHONEHOME
           MOVE IN-CUST-PHONEMOBILE
                                 TO DCL-PHONEMOBILE
           MOVE IN-CUST-EMAIL    TO DCL-EMAILADDRESS
      *****************************************************************
      *    IF DCL-POSTCODE (1:2) = 'GB'
      *       MOVE '44' TO  DCL-HOUSENUMBER(1:4)
      *    END-IF
      *****************************************************************
      * CAUSE A BUG
      *      MOVE 99               TO DCL-CUSTOMERNUMBER

           PERFORM 3000-INS-CUST-DETAILS
              THRU 3000-EXIT
            .
       2000-EXIT.
           EXIT.

       3000-INS-CUST-DETAILS.
           DISPLAY 'IN 3000:'

           EXEC SQL
               INSERT INTO CUSTOMER
               (CUSTOMERNUMBER
               ,FIRSTNAME
               ,LASTNAME
               ,DATEOFBIRTH
               ,HOUSENAME
               ,HOUSENUMBER
               ,POSTCODE
               ,PHONEHOME
               ,PHONEMOBILE
               ,EMAILADDRESS)
               VALUES (
                     :DCL-CUSTOMERNUMBER
                    ,:DCL-FIRSTNAME
                    ,:DCL-LASTNAME
                    ,:DCL-DATEOFBIRTH
                    ,:DCL-HOUSENAME
                    ,:DCL-HOUSENUMBER
                    ,:DCL-POSTCODE
                    ,:DCL-PHONEHOME
                    ,:DCL-PHONEMOBILE
                    ,:DCL-EMAILADDRESS)
           END-EXEC.

           DISPLAY 'SQLCODE:' SQLCODE
           Evaluate SQLCODE
             When 0
               DISPLAY 'SUCCESSFUL INSERT'
             When Other
               MOVE 0001 TO WS-STATUS-CODE

               DISPLAY 'INVALID SQLCODE:' SQLCODE
               PERFORM 9000-END-PARA
           END-Evaluate.

       3000-EXIT.
           EXIT.

       9000-END-PARA.

           GOBACK
           .
       9000-EXIT.
           EXIT.
