class EstimatesView < ActiveRecord::Migration
  def self.up
    execute <<-EOS
      CREATE OR REPLACE VIEW estimates_view AS
      SELECT schedule.day, schedule.issue_id, schedule.user_id,
             min(schedule.start_date) AS start_date,
             max(schedule.due_date) AS due_date,
             sum(schedule.estimated_hours) AS estimated_hours,
             sum(schedule.hours) AS hours
      FROM (SELECT weekdays.day, daily_estimates_view.issue_id,
                   daily_estimates_view.user_id,
                   daily_estimates_view.start_date, daily_estimates_view.due_date,
                   daily_estimates_view.estimated_hours, 0 AS hours
            FROM daily_estimates_view
            JOIN weekdays ON weekdays.day BETWEEN daily_estimates_view.start_date AND daily_estimates_view.due_date

            UNION ALL

            SELECT time_entries.spent_on AS day, issues.id AS issue_id,
                   time_entries.user_id,
                   null::date AS start_date, null::date AS due_date,
                   0 AS estimated_hours, sum(time_entries.hours) AS hours
            FROM issues
            JOIN time_entries ON issues.id = time_entries.issue_id
            GROUP BY time_entries.spent_on, issues.id, time_entries.user_id) AS schedule
      GROUP BY schedule.day, schedule.issue_id, schedule.user_id;
    EOS
  end

  def self.down
  end
end
