class CreateLdapExtensionSchema < ActiveRecord::Migration
  def self.up
    create_table :ldap_queries do |t|
      t.column :name, :string
      t.column :filter, :string
      t.column :base_dn, :string
      t.column :scope, :integer
      t.column :attrs, :string
    end    
  end
  
  def self.down
    drop_table :ldap_queries
  end
end