class LdapExtension < Radiant::Extension
  version "0.1"
  description "Accesses LDAP directory and allows saved queries."
  url "http://dev.radiantcms.org/svn/radiant/branches/mental/extensions/ldap"

  define_routes do |map|
    map.connect 'admin/ldap/:action/:id', :controller => 'ldap'
  end
  
  def activate
    admin.tabs.add "LDAP", "/admin/ldap", :after => "Layouts", :visibility => [:all]
    Page.send :include, LdapTags
  end
  
  def deactivate
    admin.tabs.remove "LDAP"
  end
    
end