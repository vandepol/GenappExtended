package com.ibmzpot.common;

import com.ibm.cics.server.Task;
import com.ibm.cics.server.Channel;
import com.ibm.cics.server.Container;
import com.ibm.cics.server.CicsConditionException;

public class CobolData {

    Task currentTask = Task.getTask();
    Channel currentChannel;
    String currentProgram = currentTask.getProgramName();

    public String getCobolData() { 

        Container inputContainer;
        String inputData = null;

        try {
            currentChannel = currentTask.getCurrentChannel();
	    if (currentChannel != null) {
               inputContainer = currentChannel.getContainer(currentProgram + "-INPUT");
               if (inputContainer != null) {
                  inputData = inputContainer.getString();
               }
            }
        } catch (CicsConditionException cce) {       
            throw new RuntimeException(cce);
        }
    
        return inputData;    
    }

    public void putCobolData(String outputData) { 

        Container outputContainer;

        try {
            currentChannel = currentTask.getCurrentChannel();
	    if (currentChannel != null) {
               outputContainer = currentChannel.createContainer(currentProgram + "-OUTPUT");
               outputContainer.putString(outputData); 
            }
        } catch (CicsConditionException cce) {       
            throw new RuntimeException(cce);
        }
    }

}
