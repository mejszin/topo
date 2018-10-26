# Requirements ════════════════════════════════════════════════════════════════

require 'yaml'
require 'fox16'
require 'fox16/colors'
include Fox

# App ═════════════════════════════════════════════════════════════════════════

def hex_to_rgb(hex_color)
  m = hex_color.match /#(..)(..)(..)/
  return Fox.FXRGB(m[1].hex, m[2].hex, m[3].hex)
end

def render(parent, values, level)
  cnt_params = {
    :padding  => 8, 
    :vSpacing => 8,
    :hSpacing => 8
  }
  color = case level
    when 0
      hex_to_rgb("#BED295")
    when 1
      hex_to_rgb("#DEDEDE")
    when 2
      hex_to_rgb("#BEBEBE")
  else
    hex_to_rgb("#FFFFFF")
  end
  values.each do |a,b|
    if b.is_a?(Hash)
      s = FXPacker.new(parent, (FRAME_LINE|LAYOUT_SIDE_LEFT), cnt_params)
      l = FXLabel.new(s, a.to_s)
      render(s, b, level + 1)
    else
      s = FXPacker.new(parent, (FRAME_LINE|LAYOUT_FILL_X))
      l = FXLabel.new(s, a.to_s)
    end
    s.backColor = color
    l.backColor = color
  end
end

def load_topo(parent, values)
  puts values
  render(parent, values, 0)
end

class AppWindow < FXMainWindow

  def initialize(app, title, w, h)

    properties = {
      :width => w,
      :height => h,
      :padding => 32
    }

    super(app, title, properties)

    @frame = FXPacker.new(
    	self,
      (FRAME_NONE|LAYOUT_FILL|LAYOUT_SIDE_LEFT),
      
      :padLeft 		=> 0,
      :padTop 		=> 0,
      :padRight 	=> 0,
      :padBottom 	=> 0
    )

    @frame.backColor = hex_to_rgb("#FFFFFF")
    self.backColor = hex_to_rgb("#FFFFFF")

    load_topo(@frame, YAML.load_file("./topo.yml"))

	end
	def create
    super
		show(PLACEMENT_SCREEN)
	end
end

# Initialization ══════════════════════════════════════════════════════════════

app = FXApp.new
window = AppWindow.new(app, "", 400, 360)
app.create
app.run
