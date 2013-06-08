require 'test_helper'

module Ag2Human
  class Ag2TimerecordTrackControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end
  
  end
end
