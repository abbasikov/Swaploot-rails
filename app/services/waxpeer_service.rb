class WaxpeerService
  include HTTParty

  BASE_URL = 'https://api.waxpeer.com/v1'

  def fetch_my_inventory
    params = {
      api: ENV['WAXPEER_API_KEY'],
      skip: 0,
      game: "csgo"
    }
    self.class.get(BASE_URL + '/get-my-inventory', query: params)
  end

  def fetch_balance
    params = {
      api: ENV['WAXPEER_API_KEY'],
    }
    res = self.class.get(BASE_URL + '/user', query: params)
    res['user']['wallet']
  end
end
