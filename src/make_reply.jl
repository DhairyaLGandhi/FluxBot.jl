# This is executed inside GitLab, so all the variables from there should be available here.

# Download artifacts
# Unzip and make into a gist
# Send response

# Just for testing
const ENV["CI_JOB_ID"]="359540097"
const ENV["CI_JOB_NAME"]="julia:1.1"

function respond(repo_name = "Flux.jl")
  artifacts_name = "artifacts_$(ENV["CI_JOB_ID"]).zip"
  download("https://gitlab.com/JuliaGPU/$repo_name/-/jobs/artifacts/master/download?job=$(ENV["CI_JOB_NAME"])", artifacts_name)
  run(`unzip $artifacts_name`)
  files = glob("*.ipynb", "notebooks")
  
  gist_params = Dict("description" => "Build Results for $(ENV["CI_JOB_NAME"])",
                      "public" => true,
                      "files" => Dict(last(split(f,"/")) => Dict("content" => read(f,String),) for f in files))
  
  g = GitHub.create_gist(auth = myauth, params = gist_params)
  
  dict = Dict("body" => "Find the artifacts for `$(ENV["CI_JOB_NAME"])` at $(g.html_url)")
  # GitHub.create_comment(GitHub.Repo(ENV["REPO_NAME"]), ENV["PRID"], :issue, auth = myauth, params = dict)
  GitHub.create_comment(GitHub.Repo("dhairyagandhi96/maskrcnn"), 3, :issue, auth = myauth, params = dict)
end
