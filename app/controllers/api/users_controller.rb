class Api::UsersController < ApplicationController
  # the frontend sends in data without nesting it under a "user" key
  # to make our backend take in this data without breaking the user params
  # this line wraps all the incoming data under the name of the controller
  # User.attribute_names returns a list of all the columns in the db
  # but since "password" isnt a field in our db, we have to add it on
  wrap_parameters include: User.attribute_names + ['password']

  def create
    @user = User.new(user_params)
    if @user.save!
      login!(@user)
      render :show
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
  end

  private
  def user_params
    params.require(:user).permit(:email, :username, :password)
  end
end
