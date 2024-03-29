class ThirdPartyService
  def self.endpoints
    YAML.load_file(Rails.root.join('config', 'third_party_endpoints.yml'))['endpoints']
  end
end