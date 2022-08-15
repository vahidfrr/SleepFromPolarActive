clear;
clc;
close all;

Data=readtable('Toy_data.csv'); % The adress tp to the Polar CSV file name
METvalues=(table2array(Data(:,3))); % MET values are in the 3rd row
DateTime=(table2array(Data(:,2))); % date and time are in the 
DateTime.Format='HH:mm:ss';
Time= cellstr(DateTime);

DateTime.Format = 'dd-MMM-yyyy';
Date = cellstr(DateTime); 


DateList=sort(datetime(unique(Date(:,1))));


varTypes = {'datetime','string','datetime','string'};
varNames = {'Date_Start','Time_Start','Date_End','Time_End'};

sz = [length(DateList)-1 4];
RecRestSleep_List = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

sz = [100 4];
SuspectedNonWear_List = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

SuspectedNonWear_Count=1;
RecRestSleep_List_Count=1;
DateArray_Start=0;
%length(DateList)-1
for k=2:length(DateList)-1% First day is always excluded
    NonWearIdentified=0;
    OneDayIndices=((Date==DateList(k))&(string(Time)>='18:00:00'))|((Date==DateList(k+1))&(string(Time)<'18:00:00')); % seperate one day. Change the time in 24 hour format
    METValues_OneDay=METvalues(OneDayIndices);
    Dates_OneDay=DateTime(OneDayIndices);
    Times_OneDay=Time(OneDayIndices);
    
    Empty_vector_ShortActivityBouts=NaN(length(METValues_OneDay),1); % create a Nan vector for markeing on the figure_FOR SHORTACTIVE BOUTS_
    Empty_vector_RestBouts=NaN(length(METValues_OneDay),1); % create a Nan vector for markeing on the figure_FOR REST/SLEEP_
    Empty_vector_SuspectedNonWear=NaN(length(METValues_OneDay),1); % create a Nan vector for markeing on the figure_FOR SUSPICIOUS NONWEAR_
    Empty_vector_NonWear=NaN(length(METValues_OneDay),1); % create a Nan vector for markeing on the figure_ NONWEAR_
    
    
    %%%%%Check for non-wear. All bouts more than XX hours with measurement
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
%         NonWearIdentified=1;
%         k-1
        continue; % CHANGE THIS TO COMMENT TO *PLOT* DAYS WITH NONWEAR BOUTS
    end
    
    METValues_OneDay_Indices_ABOVE1MET=(METValues_OneDay>=1);
    CosecutiveOnes_Indices_ABOVE1MET = find(diff([0;(METValues_OneDay_Indices_ABOVE1MET);0]==1));
    StartIndices = CosecutiveOnes_Indices_ABOVE1MET(1:2:end-1);  % Start indices
    EndIndices=CosecutiveOnes_Indices_ABOVE1MET(2:2:end);  % End indices
    ConsecutiveOnes_Count_ABOVE1MET = EndIndices-StartIndices;  % Consecutive ones counts
    Bout_indicesAbove20Min=ConsecutiveOnes_Count_ABOVE1MET>=20; % mark all the bouts that have MET values >=1 for 10 consecutive minutes or more
   
    StartIndices_Above20Min_1=[nan;StartIndices(Bout_indicesAbove20Min)];
  	EndIndices_Above20Min_1=[nan;EndIndices(Bout_indicesAbove20Min)];
    ActiveBoutlength=(EndIndices_Above20Min_1-StartIndices_Above20Min_1)-1;
      
    StartIndices_Above20Min_2=[StartIndices(Bout_indicesAbove20Min);0];
  	EndIndices_Above20Min_2=[0;EndIndices(Bout_indicesAbove20Min)];
    

    for i=2:length(StartIndices_Above20Min_2)-1

        
        
        if(ActiveBoutlength(i)<90) %%%%%%%___At least XX min ACTIVITY allowed between sleep____%%%%%%%%
            Empty_vector_ShortActivityBouts(StartIndices_Above20Min_1(i):EndIndices_Above20Min_1(i)-1)=2.5;

        end
       
        % Check if every 30-sec window is < 1 MET and less than XX min and
        % more than 10 min
        
        
        if((sum(METValues_OneDay(EndIndices_Above20Min_2(i):StartIndices_Above20Min_2(i)-1)==0.875)/length(METValues_OneDay(EndIndices_Above20Min_2(i):StartIndices_Above20Min_2(i)-1)==0.875))>0.98)&&...
            (((StartIndices_Above20Min_2(i)-EndIndices_Above20Min_2(i))<240)&&...
            ((StartIndices_Above20Min_2(i)-EndIndices_Above20Min_2(i))>10))
            
            Empty_vector_SuspectedNonWear(EndIndices_Above20Min_2(i):StartIndices_Above20Min_2(i)-1)=2;
           
            SuspectedNonWear_List(SuspectedNonWear_Count,1)={Dates_OneDay(EndIndices_Above20Min_2(i))};
            SuspectedNonWear_List(SuspectedNonWear_Count,2)={Times_OneDay(EndIndices_Above20Min_2(i))};
            SuspectedNonWear_List(SuspectedNonWear_Count,3)={Dates_OneDay(StartIndices_Above20Min_2(i)-1)};
            SuspectedNonWear_List(SuspectedNonWear_Count,4)={Times_OneDay(StartIndices_Above20Min_2(i)-1)};
            SuspectedNonWear_Count=SuspectedNonWear_Count+1;
           
           %elseif length(EndIndices_Above10Min_2(i):StartIndices_Above10Min_2(i)-1)>60 
        else  %%%%%%%____At least XX min to be marked sleep___%%%%%%%%
            Empty_vector_RestBouts(EndIndices_Above20Min_2(i)-1:StartIndices_Above20Min_2(i))=1.5;

        end
       
  

       
    end
    

    Empty_vector_RestBouts_ConcatenateWithActive=(~isnan(Empty_vector_RestBouts)|~isnan(Empty_vector_ShortActivityBouts));% Combine Rest/bed periods with short active bouts
    Empty_vector_RestBouts_Indices=(Empty_vector_RestBouts_ConcatenateWithActive==1);
    CosecutiveOnes_Indices_ABOVE1MET = find(diff([0;(Empty_vector_RestBouts_Indices);0]==1));
    StartIndices = CosecutiveOnes_Indices_ABOVE1MET(1:2:end-1);  % Start indices
    EndIndices=CosecutiveOnes_Indices_ABOVE1MET(2:2:end);  % End indices
    ConsecutiveOnes_Count_ABOVE1MET = EndIndices-StartIndices;  % Consecutive ones counts
    [Bout_Longest_Values, Bout_Longest_Indices]=max(ConsecutiveOnes_Count_ABOVE1MET); %Find the longest bout
    
    
    Empty_vector_RestBouts_Longest=NaN(length(METValues_OneDay),1); % create a Nan vector for markeing on the figure_FOR REST/SLEEP_
    Empty_vector_RestBouts_Longest(StartIndices(Bout_Longest_Indices):EndIndices(Bout_Longest_Indices))=3;
    
    
    
    RecRestSleep_List(k,1)={Dates_OneDay(StartIndices(Bout_Longest_Indices))};
    RecRestSleep_List(k,2)={Times_OneDay(StartIndices(Bout_Longest_Indices))};
       
              
    RecRestSleep_List(k,3)={Dates_OneDay(EndIndices(Bout_Longest_Indices))};
    RecRestSleep_List(k,4)={Times_OneDay(EndIndices(Bout_Longest_Indices))};
    

       
%     RecRestSleep_List_Count=RecRestSleep_List_Count+1;
    
    
    
    %plot the signal from one day
    TimeVectorForFigure=linspace((datetime(DateList(k).Year,DateList(k).Month,DateList(k).Day,18,0,0)),datetime(DateList(k+1).Year,DateList(k+1).Month,DateList(k+1).Day,18,0,0),2880);
    figure;
    T_length=length(METValues_OneDay);
    plot (TimeVectorForFigure(1:T_length),METValues_OneDay)
    hold on;
    plot(TimeVectorForFigure(1:T_length),Empty_vector_RestBouts,...
    TimeVectorForFigure(1:T_length),Empty_vector_RestBouts_Longest,...
    TimeVectorForFigure(1:T_length),Empty_vector_ShortActivityBouts,...
    TimeVectorForFigure(1:T_length),Empty_vector_SuspectedNonWear,'LineWidth',3)
    
end