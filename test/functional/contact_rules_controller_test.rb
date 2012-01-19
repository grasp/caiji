require 'test_helper'

class ContactRulesControllerTest < ActionController::TestCase
  setup do
    @contact_rule = contact_rules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contact_rules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contact_rule" do
    assert_difference('ContactRule.count') do
      post :create, contact_rule: @contact_rule.attributes
    end

    assert_redirected_to contact_rule_path(assigns(:contact_rule))
  end

  test "should show contact_rule" do
    get :show, id: @contact_rule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contact_rule
    assert_response :success
  end

  test "should update contact_rule" do
    put :update, id: @contact_rule, contact_rule: @contact_rule.attributes
    assert_redirected_to contact_rule_path(assigns(:contact_rule))
  end

  test "should destroy contact_rule" do
    assert_difference('ContactRule.count', -1) do
      delete :destroy, id: @contact_rule
    end

    assert_redirected_to contact_rules_path
  end
end
