# frozen_string_literal: true
# Load the API token salt from the ACCESS_TOKEN_SALT environment variable.
# Set this variable via your deployment secrets manager, Rails encrypted
# credentials (`rails credentials:edit`), or a .env file (never committed).
ACCESS_TOKEN_SALT = ENV.fetch("ACCESS_TOKEN_SALT") { raise "ACCESS_TOKEN_SALT environment variable is not set" }
