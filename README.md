Rumble
======

HTML markup in Ruby. Fast. 130 LoC. Supports CSS-proxies (see below).

Example using [Draper](https://github.com/jcasimir/draper):

    class ArticleDecorator < Draper::Base
      decorates :article
      include Rumble
      
      def published_at
        span.published_at do
          span model.published_at.strftime("%A, %B %e").squeeze(" "), :class => 'date'
          span model.published_at.strftime("%l:%M%p").delete(" "), :class => 'time'
        end
      end
    end

CSS-proxy syntax
----------------

Thanks to CSS-proxies, you can more easily define classes and ids on
elements:

    div.wrapper! do
      input.text.example(:name => 'username')
    end

Renders as:

    <div id="wrapper">
      <input class="text example" name="username">
    </div>

You are of course free to use the simple syntax too:

    div :id => "wrapper" do
      input :class => "text example", :name => "username"
    end

