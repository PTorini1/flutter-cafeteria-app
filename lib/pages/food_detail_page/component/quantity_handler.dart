import 'package:flutter/material.dart';
import 'package:lanchonet/services/theme_service.dart';
import 'package:provider/provider.dart';
import '../../../dark_theme_widget/dark_theme_provider.dart';
import 'rounded_container.dart';

class QuantityHandler extends StatefulWidget {
  final Function(int) onBtnTapped;
  const QuantityHandler({
    Key? key,
    required this.onBtnTapped,
  }) : super(key: key);

  @override
  State<QuantityHandler> createState() => _QuantityHandlerState();
}

class _QuantityHandlerState extends State<QuantityHandler> {
  int quantity = 1;
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, cons) {
        final themeState = Provider.of<DarkThemeProvider>(context);
        return Row(
          children: [
            RoundedContainer(
              child: GestureDetector(
                onTap: () => setState(() {
                  quantity++;
                  widget.onBtnTapped(quantity);
                }),
                child: FittedBox(
                  child: Icon(
                    Icons.add,
                    color: themeState.getDarktheme
                        ? Colors.white
                        : AppColor.titleTextColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                "$quantity",
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            RoundedContainer(
              child: GestureDetector(
                  onTap: quantity <= 0
                      ? null
                      : () {
                          quantity--;
                          widget.onBtnTapped(quantity);
                          setState(() {});
                        },
                  child: const FittedBox(
                    child: Icon(
                      Icons.remove,
                      color: AppColor.primaryColor,
                    ),
                  )),
            ),
          ],
        );
      });
}
