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