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
end

require 'slides/patch'
require 'slides/scene'
require 'slides/window'
require 'slides/key_checker'