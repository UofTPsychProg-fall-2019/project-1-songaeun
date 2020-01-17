function [] = part1_DetectInvertedImg()    

%******************************************************************************************
% Overview of the experiment (part1) procedure (Task: Press key when detecting an rotated image).
% 1. Get subject number in the command window (please put any number you like and then press Enter)
% 2. Show the instruction to inform task.% 
% 3. Show natual scene images (1sec/img). Participants should press spacebar when an image rotated on its side.
% 4. Show inter-trial-interval between images (500ms).
% 5. Provide break time to avoid fatigue (1 time in this version)
% ** I reduced the number of trials as total 12 trials and 4 target trials (rotated images) in this version.
% ** (Originally it was total 770 trials, 70 target trials)
% ** Output would be saved in 'data > study_main'
%******************************************************************************************    
    
    %% Basic setting
    fclose('all');
    ClockRandSeed; 
    ListenChar;
    KbName('UnifyKeyNames');
    try              
        %% Subject info.
        if ~exist('sbj','var')|| isempty(sbj) %#ok<NODEF>
            sbj = input('subject number? ', 's');
        end        
        %% Window setting
        refreshHz = 60; 
        HideCursor();
        bg_color = [200 200 200];
        Screen('Preference', 'SkipSyncTests', 1); % should be blocked in ExpRoom.
        [wptr, rect] = Screen('OpenWindow', 0, bg_color);
        [cx, cy] = RectCenter(rect);
        Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		Screen('TextFont', wptr, 'Trebuchet MS');
        Screen('TextSize', wptr, 14);
                
        %% Experiment setting
        %========Load functions=======%        
        addpath library
        %========Prepare images=======%
        % load image info.
        load('imageInfo_small.mat'); %#ok<LOAD>        
        [n_cat, n_mem] = size(imgInfo.memory);        
        [~,     n_tar] = size(imgInfo.target);
        % get random seqence for image presentation
        t_pos = GetRandomTargetPosition(n_cat, n_mem, n_tar);        
        shuf_m = randperm(n_cat*n_mem); % shuffle memory item sequence
        shuf_t = randperm(n_cat*n_tar); % shuffle target item sequence
        tm_seq = cell(n_cat*(n_mem+n_tar),1);
        tm_seq(t_pos==0) = imgInfo.memory(shuf_m);
        tm_seq(t_pos==1) = imgInfo.target(shuf_t);
        % arrange images based on the sequnece above
        images = cell(n_cat*(n_mem+n_tar),1);
        images(t_pos==0) = imgInfo.images{2}(shuf_m);
        images(t_pos==1) = imgInfo.images{3}(shuf_t);
        % save image sequence info.
        seqInfo = struct;
        seqInfo.targ_pos = t_pos;
        seqInfo.tm_seq = tm_seq; %#ok<STRNU>
        %=====Stimulus parameters=====%
        img_siza = 480;       
        img_dur = 1;
        iti_dur = 0.5;       
        rot = [90, -90]; % img rotation option       
        %======Experiment matrix======%
        % In experiment matrix, all of experimental information will be recorded.
        emat = zeros(length(t_pos), 7); % column1_targetposition, 2_target_rotation, 3_response, 4_rt, 5_imgOnset, 6_itiOnset, 7_itiOffset 
        emat(:,1) = t_pos;
        emat(t_pos==1, 2) = Shuffle([repmat([1], n_cat*n_tar/2, 1); repmat([2], n_cat*n_tar/2, 1)]);
        %======Block separation=======%
        n_block = 2;             
        tpb = length(emat)/n_block;
                
        %% Experiment start        
        %=========Instruction=========%
        ListenChar(2);
        RestrictKeysForKbCheck(KbName('space'));
        fid = fopen('instruction_study.txt', 'r', 'n','UTF-8');
        Itext =fread(fid, '*char'); 
        Itext = double(transpose(Itext));
        fclose(fid);
        DrawFormattedText(wptr, Itext, 'center', 'center', [0 0 0]);
        Screen('Flip', wptr);
        expkey(KbName('space'));    
        %============Trial============%       
        for b = 1:n_block
            % blank display for 1sec between blocks.
            Screen('FillRect', wptr, bg_color, rect);
            Screen('Flip', wptr);
            WaitSecs(1);            
            for i = (b-1)*tpb+1:b*tpb 
                %--display image--%
                currImg = Screen('MakeTexture', wptr, images{i});
                if emat(i,1) == 0 % if non-target
                    Screen('DrawTexture', wptr, currImg, [], ...
                        [cx-(img_siza/2), cy-(img_siza/2), cx+(img_siza/2), cy+(img_siza/2)]);
                else % if target
                    Screen('DrawTexture', wptr, currImg, [], ...
                        [cx-(img_siza/2), cy-(img_siza/2), cx+(img_siza/2), cy+(img_siza/2)], rot(emat(i,2))); % 90deg rotation(cw/ccw)
                end
                [~, imgOnset] = Screen('Flip', wptr);
                emat(i,5) = imgOnset; % save imageOnset clock
                %--get response--%
                timedout = false;
                itiOnset = Inf;              
                while ~timedout
                    [KeyIsDown, KeyTime] = KbCheck;
                    if KeyIsDown
                        emat(i,3) = KeyIsDown;
                        emat(i,4) = KeyTime - imgOnset;  
                    end
                    curr_time = GetSecs;
                    % iti (allow participants to respond during iti)
                    if curr_time - imgOnset >= img_dur
                        SimpleFixation(wptr, rect, 10, [0 0 0], 4, [], [], []);                                              
                        [~, itiOnset_Tmp] = Screen('Flip', wptr, imgOnset+img_dur-(1/refreshHz/2));
                        itiOnset = min(itiOnset, itiOnset_Tmp); % save iti onset(image offset) clock
                    end 
                    curr_time = GetSecs;
                    if curr_time - itiOnset >= iti_dur
                        timedout = true;
                    end                    
                end 
                itiOffset = GetSecs; % save iti offset clock
                emat(i,6) = itiOnset; % record clocks                
                emat(i,7) = itiOffset;
                
            end
            %==='break time' or 'task over' sign===%
            if b ~= n_block
                Btext = 'Take a break and press space to start the next block';
            else
                Btext = 'Press space to finish the experiment';
            end
            DrawFormattedText(wptr, Btext, 'center', 'center', [0 0 0]);
            Screen('Flip', wptr);
            expkey(KbName('space'));            
                
        end
        
        %% save experiment matrix and image sequence info.        
        matfile = fullfile('data', 'study_main', strcat(sbj, datestr(now(), '.yyyy-mm-dd.HH_MM_SS'), '.mat'));
        save(matfile, 'emat', 'seqInfo');
        Screen('CloseAll');
       
    catch e
        Screen('CloseAll');
        ListenChar
        rethrow(e);
    end    
    ListenChar
    Screen('CloseAll');  

end