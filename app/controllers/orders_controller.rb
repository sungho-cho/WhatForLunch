require 'date'
class OrdersController < ApplicationController
  def index
    @orders = current_user.orders
  end

  def create
    @order = Order.new(order_params)
    @order.date = DateTime.now
  end

private
  def order_params
    params.require(:order).permit(:user_id, :user_latitude, :user_longitude,
                                  :restaurant_id)
  end

end
