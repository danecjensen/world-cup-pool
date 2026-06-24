class Admin::PaymentsController < Admin::BaseController
  def index
    @users = User.order(Arel.sql("LOWER(display_name)"))
  end

  def update
    @user = User.find(params[:id])
    @user.update!(paid: ActiveModel::Type::Boolean.new.cast(params.dig(:user, :paid)))
    redirect_to admin_payments_path,
                notice: "#{@user.display_name} is now marked as #{@user.paid? ? 'paid' : 'unpaid'}."
  end
end
