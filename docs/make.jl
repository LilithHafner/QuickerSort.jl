using QuickerSort
using Documenter

DocMeta.setdocmeta!(QuickerSort, :DocTestSetup, :(using QuickerSort); recursive=true)

makedocs(;
    modules=[QuickerSort],
    authors="Lilith Orion Hafner <lilithhafner@gmail.com> and contributors",
    sitename="QuickerSort.jl",
    format=Documenter.HTML(;
        canonical="https://LilithHafner.github.io/QuickerSort.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/LilithHafner/QuickerSort.jl",
    devbranch="main",
)
