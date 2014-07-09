module ShipIO
  class Client
    attr_accessor :api_key

    def initialize(api_key, options={})
      @api_key = api_key
    end

    # Returns all the jobs in the user account
    def jobs
      result = get("jobs.json")
      jobs = []
      for json_job in result do
        job = Job.new(self, {
                  uuid: json_job["id"],
                  name: json_job["name"],
                  repository_name: json_job["repository"]["name"],
                  repository_branch: json_job["repository"]["selected_branch"],
                  repository_url: json_job["repository"]["html_url"]
                })
        jobs << job
      end
      jobs
    end

    # Returns a build from a Job
    def build(job, build_id)
      response = get("jobs/#{job.uuid}/builds/#{build_id}.json")

      puts response
    end

    # Returns all the builds by a User
    def builds(job)
      response = get("jobs/#{job.uuid}/builds.json")
      builds = []
      for json_build in response do
        build = Build.new({
                              uuid: json_build["id"],
                              build_number: json_build["build_number"],
                              commit_sha: json_build["commit_sha"],
                              state: json_build["state"],
                              log_url: json_build["log_url"],
                              successful: json_build["successful"]
                          })
        builds << build
      end
      builds
    end

    def pusher_channel
      get("user/channel.json")
    end

    private
    def get(url, params={})
      url = '/' + url if url[0] != '/'
      url = ShipIO::BASE_URL + url
      result = RestClient.get url, {"Authorization" => "Bearer #{api_key}"}
      JSON.parse(result)
    end
  end
end