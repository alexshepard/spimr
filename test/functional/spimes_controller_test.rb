require 'test_helper'

class SpimesControllerTest < ActionController::TestCase
  setup do
    @spime = spimes(:one)
    @update = {
      :name                 => "name",
      :description          => "description",
      :image                => "my_image.jpg",
      :public               => true,
      :materials            => "my materials",
      :date_manufactured    => "2013-05-31"
    }
  end
    
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:spimes)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create spime" do
    assert_difference('Spime.count') do
      post :create, :spime => @update
    end
    
    assert_redirected_to spime_path(assigns(:spime))
  end

  test "should show spime" do
    get :show, :id => @spime
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @spime
    assert_response :success
  end

  test "should update spime" do
    put :update, :id => @spime.to_param, :spime => @update
    assert_redirected_to spime_path(assigns(:spime))
  end

  test "should destroy spime" do
    assert_difference('Spime.count', -1) do
      delete :destroy, :id => @spime
    end

    assert_redirected_to spimes_path
  end

end
