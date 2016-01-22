get '/captcha/start/:how_many' do |how_many|
  captcha = VisualCaptchaCN::Captcha.new @session
  captcha.generate how_many
  json captcha.frontend_data
end

get '/captcha/image/:index' do
  captcha = VisualCaptchaCN::Captcha.new @session
  if (@body = captcha.stream_image @headers, params[:index], params[:retina])
    body @body
  else
    not_found
  end
end

post '/captcha/try' do
  session[:captcha_result] = nil
  if image_answer = params['value']
    captcha = VisualCaptchaCN::Captcha.new @session
    if captcha.validate_image image_answer
      session[:captcha_result] = "ok"
      json ret: "success"
    end
  end
end
