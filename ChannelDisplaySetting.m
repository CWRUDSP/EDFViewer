%--------------------------------------------------------------------------
% @license
% Copyright 2018 IDAC Signals Team, Case Western Reserve University 
%
% Lincensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public 
% you may not use this file except in compliance with the License.
%
% Unless otherwise separately undertaken by the Licensor, to the extent possible, 
% the Licensor offers the Licensed Material as-is and as-available, and makes no representations 
% or warranties of any kind concerning the Licensed Material, whether express, implied, statutory, or other. 
% This includes, without limitation, warranties of title, merchantability, fitness for a particular purpose, 
% non-infringement, absence of latent or other defects, accuracy, or the presence or absence of errors, 
% whether or not known or discoverable. 
% Where disclaimers of warranties are not allowed in full or in part, this disclaimer may not apply to You.
%
% To the extent possible, in no event will the Licensor be liable to You on any legal theory 
% (including, without limitation, negligence) or otherwise for any direct, special, indirect, incidental, 
% consequential, punitive, exemplary, or other losses, costs, expenses, or damages arising out of 
% this Public License or use of the Licensed Material, even if the Licensor has been advised of 
% the possibility of such losses, costs, expenses, or damages. 
% Where a limitation of liability is not allowed in full or in part, this limitation may not apply to You.
%
% The disclaimer of warranties and limitation of liability provided above shall be interpreted in a manner that, 
% to the extent possible, most closely approximates an absolute disclaimer and waiver of all liability.
%
% Developed by the IDAC Signals Team at Case Western Reserve University 
% with support from the National Institute of Neurological Disorders and Stroke (NINDS) 
%     under Grant NIH/NINDS U01-NS090405 and NIH/NINDS U01-NS090408.
%              Wanchat Theeranaew
%--------------------------------------------------------------------------
function varargout = ChannelDisplaySetting(varargin)
% CHANNELDISPLAYSETTING MATLAB code for ChannelDisplaySetting.fig
%      CHANNELDISPLAYSETTING, by itself, creates a new CHANNELDISPLAYSETTING or raises the existing
%      singleton*.
%
%      H = CHANNELDISPLAYSETTING returns the handle to a new CHANNELDISPLAYSETTING or the handle to
%      the existing singleton*.
%
%      CHANNELDISPLAYSETTING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANNELDISPLAYSETTING.M with the given input arguments.
%
%      CHANNELDISPLAYSETTING('Property','Value',...) creates a new CHANNELDISPLAYSETTING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChannelDisplaySetting_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChannelDisplaySetting_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChannelDisplaySetting

% Last Modified by GUIDE v2.5 01-Nov-2016 12:45:16

