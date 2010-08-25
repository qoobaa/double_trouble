require "test_helper"

module Rails
  def self.cache
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end
end

class DoubleTroubleCachedNonceTest < Test::Unit::TestCase
  def setup
    Rails.cache.clear
  end

  def test_non_existing_nonce_is_valid
    assert DoubleTrouble::CachedNonce.valid?("non-existing nonce")
  end

  def test_existing_nonce_is_not_valid
    Rails.cache.write("double_trouble_cached_nonce.existing nonce", true)
    assert_false DoubleTrouble::CachedNonce.valid?("existing nonce")
  end

  def test_raises_error_when_saving_nil
    assert_raise(DoubleTrouble::InvalidNonce) { DoubleTrouble::CachedNonce.store!(nil) }
  end

  def test_raises_error_when_saving_existing_nonce
    Rails.cache.write("double_trouble_cached_nonce.existing nonce", true)
    assert_raise(DoubleTrouble::InvalidNonce) { DoubleTrouble::CachedNonce.store!("existing nonce") }
  end
end
