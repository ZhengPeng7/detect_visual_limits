# Detect visual limits of the road in foggy scene.

1. Method 1: in the directory "visibility_detection_by_contrast", the contrast method is used. The code took the 4-nearest pixels to calculate the contrast value(In the paper<sup>[1]</sup>, it's said that use 2-nearest pixels can get the same effect while saving much time) -- ___if the contrast value of the pixel reaches the threshold and it's not a very isolated one, its y_axis value is perhaps the visual limit___. The paper referred is below.
2. Method 2: in the directory "visibility_detection_by_2nd_derivative_only_road_surface", referred to paper<sup>[2]</sup>the 2nd derivative method is used as: 
   1. ___Get the vector containing the mean of gray values of each line in a road scene image.___
   2. ___Calculate the 2nd derivative of the gray values, and find where the 2nd derivative equals 0, of which the y_axis value is probably the visual limit. Besides, I restricted the visual limits in the road region, to get rid of the interference of the trees or other things around.___
   3. ___However, the candidate y may exist a lot, so the code here took the result of method 1 -- select the y which is nearest to the result in method 1.___
   4. ___It seems that method 2 is better than method 1 here, while refered on results of method 1.___

> [Paper1](http://kns.cnki.net/KCMS/detail/detail.aspx?dbcode=CJFQ&dbname=CJFD2009&filename=JSJF200911010&v=MTA5Mjl0ak5ybzlFWklSOGVYMUx1eFlTN0RoMVQzcVRyV00xRnJDVVJMS2ZaT1JuRkNua1c3eklMejdCYUxHNEg=) -- 李勃,董蓉,陈启美.无需人工标记的视频对比度道路能见度检测[J].计算机辅助设计与图形学学报,2009,21(11):1575-1582.
>
> [Paper2](https://www.researchgate.net/publication/220464605_Automatic_fog_detection_and_estimation_of_visibility_distance_through_use_of_an_onboard_camera) -- Hautière, Nicolas & Tarel, Jean-Philippe & Lavenant, Jean & Aubert, Didier. (2006). Automatic fog detection and estimation of visibility distance through use of an onboard camera. Mach. Vis. Appl.. 17. 8-20. 10.1007/s00138-005-0011-1. 
