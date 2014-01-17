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
    display ""
    dns_advice(app, domain)
  end

  def dns
    unless domain = shift_argument
      error("Usage: heroku domains:add DOMAIN\nMust specify DOMAIN to get.")
    end
    validate_arguments!
    dns_advice(app, domain)
  end

  private

  def alias_type(domain)
    apex?(domain) ? "ALIAS" : "CNAME"
  end

  def dns_advice(app, domain)
    _app_info = app_info(app)
    _ssl_endpoints = ssl_endpoints(app)

    result = []

    if _ssl_endpoints.size > 0
      if _app_info[:region] == 'eu'
        result << ['HTTP & HTTPS:', "Domain should #{alias_type(domain)} #{_app_info[:domain]}"]
      else
        result << ['HTTP & HTTPS:', "Domain should #{alias_type(domain)} #{_ssl_endpoints.first}"]
      end
    else
      result << ['HTTP:', "Domain should #{alias_type(domain)} #{_app_info[:domain]}"]
      result << ['HTTPS:', "Not enabled on this domain.  Add an SSL:Endpoint."]
    end

    styled_array result

    if apex?(domain)
      display "Users of apex (root) domains should read https://devcenter.heroku.com/articles/apex-domains"
    end
  end

  def apex?(domain)
    uri = URI.parse("http://dominion-dns.herokuapp.com/base/#{domain}")
    base_domain = Net::HTTP.get(uri)
    domain == base_domain
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
