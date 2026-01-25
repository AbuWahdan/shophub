import 'package:flutter/material.dart';
import 'package:sinwar_shoping/src/widgets/title_text.dart';

import '../model/category.dart';
import '../themes/light_color.dart';
import '../themes/theme.dart';
import 'extentions.dart';

class ProductIcon extends StatelessWidget {
  // final String imagePath;
  // final String text;
  final ValueChanged<Categories>? onSelected;
  final Categories model;
  const ProductIcon({super.key, required this.model, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return model.id == null
        ? Container(width: 5)
        : Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child:
                Container(
                  padding: AppTheme.hPadding,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: model.isSelected
                        ? LightColor.background
                        : Colors.transparent,
                    border: Border.all(
                      color: model.isSelected
                          ? LightColor.orange
                          : LightColor.grey,
                      width: model.isSelected ? 2 : 1,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: model.isSelected
                            ? Color(0xfffbf2ef)
                            : Colors.white,
                        blurRadius: 10,
                        spreadRadius: 5,
                        offset: Offset(5, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      model.image != null
                          ? Image.asset(model.image!)
                          : SizedBox(),
                      model.name == null
                          ? Container()
                          : Container(
                              child: TitleText(
                                text: model.name,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                    ],
                  ),
                ).ripple(() {
                  onSelected?.call(model);
                }, borderRadius: BorderRadius.all(Radius.circular(10))),
          );
  }
}
