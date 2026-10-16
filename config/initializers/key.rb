# frozen_string_literal: true
# Load the encryption key from the ENCRYPTION_KEY environment variable.
# Set this variable via your deployment secrets manager, Rails encrypted
# credentials (`rails credentials:edit`), or a .env file (never committed).
KEY = ENV.fetch("ENCRYPTION_KEY") { raise "ENCRYPTION_KEY environment variable is not set" }
