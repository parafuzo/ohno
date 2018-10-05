defmodule Fabion.Builder.ProcessJob do
  alias Fabion.CloudBuild
  alias Fabion.Builder.Job

  def perform(%Job{} = job) do
    CloudBuild.update_job_status(job)
  end
end
