class BumpController < ApplicationController
  skip_before_action :verify_authenticity_token

  def fake_webhook
    # POST
    # this is a webhook, to be called implemented in bump.sh
    5.times { puts 'X' * 10 + __method__.to_s + 'X' * 10 }
    p params

    redirect_to ping_webhook_path, notice: 'POST request done on /fake_webhook'
  end

  def ping
    # GET
  end
end
