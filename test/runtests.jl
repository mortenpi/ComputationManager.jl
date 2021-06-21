using Test: occursin
using ComputationManager
using Test, IOCapture

@testset "ComputationManager.jl" begin
    ComputationManager.main([])

    # Store a job. The function must return a callable object
    savejob("job1") do name
        () -> @info "Running job: $(name)"
    end

    # By default, we print out all the job names
    c = IOCapture.capture() do
        ComputationManager.main([])
    end
    @test occursin("job1", c.output)

    # Let's add another job
    savejob("job2") do name
        () -> @info "Running job: $(name)"
    end
    c = IOCapture.capture() do
        ComputationManager.main([])
    end
    @test occursin("job1", c.output)
    @test occursin("job2", c.output)

    # Let's run jobs 1 and 2 separately
    c = IOCapture.capture() do; ComputationManager.main(["job1"]); end
    @test occursin("Running job: job1", c.output)
    @test !occursin("Running job: job2", c.output)
    c = IOCapture.capture() do; ComputationManager.main(["job2"]); end
    @test !occursin("Running job: job1", c.output)
    @test occursin("Running job: job2", c.output)
    c = IOCapture.capture() do; ComputationManager.main(["job1", "job2"]); end
    @test occursin("Running job: job1", c.output)
    @test occursin("Running job: job2", c.output)
    c = IOCapture.capture() do; ComputationManager.main(["--runall"]); end
    @test occursin("Running job: job1", c.output)
    @test occursin("Running job: job2", c.output)

    # Test the savejob(::NamedTuple) signature
    empty!(ComputationManager._JOBS) # reset global state
    savejob( (name = "job3", f = () -> @info "Running job: job3") )
    c = IOCapture.capture() do; ComputationManager.main(["--runall"]); end
    @test occursin("Running job: job3", c.output)
end
