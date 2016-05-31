#gems/slides/lib/slides.rb
# How to use:
# Check slides module and change settings on constants
# Instruct Slide::Scene about slides you are going to show
# by calling something like this
# Slides::Scene.slides = [
#   ['Picture 1 to show in Graphics/Slides', 'Test to show 1'],
#   ['Picture 2 to show in Graphics/Slides', 'Test to show 2'],
#   ['Picture 3 to show in Graphics/Slides', 'Test to show 3']
# ]
# If you do not want to show a picture or a text - past nil
# Slides::Scene.slides = [
#   [nil, 'Test to show 1'],
#   ['Picture 2 to show in Graphics/Slides', nil],
#   ['Picture 3 to show in Graphics/Slides', nil]
# ]
# Then you may use Slides::Scene as usual scene. Foe example 
# SceneManager.call(Slides::Scene)
# or you can overwrite SceneManager.first_scene_class and 
# the slides will be shown at the beginning of the game
module Slides
  # How much frames each slide will be waiting 
  # till next slide will be shown
  # Float::INFINITY = Forever
  WAIT_FRAMES = Float::INFINITY

  # Enable prev slide on LEFT key pressing
  PREV_SLIDE_ENABLED = true

  # Enable next slide on ANY key pressing 
  NEXT_SLIDE_ENABLED = true

  # Enable exit from slides on ESC key presing
  ESC_SLIDES_ENABLED = true

  # Length of fadeout effect between slides
  FADEOUT_FRAMES = 20

  # Length of fadein effect between slides
  FADEIN_FRAMES = 20
end

#gems/slides/lib/slides/patch.rb
module Slides::Patch
end

#gems/slides/lib/slides/patch/cache_patch.rb
module Cache
  def self.slides(filename)
    load_bitmap "Graphics/Slides/", filename
  end
end
#gems/slides/lib/slides/scene.rb
class Slides::Scene < Scene_Base
  def self.slides=(slides)
    @@slides = slides
  end

  def initialize(*)
    @current_slide = 0
    @sprite = Sprite.new
    @sprite.ox, @sprite.oy = 0, 0
    @sprite.bitmap = Bitmap.new width, (height / 3) * 2
    @with_text = false
    init_fast
    super
  end

  def start
    super
    create_text_window
    slide! true
  end

  def slide!(fast = false)
    @fast = fast
    if @current_slide < @@slides.length
      render(*@@slides[@current_slide])
      @current_slide += 1
    else
      quit
    end
  end

  def prev_slide!
    if @current_slide > 1
      @current_slide -= 1
      render(*@@slides[@current_slide -1])
    else
      slide!
    end
  end

  def quit
    SceneManager.call Scene_Title
  end

  def terminate
    super 
    @sprite.dispose
  end

  def update
    super 
    @sprite.update
    check_keys
  end
  
  private

  def check_keys
    unless @with_text
      key = Slides::KeyChecker.check_keys
      public_send key if key
    end
  end

  def init_fast 
    @fast = false
  end

  def render(image_path, text, face_name = nil, face_index = nil)
    Graphics.fadeout 10 unless @fast
    show_image image_path 
    show_text text, face_name, face_index
    Graphics.fadein 10 unless @fast
    init_fast
  end

  def create_text_window
    @text_window = Slides::Window.new self
  end

  def width
    Graphics.width 
  end

  def height 
    Graphics.height 
  end

  def show_image(image_path)
    @sprite.bitmap.clear
    if image_path
      if image_path.length > 0
        source = Cache.slides(image_path)
        @sprite.bitmap.stretch_blt image_rect(source.rect), source, source.rect
      end
    end
  end

  def image_rect(source_rect)
    x = [0, (width - source_rect.width) / 2].max 
    y = [0, ((height / 3) * 2 - source_rect.height) / 2].max 
    Rect.new x, y, source_rect.width, source_rect.height
  end

  def show_text(text, face_name, face_index)
    if text
      @with_text = true
      $game_message.add text
      $game_message.face_name = face_name if face_name 
      $game_message.face_index = face_index if face_name && face_index
    else
      @with_text = false
    end
  end
end
#gems/slides/lib/slides/window.rb
class Slides::Window < Window_Message
  def initialize(scene)
    @scene = scene 
    super()
  end

  private

  def input_pause
    self.pause = true
    wait(10)
    Fiber.yield until @slide_key = Slides::KeyChecker.check_keys
    Input.update
    self.pause = false
  end

  def close_and_wait
    super
    @scene.public_send @slide_key if @slide_key
  end

  def update_show_fast
    @show_fast = true if Slides::KeyChecker.any_key?
  end
end
#gems/slides/lib/slides/key_checker.rb
module Slides::KeyChecker
  def check_keys
    if key = current_key
      @checked = 0
      key
    else
      @checked ||= 0
      @checked += 1
      false
    end
  end

  def any_key?
    Input.constants.any? do |name|
      Input.trigger?(Input.const_get name)
    end
  end

  def next_key?
    Slides::NEXT_SLIDE_ENABLED && any_key?
  end

  def prev_key?
    Slides::PREV_SLIDE_ENABLED && Input.trigger?(:LEFT)
  end

  def escape?
    Slides::ESC_SLIDES_ENABLED && Input.trigger?(Input::B) 
  end

  private

  def current_key
    if escape?
      :quit 
    elsif prev_key?
      :prev_slide!
    elsif next_key?
      :slide!
    elsif @checked.to_i > Slides::WAIT_FRAMES
      :slide!
    end
  end

  extend self
end