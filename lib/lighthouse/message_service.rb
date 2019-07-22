# frozen_string_literal: true

class MessageService
  def initialize(url, audit, score)
    @url = url
    @audit = audit
    @score = score
  end

  def audit_fail_message
    <<~FAIL
      expected #{@url} to pass Lighthouse #{@audit} audit
      with a minimum score of #{@score}
    FAIL
  end
end
