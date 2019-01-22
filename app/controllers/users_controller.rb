class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]
  before_action :check_login
  authorize_resource

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params1)
    if @user.save
      flash[:notice] = "Successfully added #{@user.proper_name} as a user."
      redirect_to users_url
    else
      render action: 'new'
    end
  end

  def update
    if @user.update_attributes(user_params2)
      flash[:notice] = "Successfully updated #{@user.proper_name}."
      redirect_to users_url
    else
      render action: 'edit'
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params1
      params.require(:user).permit(:first_name, :last_name, :username, :phone,
                                   :password, :password_confirmation)
    end

    def user_params2
      params.require(:user).permit(:phone, :password, :password_confirmation)
    end

end
