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