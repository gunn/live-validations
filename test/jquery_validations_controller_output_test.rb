require File.join(File.dirname(__FILE__), "test_helper")

class JqueryValidationsControllerOutputTest < ActionController::TestCase
  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    LiveValidations.use(LiveValidations::Adapters::JqueryValidations)
    
    reset_callbacks Post
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_json_output
    Post.validates_presence_of :title
    
    get :new
    assert_response :success
            
    assert_select 'script[type=text/javascript]'
    assert @response.body.include?("$('#new_post').validate")
    expected_json = {
      "rules" => {
        "post[title]" => {"required" => true}
      },
      "messages" => {
        "post[title]" => {"required" => "can't be blank"}
      }
    }
    assert @response.body.include?(expected_json.to_json)
  end
  
  
  def test_validator_options
    Post.validates_presence_of :title
    LiveValidations.use LiveValidations::Adapters::JqueryValidations, :validator_settings => {"errorElement" => "span"}
    
    get :new
    assert_response :success
    
    assert @response.body.include?(%{"errorElement": "span"})
  end
  
  def test_validation_on_attributes_without_form_field
    Post.validates_presence_of :unexisting_attribute
    
    get :new
    assert_response :success
    
    assert @response.body.include?(%{"messages": {}})
    assert @response.body.include?(%{"rules": {}})
    assert !@response.body.include?("post[unexisting_attribute]")
  end
end