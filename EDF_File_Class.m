classdef EDF_File_Class %Improved Lazy version
    %Encapsulate file read for EDF_FileInfo  
    % Version 1.13 (2016/04/21)
    % Wanchat Theeranaew
    
    properties
       FileName
       FileInfo
    end
    
    methods
        function obj = EDF_File_Class(FileName)
            if nargin == 1
                Fid = fopen(FileName);
                
                if Fid ~= -1
                    obj.FileName = FileName;
                    obj.FileInfo = EDF_FileInfo(FileName);
                    fclose(Fid);
                else
                    error(['Cannot open [' FileName '].']);
                end;
            else
                error('Need to specify EDF file to create this object.');
            end            
        end
        
        
        function data = FileRead(obj,DataStart,DataLength,chList,Segment)       
            data = obj.FileReadDigital(DataStart,DataLength,chList,Segment);
            chList = unique(chList);
            
            for i = 1:length(chList)
               curChID = chList(i);
               Multiplier = (obj.FileInfo.ChInfo.PhysicalMaximum(curChID) - obj.FileInfo.ChInfo.PhysicalMinimum(curChID)) ./ ...
                            (obj.FileInfo.ChInfo.DigitalMaximum(curChID) - obj.FileInfo.ChInfo.DigitalMinimum(curChID)); 
                         
               data{chList(i)} = Multiplier * double(data{chList(i)} - obj.FileInfo.ChInfo.DigitalMinimum(curChID)) + ...
                  obj.FileInfo.ChInfo.PhysicalMinimum(curChID);
            end;
        end  
        
        
        function data = FileReadDigital(obj,DataStart,DataLength,chList,Segment)       
            data = [];
            %--------------------------------------------------------------------------
            Fid = fopen(obj.FileName,'r');
   
            %Block shift depend on the current segment of data
            Temp = fix([0 cumsum(obj.FileInfo.TotalTime)] / obj.FileInfo.DurationOfEachRecord);

            %EDF file reader
            startBlock = 1 + fix(DataStart / obj.FileInfo.DurationOfEachRecord) + Temp(Segment);
            endblock = 1 + fix((DataStart + DataLength) / obj.FileInfo.DurationOfEachRecord) + Temp(Segment);

            CummulativeSampleTable = cumsum(obj.FileInfo.ChInfo.NumberOfSampleInEachRecord);
            CummulativeSampleTable = [0; CummulativeSampleTable(1:end)];
            SkipBytes = obj.FileInfo.HeaderSizeInByte + 2*((startBlock - 1) * CummulativeSampleTable(end));
           
            for i = 1:length(chList)
                fseek(Fid,SkipBytes + 2*CummulativeSampleTable(chList(i)),'bof');
                
                numberOfDataPoint = (endblock - startBlock + 1) * obj.FileInfo.ChInfo.NumberOfSampleInEachRecord(chList(i));

                % Prepare information to read chunk of data
                Temp = 2*(CummulativeSampleTable(end) - obj.FileInfo.ChInfo.NumberOfSampleInEachRecord(chList(i))); % Skip data from other channel for each recording

                % Actually start to read the data
                data{chList(i)} = fread(Fid,[1 numberOfDataPoint], [num2str(obj.FileInfo.ChInfo.NumberOfSampleInEachRecord(chList(i))) '*int16=>double'], Temp); 

               %Extract the actual data be discarding unwanted data
               idx1 = (DataStart - (startBlock-1)*obj.FileInfo.DurationOfEachRecord)/obj.FileInfo.DurationOfEachRecord*obj.FileInfo.ChInfo.NumberOfSampleInEachRecord(chList(i)) + 1;
               idx1 = fix(idx1);
               idx2 = idx1 + obj.FileInfo.ChInfo.NumberOfSampleInEachRecord(chList(i))/obj.FileInfo.DurationOfEachRecord*DataLength;
            
               %Make sure that last index is not exceed the end of data
               idx2 = min(fix(idx2),length(data{chList(i)}));
                       
               data{chList(i)} = data{chList(i)}(idx1:idx2);              
            end;
            
            fclose(Fid);
            %--------------------------------------------------------------------------            
        end        
        
        % Get basic information from FileInfo
        function output = getStartDate(obj)
            output = obj.FileInfo.StartDate;
        end

        function output = getStartTime(obj)
            output = obj.FileInfo.StartTime;
        end        
        
        function output = getSegmentStartTime(obj)
            output = obj.FileInfo.SegmentStartTime;
        end   
 
        function output = getTotalTime(obj)
            output = obj.FileInfo.TotalTime;
        end   
                
        function output = getNumberOfSignals(obj)
            output = obj.FileInfo.NumberOfSignals;
        end    
        
        function output = getSamplingRate(obj)
            output = obj.FileInfo.ChInfo.NumberOfSampleInEachRecord / obj.FileInfo.DurationOfEachRecord;
        end     
        
        function output = getChMap(obj)
            output = obj.FileInfo.ChInfo.ChMap;
        end  
        
        function output = getPhysicalUnit(obj)
            output = obj.FileInfo.ChInfo.PhysicalDimension;
        end  
    
        function output = getPhysicalMaximum(obj)
            output = obj.FileInfo.ChInfo.PhysicalMaximum;
        end      
    
        function output = getPhysicalMinimum(obj)
            output = obj.FileInfo.ChInfo.PhysicalMinimum;
        end      

        function output = getHeaderBytes(obj)
            output = obj.FileInfo.HeaderBytes;
        end  
        
        function output = getNumberOfSampleInEachRecord(obj)
            output = obj.FileInfo.ChInfo.NumberOfSampleInEachRecord;
        end    
        
        function output = getDurationOfEachRecord(obj)
            output = obj.FileInfo.DurationOfEachRecord;
        end  
        
        function output = getPatientIdentification(obj)
            output = obj.FileInfo.PatientIdentification;
        end     
 
        function output = getNumberOfSegment(obj)
            output = obj.FileInfo.NumberOfSegment;
        end           

        function output = getAnnotation(obj)
            output = obj.FileInfo.Annotation;
        end      
    end
end