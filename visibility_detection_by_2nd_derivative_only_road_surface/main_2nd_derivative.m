clear, clc
close all
directory_0 = 'point_NUPT';
directory_1s = dir(directory_0);
directory_1s = {directory_1s.name};
directory_1s = directory_1s(3:length(directory_1s));
images_cant_detect_vl = {};

for dir_0_idx = 1 : length(directory_1s)
    fprintf('Processing %s\n', directory_1s{dir_0_idx})
    road_surface = imread(strcat('./road_surfaces/thr_', num2str(dir_0_idx), '.jpg'));
    valid_region = im2bw(road_surface);
    [y, x] = find(valid_region == 1);
    line_white_counter = zeros(size(valid_region, 1), 1);
    for y_idx = 1 : size(valid_region, 1)
        t_sum = sum(valid_region(y_idx, :) == 1);
        if t_sum == 0
            line_white_counter(y_idx, 1) = 1;
        else
            line_white_counter(y_idx, 1) = t_sum;
        end
    end
    valid_points = [y, x];
    valid_points = sortrows(valid_points, 1);
    valid_points_cell = cell(size(valid_points, 1), 1);
    for i = 1 : size(valid_points_cell, 1)
        valid_points_cell{i} = valid_points(i, :);
    end
    src_path = strcat('./', directory_0, '/', directory_1s(dir_0_idx), '/');
    dst_path = strcat('./results/', directory_1s(dir_0_idx), '/');
    src_path = src_path{1};
    dst_path = dst_path{1};
    vl_refered = textread(strcat(dst_path, 'visibility_limit_by_contrast.txt'), '%f');
    images = dir(strcat(src_path, '/*.jpg'));
    images = {images.name};
    pre_suffix = strsplit(images{1}, '.');
    pre_suffix = pre_suffix{1};
    pre_suffix = pre_suffix(1:max(strfind(pre_suffix, '_')));
    images = strcat(src_path, images);
    y_axis = zeros(length(images), 1);

    for image_i = 1 : length(images)
        image = strcat(src_path, pre_suffix, num2str(image_i), '.jpg');
        fprintf('Processing %s\n', image);
        img = imread(image);
        tic
        y_zero = visibility_2nd_derivative(image, valid_region, line_white_counter);
        toc
        % Plot all ys where 2nd derivative equals 0
%         for y = 1 : length(y_zero)
% %             plot((1:size(img, 2)), y_zero(y, 1), 'red');
%             for x = 1 : size(img, 2)
%                 img(y_zero(y, 1), x, 1) = 255;
%                 img(y_zero(y, 1), x, 2) = 0;
%                 img(y_zero(y, 1), x, 3) = 0;
%             end
%         end
        if ~ exist(dst_path, 'dir')
            mkdir(dst_path);
        end
        if isempty(y_zero)
            fprintf('\nCant detect 2nd derivative == 0 in\n');
            fprintf(strcat(strcat(dst_path, num2str(image_i)), '.jpg'));
            images_cant_detect_vl = [images_cant_detect_vl;strcat(strcat(dst_path, num2str(image_i)), '.jpg')];
            y_axis(image_i, 1) = -1;
        else
            y_contrast = vl_refered(image_i, 1);
            [~, idx_nearest] = min(abs(y_zero(:) - y_contrast));
            y_draw = y_zero(idx_nearest, 1);
            y_axis(image_i, 1) = y_draw;
            for x = 1 : size(img, 2)
                img(y_draw, x, 1) = 255;
                img(y_draw, x, 2) = 0;
                img(y_draw, x, 3) = 0;
            end
        end
%         imshow(img)
%         return
        imwrite(img, strcat(strcat(dst_path, num2str(image_i)), '.jpg'));
    end
    dlmwrite(strcat(dst_path, 'visibility_limit_by_2nd_derivative.txt'), y_axis, '-append', 'newline', 'pc');
end
fid = fopen('./images_cant_detect_visibility_limit.txt', 'w');
for i = 1 : length(images_cant_detect_vl)
    fprintf(fid, '%s', images_cant_detect_vl{i});
    fprintf(fid, '\n');
end
fclose(fid);