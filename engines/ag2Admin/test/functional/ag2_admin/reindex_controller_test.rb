require 'test_helper'

module Ag2Admin
  class ReindexControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end
  
  end
end
