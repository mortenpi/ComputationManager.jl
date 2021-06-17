module ComputationManager
using DataStructures: OrderedDict

export savejob

const _JOBS = OrderedDict{String,Any}()

function savejob(f, name)
    haskey(_JOBS, name) && @warn "Overwriting existing job: $(name)"
    _JOBS[name] = f(name)
    return name
end

function main(args)
    global _JOBS
    if isempty(args)
        for name in keys(_JOBS)
            println(name)
        end
        println()
    else
        names = ("--runall" in args) ? collect(keys(_JOBS)) : args
        hasnames = map(name -> haskey(_JOBS, name), names)
        if !all(hasnames)
            error("Invalid jobs names: $(names[hasnames])")
        end
        for name in names
            @info "Running: $(name)"
            _JOBS[name]()
        end
    end
end

end
