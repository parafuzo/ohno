import EctoEnum

alias Fabion.Builder.PipelineFromType
alias Fabion.Builder.WhenType

defenum(PipelineFromType, :pipeline_from_type, [
  :PUSH_EVENT
])

defenum(WhenType, :when_type, [
  :MANUAL,
  :AUTO
])
