import EctoEnum

alias Ohno.Builder.PipelineFromType
alias Ohno.Builder.WhenType
alias Ohno.Builder.JobStatus

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
