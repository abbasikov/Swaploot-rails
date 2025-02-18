class Users::SessionsController < Devise::SessionsController
  include Geocoder::Result

  def create
    super do |resource|
      if resource.persisted?
        location = get_user_location(request.remote_ip)
        flash[:notice] = "User logged in with #{resource.email} from #{location}, (IP Address: #{request.remote_ip})"
        @notification = current_user.notifications.create(title: "User Logged In", body: "User logged in with email: #{resource.email}, from #{location}, (IP Address: #{request.remote_ip})", notification_type: "Login" )
        notify_discord(@notification.body) if current_user.discord_bot_token.present? && current_user.discord_channel_id.present?
      end
    end
  end

  def destroy
    super
  end

  private

  def get_user_location(ip)
    result = Geocoder.search(ip).first
    return "#{result.city}, #{result.region}" if result.is_a?(Geocoder::Result::Base)
      "Unknown Location"
    rescue
      "Unknown Location"
  end

  def notify_discord(message)
    begin
      bot = Discordrb::Bot.new(token: current_user.discord_bot_token)
      channel = bot.channel(current_user.discord_channel_id)
      channel.send_message(message)
    rescue StandardError => e
      @notification = current_user.notifications.create(title: "Discord Login", body: "User is unauthorized", notification_type: "Login")
    end
  end
end
