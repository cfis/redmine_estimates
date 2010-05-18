class DailyEstimatesView < ActiveRecord::Migration
  def self.up
    execute <<-EOS
      CREATE OR REPLACE VIEW daily_estimates_view AS
      SELECT issues.id AS issue_id, COALESCE(issues.start_date, issues.due_date) AS start_date, 
                                    COALESCE(issues.due_date, issues.start_date) AS due_date,
             count(weekdays.day) AS weekdays,
             max(issues.estimated_hours) / count(weekdays.day) AS estimated_hours
      FROM issues
      JOIN weekdays ON weekdays.day BETWEEN COALESCE(issues.start_date, issues.due_date) AND COALESCE(issues.due_date, issues.start_date)
      WHERE issues.estimated_hours IS NOT NULL
      GROUP BY issues.id, issues.start_date, issues.due_date;
    EOS
  end

  def self.down
  end
end
