import 'package:flutter/material.dart';
import 'models/clothing_item.dart';
import 'theme.dart';

String fmtPrice(double n) => '${n.toStringAsFixed(2)} zł';

class ValueBadge {
  final String label;
  final Color color;
  final Color bgColor;
  ValueBadge(this.label, this.color, this.bgColor);
}

ValueBadge badgeForItem(ClothingItem item) {
  final cpw = item.costPerWear;
  if (cpw == null) {
    return ValueBadge('Jeszcze nie noszone', AppColors.wine, AppColors.wineSoft);
  }
  if (cpw < 5) {
    return ValueBadge('Świetna inwestycja', AppColors.sage, AppColors.sageSoft);
  }
  if (cpw < 20) {
    return ValueBadge('OK · ${fmtPrice(cpw)}/noszenie', AppColors.mustard, AppColors.mustardSoft);
  }
  return ValueBadge('Drogie · ${fmtPrice(cpw)}/noszenie', AppColors.wine, AppColors.wineSoft);
}
