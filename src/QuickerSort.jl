module QuickerSort

include("insertion_sort.jl")
include("simple_hoare.jl")
include("simple_lomuto.jl")
include("simple_hafner.jl")
include("optimized_hafner.jl")

include(joinpath(dirname(@__DIR__), "plots", "data.jl"))
include(joinpath(dirname(@__DIR__), "plots", "plot.jl"))

function reproduce_figures()
    cd(joinpath(dirname(@__DIR__), "paper")) do
        # @time save_runtime_data()
        plot_runtime_data()
        savefig("runtime.svg")
        # @time save_comparrison_data()
        plot_comparrison_data()
        savefig("comparrisons.svg")
        try
            run(`rsvg-convert -f pdf -o runtime.pdf runtime.svg`)
            run(`rsvg-convert -f pdf -o comparrisons.pdf comparrisons.svg`)
        catch
            @warn "Failed to convert SVGs to PDFs"
        end
        nothing
    end
end

end