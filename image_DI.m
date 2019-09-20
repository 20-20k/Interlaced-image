function image_DI(image)

% ECE 483, Analysis of De-interlacing techniques
% Photo deinterlacing
% Jason Carpenter, V00203100
% February 20, 2019

% Input Argument:
% image = an image file, ie. 'myimage.jpg'

I_1 = imread(image);

[row col dim] = size(I_1);          % row, column and dimension size

% ensure even number of rows as odd number produces problems
if(mod(row, 2)) ~= 0
    I_1 = I_1(1:end-1, :, :);   % get rid of last row if odd
    row = row - 1;
end

figure(1);
imshow(I_1);
title('Original Image: Inter field - Field Insertion (Weaving)');

% ------------- Show odd and even fields separately -------------------- %

image_row_odd = I_1(1:2:end, :, :);     % every odd second row, all columns
image_row_even = I_1(2:2:end, :, :);    % every even second row, all columns

figure(2);
imshow(image_row_odd);
title('Original Image Odd Field');
figure(3);
imshow(image_row_even);
title('Original Image Even Field');

% ---------------------------------------------------------------------- %
% ---------------------------------------------------------------------- %  
% ------------- Different Techniques for de-interlacing ---------------- %

% ------------- Intra Field: Scan Line Duplication (Bob) 

% From odd field
% Duplicating every second row 

tic;            % timing function
tStart = tic;
image_SLD_odd = repelem(image_row_odd(1:1:end, :, :), 2, 1);
elapsed_4 = round(toc(tStart), 5);    % round time to 4 digit precision

figure(4);
imshow(image_SLD_odd);
title(['Intra field: Odd Scan Line Duplication (Bob), Computation time ' num2str(elapsed_4) ' s']);

% from even field
tic;
tStart = tic;
image_SLD_even = repelem(image_row_even(1:1:end, :, :), 2, 1);
elapsed_5 = round(toc(tStart), 5);

figure(5);
imshow(image_SLD_even);
title(['Intra field: Even Scan Line Duplication (Bob), Computation time ' num2str(elapsed_5) ' s']);

% ------------- Intra Field: Scan Line Interpolation
%           x x x
%             o
%           x x x

% Averaging 6 surrounding pixels to make 1 centre pixel, Oops i think this
% was a mistake and not a real style of interpolation
% From odd field
image_SLI_even = image_SLD_even;  % starting with full array and replacing even lines
%                                 % with new values
% 
tic;
tStart = tic;
for z = 1:dim                     % 3 rgb frames for jpg
    for y = 2:2:(col-1)         % check every 2nd y position
        for x = 2:1:(row-1)     % check every x position
                                
        image_SLI_even(x, y, z) = image_SLI_even(x-1, y-1, z)/6 + image_SLI_even(x, y-1, z)/6 ...
            + image_SLI_even(x+1, y-1, z)/6 + image_SLI_even(x-1, y+1, z)/6 + image_SLI_even(x, y+1, z)/6 ...
            + image_SLI_even(x+1, y+1, z)/6;
        end
    end
end
elapsed_6 = round(toc(tStart), 5);
    
figure(6);
imshow(image_SLI_even);
title(['Interpolated Image (Accidentally Home Made!) from Even Field, Computation Time ' num2str(elapsed_6) ' s']); 

% ------ Intra Field: Scan Line Interpolation, Edge Line Interpolation (ELA)

% new array to work with, pre-populated
image_SLI_even = image_SLD_even; 

tic;
tStart = tic;
for z = 1:dim                     % 3 rgb frames for jpg
    for y = 2:2:(col-1)         % check every 2nd y position
        for x = 2:1:(row-1)     % check every x position
            
             A = image_SLD_even(x-1, y-1, z);    
             F = image_SLD_even(x+1, y+1, z);
             B = image_SLD_even(x, y-1, z);
             E = image_SLD_even(x, y+1, z);
             C = image_SLD_even(x+1, y-1, z);
             D = image_SLD_even(x-1, y+1, z);
             
             X_a = A/2 + F/2;
             X_b = B/2 + E/2;
             X_c = C/2 + D/2;
             
             % Looking for lowest value between two pixels, designates an
             % edge
             if((abs(A-F) < abs(C-D)) && (abs(A-F) < abs(B-E)))
                 image_SLI_even(x, y, z) = X_a;
             elseif((abs(C-D) < abs(A-F)) && (abs(C-D) < abs (B-E)))
                 image_SLI_even(x, y, z) = X_c; 
             else
                 image_SLI_even(x, y, z) = X_b;
             end
             
        end
    end
end
elapsed_8 = round(toc(tStart), 5);
        
figure(8);
imshow(image_SLI_even);
title(['Interpolated Image: Edge Line Average, from Even Field, Computation Time ' num2str(elapsed_8) ' s']);      
        
% -------- Inter field: Temporal Averaging (Blend) ---------------

% first row is not blended
tic;
tStart = tic;
for z = 1:dim
    for y = 1:col 
        for x = 1
            image_blend(x, y, z) = image_row_odd(x, y, z);
        end
    end
end    

for z = 1:dim
    for y = 1:col            % start on second row
        for x = 2:row        % blending first odd and second even row
            
            % even rows blends of odd_n/even_n, odd rows are blends of odd_n+1/even_n 
            if(mod(x,2) == 0)
                image_blend(x, y, z) = ((image_row_odd(x/2, y, z))/2 + (image_row_even(x/2, y, z))/2);
            else
                image_blend(x, y, z) = ((image_row_odd((x+1)/2, y, z))/2 + (image_row_even((x-1)/2, y, z))/2);
            end
        end
    end
end
elapsed_9 = round(toc(tStart), 5);

figure(9);
imshow(image_blend);
title(['Blended Image: Temporal Averaging, Computation Time ' num2str(elapsed_9) ' s']);   
        
end

