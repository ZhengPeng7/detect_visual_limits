function [ res, contrast_distribution ] = visibility( image, valid_area_bw )
    img = imread(image);
    gray = rgb2gray(img);
    [hei, wid] = size(gray);
    contrast_distribution = zeros(hei-2, wid-2);
    for r = 2 : hei-1
        for c = 2 : wid-1
            points = [[r-1, c]; [r, c-1]; [r, c+1]; [r+1, c]];
            % 对四个方向的都求取C(x, x_i) = |f(x) - f(x_i)| / max(f(x), f(x_i))
            C_max = -1;
            for idx = 1 : numel(points)/size(points, 2)
                p = points(idx, :);
                C_max = max(C_max, double(abs(gray(r, c) - gray(p(1), p(2)))) /...
                    double(max(gray(r, c), gray(p(1), p(2)))));
            end
            if C_max > 0.05
                C_max = 0;
            else
                C_max = 255;
            end
            contrast_distribution(r-1, c-1) = C_max;
        end
    end
    contrast_distribution = 255 - contrast_distribution;
    if [1080, 1920] == size(contrast_distribution)
        contrast_distribution(890:965, 1385:1875) = 0;
    end
%     contrast_distribution(1:120, :) = 0;
%     contrast_distribution(:, 1:200) = 0;
    contrast_distribution = im2bw(contrast_distribution);
    contrast_distribution = contrast_distribution & valid_area_bw;
    res = [0, 0];
    flag_break = 0;
    for r = 1 : size(contrast_distribution, 1)
        if flag_break
            break
        end
        poss_pt = find(contrast_distribution(r, :) > 0);
        if poss_pt
            for i = 1 : length(poss_pt)
                % 2个条件: 1. 周围范围方格内存在一定数量的其他合格点
                %         2. 之后几行有足够数量的合格点
                valid_points_num = length(find(contrast_distribution(...
                    r:min(size(contrast_distribution, 1), r+50), ...
                    max(1, poss_pt(i)-25):min(size(contrast_distribution, 2), poss_pt(i)+25)) > 0));
                if valid_points_num > 3
                    t = find(contrast_distribution(r:r+10, :) > 0);
                    if length(t) > 4
                        res = [r, poss_pt(i)];
                        flag_break = 1;
                        break
                    end
                end
            end
        end
    end
end
