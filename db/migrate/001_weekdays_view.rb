class WeekdaysView < ActiveRecord::Migration
  def self.up
    execute <<-EOS
      CREATE OR REPLACE VIEW weekdays AS
      SELECT weekdays.day::date AS day
      FROM generate_series((SELECT min(issues.start_date) AS min FROM issues),
                           (SELECT max(issues.due_date) AS max FROM issues),
                           '1 day'::interval) AS weekdays(day)
      WHERE date_part('dow'::text, weekdays.day) NOT IN (0, 6);
    EOS
  end

  def self.down
  end
end
