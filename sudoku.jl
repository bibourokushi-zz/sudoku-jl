#
# sudoku.jl: simple sudoku solver ported from python.
#

function setup_grid(id)
    #println(id)
    grid = ""
    if id == 1
        grid = "000000000"
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

function count_bit(b)
    c = 0
    for i = 1:9
        if b[i]
            c += 1
        end
    end
    return c
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
    res = ""
    for i = 1 : 9
        #print(b[i])
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


function display_grid(grid)
    for i = 0 : 8
        for j = 1 : 9
            index = i*9+j
            #println(i, ",", j, "=", index)
            print(tostring(bgrid[:,index]))
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
    #println("  ", y*9+1, " to ", y*9+10-1)
    lc = falses(9)
    #println(lc)
    for i = y*9+1:y*9+10-1
        lc = lc.|grid[:, i]
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


full      = trues(9, 9*9)
# "0" means all zero(falses)
zero_grid = falses(9)

function solver(grid, debug=false)
    if grid == full
        if debug
            println("full fill@solver")
        end
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
            clist = candidate(grid, (ix, iy), false)
            clen  = count_bit(clist)
            if get(grid_clist, "$clen:", "") == ""
                if debug
                    @printf(" len(%d)/-=0\n", clen)
                end
                grid_clist["$clen:"] = Vector(clist)
            else
                if debug
                    @printf(" len(%d)/-=%d\n",
                            clen, length(grid_clist["$clen:"]))
                    println(typeof(grid_clist["$clen:"]))
                end
                append!(grid_clist["$clen:"], clist)
            end
            if debug
                @printf("clist(%d,%d):<%d>%s\n", ix, iy, clen,
                        toStringList(clist))
                println(" len/+=", length(grid_clist["$clen:"]))
            end
        end
    end

    for i = 0:9
        println(i,":", length(grid_clist[i+1]))
    end

    return false, grid
end


if !isinteractive()
    debug = false
    prog = basename(Base.source_path())
    argc = size(ARGS,1)
    #println(argc)
    if argc != 1
        println("Usage: julia ", prog, " ID")
        #println(basename(@__FILE__))
    else
        a1 = ARGS[1]
        id = parse(Int32, a1)
        grid = setup_grid(id)
        println(" Input:")
        bgrid = gen_bit_array(grid)
        display_grid(bgrid)
    end
    #status, rgrid = solver(bgrid,  false)
    if debug
        println("given full fill")
        status, rgrid = solver(full,  true)
    end
    status, rgrid = solver(bgrid,  true)
    println(" =>Result:")
    println("  status=", status)
end
