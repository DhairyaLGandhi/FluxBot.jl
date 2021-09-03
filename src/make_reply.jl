# This is executed inside GitLab, so all the variables from there should be available here.

# Download artifacts
# Unzip and make into a gist
# Send response

# Just for testing
const ENV["CI_JOB_ID"]="359540097"
const ENV["CI_JOB_NAME"]="julia:1.1"

artifacts_url(::Val{:gitlab}, repo_name, job_id, job_name) = "https://gitlab.com/JuliaGPU/$repo_name/-/jobs/artifacts/master/download?job=$job_name"

function respond(ci_service = Val(:gitlab), repo_name = "Flux.jl")
  dict = try
    artifacts_name = "artifacts_$(ENV["CI_JOB_ID"]).zip"
    url = artifacts_url(ci_service, repo_name, ENV["CI_JOB_ID"], ENV["CI_JOB_NAME"])
    download(artifacts_url(ci_service, repo_name), artifacts_name)
    run(`unzip $artifacts_name`)
    files = glob("*.ipynb", "notebooks")
    
    gist_params = Dict("description" => "Build Results for $(ENV["CI_JOB_NAME"])",
                        "public" => true,
                        "files" => Dict(last(split(f,"/")) => Dict("content" => read(f,String),) for f in files))
    
    g = GitHub.create_gist(auth = myauth, params = gist_params)
    
    dict = Dict("body" => "Find the artifacts for `$(ENV["CI_JOB_NAME"])` at $(g.html_url)")
  catch ex
    dict = Dict("body" => "Pipeline Failed. Check the results at $(ENV["CI_PIPELINE_URL"])")
  end
  @show GitHub.Repo(ENV["REPO_NAME"])
  GitHub.create_comment(GitHub.Repo(ENV["REPO_NAME"]), ENV["PRID"], :issue, auth = myauth, params = dict)
  # GitHub.create_comment(GitHub.Repo("dhairyagandhi96/maskrcnn"), 3, :issue, auth = myauth, params = dict)
end
