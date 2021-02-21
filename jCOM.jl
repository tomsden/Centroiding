module jCOM

using PyPlot
export testimage, create_marker!, findmarkers, plot_image, centroid
export test1, test2, test3, test4
#Create a (blank) camera image for test purposes:
function testimage( width,        # width of image in pixels
                    height;       # height of image in pixels
                    #keyword arguments:
                    background=100.,  # background level in counts
                    noise=10.)        # noise level (one-sigma)
   pixelarray = Array{Float64}(undef, width, height)
   for i in eachindex(pixelarray)
       pixelarray[i] = background + noise*randn()
   end
   return pixelarray
end #(end function testimage)

function create_marker!(pixelarray, irow, icol, radius::Int, markerlevel)
#Create a circular marker within the pixel array.
    for i = -radius:1:radius
        for j = -radius:1:radius
            if i^2 + j^2 <= radius^2
               pixelarray[irow + i, icol + j] += markerlevel
               #Note: markerlevel is aded to background
            end
        end
    end
    return pixelarray
end

function plot_image(pixelarray, markerlevel)
    nrows = size(pixelarray)[1]
    ncols = size(pixelarray)[2]
    for i=1:nrows
       for j = 1:ncols
          plot(i, j, "b.")
          if pixelarray[i, j] >= markerlevel
              plot(i, j, "ro")
          end
       end
    end
end

function centroid(pixelarray, i1, i2, j1, j2)
    mass = sum(@view(pixelarray[i1:i2, j1:j2]))
    xmoment = zero(eltype(pixelarray))
    for i = i1:i2
        #xmoment += i*sum(pixelarray[i, j1:j2])
        xmoment += i*sum(@view(pixelarray[i, j1:j2]))
    end
    ymoment = zero(eltype(pixelarray))
    for j = j1:j2
        ymoment += j * sum(@view(pixelarray[i1:i2, j]))
    end
    return (xmoment/mass, ymoment/mass)
end

function findmarkers(pixelarray, signallevel)
#Find the indices of those pixels having levels above the given level.

#Find a pixel with a value above signallevel.
   (nrows, ncols) = size(pixelarray)
   indices = (0, 0)
 @time begin
   for i = 1:nrows
      for j = 1:ncols
         if pixelarray[i, j] > signallevel
            indices = (i, j)
            break
         end
      end
      if indices != (0, 0)
         break
      end
   end
 end
   println("indices: ", indices)
end

function findmarkers_fast(pixelarray, signallevel)
    k = 0
    for i in eachindex(pixelarray)
        if pixelarray[i] > signallevel
            k = i
            break
        end
    end
    (nrows, ncols) = size(pixelarray)
    row = mod(k, ncols)
    println("row: ", row)
    return ((k, pixelarray[k]))
    #return findall(x->x>signallevel, @view(pixelarray[1:4:3000, 1:4:4000]))[1]
end

function findmarkers_fast2(pixelarray, signallevel)
    nrows = size(pixelarray, 1)
    ncols = size(pixelarray, 2)
@time begin
    I = 0
    for i = 1:4:nrows
        for j = 1:4:ncols
            if pixelarray[i, j] > signallevel
                I = i
                println("I: ", I)
                break
            end
        end
        if I != 0 break end
    end
end
end

function test1()
    pxa = testimage(20, 20, noise=0.)
    create_marker!(pxa, 10, 10, 5, 1000.)
    @time (x, y) = centroid(pxa, 5, 15, 5, 15)
    println((x, y))
    @assert((x, y) == (10., 10.))
    println("test1 passed")
end

function test2()
    pxa = testimage(3000, 4000, noise=0.)
    create_marker!(pxa, 2510, 3010, 9, 1000.)
    @time (x, y) = centroid(pxa, 2500, 2520, 3000, 3020)
    println((x, y))
    @assert((x, y) == (2510., 3010.))
    println("test2 passed")
end

function test3()
    pxa = testimage(3000, 4000, noise=50.)
    create_marker!(pxa, 2510, 3010, 9, 1000.)
    @time (x, y) = centroid(pxa, 2500, 2520, 3000, 3020)
    println((x, y))
    @assert((round(x), round(y)) == (2510., 3010.))
    println("test3 passed")
end

function test4()
    pxa = testimage(3000, 4000, noise=50.)
    create_marker!(pxa, 2510, 3010, 9, 1000.)
    println("\nfindmarkers(pxa, 900.): ")
    @time findmarkers(pxa, 900.)
    println("\nfindmarkers_fast(pxa, 900.): ")
    @time findmarkers_fast(pxa, 900.)
    println("\nfindmarkers_fast2(pxa, 900.): ")
    @time findmarkers_fast2(pxa, 900.)
end



end #endmodule
