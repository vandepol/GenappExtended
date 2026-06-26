      ******************************************************************
      *                                                                *
      * LICENSED MATERIALS - PROPERTY OF IBM.                          *
      *                                                                *
      * "RESTRICTED MATERIALS OF IBM".                                 *
      *                                                                *
      * CB12                                                           *
      *                                                                *
      * (C) COPYRIGHT IBM CORP. 2011, 2013 ALL RIGHTS RESERVED         *
      *                                                                *
      * US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,      *
      * OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE                   *
      * CONTRACT WITH IBM CORPORATION                                  *
      *                                                                *
      *                                                                *
      *                    ADD Customer                                *
      *                                                                *
      *   Business logic for adding a new customer.                    *
      *                                                                *
      *                                                                *
      *                                                                *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LGACUS01.
       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.
      *
       DATA DIVISION.

       WORKING-STORAGE SECTION.

      *----------------------------------------------------------------*
      * Common defintions                                              *
      *----------------------------------------------------------------*
      * Run time (debug) infomation for this invocation
        01  WS-HEADER.
           03 WS-EYECATCHER            PIC X(16)
                                        VALUE 'LGACUS01------WS'.
           03 WS-TRANSID               PIC X(4).
           03 WS-TERMID                PIC X(4).
           03 WS-TASKNUM               PIC 9(7).
           03 WS-FILLER                PIC X.
           03 WS-ADDR-DFHCOMMAREA      USAGE is POINTER.
           03 WS-CALEN                 PIC S9(4) COMP.

      * Variables for time/date processing
       01  WS-ABSTIME                  PIC S9(8) COMP VALUE +0.
       01  WS-TIME                     PIC X(8)  VALUE SPACES.
       01  WS-DATE                     PIC X(10) VALUE SPACES.

      * Error Message structure
       01  ERROR-MSG.
           03 EM-DATE                  PIC X(8)  VALUE SPACES.
           03 FILLER                   PIC X     VALUE SPACES.
           03 EM-TIME                  PIC X(6)  VALUE SPACES.
           03 FILLER                   PIC X(9)  VALUE ' LGACUS01'.
           03 EM-VARIABLE.
             05 FILLER                 PIC X(6)  VALUE ' CNUM='.
             05 EM-CUSNUM              PIC X(10)  VALUE SPACES.
             05 FILLER                 PIC X(6)  VALUE ' PNUM='.
             05 EM-POLNUM              PIC X(10)  VALUE SPACES.
             05 EM-SQLREQ              PIC X(16) VALUE SPACES.
             05 FILLER                 PIC X(9)  VALUE ' SQLCODE='.
             05 EM-SQLRC               PIC +9(5) USAGE DISPLAY.

       01  CA-ERROR-MSG.
           03 FILLER                   PIC X(9)  VALUE 'COMMAREA='.
           03 CA-DATA                  PIC X(90) VALUE SPACES.
      *----------------------------------------------------------------*

      *----------------------------------------------------------------*
      * Definitions required for data manipulation                     *
      *----------------------------------------------------------------*
      * Fields to be used to check that commarea is correct length
       01  WS-COMMAREA-LENGTHS.
           03 WS-CA-HEADER-LEN         PIC S9(4) COMP VALUE +18.
           03 WS-REQUIRED-CA-LEN       PIC S9(4)      VALUE +0.
       77  LGACDB01                    PIC X(8)       VALUE 'LGACDB01'.
       77  LGACVS01                    PIC X(8)       VALUE 'LGACVS01'.
       77  ATRANID                     PIC X(4)       VALUE 'DSC1'.

      *    Include copybook for defintion of customer details length
           COPY LGPOLICY.

      *----------------------------------------------------------------*
      * Response from sub-routines                                     *
      *----------------------------------------------------------------*
       01  WS-RESPONSE.
           03 WS-RESPONSE-CODE         PIC 9(2).
           03 WS-RESPONSE-MESSAGE      PIC X(78).

      *-----------------------WCAz-------------------------------------*
      * Variables for invoking Java programs
       01  WS-JAVA-VARIABLES.
           03 JAVA                     PIC X(8)  VALUE 'JAVA'.
           03 LGACJV01                 PIC X(8)  VALUE 'LGACJV01'.
           03 LGACJV02                 PIC X(8)  VALUE 'LGACJV02'.
           03 WS-STATUS                PIC X(5).
      *-----------------------WCAz-------------------------------------*

      ******************************************************************
      *    L I N K A G E     S E C T I O N
      ******************************************************************
       LINKAGE SECTION.

       01  DFHCOMMAREA.
             COPY LGCMAREA.

      ******************************************************************
      *    P R O C E D U R E S
      ******************************************************************
       PROCEDURE DIVISION.

      *----------------------------------------------------------------*
       MAINLINE SECTION.

      *----------------------------------------------------------------*
      * Common code                                                    *
      *----------------------------------------------------------------*
      * initialize working storage variables
           INITIALIZE WS-HEADER.
      * set up general variable
           MOVE EIBTRNID TO WS-TRANSID.
           MOVE EIBTRMID TO WS-TERMID.
           MOVE EIBTASKN TO WS-TASKNUM.
      *----------------------------------------------------------------*

      *----------------------------------------------------------------*
      * Process incoming commarea                                      *
      *----------------------------------------------------------------*
      * If NO commarea received issue an ABEND
           IF EIBCALEN IS EQUAL TO ZERO
               MOVE ' NO COMMAREA RECEIVED' TO EM-VARIABLE
               PERFORM WRITE-ERROR-MESSAGE
               EXEC CICS ABEND ABCODE('LGCA') NODUMP END-EXEC
           END-IF

      * initialize commarea return code to zero
           MOVE '00' TO CA-RETURN-CODE
           MOVE '00' TO CA-NUM-POLICIES
           MOVE EIBCALEN TO WS-CALEN.
           SET WS-ADDR-DFHCOMMAREA TO ADDRESS OF DFHCOMMAREA.

      * check commarea length
           ADD WS-CA-HEADER-LEN TO WS-REQUIRED-CA-LEN
           ADD WS-CUSTOMER-LEN  TO WS-REQUIRED-CA-LEN

      * if less set error return code and return to caller
           IF EIBCALEN IS LESS THAN WS-REQUIRED-CA-LEN
             MOVE '98' TO CA-RETURN-CODE
             EXEC CICS RETURN END-EXEC
           END-IF

      *----------------------------------------------------------------*
      * Call routine to check first name for numbers                   *
      *----------------------------------------------------------------*
      *************************WCAZ*************************************
           PERFORM CHECK-FIRST.
           If WS-RESPONSE-CODE > 0
             MOVE WS-RESPONSE-CODE TO CA-RETURN-CODE
             DISPLAY WS-RESPONSE-MESSAGE
             EXEC CICS RETURN END-EXEC
           End-if.

           PERFORM FRAUD-CHECK.
           If WS-STATUS NOT = 'valid'
             MOVE '81' TO CA-RETURN-CODE
             EXEC CICS RETURN END-EXEC
           End-if.
      *************************WCAZ*************************************
      *----------------------------------------------------------------*

      *----------------------------------------------------------------*
      * Call routine to Insert row in DB2 Customer table               *
           PERFORM INSERT-CUSTOMER.
           If CA-RETURN-CODE > 0
             EXEC CICS RETURN END-EXEC
           End-if.

      *----------------------------------------------------------------*
      *
           EXEC CICS RETURN END-EXEC.

       MAINLINE-EXIT.
           EXIT.
      *----------------------------------------------------------------*

      *************************WCAZ*************************************
       FRAUD-CHECK.
      * Check mobile phone number                                      *
           CALL JAVA   USING     LGACJV01
                                 CA-PHONE-MOBILE
                                 WS-STATUS
                                 CONTENT LENGTH OF CA-PHONE-MOBILE
                                 CONTENT LENGTH OF WS-STATUS.
       FRAUD-CHECK-EXIT.
           EXIT.

       CHECK-FIRST.
      * COBOL / Java  switch                                           *

           PERFORM CHECK-FIRST-JAVA.
      *     PERFORM CHECK-FIRST-COBOL.
       CHECK-FIRST-EXIT.
           EXIT.

       CHECK-FIRST-JAVA.
      * Check postcode (Java version)                                  *
           CALL JAVA   USING     LGACJV02
                                 CA-POSTCODE
                                 WS-RESPONSE
                                 CONTENT LENGTH OF CA-POSTCODE
                                 CONTENT LENGTH OF WS-RESPONSE.
       CHECK-FIRST-JAVA-EXIT.
           EXIT.

       CHECK-FIRST-COBOL.
      * Check postcode (COBOL version)                                 *
           MOVE '00' TO WS-RESPONSE-CODE.
           MOVE SPACES TO WS-RESPONSE-MESSAGE.
           IF FUNCTION UPPER-CASE (CA-POSTCODE(1:2)) = 'GB'

               CONTINUE
           ELSE IF FUNCTION UPPER-CASE (CA-POSTCODE(1:2)) = 'US'

               CONTINUE
           ELSE IF FUNCTION UPPER-CASE (CA-POSTCODE(1:2)) = 'UK'

               CONTINUE
           ELSE IF FUNCTION UPPER-CASE (CA-POSTCODE(1:2)) = 'DN'

               CONTINUE
           ELSE
               MOVE '82' TO WS-RESPONSE-CODE
               STRING 'Invalid postcode: ' CA-POSTCODE
                DELIMITED BY SIZE INTO WS-RESPONSE-MESSAGE
           END-IF.
       CHECK-FIRST-COBOL-EXIT.
           EXIT.

      *************************WCAZ*************************************
      *----------------------------------------------------------------*
      * DB2                                                            *
      *----------------------------------------------------------------*
       INSERT-CUSTOMER.
           IF WS-STATUS = 'valid'
               EXEC CICS LINK PROGRAM('LGACDB01')
                   COMMAREA(DFHCOMMAREA)
                   LENGTH(32500)
               END-EXEC
           ELSE IF WS-STATUS = 'error'
               EXEC CICS ABEND ABCODE('CUSE') NODUMP END-EXEC
           END-IF.
           EXIT.

      *================================================================*
      * Procedure to write error message to Queues                     *
      *   message will include Date, Time, Program Name, Customer      *
      *   Number, Policy Number and SQLCODE.                           *
      *================================================================*
       WRITE-ERROR-MESSAGE.
      * Save SQLCODE in message
      * Obtain and format current time and date
           EXEC CICS ASKTIME ABSTIME(WS-ABSTIME)
           END-EXEC
           EXEC CICS FORMATTIME ABSTIME(WS-ABSTIME)
                     MMDDYYYY(WS-DATE)
                     TIME(WS-TIME)
           END-EXEC
           MOVE WS-DATE TO EM-DATE
           MOVE WS-TIME TO EM-TIME
      * Write output message to TDQ
           EXEC CICS LINK PROGRAM('LGSTSQ')
                     COMMAREA(ERROR-MSG)
                     LENGTH(LENGTH OF ERROR-MSG)
           END-EXEC.
      * Write 90 bytes or as much as we have of commarea to TDQ
           IF EIBCALEN > 0 THEN
             IF EIBCALEN < 91 THEN
               MOVE DFHCOMMAREA(1:EIBCALEN) TO CA-DATA
               EXEC CICS LINK PROGRAM('LGSTSQ')
                         COMMAREA(CA-ERROR-MSG)
                         LENGTH(LENGTH OF CA-ERROR-MSG)
               END-EXEC
             ELSE
               MOVE DFHCOMMAREA(1:90) TO CA-DATA
               EXEC CICS LINK PROGRAM('LGSTSQ')
                         COMMAREA(CA-ERROR-MSG)
                         LENGTH(LENGTH OF CA-ERROR-MSG)
               END-EXEC
             END-IF
           END-IF.
           EXIT.
