require "active_support"
require "action_pack"
require "action_controller"
require "action_controller/base"
require "action_view"
require "action_view/helpers/form_tag_helper"
require "active_support/cache"
require "active_support/concern"

require "double_trouble/errors"
require "double_trouble/cached_nonce"
require "double_trouble/form_tag_helper_hack"
require "double_trouble/protection"
require "double_trouble/version"

ActionController::Base.send(:include, DoubleTrouble::Protection)
