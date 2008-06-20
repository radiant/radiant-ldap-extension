module LdapTags
  include Radiant::Taggable

  TLDS = %w{com org net edu info mil gov biz ws}

  desc %{  <r:crypt_email>someaddress@us.com</r:crypt_email>
  <r:crypt_email><r:label>Somebody</r:label><r:address>someaddress@us.com</r:address></r:crypt_email>

  Encrypts the email address so it cannot be picked up easily by spambots.  Requires email.js to be
  included in the page.}
  tag "crypt_email" do |tag|
    hash = tag.locals.params = {}
    contents = tag.expand
    address = hash['address'].blank? ? contents : hash['address']
    label = hash['label']
    if address =~ /([\w.%-]+)@([\w.-]+)\.([A-z]{2,4})/
      user, domain, tld = $1, $2, $3
      tld_num = TLDS.index(tld)
      unless label.blank?
        %{<script type="text/javascript">
              // <![CDATA[
              mail2('#{user}', '#{domain}', #{tld_num}, '', "#{label}");
              // ]]>
              </script>
        }
      else
        %{<script type="text/javascript">
              // <![CDATA[
              mail('#{user}', '#{domain}', #{tld_num}, '');
              // ]]>
              </script>
        }
      end
    else
      label.blank? ? "": label
    end
  end
  
  tag "crypt_email:label" do |tag|
    tag.locals.params['label'] = tag.expand.strip
  end
  
  tag "crypt_email:address" do |tag|
    tag.locals.params['address'] = tag.expand.strip
  end
  
  desc %{  The namespace for all LDAP directory queries.}
  tag "directory" do |tag|
    tag.expand
  end
  
  desc %{    <r:directory:query name="Some Saved Query">...</r:directory:query>
    <r:directory:query filter="(objectClass=*)" [base="o=radiant"] [attrs="givenName, sn"]>...</r:directory:query>
    
    Queries the LDAP directory on the given canned query or on parameters specified in the tag and
    renders the contained block if results are returned.}
  tag "directory:query" do |tag|
    name = tag.attr['name']
    base, filter, attrs = tag.attr['base'], tag.attr['filter'], tag.attr['attrs']
    if name and query = LdapQuery.find_by_name(name)
      tag.locals.results = query.execute
      tag.expand unless tag.locals.results.empty?
    elsif filter
      query = LdapQuery.new :base_dn => base, :filter => filter, :attrs => attrs
      tag.locals.results = query.execute
      tag.expand unless tag.locals.results.empty?
    else
      raise TagError, "Must specify at least a filter on directory queries."
    end
  end
  
  desc %{  Renders the contained block on each result returned from the LDAP query.}
  tag "directory:query:each" do |tag|
    output = ""
    tag.locals.results.each do |result|
      tag.locals.result = result
      output << tag.expand
    end
    output
  end
  
  desc %{  <r:fetch attr="sn" />

  Fetches an attribute from a query result.  If not used inside the 'each' tag,
  it will fetch the attribute from the first result.}
  tag "directory:query:fetch" do |tag|
    result = tag.locals.result || tag.locals.results.first
    key = tag.attr["attr"]
    raise TagError, "Must specify an LDAP attribute to get." unless key
    case result[key]
      when Array
        result[key].join(", ")
      when String
        result[key]
      else
        ""
    end
  end
  
  desc %{  <r:if_attr attr="sn">...</r:if_attr>

  Renders the contained block if the specified attribute exists for the current query result.}
  tag "directory:query:if_attr" do |tag|
    result = tag.locals.result || tag.locals.results.first
    key = tag.attr["attr"]
    raise TagError, "Must specify an LDAP attribute to get." unless key
    tag.expand if result[key]
  end

  desc %{  <r:unless_attr attr="sn">...</r:unless_attr>

  Renders the contained block unless the specified attribute exists for the current query result.}
  tag "directory:query:unless_attr" do |tag|
    result = tag.locals.result || tag.locals.results.first
    key = tag.attr["attr"]
    raise TagError, "Must specify an LDAP attribute to get." unless key
    tag.expand unless result[key]
  end
  
end