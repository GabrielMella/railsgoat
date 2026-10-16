# frozen_string_literal: true
module Encryption

  # Encrypt val with AES-256-CBC using a unique random IV per call.
  # The 16-byte IV is prepended to the ciphertext before Base64 encoding
  # so that decrypt_sensitive_value can recover it.
  def self.encrypt_sensitive_value(val = "")
     aes = OpenSSL::Cipher.new(cipher_type)
     aes.encrypt
     aes.key = key[0..31]
     random_iv = aes.random_iv
     new_val = aes.update("#{val}") + aes.final
     Base64.strict_encode64(random_iv + new_val).encode("utf-8")
  end

  # Decrypt a value produced by encrypt_sensitive_value.
  # The first 16 bytes of the decoded payload are the IV; the rest is ciphertext.
  def self.decrypt_sensitive_value(val = "")
     aes = OpenSSL::Cipher.new(cipher_type)
     aes.decrypt
     aes.key = key[0..31]
     decoded = Base64.strict_decode64("#{val}")
     aes.iv = decoded[0, 16]
     aes.update(decoded[16..]) + aes.final
  end

  # Load the encryption key via the KEY constant (set from ENCRYPTION_KEY env var).
  def self.key
    raise "Key Missing. Set the ENCRYPTION_KEY environment variable." unless KEY
    KEY
  end

  def self.cipher_type
    "aes-256-cbc"
  end

end
