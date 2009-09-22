require 'rubygems'
require 'plasma_applet'
require 'twitter'
require 'Qt4'
$kcode = "utf-8"
 
module RubyTest
  class Main < PlasmaScripting::Applet
    def initialize parent
      super parent
    end
 
    def init
      httpauth = Twitter::HTTPAuth.new('LOGIN', 'PASSWORD')
      @client = Twitter::Base.new(httpauth)

      timer = Qt::Timer.new
      timer.start 600000

      set_minimum_size 400, 400
 
      layout = Qt::GraphicsGridLayout.new  self
      self.layout = layout
 
      label = Plasma::Label.new self
      label.text = 'Простой интерфейс для twitter.com'
      layout.add_item label, 0, 1
      layout.setRowMaximumHeight 0, 10
 
      @text_edit = Plasma::WebView.new self
      @style_sheet = "twit { color: #000; margin-bottom: .25em; }
				.twit:nth-child(odd) { background: #fbffc0; }
				.twit:nth-child(even) { background: #ffebfa; }
				.name { font-weight: bold; }
				.text { padding-left: 2ex; }
				.twit:last-child { margin-bottom: 0; }"
      @page_header = "<html><head><style type='text/css'>#{@style_sheet}</style></head><body>"
      @page_footer = "</body></html>"
      self.update_data

      layout.add_item @text_edit, 1, 1
      layout.setRowMinimumHeight 1, 100

      edit_status = Plasma::LineEdit.new self
      layout.add_item edit_status, 2, 1
      layout.setRowMaximumHeight 2, 5

      button = Plasma::PushButton.new self
      button.text = 'Обновить статус'
      layout.add_item button, 3, 1
      layout.setRowMaximumHeight 3, 5
      
      timer.connect(SIGNAL(:timeout)) do
        p "timers work #{Time.now}"
	self.update_data
      end
      
      button.connect(SIGNAL(:clicked)) do
	@client.update edit_status.text
	self.update_data
	edit_status.text = ""
      end
    end
 
    def update_data
      all_data = @client.friends_timeline
      text = ""
      8.times do |i|
	text += "<div class='twit'>
		 <div class='meta'>by <span class='name'>Name#{all_data[i].user}</span> at #{all_data[i].created_at.class}</div>
		 <div class='text'>#{all_data[i].text}</div>
		</div>"
      end
      @text_edit.html = @page_header + text + @page_footer
    end

  end
end
