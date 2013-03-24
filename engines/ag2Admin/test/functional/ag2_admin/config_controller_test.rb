require 'test_helper'

module Ag2Admin
  class ConfigControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end
  
  end
end