% Begin initialization code - DO NOT EDIT
   gui_Singleton = 1;
   gui_State = struct('gui_Name',       mfilename, ...
                      'gui_Singleton',  gui_Singleton, ...
                      'gui_OpeningFcn', @ChannelDisplaySetting_OpeningFcn, ...
                      'gui_OutputFcn',  @ChannelDisplaySetting_OutputFcn, ...
                      'gui_LayoutFcn',  [] , ...
                      'gui_Callback',   []);
   if nargin && ischar(varargin{1})
       gui_State.gui_Callback = str2func(varargin{1});
   end

   if nargout
       [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
   else
       gui_mainfcn(gui_State, varargin{:});
   end
% End initialization code - DO NOT EDIT


% --- Executes just before ChannelDisplaySetting is made visible.
function ChannelDisplaySetting_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChannelDisplaySetting (see VARARGIN)
   % Choose default command line output for ChannelDisplaySetting
   handles.output = hObject;

   handles.curSetting = evalin('base','curSetting');
   %handles.curSetting = evalin('base','curSetting');
   
   set(handles.TextChName,'string',[handles.curSetting.ChName '(' handles.curSetting.Unit ')']);

   set(handles.RadioShareYes,'value',handles.curSetting.isEEG);
   set(handles.RadioShareNo,'value',1-handles.curSetting.isEEG);
   set(handles.CheckNotch50,'value',handles.curSetting.notch50);
   set(handles.CheckNotch60,'value',handles.curSetting.notch60); 
   Scale = handles.curSetting.Scale;
   Offset = handles.curSetting.Offset;
   set(handles.EditMax,'string',num2str(Offset+Scale/2));
   set(handles.EditMin,'string',num2str(Offset-Scale/2));
   
   Temp1=get(handles.ListLowPassFilter,'string');
   set(handles.ListLowPassFilter,'value',1);
   if(handles.curSetting.LPFcutoff ~= 0)
      for i = 2:length(Temp1)
         LP_cutoff = strtrim(Temp1{i});
         LP_cutoff = str2num(LP_cutoff(1:end-2));
         if(LP_cutoff == handles.curSetting.LPFcutoff)
            set(handles.ListLowPassFilter,'value',i);
            break;
         end;
      end;
   end;
   
   Temp1=get(handles.ListHighPassFilter,'string');
   set(handles.ListHighPassFilter,'value',1);
   if(handles.curSetting.HPFcutoff ~= 0)
      Temp = [Inf, Inf];
      for i = 3:length(Temp1)
         HP_cutoff = strtrim(Temp1{i});
         HP_cutoff = str2num(HP_cutoff(1:end-3));
         HP_cutoff=1/(2*pi*HP_cutoff);
         Temp(end + 1) = abs(HP_cutoff - handles.curSetting.HPFcutoff);         
      end;   
      [~,Temp1] = min(Temp);
      set(handles.ListHighPassFilter,'value',Temp1);
   end;
   
   setEnableDisable(handles);

   % Update handles structure
   guidata(hObject, handles);
% UIWAIT makes ChannelDisplaySetting wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function setEnableDisable(handles) 
   share = get(handles.RadioShareYes,'value');
   enableFlag = 'on';
   if(share == 1)
      enableFlag = 'off';
   end;

   set(handles.CheckNotch50,'enable',enableFlag);
   set(handles.CheckNotch60,'enable',enableFlag);
   set(handles.EditMax,'enable',enableFlag);
   set(handles.EditMin,'enable',enableFlag);  
   set(handles.ListLowPassFilter,'enable',enableFlag);
   set(handles.ListHighPassFilter,'enable',enableFlag);

   
% --- Outputs from this function are returned to the command line.
function varargout = ChannelDisplaySetting_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
   varargout{1} = handles.output;


function RadioShareYes_Callback(hObject, eventdata, handles)
   setEnableDisable(handles);
   handles.curSetting.isEEG = get(handles.RadioShareYes,'value');
   guidata(hObject,handles);
   
   
function RadioShareNo_Callback(hObject, eventdata, handles)
   setEnableDisable(handles);
   handles.curSetting.isEEG = get(handles.RadioShareYes,'value');
   guidata(hObject,handles);
   
   
function ListLowPassFilter_Callback(hObject, eventdata, handles)  
   LP_cutoff = 0;
   if get(handles.ListLowPassFilter,'value')>1
      LP_cutoff=get(handles.ListLowPassFilter,'value');
      Temp1=get(handles.ListLowPassFilter,'string');
   
      LP_cutoff = strtrim(Temp1{LP_cutoff});
      LP_cutoff = str2num(LP_cutoff(1:end-2));
   end;
   handles.curSetting.LPFcutoff = LP_cutoff;
   guidata(hObject,handles);



function ListHighPassFilter_Callback(hObject, eventdata, handles)
   Sel = get(handles.ListHighPassFilter,'value');   
   if Sel ~= 2
      HP_cutoff=get(handles.ListHighPassFilter,'value');
      Temp1=get(handles.ListHighPassFilter,'string');

      HP_cutoff = strtrim(Temp1{HP_cutoff});
      HP_Type = HP_cutoff(end-2:end);
      HP_cutoff = str2num(HP_cutoff(1:end-3));
       
      % High pass filter type
      % 1 : Time constant second
      % 2 : frequency Hz
      %
      % design the filter according to filter type
      if strcmp(HP_Type,'Sec')         
         HP_cutoff=1/(2*pi*HP_cutoff);
      end
      if(isempty(HP_cutoff))
         HP_cutoff = 0;
      end;
      handles.curSetting.HPFcutoff = HP_cutoff;
      guidata(hObject,handles);
   else
      Temp = get(handles.ListHighPassFilter,'string');
      Temp = Temp{Sel};
      if strcmp(Temp,'   to Hz')
         set(hObject,'string',{'    off' '   to Sec' '   0.1 Hz' '   0.2 Hz' '   0.3 Hz'...
             '   0.5 Hz' '   0.8 Hz' '   1    Hz' '   1.6 Hz' '   2    Hz' '   4    Hz' ...
             '   5    Hz' ' 10    Hz' ' 20    Hz' ' 30    Hz' ' 40    Hz'});
      else
         set(hObject,'string',{'    off' '   to Hz' '2          Sec' '1          Sec'...
             '0.3       Sec' '0.2       Sec' '0.16     Sec' '0.1       Sec' '0.08     Sec' '0.053   Sec' ...
             '0.04     Sec' '0.032   Sec' '0.016   Sec' '0.008   Sec' '0.0053 Sec' '0.004   Sec'});
      end;
   end;


function CheckNotch50_Callback(hObject, eventdata, handles)
   handles.curSetting.notch50 = get(handles.CheckNotch50,'value');
   guidata(hObject,handles);


function CheckNotch60_Callback(hObject, eventdata, handles)
   handles.curSetting.notch60 = get(handles.CheckNotch60,'value');
   guidata(hObject,handles);

function handles = changeMaxMin(handles)
   Scale = handles.curSetting.Scale;
   Offset = handles.curSetting.Offset;
   MaxVal = str2num(get(handles.EditMax,'string'));
   MinVal = str2num(get(handles.EditMin,'string'));
      
   if(isempty(MaxVal) || isempty(MinVal)) || (MinVal > MaxVal)
      set(handles.EditMax,'string',num2str(Offset+Scale/2));
      set(handles.EditMin,'string',num2str(Offset-Scale/2));
      handles.curSetting.Scale = Scale;
      handles.curSetting.Offset = Offset;
   else
      handles.curSetting.Scale = (MaxVal - MinVal);
      handles.curSetting.Offset = (MaxVal + MinVal)/2;
   end;
   

function EditMax_Callback(hObject, eventdata, handles) 
   handles = changeMaxMin(handles);
   guidata(hObject,handles);
   

function EditMin_Callback(hObject, eventdata, handles)
   handles = changeMaxMin(handles);
   guidata(hObject,handles);

   
function ButtonApply_Callback(hObject, eventdata, handles)
   assignin('base','curSetting',handles.curSetting);
   assignin('base','settingChange',1);
   close;


function ButtonCancel_Callback(hObject, eventdata, handles)
   assignin('base','settingChange',0);
   close;
