require 'test_helper'

class TruckRulesControllerTest < ActionController::TestCase
  setup do
    @truck_rule = truck_rules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:truck_rules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create truck_rule" do
    assert_difference('TruckRule.count') do
      post :create, truck_rule: @truck_rule.attributes
    end

    assert_redirected_to truck_rule_path(assigns(:truck_rule))
  end

  test "should show truck_rule" do
    get :show, id: @truck_rule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @truck_rule
    assert_response :success
  end

  test "should update truck_rule" do
    put :update, id: @truck_rule, truck_rule: @truck_rule.attributes
    assert_redirected_to truck_rule_path(assigns(:truck_rule))
  end

  test "should destroy truck_rule" do
    assert_difference('TruckRule.count', -1) do
      delete :destroy, id: @truck_rule
    end

    assert_redirected_to truck_rules_path
  end
end
