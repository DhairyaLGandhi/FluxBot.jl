using Pkg.TOML
function ci()
  @info ENV["GITHUB_EVENT_PATH"]
  f = JSON.parsefile(ENV["GITHUB_EVENT_PATH"])
  @show keys(f)
  event = GitHub.event_from_payload!("commit", f)

  if event.payload["action"] == "deleted"
    return HTTP.Response(200)
  end

  repo = event.repository
  reply_to = event.payload["issue"]["number"]

  files = [f.filename for f in GitHub.pull_request_files(repo, reply_to, auth = myauth)]
  possible_models = [split(f, "/") for f in files]
  possible_models = [length(f) > 1 ? f : [] for f in possible_models]
  possible_models = [f[1:end-1] for f in possible_models]
  possible_models = union(possible_models...)
  possible_models = uppercase.(possible_models)

  meta = TOML.parsefile(joinpath(pwd(), "scripts" "Notebooks.toml"))
  available_models = keys(meta)

  model = intersect(possible_models, available_models)
  model = join(model, ' ')
  @show model

  comment_kind = :issue
  # resp = trigger_pipeline(reply_to, model, event, fluxbot = false)
  resp = Dict("id" => "98138293",
              "web_url" => "https://gitlab.com/JuliaGPU/Flux.jl/pipelines/98138293",
              "sha" => "fbb377a7b436327c298c536ecb9d2ff5ee8e07d4")

  GitHub.create_comment(event.repository, reply_to, comment_kind,
                        auth = myauth,
                        params = placeholder_resp(reply_to, resp))
end
