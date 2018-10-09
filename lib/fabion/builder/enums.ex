import EctoEnum

alias Fabion.Builder.PipelineFromType
alias Fabion.Builder.WhenType
alias Fabion.Builder.JobStatus

defenum(JobStatus, :job_status, [
  :NEW,
  :STATUS_UNKNOWN,
  :QUEUED,
  :WORKING,
  :SUCCESS,
  :FAILURE,
  :INTERNAL_ERROR,
  :TIMEOUT,
  :CANCELLED
])

defenum(PipelineFromType, :pipeline_from_type, [
  :PUSH_EVENT
])

defenum(WhenType, :when_type, [
  :MANUAL,
  :AUTO
])
