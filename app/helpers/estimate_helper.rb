module EstimateHelper
  def css_height(estimate)
    hours = if estimate.day >= Date.today
      [estimate.estimated_hours, 1.2].max
    else
      [estimate.hours, 1.2].max
    end

    "#{number_with_precision(hours, :precision => 2)}em"
  end

  def estimate_classes(estimate)
    diff = (estimate.estimated_hours - estimate.hours).abs
    percent = diff/estimate.estimated_hours

    if estimate.start_date >= Date.today
      'accurate'
    elsif estimate.estimated_hours == 0 or estimate.hours == 0 and diff <= 0.3
      'accurate'
    elsif estimate.estimated_hours == 0 or estimate.hours == 0
      'underestimate'
    elsif diff < 1.0
      'accurate'
    elsif estimate.estimated_hours < estimate.hours and percent <= 0.15
      'accurate'
    elsif estimate.estimated_hours > estimate.hours and percent <= 0.20
      'overestimate'
    else
      'underestimate'
    end
  end

  def format_hours(hours)
    if hours > 0
      number_with_precision(hours, :precision => 1,
                                   :separator => '.',
                                   :delimiter => ',')
    else
      '-'
    end
  end

  def format_hours_css(hours, other)
    if hours > 0 and hours > other
      'max_value'
    end
  end

  
  def issues_link(estimate)
    label = estimate.label.match(/^(\S*)/)[1]
    
    url_options = {'controller' => 'issues',
                   'action' => 'index',
                   'set_filter' => 1,
                   'operators[status_id]' => '*',
                   'values[status_id][]' => '1'}

    fields = ['fields[]=status_id']

    if estimate.start_date and estimate.due_date
      url_options.merge!('values[start_date][]' => Date.today - estimate.start_date,
                         'values[due_date][]' => Date.today - estimate.day)

      fields << 'fields[]=start_date'

      if estimate.min_start_date < estimate.day
        url_options.merge!('operators[start_date]' => '>t-',
                           'values[start_date][]' => Date.today - estimate.min_start_date - 1)
      else
        url_options.merge!('operators[start_date]' => 't-',
                           'values[start_date][]' => Date.today - estimate.min_start_date)
      end

      if estimate.max_due_date < Date.today
        fields << 'fields[]=due_date'
        if estimate.max_due_date > estimate.day
          url_options.merge!('operators[due_date]' => '<t-',
                             'values[due_date][]' => Date.today - estimate.max_due_date + 1)
        else
          url_options.merge!('operators[due_date]' => 't-',
                             'values[due_date][]' => Date.today - estimate.max_due_date)
        end
      end
    end

    case estimate.group_by
      when 'project'
        url_options[:project_id] = estimate.id
      when 'user'
        url_options[:user_id] = estimate.id
      when 'version'
        url_options[:version_id] = estimate.id
    end

    url = url_for(url_options)
    
    # Need to manually add in fields (can't put the same key into
    # a hash twice).
    url += '&' + fields.join('&')

    link_to(label, url, :title => (h estimate.label))
  end
end
