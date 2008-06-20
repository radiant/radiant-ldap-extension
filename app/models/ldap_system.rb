require 'ldap'
class LdapSystem
  include Simpleton
  attr_accessor :connection

  def connection
    connect if @connection.err.is_a?(LDAP::Error) or @connection.nil?
    @connection
  end
  
  def search(options = {})
    options.symbolize_keys!.reverse_merge! :base_dn => base_dn,
                           :filter => "(objectClass=*)", 
                           :scope => LDAP::LDAP_SCOPE_SUBTREE, 
                           :attrs => ["dn", "givenName", "sn", "mail"],
                           :sort => "sn"

    if options[:attrs].is_a? String
      options[:attrs] = options[:attrs].split(",").collect(&:strip)
    end
    connection.simple_bind(bind_user, bind_password) unless connection.bound?
    results = connection.search2(options[:base_dn], options[:scope], options[:filter], options[:attrs]) rescue []
    results.collect { |r| dearrayify(r) }
    #.sort {|x,y| 
    #      (x.has_key? options[:sort] and y.has_key? options[:sort]) ? 
    #              x[options[:sort]] <=> y[options[:sort]] :
    #              0 }
  end
   
  def attributes=(hsh)
    hsh.each do |key, value|
      if respond_to? "#{key}="
        send "#{key}=", value
      end
    end
  end
  
  def use_ssl
    @use_ssl ||= Radiant::Config["ldap.use_ssl"] == "true"
  end
  
  def use_ssl=(value)
    @use_ssl = Radiant::Config["ldap.use_ssl"] = value.to_s
  end
  
  def port
    @port ||= Radiant::Config["ldap.port"].to_i
  end
  
  def port=(value)
    @port = Radiant::Config["ldap.port"] = value.to_s
  end
  
  [:server, :base_dn, :bind_user, :bind_password].each do |key|
    class_eval %{
      def #{key}
        @#{key} ||= Radiant::Config["ldap.#{key}"]
      end
      
      def #{key}=(value)
        @#{key} = Radiant::Config["ldap.#{key}"] = value
      end  
    }
  end

  private
    def initialize
      connect
    end
    
    def connect
      @connection = (use_ssl ? LDAP::SSLConn.new(server, port) : LDAP::Conn.new(server, port)) rescue nil
    end
      
    def dearrayify(hsh)
      hsh.inject({}) do |h, (k,v)|
        h.merge k => ((v.is_a?(Array) and v.size == 1) ? v.first : v)
      end
    end
end