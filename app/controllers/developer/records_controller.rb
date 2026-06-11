require "csv"

class Developer::RecordsController < Developer::BaseController
  PER_PAGE = 100

  before_action :load_model
  before_action :load_record, only: [:show, :edit, :update, :destroy]

  def index
    @columns = @model.column_names
    @sort_column, @sort_direction = resolve_sort
    scope = @model.order(@sort_column => @sort_direction)

    respond_to do |format|
      format.html { @records = scope.limit(PER_PAGE) }
      format.csv do
        send_data build_csv(scope),
                  filename: "#{@model.table_name}-#{Time.current.strftime('%Y%m%d-%H%M%S')}.csv",
                  type: "text/csv"
      end
    end
  end

  def show
  end

  def new
    @record = @model.new
  end

  def create
    @record = @model.new(record_params)
    if @record.save
      redirect_to developer_record_path(model: @model.model_name.route_key, id: @record.id),
                  notice: "#{@model.name} ##{@record.id} created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(record_params)
      redirect_to developer_record_path(model: @model.model_name.route_key, id: @record.id),
                  notice: "#{@model.name} ##{@record.id} updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    redirect_to developer_records_path(model: @model.model_name.route_key),
                notice: "#{@model.name} ##{@record.id} deleted."
  end

  private

  def load_model
    @model = find_model(params[:model])
    return if @model
    redirect_to developer_root_path, alert: "Unknown model: #{params[:model].inspect}"
  end

  def load_record
    @record = @model.find(params[:id])
  end

  def build_csv(scope)
    if @model.respond_to?(:csv_export_columns)
      columns = @model.csv_export_columns
      CSV.generate do |csv|
        csv << columns
        @model.csv_export_scope(scope).find_each do |record|
          row = record.csv_export_row
          csv << columns.map { |col| row[col] }
        end
      end
    else
      CSV.generate do |csv|
        csv << @columns
        scope.find_each do |record|
          csv << @columns.map { |col| record[col] }
        end
      end
    end
  end

  def resolve_sort
    column = @columns.include?(params[:sort]) ? params[:sort] : "id"
    direction = params[:dir] == "asc" ? :asc : :desc
    [column, direction]
  end

  def record_params
    key = @model.model_name.param_key
    return ActionController::Parameters.new.permit! unless params[key].present?
    permitted = @model.column_names - SKIP_IN_FORMS
    params.require(key).permit(*permitted)
  end
end
