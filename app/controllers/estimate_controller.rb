class EstimateController < ApplicationController
  unloadable

  before_filter :find_optional_project
  helper :issues
  helper :projects
  helper :queries

  def show
    create_calendar
    @group_by = params[:group_by] || 'project'
    @calendar.events = Estimate.estimates(@calendar.startdt, @calendar.enddt, @group_by)
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.csv  { send_data(report_to_csv(@criterias, @periods, @hours), :type => 'text/csv; header=present', :filename => 'timelog.csv') }
    end
  end

  private

  def create_calendar
    if params[:year] and params[:year].to_i > 1900
      @year = params[:year].to_i
      if params[:month] and params[:month].to_i > 0 and params[:month].to_i < 13
        @month = params[:month].to_i
      end
    end
    @year ||= Date.today.year
    @month ||= Date.today.month

    @calendar = Redmine::Helpers::Calendar.new(Date.civil(@year, @month, 1), current_language, :month)
  end
end