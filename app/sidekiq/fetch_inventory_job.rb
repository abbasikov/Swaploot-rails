class FetchInventoryJob
	include Sidekiq::Job
	sidekiq_options retry: false
	
	def perform
		p "<============= Fetch Inventory Job started... ================>"
		@users = User.all
		@users.each do |user|
			begin
				CsgoempireService.new(user).fetch_my_inventory
			rescue
				"*********    Fetch Inventory Job Failed....  **************"
			end
		end
	end
end
