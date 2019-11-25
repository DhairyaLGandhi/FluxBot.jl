# This is executed inside GitLab, so all the variables from there should be available here.

# Download artifacts
# Unzip and make into a gist
# Send response

# Just for testing
const CI_JOB_ID="359540097"
const CI_JOB_NAME="julia:1.1"
ENV["REPO_NAME"]="dhairyagandhi96/maskrcnn"
ENV["PRID"]=3

function respond()
  artifacts_name = "artifacts_$CI_JOB_ID.zip"
  download("https://gitlab.com/JuliaGPU/Flux.jl/-/jobs/artifacts/master/download?job=$CI_JOB_NAME", artifacts_name)
  run(`unzip $artifacts_name`)
  files = glob("*.cov", "src")#, "notebooks")
  
  gist_params = Dict("description" => "Build Results",
                      "public" => true,
                      "files" => Dict(last(split(f,"/")) => Dict("content" => read(f,String),) for f in files))
  
  g = GitHub.create_gist(auth = myauth, params = gist_params)
  
  dict = Dict("body" => "Find the artifacts for `$CI_JOB_NAME` at $(g.html_url)")
  GitHub.create_comment(GitHub.Repo(ENV["REPO_NAME"]), ENV["PRID"], :issue, auth = myauth, params = dict)
end
