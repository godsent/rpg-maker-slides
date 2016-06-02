class Slides::Scene < Scene_Base
  def self.slides=(slides)
    @@slides = slides
  end

  def initialize(*)
    @current_slide = 0
    @sprite = Sprite.new
    @sprite.ox, @sprite.oy = 0, 0
    @sprite.bitmap = Bitmap.new width, height
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
    Graphics.fadeout Slides::FADEOUT_FRAMES unless @fast
    show_image image_path 
    show_text text, face_name, face_index
    Graphics.fadein Slides::FADEIN_FRAMES unless @fast
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