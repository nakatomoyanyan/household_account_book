module HouseholdsHelper
  include Ransack::Helpers::FormHelper
  def households_transahion_type_i18n_options
    Household.transaction_types.keys.map { |key| [I18n.t("transaction_type.#{key}"), key] }
  end
end
