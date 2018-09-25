import EctoEnum

alias Fabion.Builder.PipelineFromType
alias Fabion.Builder.WhenType
alias Fabion.Builder.JobStatus

defenum(JobStatus, :job_status, [
  :NEW,
  :RUNNING,
  :RUNNING_NOTIFIED,
  :FAILED,
  :FAILED_NOTIFIED,
  :CANCELLED,
  :CANCELLED_NOTIFIED,
  :SUCCESS,
  :SUCCESS_NOTIFIED,
])

defenum(PipelineFromType, :pipeline_from_type, [
  :PUSH_EVENT
])

defenum(WhenType, :when_type, [
  :MANUAL,
  :AUTO
])
