require 'test_helper'

class RailsCellsTest < ActiveSupport::TestCase
  include Cell::TestCase::TestMethods
  
  def swap(object, new_values)
    old_values = {}
    new_values.each do |key, value|
      old_values[key] = object.send key
      object.send :"#{key}=", value
    end
    yield
  ensure
    old_values.each do |key, value|
      object.send :"#{key}=", value
    end
  end
  
  context "A rails cell" do
    should "respond to view_paths" do
      assert_kind_of ActionView::PathSet, Cell::Rails.view_paths, "must be a PathSet for proper template caching/reloading (see issue#2)"
    end
    
    should "respond to view_paths=" do
      swap( Cell::Base, :view_paths => ['you', 'are', 'here'])  do
        assert_kind_of ActionView::PathSet, Cell::Base.view_paths, "must not wipe out the PathSet"
      end
    end
    
    should "respond to #request" do
      assert_equal @request, cell(:bassist).request
    end
    
    should "respond to #config" do
      assert_equal({}, cell(:bassist).config)
    end
    
    
    context "invoking defaultize_render_options_for" do
      should "set default values" do
        options = cell(:bassist).defaultize_render_options_for({}, :play)
        
        assert_equal :play, options[:view]
      end
      
      should "allow overriding defaults" do
        assert cell(:bassist).defaultize_render_options_for({:view => :slap}, :play)[:view] == :slap
      end
    end
    
    context "invoking find_family_view_for_state" do
      should "raise an error when a template is missing" do
        assert_raises ActionView::MissingTemplate do
          cell(:bassist).find_template("bassist/playyy")
        end
        
        puts "format: #{cell(:bassist).find_template("bassist/play.js").formats.inspect}"
      end
      
      should "return play.html.erb" do
        assert_equal "bassist/play", cell(:bassist).find_family_view_for_state(:play).virtual_path
      end
      
      should "find inherited play.html.erb" do
        assert_equal "bassist/play", cell(:bad_guitarist).find_family_view_for_state(:play).virtual_path
      end
      
      should_eventually "find the EN-version if i18n instructs" do
        swap I18n, :locale => :en do
          assert_equal "bassist/yell.en.html.erb", cell(:bassist).find_family_view_for_state(:yell).virtual_path
        end
      end
      
      
      should_eventually "return an already cached family view"
    end
    
    context "delegation" do
      setup do
        @request = ActionController::TestRequest.new 
        @request.env["action_dispatch.request.request_parameters"] = {:song => "Creatures"}
        @cell = cell(:bassist)
      end
      
      should_eventually "delegate log" do
        assert_nothing_raised do
          cell(:bassist).class.logger.info("everything is perfect!")
        end
      end
      
      should "respond to session" do
        assert_kind_of Hash, @cell.session
      end
    end
    
    
    should "precede cell ivars over controller ivars" do
      @controller.instance_variable_set(:@note, "E")
      BassistCell.class_eval do
        def slap; @note = "A"; render; end
      end
      assert_equal "Boing in A", render_cell(:bassist, :slap)
    end
    
    should "pass in options to render_cell as params" do
      BassistCell.class_eval do
        def slap; @note = params[:note]; render; end
      end
      assert_equal "Boing in A", render_cell(:bassist, :slap, :note => "A")
    end
    
  end   
end
