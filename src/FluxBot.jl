module FluxBot

using GitHub, Glob
using GitHub.JSON, GitHub.HTTP
using Pkg.TOML

include("trial.jl")
include("make_reply.jl")
include("zoo_ci.jl")

end # module