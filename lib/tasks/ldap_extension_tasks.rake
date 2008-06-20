namespace :radiant do
  namespace :extensions do
    namespace :ldap do
      
      desc "Runs the migration of the LDAP extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          LdapExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          LdapExtension.migrator.migrate
        end
      end
    
      desc "Copies LDAP extension assets to the public directory"
      task :update => :environment do
        FileUtils.cp LdapExtension.root + "/public/images/directory.gif", RAILS_ROOT + "/public/images"
        FileUtils.cp LdapExtension.root + "/public/javascripts/email.js", RAILS_ROOT + "/public/javascripts"
      end
      
    end
  end
end