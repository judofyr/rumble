require "minitest/unit"
require "minitest/autorun"
require "rumble"

class TestRumble < MiniTest::Unit::TestCase
  include Rumble

  def assert_rumble(html, &blk)
    exp = html.gsub(/(\s+(<)|>\s+)/) { $2 || '>' }
    res = yield.to_s
    assert_equal exp, res
  end

  def setup
    super
    assert_nil @rumble_context
  end

  def teardown
    super
    assert_nil @rumble_context
  end

  def test_simple
    html = <<-HTML
      <html>
      <head>
        <title>Rumble Test</title>
      </head>
      <body>
        <div id="wrapper">
          <h1>My Site</h1>
        </div>
      </body>
      </html>
    HTML

    assert_rumble html do
      html do
        head { title "Rumble Test" }

        body do
          div.wrapper! do
            h1 "My Site"
          end
        end
      end
    end
  end

  def test_escape
    html = <<-HTML
      <p class="&quot;test&quot;">Hello &amp; World</p>
    HTML

    assert_rumble html do
      p "Hello & World", :class => '"test"'
    end
  end

  def test_multiple_css_classes
    html = <<-HTML
      <p class="one two three"></p>
    HTML

    assert_rumble html do
      p.one.two.three
    end
  end

  def test_selfclosing
    assert_rumble "<br>" do
      br
    end
  end

  def test_text
    assert_rumble "hello" do
      text "hello"
    end
  end

  def test_error_selfclosing_content
    assert_raises Rumble::Error do
      br "content"
    end
  end

  def test_error_css_proxy_continue
    assert_raises Rumble::Error do
      p.one("test").two
    end
  end
end

