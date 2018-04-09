module ImageHistogram

export imhistogramGray, imhistogramRGB

using Images, Colors

using CustomUnitRanges: filename_for_zerorange
include(filename_for_zerorange)

#####
# convert sRGB (non-linear) to linearRGB (also used for sRGB to XYZ)
function linearRGB_from_sRGB(v)
    # v <= 0.04045 ? v/12.92 : ((v + 0.055) / 1.055)^2.4
    v <= 0.04045 ? v/12.92 : ((v + 0.055) / 1.055)^2.4
end

#####
# convert linearRGB to sRGB (non-linear) (also used for XYZ to sRGB)
function sRGB_from_linearRGB(v)
    # v <= 0.0031308 ? 12.92v : 1.055v^(1/2.4) - 0.055
    v <= 0.0031308 ? 12.92v : 1.055v^(inv(2.4)) - 0.055
end


#####
# histogram of 2D-array of image data
# only for internal use within module
#=
function _imhistogram(array2D::T) where T<:AbstractArray
    # I don't like fortran order - 1-offset arrays - driving on the left side
    ihist = ZeroRange(256);
    for j=1:size(array2D,2)
        for i=1:size(array2D,1)
            channel = Int(floor(array2D[i,j]));
            ihist[channel] += 1;
        end # i
    end # j
    
    return ihist;
end # function histogram of gray image
=#
#=
function _imhistogram(array2D::T) where T<:AbstractArray
    # I don't like fortran order - 1-offset arrays - driving on the left side
    ihist = ZeroRange(256);
    ihist[1] = 1; #  dies with 'ERROR: LoadError: indexing not defined for ImageHistogram.ZeroRange{Int64}'
    #=
    for p in array2D
        channel = Int32(floor(p));
        ihist[channel] += 1;
    end # j
    =#
    return ihist;
end # function histogram of gray image
=#
function _imhistogram(array2D::T, ncolorsteps) where T<:AbstractArray
    # I don't like fortran order - 1-offset arrays - driving on the left side
    ihist = zeros(Int32, ncolorsteps + 1);
    for p in array2D
        channel = Int32(floor(p));
        ihist[channel+1] += 1; # Bugfix : use 'channel+1' as channel can be 0 if no color. max(channel) is <= 255 for 'N0f8'
    end # for p
    
    return ihist;
end # function histogram of gray image

#####
# histogram of gray image
# ToDo: simply convert Gray Image to 2d-array and call '_histogram'
#    Gray.(img_col256)+0
#
#geht net: function imhistogram(imarray::AbstractArray{C}) where C<:AbstractGray
function imhistogramGray(imarray::AbstractArray)
    # ToDo: currently assume 8-bit per pixel per color
    typname = string("t", zero(Gray(imarray[1]))); # string("t", zero(Gray.(imarray)));
    if searchindex(typname, "N0f8") > 0
        myfactor = 2^8 - 1;
    elseif searchindex(typname, "N6f10") > 0
        myfactor = 2^10 - 1;
    elseif searchindex(typname, "N4f12") > 0
        myfactor = 2^12 - 1;
    elseif searchindex(typname, "N2f14") > 0
        myfactor = 2^14 - 1;
    elseif searchindex(typname, "N0f16") > 0
        myfactor = 2^16 - 1;
    else
        myfactor = 369; # artifical value to make the result worse
    end
            
    histo_gray = _imhistogram(Gray.(imarray) * myfactor, myfactor);
    return histo_gray;
end # function histogram of gray image

#####
# histogram of rgb image
# returns 3 histograms
#geht net: function imhistogram(imarray::AbstractArray{C}) where C<:AbstractRGB
function imhistogramRGB(imarray::AbstractArray)
    # ToDo: currently assume 8-bit per pixel per color
    typname = string("t", zero(red(imarray[1]))); # string("t", zero(red.(imarray)));
    if searchindex(typname, "N0f8") > 0
        myfactor = 2^8 - 1;
    elseif searchindex(typname, "N6f10") > 0
        myfactor = 2^10 - 1;
    elseif searchindex(typname, "N4f12") > 0
        myfactor = 2^12 - 1;
    elseif searchindex(typname, "N2f14") > 0
        myfactor = 2^14 - 1;
    elseif searchindex(typname, "N0f16") > 0
        myfactor = 2^16 - 1;
    else
        myfactor = 369; # artifical value to make the result worse
    end
            
    histo_red   = _imhistogram(red.(imarray) * myfactor, myfactor);
    histo_green = _imhistogram(green.(imarray) * myfactor, myfactor);
    histo_blue  = _imhistogram(blue.(imarray) * myfactor, myfactor);

    return histo_red, histo_green, histo_blue;
end # function histogram of RGB image

function imhistogramRGB3d(imarray::AbstractArray)
    typname = string("t", zero(red(imarray[1]))); # string("t", zero(red.(imarray)));
    if searchindex(typname, "N0f8") > 0
        myfactor = 2^8 - 1;
    elseif searchindex(typname, "N6f10") > 0
        myfactor = 2^10 - 1;
    elseif searchindex(typname, "N4f12") > 0
        myfactor = 2^12 - 1;
    elseif searchindex(typname, "N2f14") > 0
        myfactor = 2^14 - 1;
    elseif searchindex(typname, "N0f16") > 0
        myfactor = 2^16 - 1;
    else
        myfactor = 369; # artifical value to make the result worse
    end

    # 1st version
