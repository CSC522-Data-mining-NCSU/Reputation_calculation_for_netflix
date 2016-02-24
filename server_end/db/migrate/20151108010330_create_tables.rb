class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :review_records do |t|
      t.integer :submission_id
      t.integer :reviewer_id
      t.float :score
      t.float :quiz_score
    end

    create_table :reviewers do |t|
      t.float :reputation
      t.float :leniency
      t.float :variance 
      t.float :weight
    end

    create_table :submissions do |t|
      t.float :temp_score
    end
  end

  def self.down
  	drop_table :review_records
  	drop_table :reviewers
  	drop_table :submissions
  end
end
