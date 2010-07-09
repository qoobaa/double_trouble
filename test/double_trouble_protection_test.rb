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


# ROUTES
ActionController::Routing::Routes.draw { |map| map.connect ":controller/:action/:id" }

# MODEL
class MyModel
  def initialize(new_record); @new_record = new_record end
  def new_record?; @new_record end
end

# CONTROLLER
class MyController < ActionController::Base
  protect_from_double_trouble :my_model, :only => :create

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
  def setup
    @controller = MyController.new
    @nonce      = "not_really_unique_token"
    @store      = TestStore.new
    ActiveSupport::SecureRandom.stubs(:base64).returns(@nonce)
    ActionController::Base.double_trouble_nonce_param = :my_nonce
    ActionController::Base.double_trouble_nonce_store = @store
  end

  test "render form with form nonce in 'new' action" do
    get :new
    assert_select "form>div>input[name=?][value=?]", "my_nonce", @nonce
  end

  test "render form with form nonce in 'edit' action" do
    get :edit
    assert_select "form>div>input[name=?][value=?]", "my_nonce", @nonce
  end

  test "not allow to send the create form with the same nonce twice, if model was successfully saved" do
    post :create, :new_record => false, :my_nonce => @nonce
    assert_response :ok
    assert_false @store.valid?(@nonce)
    assert_raise(DoubleTrouble::InvalidNonce) { post :create, :my_nonce => @nonce }
  end

  test "allow to send the create form with different nonce twice, even if model was successfully saved" do
    post :create, :new_record => false, :my_nonce => @nonce
    assert_response :ok
    assert_false @store.valid?(@nonce)
    post :create, :new_record => false, :my_nonce => @nonce + "2"
    assert_response :ok
    assert_false @store.valid?(@nonce + "2")
  end

  test "allow to send the create form with the same nonce twice, if model was not saved" do
    post :create, :new_record => true, :my_nonce => @nonce
    assert_response :ok
    assert_true @store.valid?(@nonce)
    post :create, :new_record => false, :my_nonce => @nonce
    assert_response :ok
  end

  test "allow to send the update form with the same nonce twice" do
    post :update, :new_record => false, :my_nonce => @nonce
    assert_response :ok
    assert @store.valid?(@nonce)
    post :update, :new_record => false, :my_nonce => @nonce
    assert_response :ok
    assert @store.valid?(@nonce)
  end
end
