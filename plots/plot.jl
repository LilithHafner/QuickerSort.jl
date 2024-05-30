using Plots, CSV, DataFrames

function plot_data(;path="data.csv")
    data = CSV.read(path, DataFrame)
    # f = Figure()
    # ax = Axis(f)
    p = plot(xaxis=:log, legend=:topleft, ylabel="Runtime (ns per element)", xlabel="Input size (elements)", xticks=10 .^ (1:8))
    for (colname, color) in zip(propertynames(data)[2:end], [1,2,3,2,4,3,3])
        marker = startswith(string(colname), "simple") ? :square : colname == :optimized_hafner ? :utriangle : :circle

        plot!(data.size, 1e9 * data[:, colname] ./ data.size;
            label=string(colname), marker, color)
    end
    p
end
