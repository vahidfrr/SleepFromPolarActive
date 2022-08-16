# Extract Sleep Period From Polar Active

This sctipt will first find all the sustained movement bouts lasting (MET values constantly ≥1 MET) for more than 45 minutes, and examine the preiods in-between these bouts, to see if these bouts are potentialsleep periods. However, this approach would result in identifying multiple periods. We selected the longest period as sleep period.

Use [Toy_data.csv](https://github.com/vahidfrr/SleepFromPolarActive/blob/main/Toy_data.csv) to run the code. 

# Output

The output is a series of figures, marking the sleep periods on top of MET values. 

Here is an example from the  [Toy_data.csv](https://github.com/vahidfrr/SleepFromPolarActive/blob/main/Toy_data.csv):

<img src="https://github.com/vahidfrr/SleepFromPolarActive/blob/master/Example of output.jpg" alt="selfie">

The sleep period per 24-hour will be in the list: RecRestSleep_List
