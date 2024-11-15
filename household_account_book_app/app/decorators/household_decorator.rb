class HouseholdDecorator < Draper::Decorator
  delegate_all
  def transaction_type_options
    Household.transaction_types.keys.map { |key| [I18n.t("transaction_type.#{key}"), key] }
  end

  def transaction_type_in_japanese
    I18n.t("transaction_type.#{object.transaction_type}")
  end
end
