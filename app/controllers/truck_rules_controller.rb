class TruckRulesController < ApplicationController
  # GET /truck_rules
  # GET /truck_rules.json
  include TruckRulesHelper
  include CaijiHelper

  layout "caiji"
  def index
    @truck_rules = TruckRule.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @truck_rules }
    end
  end

  # GET /truck_rules/1
  # GET /truck_rules/1.json
  def show
    @truck_rule = TruckRule.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @truck_rule }
    end
  end

  # GET /truck_rules/new
  # GET /truck_rules/new.json
  def new
    @truck_rule = TruckRule.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @truck_rule }
    end
  end

  # GET /truck_rules/1/edit
  def edit
    @truck_rule = TruckRule.find(params[:id])
  end

  # POST /truck_rules
  # POST /truck_rules.json
  def create
    @truck_rule = TruckRule.new(params[:truck_rule])

    respond_to do |format|
      if @truck_rule.save
        format.html { redirect_to @truck_rule, notice: 'Truck rule was successfully created.' }
        format.json { render json: @truck_rule, status: :created, location: @truck_rule }
      else
        format.html { render action: "new" }
        format.json { render json: @truck_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /truck_rules/1
  # PUT /truck_rules/1.json
  def update
    @truck_rule = TruckRule.find(params[:id])

    respond_to do |format|
      if @truck_rule.update_attributes(params[:truck_rule])
        format.html { redirect_to @truck_rule, notice: 'Truck rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @truck_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /truck_rules/1
  # DELETE /truck_rules/1.json
  def destroy
    @truck_rule = TruckRule.find(params[:id])
    @truck_rule.destroy

    respond_to do |format|
      format.html { redirect_to truck_rules_url }
      format.json { head :no_content }
    end
  end
  
  def run_truck_rule
   @truck_rule=TruckRule.find(params[:id])
    run_truckrule( @truck_rule.sitename,@truck_rule.rulename)
  end
  
  def get_all_truck    
    @trucks=Truck.where(:from_site=>params[:from_site]).desc(:created_at).paginate(:page=>params[:page]||1,:per_page=>100)     
  end
  
  def post_truck
    post_truck_helper(params[:from_site])
  end
end
