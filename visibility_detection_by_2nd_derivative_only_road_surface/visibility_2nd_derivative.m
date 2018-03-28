function [ y_zero ] = visibility_2nd_derivative( image, valid_region, line_white_counter )
    img = imread(image);
    gray = rgb2gray(img);
    [hei, wid] = size(gray);
    gray_valid = gray & valid_region;
    y_zero = [];
    y_min = find(line_white_counter > 1, 1);        % added at the end
    %% Get mean_value, 1st_derivative, 2nd_derivative of each line
    lines_mean = zeros(hei, 1);
    derivative_1st = zeros(hei, 1);
    derivative_2nd = zeros(hei, 1);
    for r = 1 : length(lines_mean)
        lines_mean(r, 1) = sum(gray_valid(r, :)) / line_white_counter(r, 1);
    end
    for r = 2 : length(derivative_1st)
        derivative_1st(r, 1) = lines_mean(r, 1) - lines_mean(r-1, 1);
    end
    derivative_1st(1, 1) = 0.001;
    for r = 2 : length(derivative_2nd)
        derivative_2nd(r, 1) = derivative_1st(r, 1) - derivative_1st(r-1, 1);
    end
    derivative_2nd(1, 1) = 0.001;
    for r = 1 : length(derivative_2nd)
        if derivative_2nd(r, 1) == 0 && r > y_min && r < int32(hei * 0.8)
            y_zero = [y_zero; r];
        end
    end

end
