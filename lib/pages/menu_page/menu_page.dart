import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/models/enums.dart';
import 'package:lanchonet/router.dart';
import 'package:provider/provider.dart';
import '../../common_widgets/food_box.dart';
import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../data/food_fake_data.dart';
import '../../models/food.dart';
import '../../services/theme_service.dart';
import '../estoque_page/estoque_produtos_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final List<FoodType> _foodTypes = FoodType.values;
  late FoodType currentFoodType;
  late List<Food> currentFoods = [];
  List<Food> allfoods = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _foodTypes.length, vsync: this);
    currentFoodType = FoodType.bebidas;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.red,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          StreamBuilder(
            stream: readProdutos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final produto = snapshot.data;
                if (allfoods.isEmpty) {
                  allfoods = produto!;
                }
                List<Food> nomes = [];
                List<Food> nomesatuais = [];
                for (var x in allfoods) {
                  nomes.add(x);
                  nomesatuais.add(x);
                }

                return IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: AppColor.primaryColor,
                  ),
                  onPressed: () {
                    final produtossearch = ProdutosSearch(
                        todosfoods: nomes, atuaisfoods: nomesatuais);
                    showSearch(context: context, delegate: produtossearch);
                  },
                );
              }
            },
          )
        ],
        title: Text(
          "Menu",
          style: Theme.of(context).textTheme.headline3,
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColor.primaryColor,
          indicatorColor: AppColor.primaryColor,
          tabs: _foodTypes
              .map(
                (foodType) => _buildTab(context, foodType),
              )
              .toList(),
        ),
      );

  Tab _buildTab(BuildContext context, FoodType foodType) {
    final String typeName = getFoodType(foodType);
    return Tab(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/$typeName.png"),
          ),
        ),
      ),
    );
  }

  _buildBody(BuildContext context) => SafeArea(
        child: TabBarView(
            controller: _tabController,
            children: _foodTypes
                .map((type) =>
                    _buildCurrentMenu(context, type, currentFoods, allfoods))
                .toList()),
      );

  Widget _buildCurrentMenu(BuildContext context, FoodType type,
      List<Food> currentFoods, List<Food> allfoods) {
    return StreamBuilder<List<Food>>(
        stream: FirebaseFirestore.instance
            .collection('produtos')
            .snapshots()
            .map((snapshot) =>
                snapshot.docs.map((doc) => Food.fromMap(doc.data())).toList()),
        builder: (context, snapshot) {
          List<Food> comidas = [];
          final produto = snapshot.data;
          if (produto != null) {
            for (var x = 0; x < produto.length; x++) {
              if (produto[x].foodType == type.toString()) {
                comidas.add(produto[x]);
              }
            }
          }
          return GridView(
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
          );
        });
  }
}

class ProdutosSearch extends SearchDelegate<Food> {
  final List<Food> todosfoods;
  final List<Food> atuaisfoods;

