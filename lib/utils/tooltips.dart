import 'package:epibox/decor/default_colors.dart';
import 'package:flutter/material.dart';

void onTooltipTap(GlobalKey key) {
  final dynamic tooltip = key.currentState;
  tooltip?.ensureTooltipVisible();
}

class CustomTooltip extends StatelessWidget {
  final String message;
  final GlobalKey<State<Tooltip>> tooltipKey;
  const CustomTooltip({Key key, this.message, this.tooltipKey,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: tooltipKey,
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      /* decoration: BoxDecoration(
                          color: DefaultColors.mainLColor,
                          borderRadius: BorderRadius.circular(4),
                        ), */
      message:
          message,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTooltipTap(tooltipKey),
        child: Icon(
          Icons.info_outline_rounded,
          color: DefaultColors.mainLColor,
        ),
      ),
    );
  }
}
