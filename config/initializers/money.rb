# encoding : utf-8

MoneyRails.configure do |config|

  # To set the default currency
  #
  # config.default_currency = :usd

  # Set default bank object
  #
  # Example:
  # config.default_bank = EuCentralBank.new

  # Add exchange rates to current money bank object.
  # (The conversion rate refers to one direction only)
  #
  # Example:
  # config.add_rate "USD", "CAD", 1.24515
  # config.add_rate "CAD", "USD", 0.803115

  # To handle the inclusion of validations for monetized fields
  # The default value is true
  #
  # config.include_validations = true

  # Default ActiveRecord migration configuration values for columns:
  #
  # config.amount_column = { prefix: '',           # column name prefix
  #                          postfix: '_cents',    # column name  postfix
  #                          column_name: nil,     # full column name (overrides prefix, postfix and accessor name)
  #                          type: :integer,       # column type
  #                          present: true,        # column will be created
  #                          null: false,          # other options will be treated as column options
  #                          default: 0
  #                        }
  #
  # config.currency_column = { prefix: '',
  #                            postfix: '_currency',
  #                            column_name: nil,
  #                            type: :string,
  #                            present: true,
  #                            null: false,
  #                            default: 'USD'
  #                          }
  config.currency_column = { prefix: '',
                             postfix: '_currency',
                             column_name: nil,
                             type: :string,
                             present: true,
                             null: false,
                             default: 'EU4TAX'
                           }

  # Register a custom currency
  #
  # Example:
  # config.register_currency = {
  #   :priority            => 1,
  #   :iso_code            => "EU4",
  #   :name                => "Euro with subunit of 4 digits",
  #   :symbol              => "€",
  #   :symbol_first        => true,
  #   :subunit             => "Subcent",
  #   :subunit_to_unit     => 10000,
  #   :thousands_separator => ".",
  #   :decimal_mark        => ","
  # }
  config.register_currency = {
    priority:            1,
    iso_code:            'EU4TAX',
    name:                'Euro with subunit of 4 digits (with tax)',
    symbol:              '€',
    symbol_first:        false,
    subunit:             'cent',
    subunit_to_unit:     10000,
    thousands_separator: '.',
    decimal_mark:        ',',
    no_cents_if_whole:  false,
  }
  config.register_currency = {
    priority:            2,
    iso_code:            'EU4NET',
    name:                'Euro with subunit of 4 digits',
    symbol:              '€',
    symbol_first:        false,
    subunit:             'cent',
    subunit_to_unit:     10000,
    thousands_separator: '.',
    decimal_mark:        ',',
    no_cents_if_whole:  false,
  }
  config.register_currency = {
    priority:            3,
    iso_code:            'EURTAX',
    name:                'Euro (with tax)',
    symbol:              '€',
    symbol_first:        false,
    subunit:             'cent',
    subunit_to_unit:     100,
    thousands_separator: '.',
    decimal_mark:        ',',
    no_cents_if_whole:  false,
  }
  config.register_currency = {
    priority:            4,
    iso_code:            'EURNET',
    name:                'Euro (net)',
    symbol:              '€',
    symbol_first:        false,
    subunit:             'cent',
    subunit_to_unit:     100,
    thousands_separator: '.',
    decimal_mark:        ',',
    no_cents_if_whole:  false,
  }
  config.register_currency = {
    priority:            5,
    iso_code:            'TAX',
    name:                'MwSt',
    symbol:              '€',
    symbol_first:        false,
    subunit:             'cent',
    subunit_to_unit:     100,
    thousands_separator: '.',
    decimal_mark:        ',',
    no_cents_if_whole:  false,
  }

  config.add_rate 'EU4TAX', 'EU4NET', (1 / 1.19)
  config.add_rate 'EU4NET', 'EU4TAX', 1.19
  config.add_rate 'EU4TAX', 'EURTAX', 1
  config.add_rate 'EU4NET', 'EURNET', 1
  config.add_rate 'EU4TAX', 'TAX', (1 / 0.19)
  config.add_rate 'EU4NET', 'TAX', 0.19

  config.default_currency = :eu4tax
  config.no_cents_if_whole = false

  # Set default money format globally.
  # Default value is nil meaning "ignore this option".
  # Example:
  #
  # config.default_format = {
  #   :no_cents_if_whole => nil,
  #   :symbol => nil,
  #   :sign_before_symbol => nil
  # }
  # config.default_format = {
  #   no_cents_if_whole:  false,
  #   symbol:             nil,
  #   sign_before_symbol: nil
  # }

  # Set default raise_error_on_money_parsing option
  # It will be raise error if assigned different currency
  # The default value is false
  #
  # Example:
  # config.raise_error_on_money_parsing = false
end

class Money
  def self.currencies
    {
      'netto'  => 'EU4NET',
      'brutto' => 'EU4TAX'
    }
  end
end
