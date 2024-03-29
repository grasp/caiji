class ContactRulesController < ApplicationController
  # GET /contact_rules
  # GET /contact_rules.json
  include ContactRulesHelper
  include CaijiHelper
  include EmailHelper
  layout 'caiji'
  
  def emails
    clear_nil_address_email
    @emails=Email.all.paginate(:page=>params[:page]||1,:per_page=>50)
  end
  
  def index
    @contact_rules = ContactRule.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @contact_rules }
    end
  end

  # GET /contact_rules/1
  # GET /contact_rules/1.json
  def show
    @contact_rule = ContactRule.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @contact_rule }
    end
  end
  
  def count_contact
     @contact_rules = ContactRule.all
  end

  # GET /contact_rules/new
  # GET /contact_rules/new.json
  def new
    @contact_rule = ContactRule.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contact_rule }
    end
  end

  # GET /contact_rules/1/edit
  def edit
    @contact_rule = ContactRule.find(params[:id])
  end

  # POST /contact_rules
  # POST /contact_rules.json
  def create
    @contact_rule = ContactRule.new(params[:contact_rule])

    respond_to do |format|
      if @contact_rule.save
        format.html { redirect_to @contact_rule, notice: 'Contact rule was successfully created.' }
        format.json { render json: @contact_rule, status: :created, location: @contact_rule }
      else
        format.html { render action: "new" }
        format.json { render json: @contact_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /contact_rules/1
  # PUT /contact_rules/1.json
  def update
    @contact_rule = ContactRule.find(params[:id])

    respond_to do |format|
      if @contact_rule.update_attributes(params[:contact_rule])
        format.html { redirect_to @contact_rule, notice: 'Contact rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @contact_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contact_rules/1
  # DELETE /contact_rules/1.json
  def destroy
    @contact_rule = ContactRule.find(params[:id])
    @contact_rule.destroy

    respond_to do |format|
      format.html { redirect_to contact_rules_url }
      format.json { head :no_content }
    end
  end
  
  def run_contact_rule
    @contact_rule=ContactRule.find(params[:id])
    run_contactrule( @contact_rule.rulename)
  end
  
  def get_all_contact
     @total_contact=Contact.count
    @total_site_contact=Contact.where(:from_site=>params[:from_site]).count
    @contacts=Contact.where(:from_site=>params[:from_site]).desc(:created_at).paginate(:page=>params[:page]||1,:per_page=>100) 
    logger.info Contact.where(:from_site=>nil).count
    puts "from site=nil="+Contact.where(:from_site=>nil).count.to_s
    Contact.where(:from_site=>nil).each do |contact|
      contact.delete
    end
    
    Contact.where(:from_site=>"tuge",:email=>nil,:mphone=>nil,:qq=>nil).each do |contact|
      contact.delete
    end
  end
  
end
