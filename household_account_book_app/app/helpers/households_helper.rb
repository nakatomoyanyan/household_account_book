module HouseholdsHelper
  def transaction_type_options
    Household.transaction_types.keys.map { |key| [I18n.t("transaction_type.#{key}"), key] }
  end
end
