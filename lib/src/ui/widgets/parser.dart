double? parseDouble(
  dynamic value, [
  double? defaultValue,
]) {
  double? result;
  try {
    if (value is String) {
      if (value.toLowerCase() == 'infinity') {
        result = double.infinity;
      } else if (value.startsWith('0x') == true) {
        result = int.tryParse(value.substring(2), radix: 16)?.toDouble();
      } else {
        result = double.tryParse(value);
      }
    } else if (value is double) {
      result = value;
    } else if (value is int) {
      result = value.toDouble();
    }
  } catch (e) {
    return null;
  }

  return result ?? defaultValue;
}
