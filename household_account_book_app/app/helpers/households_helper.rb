module HouseholdsHelper
  def transaction_type_i18n_options_create
    Household.transaction_types.keys.map { |key| [I18n.t("transaction_type.#{key}"), key] }
  end
end
