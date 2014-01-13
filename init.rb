require 'uri'
require 'net/http'

class Heroku::Command::Domains < Heroku::Command::Base

  def add
    unless domain = shift_argument
      error("Usage: heroku domains:add DOMAIN\nMust specify DOMAIN to add.")
    end
    validate_arguments!
    action("Adding #{domain} to #{app}") do
      api.post_domain(app, domain)
    end
    display "Verify DNS settings with domains:verify"
  end

  def verify
    unless domain = shift_argument
      error("Usage: heroku domains:verify DOMAIN\nMust specify DOMAIN to verify.")
    end

    display ""

    _app_info = app_info(app)
    _ssl_endpoints = ssl_endpoints(app)

    result = []

    if _ssl_endpoints.size > 0
      if _app_info[:region] == 'eu'
        result << ['HTTP & HTTPS:', "Domain should CNAME/ALIAS #{_app_info[:domain]}"]
      else
        result << ['HTTP & HTTPS:', "Domain should CNAME/ALIAS #{_ssl_endpoints.first}"]
      end
    else
      result << ['HTTP:', "Domain should CNAME/ALIAS #{_app_info[:domain]}"]
      result << ['HTTPS:', "Not available on this domain.  Add an SSL:Endpoint."]
    end

    styled_array result

    if apex?(domain)
      display "Users of apex (root) domains should read https://devcenter.heroku.com/articles/apex-domains"
      display ""
    end

    action "Routing..." do
      if is_on_heroku?(domain)
        display "OK"
      else
        display "Error"
        display ""
        display "We could not resolve this domain to Heroku. Please check DNS settings and try again."
        display "https://devcenter.heroku.com/articles/custom-domains"
      end
    end
  end

  private

  def apex?(domain)
    domain.split('.').size == 2
  end

  def is_on_heroku?(domain)
    uri = URI.parse "http://radiocheck.herokuapp.com/check/#{domain}"
    radio_check = Net::HTTP.get(uri)
    radio_check == 'true'
  end

  def app_info(app)
    _info = api.get_app(app).body
    return {
          cedar: _info['stack'],
          region: _info['region'],
          domain: _info['domain_name']['domain']
        }
  end

  def ssl_endpoints(app)
    begin
      _info = heroku.ssl_endpoint_list(app)
    rescue
      return {}
    end
    _info.collect{|ep| ep["cname"]}
  end

end