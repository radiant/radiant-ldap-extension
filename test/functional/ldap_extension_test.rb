require File.dirname(__FILE__) + '/../test_helper'

class LdapExtensionTest < Test::Unit::TestCase
  
  def test_initialization
    assert_equal RADIANT_ROOT + '/vendor/extensions/ldap', LdapExtension.root
    assert_equal 'Ldap', LdapExtension.extension_name
    assert Page.included_modules.include?(LdapTags)
  end
  
end
