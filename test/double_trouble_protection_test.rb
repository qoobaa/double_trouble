require "test_helper"

# STORE
class TestStore
  attr_accessor :store

  def initialize
    self.store = {}
  end

  def valid?(nonce)
    nonce.present? && !store.key?(nonce.to_s)
  end

  def store!(nonce)
    valid?(nonce) ? store[nonce.to_s] = true : raise(DoubleTrouble::InvalidNonce)
  end
end

module DoubleTroubleApp
  class Application < Rails::Application
  end
end

DoubleTroubleApp::Application.routes.draw do
  match "/:controller(/:action(/:id))"
end

# MODEL
class MyModel
  def initialize(new_record); @new_record = new_record end
  def new_record?; @new_record end
end

# CONTROLLER
class MyController < ActionController::Base
  protect_from_double_trouble :my_model, :only => :create

  def self._routes
    DoubleTroubleApp::Application.routes
  end

  def new
    render :inline => "<%= form_tag('/') {} %>"
  end

  def create
    @my_model = MyModel.new(params[:new_record])
    render :inline => "OK"
  end

  def edit
    render :inline => "<%= form_tag('/') {} %>"
  end

  def update
    @my_model = MyModel.new(params[:new_record])
    render :inline => "OK"
  end

  def rescue_action(exception)
    raise(exception)
  end
end

class DoubleTroubleProtectionTest < ActionController::TestCase

  self.controller_class = MyController

  def setup
    @nonce      = "not_really_unique_token"
    @store      = TestStore.new

    @routes = DoubleTroubleApp::Application.routes

    ActiveSupport::SecureRandom.stubs(:base64).returns(@nonce)
    ActionController::Base.double_trouble_nonce_param = :my_nonce
    ActionController::Base.double_trouble_nonce_store = @store
  end

  def test_render_form_with_form_nonce_in_new_action
    get :new
    assert_select "form>div>input[name=?][value=?]", "my_nonce", @nonce
  end

  def test_render_form_with_form_nonce_in_edit_action
    get :edit
    assert_select "form>div>input[name=?][value=?]", "my_nonce", @nonce
  end

  def test_not_allow_to_send_the_create_form_with_the_same_nonce_twice_if_model_was_successfully_saved
    post :create, :new_record => false, :my_nonce => @nonce
    assert_response :ok
    assert_false @store.valid?(@nonce)
    assert_raise(DoubleTrouble::InvalidNonce) { post :create, :my_nonce => @nonce }
  end

  def test_allow_to_send_the_create_form_with_different_nonce_twice_even_if_model_was_successfully_saved
    post :create, :new_record => false, :my_nonce => @nonce
    assert_response :ok
    assert_false @store.valid?(@nonce)
    post :create, :new_record => false, :my_nonce => @nonce + "2"
    assert_response :ok
    assert_false @store.valid?(@nonce + "2")
  end

  def test_allow_to_send_the_create_form_with_the_same_nonce_twice_if_model_was_not_saved
    post :create, :new_record => true, :my_nonce => @nonce
    assert_response :ok
    assert_true @store.valid?(@nonce)
    post :create, :new_record => false, :my_nonce => @nonce
    assert_response :ok
  end

  def test_allow_to_send_the_update_form_with_the_same_nonce_twice
    post :update, :new_record => false, :my_nonce => @nonce
    assert_response :ok
    assert @store.valid?(@nonce)
    post :update, :new_record => false, :my_nonce => @nonce
    assert_response :ok
    assert @store.valid?(@nonce)
  end
end
