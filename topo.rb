require 'yaml'
require 'json'
require 'fox16'
require 'fox16/colors'
include Fox

COLORS = ["#BED295", "#DEDEDE", "#BEBEBE", "#FFFFFF"]

def hex_to_rgb(hex_color)
  m = hex_color.match /#(..)(..)(..)/
  return Fox.FXRGB(m[1].hex, m[2].hex, m[3].hex)
end

def render(parent, values, level)
  color = level < COLORS.length ? COLORS[level] : COLORS.last
  values.each do |key, val|
    # Assign dimensions and drawing options
    opts = val.is_a?(Hash) ? (FRAME_LINE|LAYOUT_SIDE_LEFT) : (FRAME_LINE|LAYOUT_FILL_X)
    dims = val.is_a?(Hash) ? { :padding => 8, :vSpacing => 8, :hSpacing => 8 } : {}
    # Create container
    box = FXPacker.new(parent, opts, dims)
    box.backColor = hex_to_rgb(color)
    # Create label
    lbl = FXLabel.new(box, key.to_s)
    lbl.backColor = hex_to_rgb(color)
    # Call recursively until endpoint
    render(box, val, level + 1) if val.is_a?(Hash)
  end
end

def topo(parent, values)
  render(parent, values, 0)
end

class AppWindow < FXMainWindow

  def initialize(app, title, w, h, data)
    # Create app window
    properties = { :width => w, :height => h, :padding => 32 }
    super(app, title, properties)
    # Create window frame
    opts = (FRAME_NONE|LAYOUT_FILL|LAYOUT_SIDE_LEFT)
    dims = {:padLeft => 0, :padTop => 0, :padRight => 0, :padBottom => 0 }
    @frame = FXPacker.new(self, opts, dims)
    @frame.backColor = hex_to_rgb("#FFFFFF")
    self.backColor = hex_to_rgb("#FFFFFF")
    # Render topo
    topo(@frame, data)
	end
	def create
    super
		show(PLACEMENT_SCREEN)
	end
end

# Return if no path given or not a path
if (ARGV.length == 0) || (!File.file?(ARGV[0]))
  puts "Invalid file name"; exit
end

# Assign path
path = ARGV[0]

# Get data
case File.extname(path)
when ".json"
  file = File.open(path)
  data = JSON.load(file)
  file.close
when ".yml", ".yaml"
  data = YAML.load_file(path)
else
  puts "Invalid file extension"; exit
end

# Create app
app = FXApp.new
window = AppWindow.new(app, "", 400, 360, data)
app.create
app.run
