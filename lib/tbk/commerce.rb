
module TBK
  # Represents a commerce registered with Transbank
  class Commerce

    # The registered commerce id
    attr_accessor :id

    # The commerce secret RSA key
    attr_accessor :key

    # Initialyzes a new commerce
    # @param [Hash] attributes The commerce attributes
    # @option attributes [Integer] :id The commerce ID
    # @option attributes [String|OpenSSL::PKey::RSA] :key The commerce RSA private key
    # @option attributes [Boolean] :test flag to set commerce in test mode
    def initialize(attributes)
      @test = attributes[:test]

      self.id = attributes[:id]
      raise TBK::CommerceError, "Missing commerce id" if self.id.nil?

      self.key = case attributes[:key]
      when String
        OpenSSL::PKey::RSA.new(attributes[:key])
      when OpenSSL::PKey::RSA.new
        attributes[:key]
      when nil
        TEST_COMMERCE_KEY if self.test?
      end

      raise TBK::CommerceError, "Missing commerce key" if self.key.nil?
      raise TBK::CommerceError, "Commerce key must be a RSA private key" unless self.key.private?
    end

    # @return [Boolean] wether or not the commerce is in test mode
    def test?
      @test || false
    end

    # @return [Boolean] wether or not the commerce is in production mode
    def production?
      !self.test?
    end

    # @return [Integer] RSA key bytes
    def key_bytes
      self.key.n.num_bytes
    end

    TEST_COMMERCE_KEY = TBK.parse_key('test_commerce')
  end
end