class DomainConstraint
  def initialize(subdomain)
    Rails.logger.info @subdomains
    @subdomains = [subdomain].flatten
  end

  def matches?(request)
    Rails.logger.info request.subdomain
    @subdomains.include? request.subdomain
  end
end