#    red_vector   = reshape(red.(imarray), :) .* myfactor; # reshape(red.(imarray), :, 1) * myfactor;
#    green_vector = reshape(green.(imarray), :) .* myfactor; # reshape(green.(imarray), :, 1) * myfactor;
#    blue_vector  = reshape(blue.(imarray), :) .* myfactor; # reshape(blue.(imarray), :, 1) * myfactor;
#    col_vector   = reshape(RGB24.(imarray), :); # reshape(RGB24.(imarray), :, 1);
    
    # make as 1 dim array
    red_vector   = reshape(red.(imarray), :); # reshape(red.(imarray), :, 1) * myfactor;
    green_vector = reshape(green.(imarray), :); # reshape(green.(imarray), :, 1) * myfactor;
    blue_vector  = reshape(blue.(imarray), :); # reshape(blue.(imarray), :, 1) * myfactor;

    # convert to ...
    if searchindex(typname, "N0f8") > 0
        # ... 8-bit int
        red_ivector   = reinterpret.(N0f8.(red_vector));
        green_ivector = reinterpret.(N0f8.(green_vector));
        blue_ivector  = reinterpret.(N0f8.(blue_vector));

        col_ivector = (red_ivector .% UInt32) .<< 16 .+ (green_ivector .% UInt32) .<< 8 .+ (blue_ivector .% UInt32);

        # now do unique sort to reduce the number of color values
        # and prepare the data for the color cube
        col_cube_iv   = unique(sort(col_ivector));
        red_cube_iv   = (col_cube_iv .& 0x00ff0000) .>> 16;
        green_cube_iv = (col_cube_iv .& 0x0000ff00) .>> 8;
        blue_cube_iv  = (col_cube_iv .& 0x000000ff);
    else
        # ... 16-bit int ; currently raw images have 10, 12 or 14 bits per color, some image tools work with 16 bit
        red_ivector   = reinterpret.(N0f16.(red_vector));
        green_ivector = reinterpret.(N0f16.(green_vector));
        blue_ivector  = reinterpret.(N0f16.(blue_vector));

        col_ivector = (red_ivector .% UInt64) .<< 32 .+ (green_ivector .% UInt64) .<< 16 .+ (blue_ivector .% UInt64);

        # now do unique sort to reduce the number of color values
        # and prepare the data for the color cube
        col_cube_iv   = unique(sort(col_ivector));
        red_cube_iv   = (col_cube_iv .& 0x0000ffff00000000) .>> 32;
        green_cube_iv = (col_cube_iv .& 0x00000000ffff0000) .>> 16;
        blue_cube_iv  = (col_cube_iv .& 0x000000000000ffff);
    end
    

    # now this can be plotted as 3D using gnuplot from julia
    # with the command
    #   @gp(splot=true,redv[:],greenv[:],bluev[:],colv[:],"with points pt 13 ps 0.7 lc rgb variable")
                         
    
#    return red_ivector, green_ivector, blue_ivector, col_ivector;
    return red_cube_iv, green_cube_iv, blue_cube_iv, col_cube_iv;
end # function imhistogramRGB3d of RGB image

# ToDo : => no, array tooooo large
# my_rgb24int = Int32.(floor.(red.(colv)*255)) .<< 16 .+ Int32.(floor.(green.(colv)*255)) .<< 8 .+ Int32.(floor.(blue.(colv)*255))

#=
# das folgende braucht noch 'using Plots'
# Plot examples:

function plot_imhi_RGB(imarray::AbstractArray)
    ihr, ihg, ihb = ImageHistogram.imhistogramRGB(imarray);
    plot(ihr, color=:red, w=2)
    plot!(ihg, color=:green, w=3)
    plot!(ihb, color=:blue, w=3)
    plot!(igray, color=:lightgray, w=3, line=:sticks)
    # or using as subplot
    # plot_red = plot(ihr, line=:red, w=2);
    # plot(plot_red, plot_green, plot_blue, plot_gray,layout=(2,2),legend=false)

ploting into a 3d RGB-cube:
using Images, TestImages ; import ImageHistogram ; img_col256 = testimage("lena_color_256");
redv, greenv,bluev, colv = ImageHistogram.imhistogramRGB3d(img_col256);
redv1=redv[1:32:65536]; greenv1=greenv[1:32:65536]; bluev1=bluev[1:32:65536]; colv1=colv[1:32:65536];

plot using Plots:
scatter3d(redv1, greenv1, bluev1, xlabel="red",ylabel="green",zlabel="blue"; color=colv1)

plot using GR:
setmarkersize=1; setmarkertype(GR.MARKERTYPE_DOT)
scatter3(redv1, greenv1, bluev1, xlabel="red",ylabel="green",zlabel="blue"; color=colv1)

the previous is not as good as using gnuplot
some reasons:
  Plots and GR do not support x-, y-, z-lables as expected
  take too long
  ? grid ?
  ? user defined view angle ?

end # function plot_imhi_RGB
=#

end # module ImageHistory
