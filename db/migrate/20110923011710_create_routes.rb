class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string  :title
      t.string  :slug
      t.string  :breadcrumb
      t.string  :class_name
      t.string  :path
      t.integer :parent_id
      t.integer :lock_version, :default => 0
      t.timestamps
    end
  end
end
