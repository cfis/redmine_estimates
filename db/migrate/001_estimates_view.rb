class EstimatesView < ActiveRecord::Migration
  def self.up
    execute <<-EOS
      CREATE OR REPLACE VIEW estimates_view AS
      SELECT schedule.day, schedule.issue_id, schedule.issue_id::text AS label, 'none'::text AS group_by, sum(schedule.estimated_hours) AS estimated_hours, sum(schedule.hours) AS hours
      FROM (SELECT day.day::date AS day, issues.id AS issue_id, avg(issues.estimated_hours / (1 + COALESCE(issues.due_date, issues.start_date) - COALESCE(issues.start_date, issues.due_date))::double precision) AS estimated_hours, 0 AS hours
           FROM issues
           CROSS JOIN generate_series('2009-07-01'::date::timestamp with time zone, '2010-12-31'::date::timestamp with time zone, '1 day'::interval) day(day)
           WHERE issues.estimated_hours IS NOT NULL AND day.day >= COALESCE(issues.start_date, issues.due_date) AND day.day <= COALESCE(issues.due_date, issues.start_date)
           GROUP BY day.day, issues.id

           UNION ALL

           SELECT time_entries.spent_on AS day, issues.id AS issue_id, 0 AS estimated_hours, sum(time_entries.hours) AS hours
           FROM issues
           JOIN time_entries ON issues.id = time_entries.issue_id
           GROUP BY time_entries.spent_on, issues.id) schedule
      GROUP BY schedule.day, schedule.issue_id;
    EOS
  end

  def self.down
  end
end
