class ServiceResult
  attr_reader :error, :errors, :over, :match, :ball

  def initialize(success:, **kwargs)
    @success = success
    @error = kwargs[:error]
    @errors = kwargs[:errors]
    @over = kwargs[:over]
    @match = kwargs[:match]
    @ball = kwargs[:ball]
  end

  def success?
    @success
  end
end
