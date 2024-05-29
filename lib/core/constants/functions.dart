String getPaymentMethodEmoji(String paymentMethod, String cardLastdigits) {
  switch (paymentMethod) {
    case 'PaymentMethod.cash':
      return '💰 Cash';
    case 'PaymentMethod.creditCard':
      return '💳 Credit Card\n🔑Last 4 Digit: $cardLastdigits';
    case 'PaymentMethod.debitCard':
      return '💳 Debit Card\n🔑Last 4 Digit: $cardLastdigits';
    default:
      return '🤷‍♂️ Unknown';
  }
}

String getCategoryEmoji(String category) {
  switch (category) {
    case 'ExpenseCategory.general':
      return '🧾 General';
    case 'ExpenseCategory.school':
      return '🎓 School';
    case 'ExpenseCategory.health':
      return '⚕️ Health';
    case 'ExpenseCategory.grocery':
      return '🛒 Grocery';
    case 'ExpenseCategory.clothing':
      return '👕 Clothing';
    case 'ExpenseCategory.entertainment':
      return '🎉 Entertainment';
    case 'ExpenseCategory.other':
      return '🔍 Other';
    default:
      return '🤷‍♂️ Unknown';
  }
}
