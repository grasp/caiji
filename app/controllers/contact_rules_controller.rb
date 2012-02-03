class ContactRulesController < ApplicationController
  # GET /contact_rules
  # GET /contact_rules.json
  include ContactRulesHelper
  include CaijiHelper
  layout 'caiji'
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
    @contacts=Contact.where(:from_site=>params[:from_site])
  end
  
end
