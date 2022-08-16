clear;
clc;
close all;

Data=readtable('Toy_data.csv'); % The adress tp to the Polar CSV file name
METvalues=(table2array(Data(:,3))); % MET values are in the 3rd row
DateTime=(table2array(Data(:,2))); % date and time are in the 


DateTime.Format='HH:mm:ss'; % Define the format for time 
Time= cellstr(DateTime); % Seperate time

DateTime.Format = 'dd-MMM-yyyy'; % Define the format for date
Date = cellstr(DateTime);  % seperate the date

DateList=sort(datetime(unique(Date(:,1)))); % Get the list of days/dates in the file

% Create list for extracting the variables
varTypes = {'datetime','string','datetime','string'};
varNames = {'Date_Start','Time_Start','Date_End','Time_End'};
sz = [length(DateList)-1 4];
RecRestSleep_List = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);


% intialize the variables
RecRestSleep_List_Count=1;
DateArray_Start=0;


for k=2:length(DateList)-1 %First day is always excluded
    
    % Seperate one day from 18 to 18 next  day. Change the time in 24 hour format
    OneDayIndices=((Date==DateList(k))&(string(Time)>='18:00:00'))|((Date==DateList(k+1))&(string(Time)<'18:00:00')); 
    METValues_OneDay=METvalues(OneDayIndices);
    Dates_OneDay=DateTime(OneDayIndices);
    Times_OneDay=Time(OneDayIndices);
    
    % Create a Nan vector for visualization purposes.
    % These Nan vectors will be used to show rest/sleep period
    vector_RestBouts=NaN(length(METValues_OneDay),1); 

    
    
    %%%%%Check for non-wear. All bouts more than 2.5 hours with measurement
    %%%%%constantly < 1 MET is nonwear.
    METValues_OneDay_Indices_BELOW1MET=(METValues_OneDay<1);
    CosecutiveOnes_Indices_BELOW1MET= find(diff([0;(METValues_OneDay_Indices_BELOW1MET);0]==1));
    StartIndices = CosecutiveOnes_Indices_BELOW1MET(1:2:end-1);  % Start indices
    EndIndices=CosecutiveOnes_Indices_BELOW1MET(2:2:end);  % End indices
    ConsecutiveOnes_Count_BELOW1MET = EndIndices-StartIndices;  % Consecutive ones counts
    ConsecutiveOnes_Count_BELOW1MET;
    NonWearBout_indices=ConsecutiveOnes_Count_BELOW1MET>=300; % identify non-wear bouts
    NonWearBout_indices;
    if ~all(NonWearBout_indices==0)
        continue; 
    end
    

    % Identify sustained activity bouts > 45 minutes
    METValues_OneDay_Indices_ABOVE1MET=(METValues_OneDay>=1);
    CosecutiveOnes_Indices_ABOVE1MET = find(diff([0;(METValues_OneDay_Indices_ABOVE1MET);0]==1));
    StartIndices = CosecutiveOnes_Indices_ABOVE1MET(1:2:end-1);  % Start indices
    EndIndices=CosecutiveOnes_Indices_ABOVE1MET(2:2:end);  % End indices
    ConsecutiveOnes_Count_ABOVE1MET = EndIndices-StartIndices;  % Consecutive ones counts
    Bout_indicesAbove10Min=ConsecutiveOnes_Count_ABOVE1MET>=90; % mark all the bouts that have MET values >=1 for 45 consecutive minutes or more
   
    StartIndices_Above10Min_1=[nan;StartIndices(Bout_indicesAbove10Min)];
  	EndIndices_Above10Min_1=[nan;EndIndices(Bout_indicesAbove10Min)];
    ActiveBoutlength=(EndIndices_Above10Min_1-StartIndices_Above10Min_1)-1;
      
    StartIndices_Above10Min_2=[StartIndices(Bout_indicesAbove10Min);0];
  	EndIndices_Above10Min_2=[0;EndIndices(Bout_indicesAbove10Min)];
    

    % Go through all identified bouts 
    for i=2:length(StartIndices_Above10Min_2)-1
        vector_RestBouts(EndIndices_Above10Min_2(i)-1:StartIndices_Above10Min_2(i))=1.5;       
    end
    
    
    % Combine Rest/bed periods with short active bouts
    RestBouts=(~isnan(vector_RestBouts));
    RestBouts_Indices=(RestBouts==1);
    CosecutiveOnes_Indices_ABOVE1MET = find(diff([0;(RestBouts_Indices);0]==1));
    StartIndices = CosecutiveOnes_Indices_ABOVE1MET(1:2:end-1);  % Start indices
    EndIndices=CosecutiveOnes_Indices_ABOVE1MET(2:2:end);  % End indices
    ConsecutiveOnes_Count_ABOVE1MET = EndIndices-StartIndices;  % Consecutive ones counts
    [Bout_Longest_Values, Bout_Longest_Indices]=max(ConsecutiveOnes_Count_ABOVE1MET); %Find the longest bout
    
    % create a Nan vector for marking time in bed periods on the figure
    RestBouts_Longest=NaN(length(METValues_OneDay),1); 
    RestBouts_Longest(StartIndices(Bout_Longest_Indices):EndIndices(Bout_Longest_Indices))=3;
    
    
    
    RecRestSleep_List(k,1)={Dates_OneDay(StartIndices(Bout_Longest_Indices))};
    RecRestSleep_List(k,2)={Times_OneDay(StartIndices(Bout_Longest_Indices))};
       
              
    RecRestSleep_List(k,3)={Dates_OneDay(EndIndices(Bout_Longest_Indices))};
    RecRestSleep_List(k,4)={Times_OneDay(EndIndices(Bout_Longest_Indices))};
    

       
    
    
    
    %plot the signal from one day
    TimeVectorForFigure=linspace((datetime(DateList(k).Year,DateList(k).Month,DateList(k).Day,18,0,0)),datetime(DateList(k+1).Year,DateList(k+1).Month,DateList(k+1).Day,18,0,0),2880);
    figure;
    T_length=length(METValues_OneDay);
    plot (TimeVectorForFigure(1:T_length),METValues_OneDay)
    hold on;
    plot(TimeVectorForFigure(1:T_length),vector_RestBouts,...
    TimeVectorForFigure(1:T_length),RestBouts_Longest,'LineWidth',3)
    legend('Met values','Potential sleep periods', 'Sleep period (longest inactive bout)')
    
end
