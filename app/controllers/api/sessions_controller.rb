class Api::SessionsController < ApplicationController
  def show
    if @current_user
      render json: @current_user
    else
      render json: {user: nil}
    end
  end

  def create
    @user = User.find_by_credentials(credential, password)
    if @user
      login(@user)
      render json: @user
    else
      render json: { errors: ['The provided credentials were invalid.'] }, status: :unauthorized
    end
  end

  def destroy
    if @current_user
      logout
      render json: { message: 'success' }
    end
  end
end
