#
# sudoku.jl: simple sudoku solver ported from python.
#

using Printf

struct CandXY
    gridX::Int8
    gridY::Int8
    cand::Array{Bool}
end



function setup_grid(id)
    #println(id)
    grid = ""
    if id == -1 # For dev
        grid  = "287465193"
        grid *= "691238745"
        grid *= "435719826"
        grid *= "369124587"
        grid *= "814357962"
        grid *= "572986314"
        grid *= "000000000"
#        grid *= "726591438"
        grid *= "000000000"
#        grid *= "958643271"
        grid *= "000000000"
#        grid *= "143872659"
    end
    if id == 0 # full fill check
        grid  = "287465193"
        grid *= "691238745"
        grid *= "435719826"
        grid *= "369124587"
        grid *= "814357962"
        grid *= "572986314"
        grid *= "726591438"
        grid *= "958643271"
        grid *= "143872659"
    end
    if id == 1 # Very easy
        grid  = "000349806"
        grid *= "368072409"
        grid *= "407000253"

        grid *= "050107904"
        grid *= "780096035"
        grid *= "030405062"
        grid *= "072604301"
        grid *= "600703528"
        grid *= "503928000"
    end
    if id == 2
        grid  = "000000000"
        grid *= "000000027"
        grid *= "400608000"
        grid *= "071000300"
        grid *= "238506419"
        grid *= "964100750"
        grid *= "395027800"
        grid *= "182060974"
        grid *= "046819205"
    end
    return grid
end


function gen_bit_array(grid, debug=false)
    #println(grid)
    bgrid = falses(9, 9*9)
    if debug
        println("bgrid, typeof=", typeof(bgrid))
    end
    for i = 1: (9*9)
        n = parse(Int8, grid[i])
        if n != 0
            #println(i, ":", n)
            bgrid[n, i] = true
        end
    end
    #println(bgrid)
    if debug
        println("bgrid, typeof/+=", typeof(bgrid))
    end
    return bgrid
end

function toStringList(b)
    # b: bit array according 1..9, num
    res = ""
    for i = 1 : 9
        #print(" i/@toStringList=", i, ",b=",b[i])
        if b[i]
            res *= string(i)
        end
    end
    if res == ""
        return "0"
    else
        return res
    end
end


function tostring(b)
    #print(typeof(b))
    for i = 1 : 9
        #print(b[i])
        if b[i]
            return string(i)
        end
    end
    return "0"
end

function or_line_disp(por_line)
    for j = 1 : 9
        println("or line: [", j, "], index=", j)
        println(" ", por_line[:,j])
        if (j%3) == 0
            if j != 9
                print(" ")
            end
        end
    end
end

function is_full(pgrid, debug=false)
    or_line = falses(9, 9)
    for i = 0 : 8
        for j = 1 : 9
            index = i*9+j
            if debug
                println("[", i, ",", j, "], index=", index)
                println(typeof(pgrid))
                println(pgrid[:,index])
            end
            if debug
                if (j%3) == 0
                    if j != 9
                        print(" ")
                    end
                end
            end
            if debug
                println(typeof(pgrid))
            end
            for k = 1:9
                if debug
                    println(" [", k, "]=", typeof(pgrid[k, index]))
                    println(" or[", k, "]=", typeof(or_line[k, j]))
                end
                #or_line[k, j] = or_line[k,j] | pgrid[k, index]
            end
            or_line[:,j] .|= pgrid[:,index]
        end
        if debug
            or_line_disp(or_line)
            println("")
            if (i%3)==2
                println("")
            end
        end
    end
    if debug
        or_line_disp(or_line)
        print(" +/all=", all(x->x==true, or_line))
    end
    return all(x->x==true, or_line)
end

function display_grid(pgrid, debug=false)
    for i = 0 : 8
        for j = 1 : 9
            index = i*9+j
            if debug
                println("\n[", i, ",", j, "]@", index,":", pgrid[:,index])
            end
            print(tostring(pgrid[:,index]))
            if (j%3) == 0
                if j != 9
                    print(" ")
                end
            end
        end
        println("")
        if (i%3)==2
            println("")
        end
    end
end

full_clist = trues(9)

function candidate(grid, ppoint, debug=false)
    (x, y) = ppoint
    if debug
        print("Point:", ppoint)
    end
    
    # Line
    if debug
        println("  ", y*9+1, " to ", y*9+10-1)
    end
    lc = falses(9)
    for i = y*9+1:y*9+10-1
        lc = lc.|grid[:, i]
        if debug
            @printf(" lc/.(%d):", i)
            println(grid[:, i])
        end
    end
    if debug
        println(" lc/+:", lc)
    end
    lc = full_clist.&.~lc
    if debug
        println("lc=", toStringList(lc))
    end
    # Column
    c = grid[:, x:81:9]
    cc = falses(9)
    for i = 0 : 8
        #println(i*9+x)
        #println("typeof grid Columng=", typeof(grid[:, i*9+x]))
        #println(grid[:, i*9+x])
        cc = cc.|grid[:, i*9+x] 
    end
    cc = lc.&.~cc
    if debug
        println("cc=", toStringList(cc))
    end
    # Block
    x0 = Int(trunc((x-1)/3)*3)+1
    y0 = Int(trunc(y/3)*3)
    if debug
        println(" x0=", x0, " y0=", y0)
    end
    r = y % 3
    bc = falses(9)
    if r != 0
        for i = 0:2
            if debug
                print("  y0.=",y0)
            end
            bc = bc.|grid[:, x0+y0*9+i]
        end
    end
    y0 += 1
    if r != 1
        for i = 0:2
            if debug
                print("  y0..=",y0)
            end
            bc = bc.|grid[:, x0+y0*9+i]
        end
    end
    y0 += 1
    if r != 2
        for i = 0:2
            if debug
                print("  y0...=",y0)
            end
            bc = bc.|grid[:, x0+y0*9+i]
        end
    end
    if debug
        println("")
    end
    bc = cc.&.~bc
    if debug
        println("bc=", toStringList(bc))
    end
    return bc
