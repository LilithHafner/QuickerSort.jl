using Plots, CSV, DataFrames

legendify(s::Symbol) = replace(string(s), "_" => " ", "hafner" => "proposed", "lomuto" => "Lomuto", "hoare" => "Hoare", "simple" => "Simple", "optimized" => "Optimized", "theoretical" => "Theoretical")

function plot_runtime_data(;path="runtime_data.csv")
    data = CSV.read(path, DataFrame)
    p = plot(xaxis=:log, legend=:topleft, ylabel="Runtime (ns per element)", xlabel="Input size (elements)", xticks=10 .^ (1:8))
    for (colname, color) in zip(propertynames(data)[2:end], [1,2,3,2,4,3,3])
        marker = startswith(string(colname), "simple") ? :square : colname == :optimized_hafner ? :utriangle : :circle

        plot!(data.size, 1e9 * data[:, colname] ./ data.size;
            label=legendify(colname), marker, color)
    end
    p
end

function plot_count_data(;path="count_data.csv")
    data = CSV.read(path, DataFrame)
    p = plot(xaxis=:log, legend=:topleft, ylabel="Average comparrisons per element", xlabel="Input size (elements)", xticks=10 .^ (1:8))
    for (colname, color) in zip(propertynames(data)[2:end], [1,2,3,2,4,3,3,:black])
        marker = startswith(string(colname), "simple") ? :square : colname == :optimized_hafner ? :utriangle : colname == :theoretical_minimum ? :none : :circle

        plot!(data.size, data[:, colname] ./ data.size;
            label=legendify(colname), marker, color)
    end
    p
end
