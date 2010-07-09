module DoubleTrouble
  class CachedNonce
    cattr_accessor :expires_in
    self.expires_in = 1.hour

    attr_accessor :nonce

    def self.valid?(nonce)
      new(nonce).valid?
    end

    def self.store!(nonce)
      new(nonce).save!
    end

    def initialize(nonce)
      self.nonce = nonce
    end

    def save
      valid? && ::Rails.cache.write(cache_key, true, :expires_in => self.class.expires_in)
    end

    def save!
      save || raise(InvalidNonce)
    end

    def valid?
      nonce.present? && !::Rails.cache.exist?(cache_key, :expires_in => self.class.expires_in)
    end

    def cache_key
      "double_trouble_cached_nonce.#{nonce}"
    end
  end
end
