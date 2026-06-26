package com.ibmzpot.genapp;

import com.ibmzpot.common.CobolData;
import com.ibm.cics.server.invocation.CICSProgram;

public class CustomerValidation {

    // Make this Method available as a CICS program 
    @CICSProgram("LGACJV01")
    public void validateCustomer() {

        String inputData;
        String outputData;
        CobolData cd = new CobolData();

        // Input from caller is provided in a CICS Container
        inputData = cd.getCobolData();

        outputData = isNumeric(inputData) ? "valid" : "error";

        // Return Output to caller in a CICS Container
        cd.putCobolData(outputData);
    }


    public static boolean isNumeric(String str) {
        if (str == null) {
           return false;
        }
        try {
           double d = Double.parseDouble(str);
        } catch (NumberFormatException nfe) {
           return false;
        }
        return true;
    }

}
