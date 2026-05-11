double Convert(double amount, double fromCurrent, double toNow) {
  double result = (amount / fromCurrent) * toNow;

  return result;
}
