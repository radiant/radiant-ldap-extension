class LdapController < ApplicationController
  
  def index
    @ldap_queries = LdapQuery.find(:all, :order => "name asc")
    @ldap_query = LdapQuery.new
  end
  
  def new
    @ldap_query = LdapQuery.new
  end
  
  def create
    @ldap_query = LdapQuery.new(params[:ldap_query])
    if @ldap_query.save
      flash[:notice] = "Query successfully saved."
      redirect_to :action => "index"
    else
      flash[:error] = "There was an error saving your query."
      render :action => "new"
    end
  end
  
  def edit
    @ldap_query = LdapQuery.find(params[:id])
  end
  
  def update
    @ldap_query = LdapQuery.find(params[:id])
    if @ldap_query.update_attributes(params[:ldap_query])
      flash[:notice] = "Query successfully updated."
      redirect_to :action => "index"
    else
      flash[:error] = "There was an error saving your query."
      render :action => "edit"
    end
  end
  
  def destroy
    LdapQuery.find(params[:id]).destroy
    flash[:notice] = "Query deleted."
    redirect_to :action => "index"
  end

  # For editing LDAP configuration  
  def settings
    @config = LdapSystem.instance
    if request.post?
      @config = LdapSystem.instance
      @config.attributes = params[:config]
      flash[:notice] = "LDAP configuration saved."
    end
  end
  
  def test_query
    @ldap_query = LdapQuery.new(params[:ldap_query])
    @results = @ldap_query.execute
    render :update do |page|
      page.replace_html :results, :partial => "results"
      page.visual_effect :appear, 'results'
    end
  end
end