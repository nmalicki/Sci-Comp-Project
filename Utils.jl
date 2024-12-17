module Utils
import Base

export list_diff, list_dif_multi, list_append, get_season_driver_nums, dropmissing

function list_diff(a, b)
    sort!(a)
    sort!(b)
    for i in eachindex(a)
        if (a[i] != b[i])
            return a[i]
        end
    end
end

function list_diff_multi(main_list, new)
    result = []
    for i in eachindex(new)
        if (new[i] in main_list) == false
            push!(result, new[i])
        end
    end
    return result
end

function list_append(main_list, to_add)
    result = main_list
    for i in eachindex(to_add)
        result = push!(main_list, to_add[i])
    end
    return result
end

function get_season_driver_nums(data)
    all_driver_nums = []
    sort!(map(d->d["driver_number"], data[1][2]))
    for i in 2:length(data)
        new_nums = []
        if data[i][2][20] != nothing
            new_nums = Utils.list_diff_multi(all_driver_nums, map(d->d["driver_number"], data[i][2]))
        else
            new_nums = Utils.list_diff_multi(all_driver_nums, map(d->d["driver_number"], data[i][2][1:end-1]))
        end
        if length(new_nums) != 0
            all_driver_nums = Utils.list_append(all_driver_nums, new_nums)
        end
    end
    return sort!(all_driver_nums)
end
function dropmissing(a::Vector{Any})
    result = Int64[]
    for i in 1:length(a)
        if (typeof(a[i]) != Missing)
            push!(result, a[i])
        end
    end
    return result
end

end