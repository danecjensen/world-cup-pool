class Admin::UsersController < Admin::BaseController
  def index
    @users = User.order(admin: :desc).order(Arel.sql("LOWER(display_name)"))
    @points_by_user = Pick.group(:user_id).sum(:points_awarded)
  end

  def update
    @user = User.find(params[:id])

    if @user == current_user && @user.admin? && User.admins.count == 1
      redirect_to admin_users_path, alert: "Can't remove the last admin."
      return
    end

    @user.update!(admin: ActiveModel::Type::Boolean.new.cast(params.dig(:user, :admin)))
    redirect_to admin_users_path,
                notice: "#{@user.display_name} is #{@user.admin? ? 'now an admin' : 'no longer an admin'}."
  end

  def reset_password
    @user = User.find(params[:id])
    new_password = params.dig(:user, :password).to_s

    if @user.update(password: new_password, password_confirmation: new_password)
      redirect_to admin_users_path,
                  notice: "Password reset for #{@user.display_name}."
    else
      redirect_to admin_users_path,
                  alert: "Couldn't reset password for #{@user.display_name}: #{@user.errors[:password].to_sentence}."
    end
  end
end
