require 'test_helper'

class CargoRulesControllerTest < ActionController::TestCase
  setup do
    @cargo_rule = cargo_rules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cargo_rules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cargo_rule" do
    assert_difference('CargoRule.count') do
      post :create, cargo_rule: @cargo_rule.attributes
    end

    assert_redirected_to cargo_rule_path(assigns(:cargo_rule))
  end

  test "should show cargo_rule" do
    get :show, id: @cargo_rule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cargo_rule
    assert_response :success
  end

  test "should update cargo_rule" do
    put :update, id: @cargo_rule, cargo_rule: @cargo_rule.attributes
    assert_redirected_to cargo_rule_path(assigns(:cargo_rule))
  end

  test "should destroy cargo_rule" do
    assert_difference('CargoRule.count', -1) do
      delete :destroy, id: @cargo_rule
    end

    assert_redirected_to cargo_rules_path
  end
end
