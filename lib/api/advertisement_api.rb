require 'api/base_api'

class AdvertisementAPI < BaseAPI
  get '/ad_images' do
    type =params['type']
    callback = params.delete('callback') # jsonp
    result = [
        {
            image: 'images/ad/index_1.png',
            link: {
                event: 'designer',
                designer_id: 2
            }
        },
        {
            image: 'images/ad/index_2.png',
            link: {
                event: 'designer_rank',
                query: {
                    type: 'monthly'
                }
            }
        }
    ]
    return_response callback, result
  end
end



