require "rails/all"
require "active_support/all"

require "double_trouble/errors"
require "double_trouble/cached_nonce"
require "double_trouble/form_tag_helper_hack"
require "double_trouble/protection"
require "double_trouble/version"

ActionController::Base.send(:include, DoubleTrouble::Protection)
