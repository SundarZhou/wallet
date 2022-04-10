class ApplicationController < ActionController::API
  def add_message(msg)
    @_messages ||= []
    @_messages << msg
  end

  def render_error(code, data={})
    render_result(code, @_messages, camelize_keys(data))
  end

  def render_json(data)
    render_result('0', @_messages, camelize_keys(data))
  end

  def render_result(code, messages, data)
    render json: {
      code: code,
      messages: messages,
      data: data
    }
  end

  def camelize_keys object
    case object
    when Hash
      object.map{|k,v| [k.to_s.delete('?').camelize(:lower), camelize_keys(v)]}.to_h
    when Array
      object.map{|e| camelize_keys e}
    else
      object
    end
  end

  def encode_token(payload)
    JWT.encode(payload, ENV["API_SECRET_KEY"])
  end

  def auth_header
    request.headers['Authorization'] || params["HTTP_AUTHENTICATE"]
  end

  def decoded_token
    if auth_header
      token = auth_header
      begin
        JWT.decode(token, ENV["API_SECRET_KEY"], true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def logged_in_account
    if decoded_token
      account_id = decoded_token[0]['account_id']
      @account = Account.find_by(id: account_id)
    end
  end

  def logged_in?
    !!logged_in_account
  end

  def authorized
    unless logged_in?
      add_message("Please log in")
      render_error("332")
    end
  end
end