end



# "0" means all zero(falses)
zero_grid = falses(9)

function solver(grid, debug=false, level=0)
    #res = is_full(grid, debug)
    res = is_full(grid)
    if debug
        println("   is_full ret:", res)
    end
    if res 
        return true, grid
    end
    
    # Cnadidiate list, clist[0] :[[x,y], "candidate")
    #grid_clist = fill([], 10)
    grid_clist = Dict()
    for iy = 0:8
        for ix = 1:9
            index = iy*9+ix
            if grid[:, index] != zero_grid
                if debug
                    if false
                        println(typeof(grid[:,index]))
                        println("non zero@loop.solvergrid[", index, "]=",
                                grid[:,index])
                    end
                end
                continue
            end
            clist = candidate(grid, (ix, iy), debug)
            #clen  = count_bit(clist)
            clen  = length(clist[clist .== true])
	    # Canidite list: [# cand] = [...]
            if get(grid_clist, "$clen:", "") == ""
                if debug
                    @printf("<%d> len(%d)/-=0\n", level, clen)
                end
                #grid_clist["$clen:"] = [[ix, iy], [clist]]
                grid_clist["$clen:"] = CandXY[]
                push!(grid_clist["$clen:"], CandXY(ix, iy, clist))
            else
                if debug
                    @printf("<%d> len(%d)/-=%d\n",
                            level, clen, length(grid_clist["$clen:"]))
                    println(typeof(grid_clist["$clen:"]))
                end
                cclist = grid_clist["$clen:"]
                #append!(grid_clist["$clen:"], [[ix, iy], clist])
                #append!(grid_clist["$clen:"], CandXY(ix, iy, clist))
                push!(grid_clist["$clen:"], CandXY(ix, iy, clist))
            end
            if debug
                @printf("<%d>clist(%d,%d):[%d]%s\n", level, ix, iy, clen,
                        toStringList(clist))
                println(typeof(grid_clist["$clen:"]))
                println(" len/+=", length(grid_clist["$clen:"]))
            end
        end
    end

    for i = 1:9
	try
	    if get(grid_clist,"$i:","") == ""
	    	continue
            end
        catch KeyError
                continue
	end
        if debug
            println(typeof(grid_clist["$i:"]))
    	    println(i,":", length(grid_clist["$i:"]))
        end
        cclist = grid_clist["$i:"]
        for cc in cclist
            #println(" cc:", cc)
            #println(typeof(cc))
            #[[ix, iy], clist] = cc
            #ix = cc[1][1]
            #iy = cc[1][2]
            #clist = cc[2]
            if debug
                @printf("<%d> [%d, %d]: %s\n",
                        level, cc.gridX, cc.gridY, toStringList(cc.cand))
            end
            # Put cc.and into [gridX, gridY]
            for i = 1: 9
                if cc.cand[i]
                    # Put
                    grid[i, cc.gridY*9+cc.gridX] = true
                    res, grid = solver(grid, debug, level+1)
                    if res == true
                        return res, grid
                    end
                    # Unput
                    grid[i, cc.gridY*9+cc.gridX] = false
                end
            end

            if false
                # Put cc.and into [gridX, gridY]
                grid[cc.cand, cc.gridY*9+cc.gridX] .= true
                res, grid = solver(grid)
                if res == true
                    return res, grid
                end
                # Unput
                grid[cc.cand, cc.gridY*9+cc.gridX] .= false
            end

        end
    end

    return false, grid
end


if !isinteractive()
    println("Start.")
    debug = false
    #debug = true
    prog = basename(Base.source_path())
    argc = size(ARGS,1)
    if debug
        println("argc=", argc)
    end
    if argc != 1
        println("Usage: julia ", prog, " ID")
        if debug
            println(basename(@__FILE__))
        end
    else
        a1 = ARGS[1]
        id = parse(Int32, a1)
        grid = setup_grid(id)
        println(" Input:")
        bgrid = gen_bit_array(grid)
        #display_grid(bgrid, debug)
        display_grid(bgrid)
    end
    status, rgrid = solver(bgrid,  debug)
    if debug
        println("  status=", status)
    end
    if status
        println(" =>Result:")
        display_grid(bgrid)
    end
    println("Finished.")
end
