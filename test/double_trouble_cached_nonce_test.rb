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

  test "non-existing nonce is valid" do
    assert DoubleTrouble::CachedNonce.valid?("non-existing nonce")
  end

  test "existing nonce is not valid" do
    Rails.cache.write("double_trouble_cached_nonce.existing nonce", true)
    assert_false DoubleTrouble::CachedNonce.valid?("existing nonce")
  end

  test "raises error when saving nil" do
    assert_raise(DoubleTrouble::InvalidNonce) { DoubleTrouble::CachedNonce.store!(nil) }
  end

  test "raises error when saving existing nonce" do
    Rails.cache.write("double_trouble_cached_nonce.existing nonce", true)
    assert_raise(DoubleTrouble::InvalidNonce) { DoubleTrouble::CachedNonce.store!("existing nonce") }
  end
end