  ProdutosSearch({
    required this.todosfoods,
    required this.atuaisfoods,
  });

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: Icon(
            Icons.clear,
            color: AppColor.primaryColor,
          ),
          onPressed: () {
            query = '';
          },
        )
      ];

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColor.primaryColor,
        ),
        onPressed: () {
          Navigator.pop(context);
        });
  }

  Widget getResults(String query, List<Food> foods, BuildContext context) {
    Widget retorno = Center(
      child: Text("Sem Resultados", style: TextStyle(fontSize: 28)),
    );
    var foodconfirmed;
    var foodconfirmed2;
    for (var x in foods) {
      if (x.name.toLowerCase() == query.toLowerCase()) {
        foodconfirmed = x;
        break;
      } else if (x.name.toUpperCase().contains(query.toUpperCase()) &&
          query.isNotEmpty) {
        foodconfirmed2 = x;
        break;
      }
    }
    if (foodconfirmed == null && foodconfirmed2 == null) {
      retorno = Center(
        child: Text("Sem Resultados", style: TextStyle(fontSize: 28)),
      );
    } else if (foodconfirmed != null) {
      retorno = Scaffold(
          body: Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * .4,
                          child:
                              Image.network((foodconfirmed.image.toString())),
                        ),
                      ),

                      Text(foodconfirmed.name.toString(),
                          style: Theme.of(context).textTheme.headline3),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                          'Categoria: ' +
                              '"' +
                              foodconfirmed.foodType
                                  .toString()
                                  .substring(9)
                                  .capitalize(
                                      foodconfirmed.foodType.toString()) +
                              '"',
                          style: Theme.of(context).textTheme.headline3),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Preço: ' + foodconfirmed.price.toString(),
                          style: Theme.of(context).textTheme.headline3),
                      // SizedBox(
                      //   height: 5,
                      // ),
                      // Text(foodconfirmed.ingredients.toString(),
                      //     style: Theme.of(context).textTheme.headline3),
                      Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(bottom: 30),
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColor.primaryColor,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: SizedBox.expand(
                                        child: TextButton(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "Editar Informações",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              )
                                            ],
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, 'editarprodutos',
                                                arguments: foodconfirmed);
                                          },
                                        ),
                                      ))),
                            ]),
                      ),
                    ]),
              )));
    } else if (foodconfirmed2 != null) {
      retorno = Scaffold(
          body: Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * .4,
                          child:
                              Image.network((foodconfirmed2.image.toString())),
                        ),
                      ),

                      Text(foodconfirmed2.name.toString(),
                          style: Theme.of(context).textTheme.headline3),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                          'Categoria: ' +
                              '"' +
                              foodconfirmed2.foodType
                                  .toString()
                                  .substring(9)
                                  .capitalize(
                                      foodconfirmed2.foodType.toString()) +
                              '"',
                          style: Theme.of(context).textTheme.headline3),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Preço: ' + foodconfirmed2.price.toString(),
                          style: Theme.of(context).textTheme.headline3),
                      // SizedBox(
                      //   height: 5,
                      // ),
                      // Text(foodconfirmed.ingredients.toString(),
                      //     style: Theme.of(context).textTheme.headline3),
                      Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(bottom: 30),
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColor.primaryColor,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: SizedBox.expand(
                                        child: TextButton(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "Editar Informações",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              )
                                            ],
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, 'editarprodutos',
                                                arguments: foodconfirmed2);
                                          },
                                        ),
                                      ))),
                            ]),
                      ),
                    ]),
              )));
    }
    return retorno;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? atuaisfoods
        : todosfoods.where((element) {
            final foodLower = element.name.toLowerCase();
            final queryLower = query.toLowerCase();
            return foodLower.contains(queryLower);
          }).toList();

    if (query.isEmpty) {
      return buildNoSuggestions();
    }
    return buildSuggestionsSucess(suggestions);
  }

  Widget buildNoSuggestions() => ListView.builder(
        itemCount: atuaisfoods.length,
        itemBuilder: (context, index) {
          final suggestion = atuaisfoods[index];
          final queryText = suggestion.name.substring(0, query.length);
          final remainingText = suggestion.name.substring(query.length);
          final themeState = Provider.of<DarkThemeProvider>(context);
          return GestureDetector(
              onTap: () => Navigator.pushNamed(context, 'detail',
                  arguments: atuaisfoods[index]),
              child: Container(
                margin: const EdgeInsets.all(9),
                height: 100,
                decoration: BoxDecoration(
                  color: themeState.getDarktheme
                      ? Color.fromARGB(255, 46, 46, 46)
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: themeState.getDarktheme
                          ? Color.fromARGB(255, 0, 0, 0).withOpacity(0.5)
                          : Color.fromARGB(255, 170, 170, 170).withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    ),
                  ],
                  borderRadius: BorderRadius.all(
                    Radius.circular(7),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                            text: TextSpan(
                                text: queryText,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.copyWith(
                                      fontSize: 18.0,
                                    ),
                                children: [
                              TextSpan(
                                text: remainingText,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.copyWith(
                                        fontSize: 18.0, color: Colors.grey),
                              )
                            ])),
                      ],
                    ),
                  ],
                ),
              ));
        },
      );
  Widget buildSuggestionsSucess(List<Food> suggestions) => ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          final queryText = suggestion.name.substring(0, query.length);
          var remainingText = suggestion.name.substring(query.length);
          final themeState = Provider.of<DarkThemeProvider>(context);
          return GestureDetector(
              onTap: () => Navigator.pushNamed(context, 'detail',
                  arguments: suggestions[index]),
              child: Container(
                margin: const EdgeInsets.all(9),
                height: 100,
                decoration: BoxDecoration(
                  color: themeState.getDarktheme
                      ? Color.fromARGB(255, 46, 46, 46)
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: themeState.getDarktheme
                          ? Color.fromARGB(255, 0, 0, 0).withOpacity(0.5)
                          : Color.fromARGB(255, 170, 170, 170).withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    ),
                  ],
                  borderRadius: BorderRadius.all(
                    Radius.circular(7),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                            text: TextSpan(
                                text: queryText,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.copyWith(
                                      fontSize: 18.0,
                                    ),
                                children: [
                              TextSpan(
                                text: remainingText,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.copyWith(fontSize: 18.0),
                              )
                            ])),
                      ],
                    ),
                  ],
                ),
              ));
        },
      );

  @override
  Widget buildResults(
    BuildContext context,
  ) {
    return StreamBuilder(
      stream: readProdutos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final produto = snapshot.data;
        return getResults(query, produto!, context);
      },
    );
  }
}
