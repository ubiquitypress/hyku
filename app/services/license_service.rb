# overrides hyrax/app/services/hyrax/license_service.rb

module LicenseService
  mattr_accessor :authority
  self.authority = Qa::Authorities::Local.subauthority_for('licenses')

  def self.active?(id)
    authority.find(id).fetch('term', nil )
  end

  def self.active_elements
    authority.all.select { |e| e.fetch('active') }
  end

  def self.label(id)
    authority.find(id).fetch('term', '[Error: Unknown value]' )
  end

  def self.select_active_options
    active_elements.map { |e| [e[:label], e[:id]] }
  end

  def self.include_current_value(value, _index, render_options, html_options)
    unless value.blank? || active?(value)
      html_options[:class] << ' force-select'
      render_options += [[label(value), value]]
    end
    [render_options, html_options]
  end

end
