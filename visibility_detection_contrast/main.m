clear, clc
close all
directory_0 = 'point_NUPT';
directory_1s = dir(directory_0);
directory_1s = {directory_1s.name};
directory_1s = directory_1s(3:length(directory_1s));
headers = {'1_point', '2_point', '3_point' ,'4_point' ,'5_point', '6_point'};
headers = [headers];
values = {};
values_p = {};
for dir_0_idx = 1 : length(directory_1s)
    road_surface = imread(strcat('./road_surfaces/thr_', num2str(dir_0_idx), '.jpg'));
    bw = im2bw(road_surface);
    bw = bw(2:size(bw, 1), 2:size(bw, 2));
    bw = bw(1:size(bw, 1)-1, 1:size(bw, 2)-1);
%     valid_points = find(road_surface > 0);
%     valid_points = [floor(valid_points / size(road_surface, 2)),...
%         mod(valid_points, size(road_surface, 2))];
    src_path = strcat('./', directory_0, '/', directory_1s(dir_0_idx), '/');
    dst_path = strcat('./results/', directory_1s(dir_0_idx), '/');
    src_path = src_path{1};
    dst_path = dst_path{1};
    images = dir(strcat(src_path, '/*.jpg'));
    images = {images.name};
    pre_suffix = strsplit(images{1}, '.');
    pre_suffix = pre_suffix{1};
    pre_suffix = pre_suffix(1:max(strfind(pre_suffix, '_')));
    images = strcat(src_path, images);
    res = [];
    non_zpzf_p = [];
    non_zpzf_pp = [];
    for image_i = 1 : length(images)
        image = strcat(src_path, pre_suffix, num2str(image_i), '.jpg');
        img = imread(image);
        [res_current, contrast_img] = visibility(image, bw);
        if ~ find(contrast_img == 0.05)
            non_zpzf_p = [non_zpzf_p; image_i];
        end
        if ~ find(contrast_img > 0.05)
            non_zpzf_pp = [non_zpzf_pp; image_i];
        end
        res = [res; [res_current(2), res_current(1)]];
        fig_name = figure(1);
        imshow(img,'border','tight','initialmagnification','fit');
        hold on;
        plot((1:size(img, 2)), res_current(1), 'red');
        scatter(res_current(2), res_current(1), 'red');
        text_x = min(res_current(2)+20, size(img, 2)-130);
        text_y = max(res_current(1)-20, 50);
        text(text_x, text_y,...
             strcat('(',num2str(res_current(2)), ', ',...
                    num2str(res_current(1)), ')'), 'Color', 'blue');
        hold off;
        if ~ exist(dst_path, 'dir')
            mkdir(dst_path);
        end
        saveas(fig_name, strcat(dst_path, num2str(image_i)), 'jpg')
        figure(2);
        imshow(contrast_img);
    %     pause(1);
        close all;
    end
    values{dir_0_idx} = [values, non_zpzf_p];
    values_p{dir_0_idx} = [values_p, non_zpzf_pp];
    dlmwrite(strcat(dst_path, 'visibility_limit.txt'), 'xy', 'newline', 'pc');
    dlmwrite(strcat(dst_path, 'visibility_limit.txt'), res, '-append', 'newline', 'pc');
end
xlswrite('non_005_statistics.xlsx', [zeros(1, 6); [non_zpzf_p{:}]]);
xlswrite('non_005_statistics.xlsx', headers);
xlswrite('non_gt005_statistics.xlsx', [zeros(1, 6); [non_zpzf_pp{:}]]);
xlswrite('non_gt005_statistics.xlsx', headers);