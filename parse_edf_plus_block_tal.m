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
%              James McDonald
%--------------------------------------------------------------------------
function [tals] = parse_edf_plus_block_tal(ann_str,disp)
    %   
    %   [tals,start_wrt_file] = parse_edf_plus_annotation_block(ann_str,disp)
    %   
    %   ann_str: string of chars from EDF+D or EDF+C block or segment of data
    %
    %   disp: boolean to display operations and test (open this file to see tests)
    %   
    %   returns [tals,start_wrt_file] -------
    %   
    %   start_wrt_file is a string of the recorded time advanced or delayed (+/-)
    %   from the start/recording time of the entire EDF+ file
    %   
    %   tals: a cell array, each element containing
    %       tals{i}.onset: (string)  onset time of the file (beginning with +/-)
    %       tals{i}.duration: (string) duration of file (must be positive, no + or -)
    %       tals{}.dannotations: cell array of strings, each being an annotation
    %
    %
    %   REFACTOR: 

    if nargin < 2
        disp = false;
    end
    
    if nargin == 0
        t = char(20);
        t1 = char(21);
        z = char(0);
        ann_str = ['-7.1231345',t1, '12234',t,'Hello=-=-=-=-+++_=-= there',t,'Muahahahahsdaklsdjlakjsd',t,'asdalkjsdlkajsldkjasd',t,z];        
    end

    % See: http://www.edfplus.info/specs/edfplus.html
    % implementation is a finite state machine to recognize these patterns
    ann_str_len = numel(ann_str);
    ann.type = {};
    ann.text = {};

    matches = []; %#ok<NASGU>
    last_m0 = true;
    last_m20 = false;    
    last_m21 = false;
    last_m_plus_min = false;
    
    tals = {};
    ann_index = 0;
    char_index = 1;
    ann_str_len = numel(ann_str);
    while true
        if ~last_m20 && ~last_m21
            matches = [0 20 21 uint8('+'), uint8('-')];
        else
            matches = [0 20 21];
        end
        if char_index > 1
            while char_index < ann_str_len && ~any(ann_str(char_index) == matches)
                char_index = char_index + 1;
            end
        end
        
        if char_index > ann_str_len
            break
        end
        
        % state variables
        m0 = ann_str(char_index) == 0;
        m20 = ann_str(char_index) == 20;
        m21 = ann_str(char_index) == 21;
        m_plus_min = (ann_str(char_index) == uint8('+')) || (ann_str(char_index) == uint8('-'));
        if char_index == ann_str_len
            break
        end
        next_m_plus_min = (ann_str(char_index+1) == uint8('+')) || (ann_str(char_index+1) == uint8('-'));

        found_annotation = m20 && last_m20;

        found_duration = m20 && last_m21;
        
        found_onset = (m20 || m21) && last_m_plus_min && ~last_m20 && ~last_m21;
        
        found_tals_beg = m_plus_min && last_m0;
        found_talss_end = m0 && ~next_m_plus_min;

        starting_first_annotation = ann_str(char_index) == 20 && last_m20 && m_plus_min;
        if found_tals_beg
            if disp, char_index, end;
            if ann_index > 1
                fprintf('    ...onset = %s', tals{ann_index}.onset);
                fprintf('    ...duration = %s', tals{ann_index}.duration);
                fprintf('    ...annotations{:} = %s', tals{ann_index}.annotations{:});
            end
            if disp, fprintf('Next TAL Discovered! Next Character: %s\n\n',ann_str(char_index)); end
            ann_index = ann_index+1;
            tals{ann_index}.onset = '';
            tals{ann_index}.duration = '';
            tals{ann_index}.annotations = {};
        else
            str = strtrim(ann_str(last_matched_index:char_index-1));
            if numel(strtrim(str)) > 0
                if disp, str_totals = ann_str(1:char_index-1), end;                
                if found_talss_end
                    if disp, fprintf('No More TAL"s; Next Character: %s\n\n',ann_str(char_index)), end;
                    break;
                elseif found_duration
                    str = str(2:end);
                    tals{ann_index}.duration  = str;        
                    if disp, fprintf('Duration: %s\n',str); end   
                    ann.type = {ann.type{:},'Duration'};                
                elseif found_onset
                    tals{ann_index}.onset = str;              
                    if disp, fprintf('Onset: %s\n',str); end
                    ann.type = {ann.type{:},'Onset'};                
                elseif found_annotation
                    str = str(2:end);
                    if isfield(tals{ann_index},'annotations')
                        tals{ann_index}.annotations = {tals{ann_index}.annotations{:},str};
                    else
                        tals{ann_index}.annotations = {str};
                    end
                    if disp, fprintf('Annotation: %s\n',str); end
                    ann.type = {ann.type{:},'Annotation'};                      
                end
                ann.text = {ann.text{:},str};
                if disp, pause; end
            end
        end
        
        last_m0 = m0;
        last_m20 = m20;
        last_m21 = m21;
        last_m_plus_min = m_plus_min;
        last_matched_index = char_index;

        char_index = char_index + 1;
    end
    if disp
        fprintf('start_wrt_file:\n')
        fprintf(tals2string(tals))
    end
end

