module Hpricot
  module Rss
    module Common
      def unicode?
        @unicode ||= ["", nil, 'UTF-8' ,'UTF8', 'utf-8', 'utf8'].include?(encoding)
      end
      def utf8(data)
        return data if data.nil? || unicode?
        Iconv.iconv('UTF-8', encoding, data).join rescue data
      end
      def get_preferred(*args)
        value = nil
        args.each do |search|
          if !value && elem = (self/search).first
            value ||= yield(elem)
            value = nil if value == ""
          end
        end
        value
      end
    end
    module Doc
      include Common
      FEED_ELEMS = "//channel/title,/feed/title,/channel/link"
      FEED_URL_ELEMS = "//channel/link,//feed/link[@rel = 'alternate']"
      AUTHOR_ELEMS = ["author/email","author//name","author","creator", "dc:creator"]

      def encoding
        @encoding ||= if ele = children.first
          if ele.kind_of?(Hpricot::XMLDecl)
            ele.encoding || ""
          else
            ""
          end
        end
      end
      def feed_title
        @feed_title ||= if ele = (self/FEED_ELEMS).first
          utf8(ele.inner_text).strip
        end
      end
      def feed_url
        @feed_url ||= if ele = (self/FEED_URL_ELEMS).first
          utf8(ele.get_attribute("href") || ele.inner_text)
        end
      end
      def feed_base
        @feed_base ||= utf8(self.root.get_attribute("xml:base"))
      end
      def entries
        (self/"entry,item")
      end
      def author
        @author ||= get_preferred(*AUTHOR_ELEMS) do |elem|
          utf8(elem.inner_text)
        end
      end
    end
    module Elem
      include Common
      ENTRY_TITLE_ELEMS = ["topic", "title","pubDate","modified","date","dc:date","updated"]
      ENTRY_URL_ELEMS = ["link[@type = 'text/html']", "link", "guid"]
      ENTRY_AUTHOR_ELEMS = ["author/email","author//name","author","creator"]
      ENTRY_CONTENT_ELEMS = ["content:encoded","description","content","summary","body"]

      def encoding
        @feed_encoding ||= parent.encoding
      end
      def feed_title
        @feed_title ||= parent.feed_title
      end
      def feed_url
        @feed_url ||= parent.feed_url
      end
      def feed_base
        @feed_base ||= parent.feed_base
      end
      def entry_base
        @entry_base ||= self.get_attribute("xml:base")
      end
      def title
        @title ||= get_preferred(*ENTRY_TITLE_ELEMS) do |elem|
          utf8(elem.inner_text)
        end
      end
      def url
        @url ||= get_preferred(*ENTRY_URL_ELEMS) do |elem|
          utf8(elem.get_attribute("href") || elem.inner_text)
        end
        if feed_base
          @url = URI.join(feed_base, entry_base, @url)
        else
          @url
        end
      end
      def author
        @author ||= get_preferred(*ENTRY_AUTHOR_ELEMS) do |elem|
          utf8(elem.inner_text)
        end || parent.author
      end
      ENTRY_DATE_ELEMS = ["date","modified","pubDate","dc:date"]
      def date
        @date ||= get_preferred(*ENTRY_DATE_ELEMS) do |elem|
          utf8(elem.inner_text)
        end
      end
      def content
        @content ||= begin
          @content = get_preferred(*ENTRY_CONTENT_ELEMS) do |elem|
            utf8(elem.inner_html)
          end
          if @content_doc = Hpricot(@content)
            @cwd_url ||= URI.join(feed_url, ".").to_s
            (@content_doc/"*[@src]").each do |elem|
              elem.set_attribute("src", URI.join(@cwd_url, elem.get_attribute("src").to_s.strip))
            end
            (@content_doc/"*[@href]").each do |elem|
              elem.set_attribute("href", URI.join(@cwd_url, elem.get_attribute("href").to_s.strip))
            end
          end
          @content = @content_doc.to_s
          @content.gsub!(/\<\!\[CDATA\[(.*)\]\]\>/m, '\1') if @content =~ /<\!\[CDATA\[/ && @content =~ /\]\]>/
          @content = Hpricot.uxs(@content) unless @content =~ /</
          @content
        end
      end
      def enclosure
        utf8(@enclosure ||= (self/"enclosure[@url]").first)
      end
      def enclosure_url
        enclosure.respond_to?(:get_attribute) && utf8(enclosure.get_attribute("url"))
      end
      def enclosure_length
        enclosure.respond_to?(:get_attribute) && enclosure.get_attribute("length")
      end
      def enclosure_type
        enclosure.respond_to?(:get_attribute) && enclosure.get_attribute("type")
      end  
    end
  end
  
  class << self
    def uxs(str)
      str.to_s.
          gsub(/\&\w+;/) { |x| (XChar::PREDEFINED_U[x] || ??).chr }.
          gsub(/\&\#(\d+);/) { [$1.to_i].pack("U*") }.
          gsub(/\&\#x(\d+);/) { [$1].pack("H*") }
    end
  end
end

Hpricot::Doc.send :include, Hpricot::Rss::Doc
Hpricot::Elem.send :include, Hpricot::Rss::Elem
