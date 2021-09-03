using JSON, HTTP

const HEADERS = Dict("Authorization" => "Bearer " * ENV["FLUXBOT_BUILDKITE_SECRET"])
const ORG_SLUG = "julialang"
const BUILDKITE_BASE_URL = "https://api.buildkite.com/v2/organizations/$ORG_SLUG/pipelines/" 

### Jobs API

function create_job(project_slug, commit, branch; headers = HEADERS)

  d = Dict("commit" => commit, "branch" => branch)
  url = joinpath(BUILDKITE_BASE_URL, project_slug, "builds")
  req = HTTP.post(url, headers, data)
  JSON.parse(req.body)
end

function get_job_logs(project_slug, build_number, job_id; headers = HEADERS)
  url = joinpath(BUILDKITE_BASE_URL, project_slug, "builds", build_number, "jobs", job_id, "log")
  req = HTTP.get(url, headers)
  JSON.parse(req.body)
end



### Builds API

function get_build(project_slug, build_number; headers = HEADERS)
  url = joinpath(BUILDKITE_BASE_URL, project_slug, "builds", build_number)
  req = HTTP.get(url, headers = headers)
  JSON.parse(req.body)
end
get_build(project_slug; kwargs...) = get_build(project_slug, ""; kwargs...)

function create_build(project_slug, commit, branch; headers = HEADERS)
  url = joinpath(BUILDKITE_BASE_URL, project_slug, "builds")
  data = Dict("commit" => commit, "branch" => branch)
  req = HTTP.post(url, headers, data)
  JSON.parse(req.body)
end

function cancel_build(project_slug, build_number; headers = HEADERS)
  url = joinpath(BUILDKITE_BASE_URL, project_slug, "builds", build_number, "cancel")
  req = HTTP.put(url, headers)
  JSON.parse(req.body)
end

function rebuild_build(project_slug, build_number; headers = HEADERS)
  url = joinpath(BUILDKITE_BASE_URL, project_slug, "builds", build_number, "rebuild")
  req = HTTP.put(url, headers)
  JSON.parse(req.body)
end


