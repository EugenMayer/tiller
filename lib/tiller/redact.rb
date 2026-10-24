module Tiller
  # Masks values whose key looks like a secret, so they do not end up in logs.
  module Redact
    SECRET_KEY = /passw(or)?d|passphrase|(\A|[_-])pass(\z|[_-])|secret|token|credential|api[_-]?key|private[_-]?key/i
    MASK = '[REDACTED]'

    def self.secret_key?(key)
      !(key.to_s =~ SECRET_KEY).nil?
    end

    # The value to log for the given key
    def self.value(key, value)
      secret_key?(key) ? MASK : value
    end
  end
end
