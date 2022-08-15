# Extract Sleep Period From Polar Active

This sctipt will first find all the sustainded movement bouts lasting (MET values constantly ≥1 MET) for more than 10 minutes, and examine the preiods in-between these bouts, to see if these bouts contain sleep periods. However, due to spontaneous movement, multiple periods were identifed. These periods were combined into one if the interuption did not last more than 45 minutes.

Use [Toy_data.csv](https://github.com/vahidfrr/SleepFromPolarActive/blob/main/Toy_data.csv) to run the code. 

# Output

The output is a series of figure, marking the sleep periods on top of MET values. 

The period per day will be in the list: RecRestSleep_List
