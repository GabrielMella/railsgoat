# frozen_string_literal: true
class TutorialsController < ApplicationController
  skip_before_action :has_info
  skip_before_action :authenticated

  def credentials
    # Render credentials page with layout
  end

  # Tutorial: See wiki R8-A1-ReDoS for exploitation details
  def redos_email
    email = params[:email]

    # SAFE: Use Ruby's built-in URI email regex which does not have catastrophic backtracking
    email_pattern = URI::MailTo::EMAIL_REGEXP

    begin
      start_time = Time.now
      is_valid = email =~ email_pattern
      elapsed_time = Time.now - start_time

      render json: {
        valid: is_valid.present?,
        time_elapsed: elapsed_time,
        message: "Email validation completed"
      }
    rescue Regexp::TimeoutError => e
      elapsed_time = Time.now - start_time
      Rails.logger.warn "[SECURITY] Regexp timeout during email validation, elapsed: #{elapsed_time}s"

      render json: {
        error: "Timeout",
        message: "Email validation timed out",
        time_elapsed: elapsed_time
      }, status: :bad_request
    end
  end

  # Tutorial: See wiki R8-A1-ReDoS for exploitation details
  def redos_username
    username = params[:username]

    # SAFE: Simple character class pattern without nested quantifiers
    username_pattern = /\A\w+\z/

    begin
      start_time = Time.now
      is_valid = username =~ username_pattern
      elapsed_time = Time.now - start_time

      render json: {
        valid: is_valid.present?,
        time_elapsed: elapsed_time,
        message: "Username validation completed"
      }
    rescue Regexp::TimeoutError => e
      elapsed_time = Time.now - start_time
      Rails.logger.warn "[SECURITY] Regexp timeout during username validation, elapsed: #{elapsed_time}s"

      render json: {
        error: "Timeout",
        message: "Username validation timed out",
        time_elapsed: elapsed_time
      }, status: :bad_request
    end
  end

  # SECURE: Fixed version using simpler regex
  # This shows the proper way to validate without ReDoS risk
  def redos_email_safe
    email = params[:email]

    # SAFE: Use Ruby's built-in URI email regex or simple validation
    begin
      start_time = Time.now
      is_valid = email =~ URI::MailTo::EMAIL_REGEXP
      elapsed_time = Time.now - start_time

      render json: {
        valid: is_valid.present?,
        time_elapsed: elapsed_time,
        message: "Email validation completed (safe method)"
      }
    rescue Regexp::TimeoutError => e
      # This should never happen with the built-in regex, but handle it anyway
      elapsed_time = Time.now - start_time
      render json: {
        error: "Timeout",
        message: "Validation timed out",
        time_elapsed: elapsed_time
      }, status: :bad_request
    end
  end

  # VULNERABILITY A03:2025 - Software Supply Chain Failures
  # This endpoint demonstrates various supply chain security issues
  #
  # Tutorial: See wiki for A03 exploitation details
  def supply_chain
    render json: {
      vulnerabilities: [
        {
          type: "Missing Subresource Integrity (SRI)",
          location: "app/views/layouts/application.html.erb",
          description: "CDN assets loaded without integrity checks",
          impact: "If CDN is compromised, malicious code can be injected",
          cve_example: "Similar to British Airways breach (2018) via Magecart"
        },
        {
          type: "Outdated Dependencies",
          location: "Gemfile.lock",
          description: "Application may use gems with known vulnerabilities",
          impact: "Exploitable CVEs in dependencies",
          mitigation: "Run 'bundle audit' to check for known vulnerabilities"
        },
        {
          type: "No Dependency Integrity Validation",
          location: "Gemfile / bundler configuration",
          description: "Gemfile.lock can be modified without detection",
          impact: "Malicious dependencies could be injected",
          mitigation: "Use checksums, verify signatures, implement SBOM"
        },
        {
          type: "Insecure Gem Sources",
          location: "Gemfile (if misconfigured)",
          description: "Using HTTP instead of HTTPS for gem sources",
          impact: "Man-in-the-middle attacks during bundle install",
          note: "RailsGoat correctly uses HTTPS, but many apps don't"
        },
        {
          type: "No Software Bill of Materials (SBOM)",
          location: "Project root",
          description: "Missing SBOM documentation",
          impact: "Cannot track supply chain components or vulnerabilities",
          mitigation: "Generate SBOM using CycloneDX or SPDX formats"
        }
      ],
      demo: "Check application.html.erb for CDN assets without SRI",
      secure_example: {
        vulnerable: '<script src="https://cdn.example.com/lib.js"></script>',
        secure: '<script src="https://cdn.example.com/lib.js" integrity="sha384-hash" crossorigin="anonymous"></script>'
      }
    }
  end

  # Demonstrate checking for vulnerable dependencies
  def check_dependencies
    begin
      # In a real scenario, this would run bundle-audit or similar
      # For demo purposes, we'll return example vulnerability data
      render json: {
        status: "scan_complete",
        message: "This endpoint simulates dependency vulnerability scanning",
        note: "Run 'bundle audit' or 'bundle-audit check' in your terminal",
        example_vulnerabilities: [
          {
            gem: "rails",
            version: "8.0.4",
            advisory: "Check https://rubysec.com for any advisories",
            severity: "varies"
          },
          {
            gem: "nokogiri",
            note: "Commonly has CVEs, check current version against advisories",
            resources: "https://github.com/sparklemotion/nokogiri/security/advisories"
          }
        ],
        recommended_tools: [
          "bundle-audit - https://github.com/rubysec/bundler-audit",
          "Dependabot - https://github.com/dependabot",
          "Snyk - https://snyk.io",
          "OWASP Dependency-Check"
        ]
      }
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end
end
