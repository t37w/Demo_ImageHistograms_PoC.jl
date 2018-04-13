# Package ImageHistograms.jl
Implement 2d and 3d histograms of images. Support gray and colored. Include support for plotting and some predefined layouts.

## Goal [ToDo]
* Check image if balanced: Low key, High key, Color balance
* 2d histograms
 + gray, red, green, blue
* 3d histogram
 + x-, y-, z-axis : derive from red, green, blue
 + plot using colored dots in RGB24 to get an impression of used color distribution within the image
* identify which Plt package is best for 3d plotting
 + currently under evaluation
  - Plots
  - Gnuplot
  - GR

## Used Packages
* julia as programming language
* Images.jl
* TestImages.jl
* Plots.jl : as default; may change
* Gnuplot.jl : may change
* GR.jl : may change

## Package tree layout
* directory src:
 + module "ImageHistogram" : contains the stable source. No cooked plotting
 + module "ImageHistogramTest" : contains the unstable source; use to try something, add new stuff, change existing, ...
  - cooked plotting in 2D using Plots
This way, source and runtime can be compared easily.

## Background Information and related URLs [ToDo]
* Color to Gray conversions
* Color schemes
* RGB and friends

## Usage
Copy ImageHistogram.jl and/or ImageHistogramTest.jl into the load path of julia.
Alternatively extend julia's load path to contain the directory the module files are located.

* use of ImageHistogram.jl

using Images, TestImages ; reload("ImageHistogram") ; img_col256 = testimage("lena_color_256");

ihR,ihG,ihB = ImageHistogramTest.imhistogramRGB(img_col256);
ihgray = ImageHistogramTest.imhistogramGray(img_col256);

plot(ihgray, color=:lightgray, w=3, line=:sticks)

plot(ihR, line=:red, w=2)

plot_red = plot(ihR, line=:red, w=2); plot_green = plot(ihG, line=:green, w=2); plot_blue = plot(ihB, line=:blue, w=2); plot_Gray = plot(ihgray, line=:lightgray, w=2);


* use of ImageHistogramTest.jl

using Images, TestImages ; reload("ImageHistogramTest") ; img_col256 = testimage("mandril_color");

ihR,ihG,ihB = ImageHistogramTest.imhistogramRGB(img_col256);
ihgray = ImageHistogramTest.imhistogramGray(img_col256);

ImageHistogramTest.plot_imhi(ihR_cooked=ihR, ihG_cooked=ihG, ihB_cooked=ihB,how=1,bg=1)
ImageHistogramTest.plot_imhi(ihR_cooked=ihR, ihG_cooked=ihG, ihB_cooked=ihB,how=4,bg=1)
ImageHistogramTest.plot_imhi(ihGray_cooked=ihgray,ihR_cooked=ihR, ihG_cooked=ihG, ihB_cooked=ihB,how=3,bg=1)

ImageHistogramTest.plot_imhi_GrayRGB(img_col256)
ImageHistogramTest.plot_imhi_GrayRGB(img_col256, how=3, bg=0)
