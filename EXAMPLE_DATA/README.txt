# TEMPLATE FOR INTEGRATING IRGA SMALL GAS INJECTION:

The excel file has the following columns:

UID: Unique identification. This is a number from 1 to the number of injected standards and samples.	
Indentification: The identification of the sample or standard. Standards injected in the same bout should have the SAME name (e.g., S1 for the first set, S2 for the second set).
Standard: A Boolean as to whether it is a standard.
Time_Inject: The time injected into the IRGA in the format hh:mm:ss using the clock ON THE IRGA COMPUTER	
FlowRate: The flow rate in ml/min (typically 0.1 or 0.2).	
Notes: Any notes


The IRGA outputs are saved here using the logging function in the Licor program. This file must be called IRGA_output.txt
