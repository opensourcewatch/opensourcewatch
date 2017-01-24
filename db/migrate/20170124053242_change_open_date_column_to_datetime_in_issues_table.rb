class ChangeOpenDateColumnToDatetimeInIssuesTable < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      ALTER TABLE issues DROP COLUMN IF EXISTS open_date CASCADE;
    SQL

    execute <<-SQL
      ALTER TABLE issues ADD COLUMN open_date timestamp without time zone;
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE issues DROP COLUMN IF EXISTS open_date CASCADE;
    SQL

    execute <<-SQL
      ALTER TABLE issues ADD COLUMN open_date character varying;
    SQL
  end
end
