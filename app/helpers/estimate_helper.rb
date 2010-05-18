module EstimateHelper
  def css_height(estimate)
    hours = [estimate.estimated_hours, 1.2].max
    "#{number_with_precision(hours, :precision => 2)}em"
  end

  def estimate_classes(estimate)
    if estimate.estimated_hours >= estimate.hours
      'on_time'
    else
      'over_time'
    end
  end

  def format_hours(hours)
    number_with_precision(hours, :precision => 1,
                                 :separator => '.',
                                 :delimiter => ',')
  end
  
  def issues_link(estimate)
    label = estimate.label.match(/^(\S*)/)[1]
    
    url_options = {:controller => 'issues',
                   :action => 'list'}

    case estimate.group_by
      when 'project'
        url_options[:project_id] = estimate.id
      when 'user'
        url_options[:user_id] = estimate.id
      when 'version'
        url_options[:version_id] = estimate.id
    end

    link_to(label, url_options, :title => (h estimate.label))
  end
end
