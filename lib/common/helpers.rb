#add your common methods here
helpers do
  def return_response callback, results
    if callback
      content_type :js
      response = "#{callback}(#{results.to_json})"
    else
      content_type :json
      response = results.to_json
    end
    response
  end

  def return_xml results
    content_type :xml
    response = "<xml>#{results.map { |k, v| "<#{k}>#{v}</#{k}>" }.join}</xml>"
  end
end