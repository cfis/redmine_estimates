class Estimate < ActiveRecord::Base
  unloadable
  set_table_name :estimates_view
  belongs_to :issue
  
  def self.groups
    { 'none' => {:id => 'estimates_view.issue_id',
                 :label => '\'Total\'',
                 :joins => nil,
                 :group => nil},

      'project' => {:id => 'projects.id',
                    :label => 'projects.name',
                    :joins => 'JOIN issues ON estimates_view.issue_id = issues.id
                               JOIN projects on issues.project_id = projects.id',
                    :group => 'projects.name'},

      'user' => {:id => "users.id",
                 :label => "users.firstname",
                 :joins => 'JOIN users on estimates_view.user_id = users.id',
                 :group => 'users.firstname'},

      'version' => {:id => "versions.id",
                    :label => "versions.name",
                    :joins => 'JOIN issues ON estimates_view.issue_id = issues.id
                               JOIN issues_versions on issues.id = issues_versions.issue_id
                               JOIN versions on issues_versions.version_id = versions.id',
                    :group => 'versions.name'}
    }
  end

  def self.estimates(to, from, group_by)
    group = self.groups[group_by]
    sql = <<-EOS
      SELECT estimates_view.day,
             #{group[:label]} AS label,
             max(#{group[:id]}) AS id,
             '#{group_by}' AS group_by,
             min(estimates_view.start_date) AS start_date,
             max(estimates_view.due_date) AS due_date,
             sum(estimates_view.estimated_hours) AS estimated_hours,
             sum(estimates_view.hours) AS hours
      FROM estimates_view
      #{group[:joins]}
      WHERE estimates_view.day BETWEEN '#{to}' AND '#{from}'
      GROUP BY estimates_view.day
    EOS

    if group[:group]
      sql << ", #{group[:group]}"
    end
    self.find_by_sql(sql)
  end

  # For calendar compatability
  def start_date
    self.day
  end

  def due_date
    self.day
  end

  def min_start_date
    self['start_date'] || self.day
  end

  def max_due_date
    self['due_date'] || self.day
  end
end