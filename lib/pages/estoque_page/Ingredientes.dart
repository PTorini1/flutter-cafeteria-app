import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/models/enums.dart';
import 'package:lanchonet/models/foods/ingredient.dart';
import 'package:lanchonet/services/theme_service.dart';
import 'package:provider/provider.dart';
import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../data/food_fake_data.dart';

class IngredientesPage extends StatefulWidget {
  const IngredientesPage({super.key});

  @override
  State<IngredientesPage> createState() => _IngredientesPageState();
}

class _IngredientesPageState extends State<IngredientesPage> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Stream<List<Ingredient>> readIngredientes() => FirebaseFirestore.instance
        .collection('ingrediente')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ingredient.fromJson(doc.data()))
            .toList());
    final themeState = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
        appBar: _buildAppBar(context),
        body: StreamBuilder(
          stream: readIngredientes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final ingredientes = snapshot.data;
            return ListView.builder(
              itemCount: ingredientes!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, 'detailIngrediente',
                        arguments: ingredientes[index]),
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
                              child: (ingredientes[index].icon.toString() == '')
                                  ? Text(
                                      'Sem Imagem',
                                      style: TextStyle(fontSize: 16),
                                    )
                                  : Image.network(
                                      ingredientes[index].icon.toString(),
                                      height: 70)),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ingredientes[index].name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.copyWith(
                                      fontSize: 18.0,
                                    ),
                              ),
                              Text(
                                'Quantidade no Estoque: ${ingredientes[index].quantity}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.copyWith(
                                      fontSize: 18.0,
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
        ));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
        title: Text(
          "Gerenciar Ingrediente",
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
            stream: readIngredientes(),
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
                List<Ingredient> nomes = [];
                List<Ingredient> nomesatuais = [];
                if (produto != null) {
                  for (var x in produto) {
                    nomes.add(x);
                    nomesatuais.add(x);
                  }
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
                      showSearch(context: context, delegate: produtossearch);
                    });
                  },
                );
              }
            },
          )
        ],
        centerTitle: true,
      );
}

class ProdutosSearch extends SearchDelegate<Ingredient> {
  final List<Ingredient> todosfoods;
  final List<Ingredient> atuaisfoods;

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

  Widget getResults(
      String query, List<Ingredient> foods, BuildContext context) {
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
      retorno = Padding(
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
                        child: (foodconfirmed.icon.toString() == '')
                            ? Center(
                                child: Text(
                                  'Sem Imagem',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : Image.network(foodconfirmed.icon.toString(),
                                height: 70)),
                  ),
                  Text(foodconfirmed.name.toString(),
                      style: Theme.of(context).textTheme.headline3),
                  const SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 30),
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 40,
                                  decoration: const BoxDecoration(
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
                                            context, 'editarIngrediente',
                                            arguments: foodconfirmed);
                                      },
                                    ),
                                  ))),
                        ]),
                  ),
                ]),
          ));
    } else if (foodconfirmed2 != null) {
      retorno = Padding(
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
                        child: (foodconfirmed2.icon.toString() == '')
                            ? Center(
                                child: Text(
                                  'Sem Imagem',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : Image.network(foodconfirmed2.icon.toString(),
                                height: 70)),
                  ),
                  Text(foodconfirmed2.name.toString(),
                      style: Theme.of(context).textTheme.headline3),
                  const SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 30),
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 40,
                                  decoration: const BoxDecoration(
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
                                            context, 'editarIngrediente',
                                            arguments: foodconfirmed2);
                                      },
                                    ),
                                  ))),
                        ]),
                  ),
                ]),
          ));
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
  Widget buildSuggestionsSucess(List<Ingredient> suggestions) =>
      ListView.builder(
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
      stream: readIngredientes(),
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
