module LogStash::Outputs
  module Keystone
    class Token
      attr_accessor :id, :expire_at
      def initialize id, expire_at
        @id = id
        @expire_at = expire_at
      end

      def ==(another_token)
        self.id == another_token.id && self.expire_at == another_token.expire_at
      end
    end
  end
end