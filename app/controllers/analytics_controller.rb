class AnalyticsController < ApplicationController
  def index
    @profit_by_month = {}
    @quantity_sold_by_month = {}
    @quantity_purchased_by_month = {}
    params[:year] ||= Date.current.year
    if current_user.active_steam_account.present?
      profit = current_user.active_steam_account.sold_items.profits_by_year(params[:year])
      profit_hash = {}
      profit.each do |key, value|
        profit_hash[key.to_i] = value.to_f
      end

      Date::MONTHNAMES.compact.each.with_index do |month, index|
        @profit_by_month[month] = profit_hash[(index + 1)]
      end

      sold_quantity = current_user.active_steam_account.sold_items.quantity_by_year(params[:year]).group("DATE_TRUNC('month', date)").count.transform_keys { |k| k.strftime('%B') }
      Date::MONTHNAMES.compact.each do |month|
        @quantity_sold_by_month[month] = sold_quantity[month]
      end

      purchased_quantity = Inventory.where('EXTRACT(YEAR FROM created_at) = ? AND steam_id = ?', params[:year], current_user.active_steam_account.steam_id).group("DATE_TRUNC('month', created_at)").count.transform_keys { |k| k.strftime('%B') }
      Date::MONTHNAMES.compact.each do |month|
        @quantity_purchased_by_month[month] = purchased_quantity[month]
      end
    else
      profit = []
      current_user.steam_accounts.each do |steam_account|
        profit << steam_account.sold_items.profits_by_year(params[:year])
      end
      
      profit = profit.reduce({}, :merge)
      profit = profit.transform_keys(&:to_i).transform_values(&:to_f)
      Date::MONTHNAMES.compact.each.with_index do |month, index|
        @profit_by_month[month] = profit[(index + 1)]
      end

      steam_account_ids = current_user.steam_accounts.ids      
      sold_quantity =  SoldItem.quantity_by_year(params[:year]).where(steam_account_id: steam_account_ids).group("DATE_TRUNC('month', date)").count.transform_keys { |k| k.strftime('%B') }
      Date::MONTHNAMES.compact.each do |month|
        @quantity_sold_by_month[month] = sold_quantity[month]
      end
      
      steam_account_steam_ids = current_user.steam_accounts.pluck(:steam_id)
      purchased_quantity = Inventory.where('EXTRACT(YEAR FROM created_at) = ? AND steam_id IN (?)', params[:year], steam_account_steam_ids).group("DATE_TRUNC('month', created_at)").count.transform_keys { |k| k.strftime('%B') }

      Date::MONTHNAMES.compact.each do |month|
        @quantity_purchased_by_month[month] = purchased_quantity[month]
      end
    end
  end
end
