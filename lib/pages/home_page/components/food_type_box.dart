import 'package:flutter/material.dart';
import 'package:lanchonet/models/enums.dart';
import 'package:provider/provider.dart';
import '../../../dark_theme_widget/dark_theme_provider.dart';
import '../../../services/theme_service.dart';

class FoodTypeBox extends StatefulWidget {
  final FoodType foodType;
  final bool isSelected;
  final VoidCallback onItemSelected;
  const FoodTypeBox({
    Key? key,
    required this.foodType,
    required this.onItemSelected,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<FoodTypeBox> createState() => _FoodTypeBoxState();
}

class _FoodTypeBoxState extends State<FoodTypeBox> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  late final String typeName;
  late final String typeName2;

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
    typeName2 = getFoodType(widget.foodType).capitalize(widget.foodType.toString());
    typeName = getFoodType(widget.foodType);
    print(typeName);
  }

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            widget.onItemSelected();
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Material(
              type: MaterialType.card,
              elevation: 3.0,
              color: themeState.getDarktheme
                  ? (widget.isSelected
                      ? AppColor.primaryColor
                      : Color.fromARGB(255, 66, 66, 66))
                  : (widget.isSelected
                      ? AppColor.primaryColor
                      : Color.fromARGB(255, 255, 255, 255)),
              // color: widget.,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //icona immagine,
                  Container(
                    height: constraints.maxHeight * 0.3,
                    width: constraints.maxWidth * 0.5,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage("assets/images/$typeName.png"),
                    )),
                  ),
                  Text(
                    typeName2,
                    style: Theme.of(context).textTheme.headline1?.copyWith(
                          color: themeState.getDarktheme
                              ? (widget.isSelected
                                  ? Color.fromARGB(255, 255, 255, 255)
                                  : Color.fromARGB(255, 255, 255, 255))
                              : (widget.isSelected
                                  ? Color.fromARGB(255, 255, 255, 255)
                                  : AppColor.titleTextColor),
                        ),
                  ),
                  Container(
                    height: constraints.maxHeight * 0.2,
                    width: constraints.maxHeight * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isSelected
                          ? Colors.white
                          : AppColor.primaryColor,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                      color: widget.isSelected
                          ? AppColor.primaryColor
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
