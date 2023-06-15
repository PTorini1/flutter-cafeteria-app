import 'package:flutter/material.dart';

import '../models/food.dart';
import '../services/theme_service.dart';

//widget usato da home_page (elementi della list view in basso)
//e da favorite page (elementi della grid view)
class FoodBox extends StatelessWidget {
  final Food food;
  final VoidCallback onNavigate;
  const FoodBox({
    Key? key,
    required this.food,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: InkWell(
            onDoubleTap: () => onNavigate(),
            child: Material(
              type: MaterialType.card,
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: LayoutBuilder(
                builder: (context, cons) => Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //food image
                    Container(
                      width: cons.maxWidth * 0.8,
                      height: cons.maxHeight * 0.6,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(food.image),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    //image name
                    FittedBox(
                      child: Text(
                        food.name,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                    //mini description

                    //prezzo
                    Text(
                      "R\$ ${food.price}",
                      style: const TextStyle(
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
