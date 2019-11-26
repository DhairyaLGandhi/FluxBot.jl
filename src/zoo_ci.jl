function ci()
  @info ENV["GITHUB_EVENT_PATH"]
  f = JSON.parsefile(ENV["GITHUB_EVENT_PATH"])
  event = GitHub.event_from_payload!("commit", f)

  repo = event.repository

  # Fails if push to repo directly
  # issue => pull_request
  @show event.payload
  reply_to = event.payload["pull_request"]["number"]

  files = [f.filename for f in GitHub.pull_request_files(repo, reply_to, auth = myauth)]
  possible_models = [split(f, "/") for f in files]
  possible_models = [length(f) > 1 ? f : [] for f in possible_models]
  possible_models = [f[1:end-1] for f in possible_models]
  possible_models = union(possible_models...)
  possible_models = uppercase.(possible_models)

  # meta = TOML.parsefile(joinpath(pwd(), "scripts", "Notebooks.toml"))
  meta = ["MNIST", "CPPN", ]
  available_models = keys(meta)

  model = intersect(possible_models, available_models)
  model = join(model, ' ')
  @show model

  # Handle when model is not found
  if all(map(isspace, collect(model)))
  	GitHub.create_comment(event.repository, reply_to, comment_kind,
		                      auth = myauth,
		                      params = Dict("body" => "No matching models found, consider adding the appropriate models to the `Notebooks.toml`."))
  	return HTTP.Response(200)
  end

  comment_kind = :issue
  # resp = trigger_pipeline(reply_to, model, event, fluxbot = false)
  resp = Dict("id" => "98138293",
              "web_url" => "https://gitlab.com/JuliaGPU/Flux.jl/pipelines/98138293",
              "sha" => "fbb377a7b436327c298c536ecb9d2ff5ee8e07d4")

  GitHub.create_comment(event.repository, reply_to, comment_kind,
                        auth = myauth,
                        params = placeholder_resp(reply_to, resp))
end
