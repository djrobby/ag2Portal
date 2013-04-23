require 'test_helper'

module Ag2Human
  class Ag2TimerecordControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end
  
  end
end
