import 'dart:io';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/models/enums.dart';
import 'package:lanchonet/models/food.dart';
import 'package:lanchonet/services/theme_service.dart';
import 'package:provider/provider.dart';
import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../data/food_fake_data.dart';
import 'MenuItems.dart';

class EstoqueProdutosPage extends StatefulWidget {
  const EstoqueProdutosPage({super.key});

  @override
  State<EstoqueProdutosPage> createState() => _EstoqueProdutosPageState();
}

class _EstoqueProdutosPageState extends State<EstoqueProdutosPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late final List<FoodType> _foodTypes = FoodType.values;
  late FoodType currentFoodType;
  late List<Food> currentFoods = [];
  List<Food> allfoods = [];
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _foodTypes.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context, currentFoods),
      );

  _buildBody(BuildContext context, List<Food> currentFoods) => SafeArea(
        child: TabBarView(
            controller: _tabController,
            children: _foodTypes
                .map((type) =>
                    _buildCurrentMenu(context, type, currentFoods, allfoods))
                .toList()),
      );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
        title: Text(
          "Gerenciar Produtos",
          style: Theme.of(context).textTheme.headline3,
        ),
        leading: BackButton(
          color: AppColor.primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
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
              } else if (snapshot.hasError) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final produto = snapshot.data;
              allfoods = produto!;
              return PopupMenuButton<MenuItem>(
                  onSelected: (item) => setState(() {
                        onSelected(context, item, allfoods);
                      }),
                  icon: const Icon(
                    Icons.more_vert_outlined,
                    color: AppColor.primaryColor,
                  ),
                  itemBuilder: (context) => [
                        ...MenuItems.primeiro.map(buildItem).toList(),
                        const PopupMenuDivider(),
                        ...MenuItems.segundo.map(buildItem).toList(),
                      ]);
            },
          ),
          StreamBuilder(
            stream: readProdutos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
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
                    setState(() {
                      final produtossearch = ProdutosSearch(
                          todosfoods: nomes, atuaisfoods: nomesatuais);
                      showSearch(
                        context: context,
                        delegate: produtossearch,
                      );
                    });
                  },
                );
              }
            },
          )
        ],
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: Theme.of(context).textTheme.headline3,
          indicatorColor: AppColor.primaryColor,
          tabs: _foodTypes
              .map(
                (foodType) => _buildTab(context, foodType),
              )
              .toList(),
        ),
      );
}

PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem(
    value: item,
    child: Row(children: [
      Icon(
        item.icon,
        size: 15,
        color: AppColor.primaryColor,
      ),
      const SizedBox(
        width: 12,
      ),
      Text(item.text),
    ]));
Future<void> onSelected(
    BuildContext context, MenuItem item, List<Food> allfoods) async {
  switch (item) {
    case MenuItems.itemIngredientes:
      Navigator.pushNamed(context, 'ingredienteEstoque');
      break;
    case MenuItems.itemRelatorio:
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Estoque'];

      sheetObject.cell(CellIndex.indexByString('A1')).value = 'Produtos';
      sheetObject.cell(CellIndex.indexByString('B1')).value = 'Preço';
      sheetObject.cell(CellIndex.indexByString('C1')).value = 'Quantidade';
      sheetObject.cell(CellIndex.indexByString('D1')).value = 'Ingredientes';
      sheetObject.cell(CellIndex.indexByString('E1')).value = 'Categoria';

      for (int i = 0; i < allfoods.length; i++) {

        sheetObject.cell(CellIndex.indexByString('A${i+2}')).value = allfoods[i].name;

        sheetObject.cell(CellIndex.indexByString('B${i+2}')).value =  allfoods[i].price;
        
        sheetObject.cell(CellIndex.indexByString('C${i+2}')).value = allfoods[i].quantity;;
        
        var ingredientesProduto = sheetObject.cell(CellIndex.indexByString('D${i+2}'));
        String tipoComida = '';

        for(int x = 0; x<allfoods[i].ingredients.length;x++){
          String ingredient = allfoods[i].ingredients[x].name;
          if(tipoComida.trim().isEmpty || tipoComida.isEmpty){
            tipoComida = ingredient; 
          }else{
            tipoComida = '$tipoComida , $ingredient';
          }
        }

        ingredientesProduto.value = tipoComida;
        sheetObject.cell(CellIndex.indexByString('E${i+2}')).value = allfoods[i].foodType.capitalize(allfoods[i].foodType);
      }

      var fileBytes = excel.save();

      File(join('/storage/emulated/0/Download/Estoque.xlsx'))
        ..create(recursive: true)
        ..writeAsBytes(fileBytes!);
      break;
    case MenuItems.maior:
      allfoods.sort((a, b) => b.quantity.compareTo(a.quantity));
      break;
    case MenuItems.menor:
      allfoods.sort((a, b) => a.quantity.compareTo(b.quantity));
      break;
  }
}

