require_relative 'lib/rumble'
require "markaby"
require "erector"
require "benchmark"

CODE = <<-'RUBY'
text '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
html(:xmlns=>'http://www.w3.org/1999/xhtml', 'xml:lang'=>'en-US') do
  head do
    title "Hampton Catlin Is Totally Awesome"
    meta("http-equiv" => "Content-Type", :content => "text/html; charset=utf-8")
  end
  body do
    # You're In my house now!
    div :class => "header" do
      text %|Yes, ladies and gentileman. He is just that egotistical.
      Fantastic! This should be multi-line output
      The question is if this would translate! Ahah!|
      text 1 + 9 + 8 + 2 #numbers should work and this should be ignored
    end
    div(:id => "body") { text "Quotes should be loved! Just like people!" }
    120.times do |number|
      a(number, :href => "#id-#{number}")
    end
    text "Wow.|"
    p do
      text "Holy cow        " + 
        "multiline       " +       
        "tags!           " + 
        "A pipe (|) even!"   
      text [1, 2, 3].collect { |n| "PipesIgnored|" }
      text [1, 2, 3].collect { |n|     
          n.to_s                    
        }.join("|")                
    end
    div(:class => "silent #{@night}") do
      foo = String.new
      foo << "this"
      foo << " shouldn't"
      foo << " evaluate"
      text foo + " but now it should!\n"
      # Woah crap a comment!
    end
    # That was a line that shouldn't close everything.
    ul(:class => "really cool") do
      ('a'..'f').each do |a|
        li a
      end
    end
    div((@should_eval = "with this text"), :id => "combo", :class => "of_divs_with_underscore")
    [ 104, 101, 108, 108, 111 ].map do |byte|
      byte.chr
    end
    div(:class => "footer") do
      div "See, and this contains a tag: <strong>escape me!</strong>"
      strong("This is a really long ruby quote. It should be loved and wrapped because its more than 50 characters. This value may change in the future and this test may look stupid. \nSo, I'm just making it *really* long. God, I hope this works", :class => "shout")
    end
  end
end
RUBY

Markaby::Builder.set :output_meta_tag, false
class Example
  include Rumble
  include Erector::Mixin

  class_eval <<-RUBY
    def test_rumble
      #{CODE}
    end

    def test_markaby
      Markaby::Builder.new do
        #{CODE}
      end.to_s
    end

    def test_erector
      erector do
        #{CODE}
      end
    end
  RUBY
end

e = Example.new
puts "RUMBLE"
puts r=e.test_rumble
puts "MARKABY"
puts m=e.test_markaby
puts "ERECTOR"
puts e.test_erector

N = 1000

Benchmark.bmbm do |x|
  x.report('Rumble')  { N.times { e.test_rumble  } }
  x.report('Erector') { N.times { e.test_erector } }
  x.report('Markaby') { N.times { e.test_markaby } }
end


