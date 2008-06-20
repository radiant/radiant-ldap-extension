require 'ldap'
class LdapQuery < ActiveRecord::Base

  def self.scopes
    (LDAP.constants - Object.constants).
      grep(/LDAP_SCOPE(.*)/).
      inject({}) { |hash, i| hash.merge i => LDAP.const_get(i) }
  end
  
  validates_presence_of :name
  validates_numericality_of :scope, :allow_nil => true
  validates_inclusion_of :scope, :in => LdapQuery.scopes.values, :allow_nil => true
  validates_format_of :base_dn, :with => /^(\w+=\w+)(,\w+=\w+)*$/, 
          :message => "must be a comma-separated LDAP scope, e.g. ou=Example,o=World.",
          :allow_nil => true
  validates_format_of :attrs, :with => /^\s*\w+\s*(,\s*\w+)*/, 
          :message => 'must be a comma-separated list of LDAP attributes, e.g. "dn, givenName, mail".',
          :allow_nil => true

  def scope=(val)
    write_attribute :scope, val.to_i
  end

  def execute
    attrs = attributes.reject { |k,v| 
      v.nil? or (v.respond_to? :empty? and v.empty?) or k.to_s == 'name'
    }.symbolize_keys
    LdapSystem.search(attrs)
  end
end