Widget _buildCurrentMenu(BuildContext context, FoodType type,
    List<Food> currentFoods, List<Food> allfoods) {
  final themeState = Provider.of<DarkThemeProvider>(context);
  return StreamBuilder(
    stream: readProdutos(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (snapshot.hasError) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      final produto = snapshot.data;
      List<Food> comidas = [];
      if (produto != null) {
        if (allfoods.isEmpty) {
          allfoods = produto;
        }
        for (var x = 0; x != allfoods.length; x++) {
          if (allfoods[x].foodType == type.toString()) {
            comidas.add(allfoods[x]);
          } else {
            comidas.remove(allfoods[x]);
          }
        }
        currentFoods = comidas;
      }
      return ListView.builder(
        itemCount: currentFoods.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () => Navigator.pushNamed(context, 'estoqueDetail',
                  arguments: currentFoods[index]),
              child: Container(
                margin: EdgeInsets.all(9),
                height: 100,
                decoration: BoxDecoration(
                  color: themeState.getDarktheme
                      ? Color.fromARGB(255, 46, 46, 46)
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: themeState.getDarktheme
                          ? Color.fromARGB(255, 0, 0, 0).withOpacity(0.5)
                          : Colors.grey.withOpacity(0.5),
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
                    Padding(
                        padding: EdgeInsets.only(left: 2),
                        child: (currentFoods[index].image.toString() == '')
                            ? Text(
                                'Sem Imagem',
                                style: TextStyle(fontSize: 16),
                              )
                            : Image.network(
                                currentFoods[index].image.toString(),
                                height: 70,
                              )),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentFoods[index].name,
                          style:
                              Theme.of(context).textTheme.headline3?.copyWith(
                                    fontSize: 18.0,
                                  ),
                        ),
                        Text(
                          currentFoods[index]
                              .foodType
                              .toString()
                              .substring(9)
                              .capitalize(comidas[index].foodType),
                          style:
                              Theme.of(context).textTheme.headline3?.copyWith(
                                    fontSize: 15.0,
                                  ),
                        ),
                        Text(
                          'Preço: ${currentFoods[index].price}',
                          style:
                              Theme.of(context).textTheme.headline3?.copyWith(
                                    fontSize: 15.0,
                                  ),
                        ),
                        Text(
                          'Quantidade: ${currentFoods[index].quantity}',
                          style:
                              Theme.of(context).textTheme.headline3?.copyWith(
                                    fontSize: 15.0,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ));
        },
      );
    },
  );
}

Tab _buildTab(BuildContext context, FoodType foodType) {
  final String typeName = getFoodType(foodType);
  return Tab(
    child: FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(
        foodType.name,
        style: Theme.of(context).textTheme.headline3,
      ),
    ),
  );
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
              onTap: () => Navigator.pushNamed(context, 'estoqueDetail',
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
              onTap: () => Navigator.pushNamed(context, 'estoqueDetail',
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
