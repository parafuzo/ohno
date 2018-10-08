defmodule Fabion.Builder.ProcessJob do
  alias Fabion.CloudBuild
  alias Fabion.Builder.Job

  require Logger

  def perform(%Job{} = job) do
    with {:error, error} <- CloudBuild.update_job_status(job) do
      Logger.error("Error in process job: #{inspect(error)}")
      {:error, error}
    end
  end
end
