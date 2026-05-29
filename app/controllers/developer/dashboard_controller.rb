class Developer::DashboardController < Developer::BaseController
  def index
    @model_stats = developer_models.map { |k| [k, k.count] }
  end
end
