#coding:utf-8
class CargoRulesController < ApplicationController
  # GET /cargo_rules
  # GET /cargo_rules.json
  include CargoRulesHelper
  include CaijiHelper
  layout 'caiji'
  def index
    @title="采集零距离"
    @cargo_rules = CargoRule.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cargo_rules }
    end
  end

  # GET /cargo_rules/1
  # GET /cargo_rules/1.json
  def show
    @cargo_rule = CargoRule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cargo_rule }
    end
  end

  # GET /cargo_rules/new
  # GET /cargo_rules/new.json
  def new
    @cargo_rule = CargoRule.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cargo_rule }
    end
  end

  # GET /cargo_rules/1/edit
  def edit
    @cargo_rule = CargoRule.find(params[:id])
  end

  # POST /cargo_rules
  # POST /cargo_rules.json
  def create
    params[:cargo_rule].each do |key,value|   
      params[:cargo_rule].delete(key) if value.blank?
      #   puts "delete #{key}"
    end

    @cargo_rule = CargoRule.new(params[:cargo_rule])

    respond_to do |format|
      if @cargo_rule.save
        format.html { redirect_to @cargo_rule, notice: 'Cargo rule was successfully created.' }
        format.json { render json: @cargo_rule, status: :created, location: @cargo_rule }
      else
        format.html { render action: "new" }
        format.json { render json: @cargo_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cargo_rules/1
  # PUT /cargo_rules/1.json
  def update
    @cargo_rule = CargoRule.find(params[:id])

    respond_to do |format|
      params[:cargo_rule].each do |key,value|   
        params[:cargo_rule].delete(key) if value.blank?
        #  puts "delete #{key}"
      end
      if @cargo_rule.update_attributes(params[:cargo_rule])
        format.html { redirect_to @cargo_rule, notice: 'Cargo rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cargo_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cargo_rules/1
  # DELETE /cargo_rules/1.json
  def destroy
    @cargo_rule = CargoRule.find(params[:id])
    @cargo_rule.destroy

    respond_to do |format|
      format.html { redirect_to cargo_rules_url }
      format.json { head :no_content }
    end
  end
  
  def run_cargo_rule
    @cargo_rule=CargoRule.find(params[:id])
    @title="#{@cargo_rule.rulename}运行结果"
    run_cargorule(@cargo_rule.rulename)
    respond_to do |format|
      format.html 
      format.json { head :no_content }
    end
  end
  
  def get_all_cargo
    @title="#{params[:from_site]}全部采集结果"
    @cargos=Cargo.where(:from_site=>params[:from_site]).desc(:created_at).paginate(:page=>params[:page]||1,:per_page=>100) 
    @count=Cargo.where(:from_site=>params[:from_site]).count
  end
  
  def post_cargo
    post_cargo_helper(params[:from_site])
  end
end
