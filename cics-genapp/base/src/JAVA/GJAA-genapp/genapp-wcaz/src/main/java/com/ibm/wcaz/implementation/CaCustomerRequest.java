package com.ibm.wcaz.implementation;

import com.ibm.jzos.fields.CobolDatatypeFactory;
import com.ibm.jzos.fields.StringField;
import java.io.UnsupportedEncodingException;
import java.util.Arrays;


//SF: Import CICS Container abstraction class
import com.ibmzpot.common.CobolData;

public class CaCustomerRequest extends Dfhcommarea1 {
    private String caPostcode = "";
    
    // SF: Constructor - initialise object using data provided in an input Container
    public CaCustomerRequest() {
        CobolData input = new CobolData();
        this.caPostcode = input.getCobolData();
    }
    
    public CaCustomerRequest(String caPostcode) {
        this.caPostcode = caPostcode;
    }
    
    public CaCustomerRequest(CaCustomerRequest that) {
        super(that);
        this.caPostcode = that.caPostcode;
    }
    
    protected CaCustomerRequest(byte[] bytes, int offset) {
        setBytes(bytes, offset);
    }
    
    protected CaCustomerRequest(byte[] bytes) {
        this(bytes, 0);
    }
    
    public static CaCustomerRequest fromBytes(byte[] bytes, int offset) {
        return new CaCustomerRequest(bytes, offset);
    }
    
    public static CaCustomerRequest fromBytes(byte[] bytes) {
        return fromBytes(bytes, 0);
    }
    
    public static CaCustomerRequest fromBytes(String bytes) {
        try {
            return fromBytes(bytes.getBytes(factory.getStringEncoding()));
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException(e);
        }
    }
    
    public String getCaPostcode() {
        return this.caPostcode;
    }
    
    public void setCaPostcode(String caPostcode) {
        this.caPostcode = caPostcode;
    }
    
    public void reset() {
        super.reset();
        caPostcode = "";
    }
    
    
    public String toString() {
        StringBuilder s = new StringBuilder(super.toString());
        s.append("{ caPostcode=\"");
        s.append(getCaPostcode());
        s.append("\"");
        s.append("}");
        return s.toString();
    }
    
    public boolean equals(CaCustomerRequest that) {
        return super.equals(that) &&
            this.caPostcode.equals(that.caPostcode);
    }
    
    @Override
    public boolean equals(Object that) {
        return (that instanceof CaCustomerRequest) && this.equals((CaCustomerRequest)that);
    }
    
    @Override
    public int hashCode() {
        return super.hashCode() ^
            caPostcode.hashCode();
    }
    
    public int compareTo(CaCustomerRequest that) {
        int c = 0;
        c = super.compareTo(that);
        if ( c != 0 ) return c;
        c = this.caPostcode.compareTo(that.caPostcode);
        return c;
    }
    
    @Override
    public int compareTo(Dfhcommarea1 that) {
        if (that instanceof CaCustomerRequest) {
            return this.compareTo((CaCustomerRequest)that);
        } else {
            int c = super.compareTo(that);
            // for compatibility with equals(), unequal objects shouldn't compare equal
            if ( c == 0 ) {
                return this.getClass().getTypeName().compareTo(that.getClass().getTypeName());
            } else {
                return c;
            }
        }
    }
    
    // Start of COBOL-compatible binary serialization metadata
    private static CobolDatatypeFactory factory = new CobolDatatypeFactory();
    static {
        factory.setStringTrimDefault(true);
        factory.setStringEncoding("IBM-1047");
        factory.incrementOffset(Dfhcommarea1.SIZE);
    }
    
    private static final StringField CAPOSTCODE = factory.getStringField(8);
    public static final int SIZE = factory.getOffset();
    // End of COBOL-compatible binary serialization metadata
    
    public byte[] getBytes(byte[] bytes, int offset) {
        super.getBytes(bytes, offset);
        CAPOSTCODE.putString(caPostcode, bytes, offset);
        return bytes;
    }
    
    public void setBytes(byte[] bytes, int offset) {
        if (bytes.length < SIZE + offset) {
            byte[] newBytes = Arrays.copyOf(bytes, SIZE + offset);
            Arrays.fill(newBytes, bytes.length, SIZE + offset, (byte)0x40 /*default EBCDIC space character*/);
            bytes = newBytes;
        }
        super.setBytes(bytes, offset);
        caPostcode = CAPOSTCODE.getString(bytes, offset);
    }
    
    public int numBytes() {
        return SIZE;
    }
}
