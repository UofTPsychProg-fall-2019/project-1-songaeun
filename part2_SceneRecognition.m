function [] = part2_SceneRecognition()

%******************************************************************************************
% Overview of the experiment (part2) procedure (Task: select the image seen in part 1).
% 1. Get subject number in the command window (please put any number you like and then press Enter)
% 2. Show the instruction to inform task.
% 3. Show pairs of natual scene images. Participants should choose which of the pair was seen during the study session. 
% 4. Provide break time to avoid fatigue (1 time in this version)
% ** I reduced the number of trials as total 8 trials in this version.
% ** (Originally it was total 700 trials)
% ** Output would be saved in 'data > memory_main'
%******************************************************************************************

    %% Basic setting
    fclose('all');
    ClockRandSeed;
    KbName('UnifyKeyNames')
    addpath library
    
    try
        %% Get subject info.
        if ~exist('sbj','var')|| isempty(sbj) %#ok<NODEF>
            sbj = input('subject number? ', 's');
        end        
        
        %% Window setting       
        HideCursor();
        bg_color = [200 200 200];        
        Screen('Preference', 'SkipSyncTests', 1); % should be blocked in ExpRoom
        [wptr, rect] = Screen('OpenWindow', 0, bg_color);
        [cx, cy] = RectCenter(rect);
        Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		Screen('TextFont', wptr, 'Trebuchet MS');
        Screen('TextSize', wptr, 14);
        %% Stimuli setting
        %===load image and image pair info.===%
        load('pair_idx_small.mat'); %#ok<*LOAD>
        load('imageInfo_small.mat');        
        [n_cat, n_mem] = size(imgInfo.memory);
        m_images = reshape(imgInfo.images{2}, n_cat*n_mem, 1);
        l_images = reshape(imgInfo.images{1}, n_cat*n_mem, 1);
        img_pair = [m_images(pair_idx(:,1)), l_images(pair_idx(:,2))]; %#ok<NODEF>
        %==get image file name for recording==%
        m_items = reshape(imgInfo.memory, n_cat*n_mem, 1);
        l_items = reshape(imgInfo.lure  , n_cat*n_mem, 1);
        pair = [m_items(pair_idx(:,1)), l_items(pair_idx(:,2))]; %#ok<NASGU>
        %=======image size and position=======%
        is = 480;
        s_loc = {[(cx*0.5)-(is/2), cy-(is/2), (cx*0.5)+(is/2), cy+(is/2)], ...
            [(cx*1.5)-(is/2), cy-(is/2), (cx*1.5)+(is/2), cy+(is/2)]};
        
        %% Experiment matrix       
        emat = zeros(n_cat*n_mem, 4); % column1_random sequence of pairs, 2_mem_location, 3_response, 4_rt
        emat(:,1) = randperm(n_cat*n_mem);
        emat(:,2) = Shuffle([repmat([1],n_cat*n_mem/2,1); repmat([2],n_cat*n_mem/2,1)]); %1_studiedImg on left, 2_studiedImg on right
        % block separation
        n_block = 2;
        tpb = length(emat)/n_block;
                
        %% Experiment start
        %===========Instruction==========%
        ListenChar(2);
        fid = fopen('instruction_test.txt','r', 'n','UTF-8');
        Itext =fread(fid, '*char'); 
        Itext = double(transpose(Itext));
        fclose(fid);
        DrawFormattedText(wptr, Itext, 'center', 'center', [0 0 0]);
        Screen('Flip', wptr);
        expkey(KbName('space'));        
        %=============Trial==============%       
        Screen('FillRect', wptr, bg_color, rect);
        Screen('Flip', wptr);
        WaitSecs(1);
        for b = 1:n_block
            for i = (b-1)*tpb+1:b*tpb                
                curr_memo = Screen('MakeTexture', wptr, img_pair{emat(i,1),1});
                curr_lure = Screen('MakeTexture', wptr, img_pair{emat(i,1),2});
                if emat(i,2) == 1
                    Screen('DrawTexture', wptr, curr_memo, [], s_loc{1});
                    Screen('DrawTexture', wptr, curr_lure, [], s_loc{2});
                else
                    Screen('DrawTexture', wptr, curr_memo, [], s_loc{2});
                    Screen('DrawTexture', wptr, curr_lure, [], s_loc{1});
                end
                Screen('Flip', wptr);
                [rkey, rt] = expkey([KbName('z'), KbName('/?')], [], [], 10);
                if rkey
                    emat(i,3) = rkey;
                else
                    emat(i,3) = 0;
                end
                emat(i,4) = rt;               
            end
            if b ~=n_block
                btext = 'Take a break and press space to start the next block';
            else
                btext = 'Thank you for participation. Press space to finish';
            end
            DrawFormattedText(wptr, btext, 'center', 'center', [0 0 0]);
            Screen('Flip', wptr);
            expkey(KbName('space')); 
        end
        %=============save==============%
        matfile = fullfile('data', 'memory_main', strcat(sbj, datestr(now(), '.yyyy-mm-dd.HH_MM_SS'), '.mat'));
        save(matfile, 'emat', 'pair');
        Screen('CloseAll');        
        
        
    catch e
        Screen('CloseAll')
        ListenChar
        rethrow(e);
    end
    ListenChar
    Screen('CloseAll')

end

