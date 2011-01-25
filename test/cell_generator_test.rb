require 'test_helper'
require 'generators/cells/cell_generator'

class CellGeneratorTest < Rails::Generators::TestCase
  destination File.join(Rails.root, "tmp")
  setup :prepare_destination
  tests ::Cells::Generators::CellGenerator

  context "Running script/generate cell" do
    context "Blog post latest" do

      should "create the standard assets" do
        run_generator %w(Blog post latest)

        assert_file "app/cells/blog_cell.rb", /class BlogCell < Cell::Rails/
        assert_file "app/cells/blog_cell.rb", /def post/
        assert_file "app/cells/blog_cell.rb", /def latest/
        assert_file "app/cells/blog/post.html.erb", %r(app/cells/blog/post\.html\.erb)
        assert_file "app/cells/blog/post.html.erb", %r(<p>)
        assert_file "app/cells/blog/latest.html.erb", %r(app/cells/blog/latest\.html\.erb)


        assert_no_file "app/cells/blog/post.html.haml"
        assert_no_file "app/cells/blog/post.html.haml"
        assert_no_file "app/cells/blog/latest.html.haml"
      end

      should "create haml assets with -e haml" do
        run_generator %w(Blog post latest -e haml)

        assert_file "app/cells/blog_cell.rb", /class BlogCell < Cell::Rails/
        assert_file "app/cells/blog_cell.rb", /def post/
        assert_file "app/cells/blog_cell.rb", /def latest/
        assert_file "app/cells/blog/post.html.haml", %r(app/cells/blog/post\.html\.haml)
        assert_file "app/cells/blog/post.html.haml", %r(%p)
        assert_file "app/cells/blog/latest.html.haml", %r(app/cells/blog/latest\.html\.haml)


        assert_no_file "app/cells/blog/post.html.erb"
        assert_no_file "app/cells/blog/post.html.erb"
        assert_no_file "app/cells/blog/latest.html.erb"
      end

      should "create test_unit assets with -t test_unit" do
        run_generator %w(Blog post latest -t test_unit)

        assert_file "test/cells/blog_cell_test.rb"
      end

      should "create test_unit assets with -t rspec" do
        run_generator %w(Blog post latest -t rspec)

        assert_no_file "test/cells/blog_cell_test.rb"
      end

    end
  end
end
