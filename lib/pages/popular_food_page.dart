import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/models/enums.dart';
import '../common_widgets/food_box.dart';
import '../models/food.dart';
import '../router.dart';
import '../services/theme_service.dart';
import 'food_detail_page/component/rounded_container.dart';

class PopularFoodPage extends StatelessWidget {
  final FoodType currentFoodType;
  final String foodTypeName;
  PopularFoodPage({
    Key? key,
    required this.currentFoodType,
  })  : foodTypeName =
            getFoodType(currentFoodType).capitalize(currentFoodType.toString()),
        super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context, currentFoodType),
      );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
          //if user changed favorite item -> rebuild previous page to see modify
         leading: BackButton(
          color: AppColor.primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "$foodTypeName Populares",
          style: Theme.of(context).textTheme.headline3,
        ),
        centerTitle: true,
      );

  _buildBody(BuildContext context, FoodType type) => StreamBuilder<List<Food>>(
        stream: FirebaseFirestore.instance
            .collection('produtos')
            .snapshots()
            .map((snapshot) =>
                snapshot.docs.map((doc) => Food.fromMap(doc.data())).toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Food> comidas = [];
          final produto = snapshot.data;
          if (produto != null) {
            for (var x = 0; x < produto.length; x++) {
              if (produto[x].foodType == type.toString() &&
                  produto[x].isPopular == true) {
                comidas.add(produto[x]);
              }
            }
          }
          return SafeArea(
            child: GridView(
              padding: const EdgeInsets.all(5.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
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
          );
        },
      );
}
