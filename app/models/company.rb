# frozen_string_literal: true

## class company
class Company
  ATTRS = %w[name short address tax_info phone fax email legal_info ceo bank_info].freeze
  attr_reader(*ATTRS)

  def self.current
    new
  end

  def initialize
    comp = Setting.company
    return unless comp
    ATTRS.each do |attr|
      instance_variable_set "@#{attr}", comp[attr]&.strip
    end
  end

  def full_address
    [name, address.split("\n")].flatten
  end

  def contact_lines
    %w[name address tax_info].map { |set| send(set).strip }.join("\n")
  end

  def legal_info_lines
    items = [legal_info.strip]
    items << I18n.t(:ceo) + ': ' + ceo.strip
    items.join("\n")
  end

  def bank_info_lines
    bank_info.strip
  end
end
