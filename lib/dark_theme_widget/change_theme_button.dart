import 'package:flutter/material.dart';
import 'package:lanchonet/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'dark_theme_provider.dart';

class ChangeThemeButton extends StatelessWidget {
  const ChangeThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    return Switch(
      onChanged: (bool value) {
        themeState.setDarkTheme = value;
      },
      value: themeState.getDarktheme,
      activeTrackColor: AppColor.titleTextColor,
      activeColor: Color.fromARGB(255, 9, 34, 80),
      activeThumbImage: NetworkImage(
          "https://th.bing.com/th/id/R.4360a808e505157b723acef639e2d007?rik=hHfh1tq9Awk9XA&riu=http%3a%2f%2floveferrari.l.o.pic.centerblog.net%2f05aeef4f.png&ehk=aLW6ZO2%2f5h51dGVsS6%2fTYr46kcdm%2bD61fE3tVFrnkcM%3d&risl=&pid=ImgRaw&r=0"),
    );
  }
}
