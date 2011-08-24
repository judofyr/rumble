require "cgi"

module Rumble
  class Error < StandardError; end
  SELFCLOSING = %w[base meta link hr br param img area input col frame]

  %w[a abbr acronym address applet area article aside audio b base
basefont bdo big blockquote body br button canvas caption center cite
code col colgroup command datalist dd del details dfn dir div dl dt em
embed fieldset figcaption figure font footer form frame frameset h1
h6 head header hgroup hr html i iframe img input ins keygen kbd label
legend li link map mark menu meta meter nav noframes noscript object ol
optgroup option output p param pre progress q rp rt ruby s samp script
section select small source span strike strong style sub summary sup
table tbody td textarea tfoot th thead time title tr tt u ul var video
wbr xmp ].each do |tag|
    sc = SELFCLOSING.include?(tag).inspect
    class_eval "def #{tag}(*args, &blk); rumble_tag :#{tag}, #{sc}, *args, &blk end"
  end

  class Context < Array
    attr_accessor :instance

    def initialize(instance)
      @instance = instance
    end

    def done
      @instance.instance_eval { @rumble_context = nil }
      self
    end

    def to_s
      join
    end
  end

  class Tag
    def initialize(context, name, sc, main_tag)
      @context = context
      @name = name
      @sc = sc
      @main_tag = main_tag
    end

    def attributes
      @attributes ||= {}
    end

    def merge_attributes(attrs)
      if defined?(@attributes)
        @attributes.merge!(attrs)
      else
        @attributes = attrs
      end
    end

    def method_missing(name, content = nil, attrs = nil, &blk)
      name = name.to_s

      if name[-1] == ?!
        attributes[:id] = name[0..-2]
      else
        if attributes.has_key?(:class)
          attributes[:class] += " #{name}"
        else
          attributes[:class] = name
        end
      end

      insert(content, attrs, &blk)
    end

    def insert(content = nil, attrs = nil, &blk)
      error("This tag is already closed") if @done

      if content.is_a?(Hash)
        attrs = content
        content = nil
      end

      merge_attributes(attrs) if attrs

      if block_given?
        error("`#{@name}` is not allowed to have content") if @sc
        @done = :block
        before = @context.size
        res = yield
        @content = res if @context.size == before
        @context << "</#{@name}>"
        return @context.done.join if @main_tag
      elsif content
        error("`#{@name}` is not allowed to have content") if @sc
        @done = true
        @content = CGI.escape_html(content.to_s)
      elsif attrs
        @done = true
      end

      self
    end

    def error(str)
      @context.done
      raise Error, str
    end

    def to_ary; nil end
    def to_str; to_s end

    def to_s
      res = "<#{@name}#{attrs_to_s}>"
      res << @content if @content
      res << "</#{@name}>" if !@sc && @done != :block
      res
    ensure
      @context.done if @main_tag
    end

    def inspect; to_s.inspect end

    def attrs_to_s
      attributes.inject("") do |res, (name, value)|
        if value
          value = (value == true) ? name : CGI.escape_html(value.to_s)
          res << " #{name}=\"#{value}\""
        end
        res
      end
    end
  end

  def rumble_tag(name, sc, content = nil, attrs = nil, &blk)
    context = @rumble_context

    if !context
      new_context = true
      context = @rumble_context = Context.new(self)
    end

    tag = Tag.new(context, name, sc, new_context)
    context << tag
    tag.insert(content, attrs, &blk)
  end

  def text(str)
    if @rumble_context
      @rumble_context << str
    else
      str
    end
  end

  def rumble
    ctx = @rumble_context
    @rumble_context = nil
    yield
    @rumble_context.to_s
  ensure
    @rumble_context = ctx
  end
end

