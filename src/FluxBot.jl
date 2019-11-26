module FluxBot

using GitHub, Glob
using GitHub.JSON, GitHub.HTTP

include("trial.jl")
include("make_reply.jl")
include("zoo_ci.jl")

end # module