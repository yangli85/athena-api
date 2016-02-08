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
end