class HouseholdDecorator < Draper::Decorator
  delegate_all
  def transaction_type_i18n
    I18n.t("transaction_type.#{object.transaction_type}")
  end
end
