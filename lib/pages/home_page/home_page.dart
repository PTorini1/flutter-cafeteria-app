import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/models/enums.dart';
import 'package:lanchonet/models/food.dart';
import 'package:lanchonet/pages/home_page/components/food_type_box.dart';
import 'package:lanchonet/router.dart';
import 'package:lanchonet/services/theme_service.dart';
import '../../common_widgets/food_box.dart';
import '../../responsive_widget/responsive_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _buildGridView(
          BuildContext context, int crossAxisCount, List<Food> comidas) =>
      GridView(
        padding: const EdgeInsets.all(5.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        children: comidas
            .map((food) => FoodBox(
                food: food,
                onNavigate: () {
                  Navigator.of(context).pushNamed(FoodDeliveryRouter.detailPage,
                      arguments: food);
                }))
            .toList(),
      );
  FoodType _selectedFoodType = FoodType.lanches;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Food>>(
        stream: FirebaseFirestore.instance
            .collection('produtos')
            .snapshots()
            .map((snapshot) =>
                snapshot.docs.map((doc) => Food.fromMap(doc.data())).toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: const CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            List<Food> comidas = [];
            for (var x in snapshot.data!) {
              if (snapshot.hasData &&
                  x.foodType == _selectedFoodType.toString() &&
                  x.isPopular == true) {
                comidas.add(x);
              }
            }
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Categorias",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  //food type
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: FoodType.values
                          .map((type) => FoodTypeBox(
                                foodType: type,
                                isSelected: _selectedFoodType == type,
                                onItemSelected: () =>
                                    setState(() => _selectedFoodType = type),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mais Populares",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          FoodDeliveryRouter.popularPage,
                          arguments: _selectedFoodType,
                        ),
                        child: const Text(
                          "Ver Todos",
                          style: TextStyle(
                            color: AppColor.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Expanded(
                      child: SizedBox(
                    child: ResponsiveWidget(
                      mobileWidget: ListView(
                        scrollDirection: Axis.horizontal,
                        children: comidas
                            .map((food) => FoodBox(
                                food: food,
                                onNavigate: () {
                                  Navigator.of(context).pushNamed(
                                      FoodDeliveryRouter.detailPage,
                                      arguments: food);
                                }))
                            .toList(),
                      ),
                      tabletWidget: _buildGridView(context, 2, comidas),
                      webWidget: _buildGridView(context, 3, comidas),
                    ),
                  ))
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
