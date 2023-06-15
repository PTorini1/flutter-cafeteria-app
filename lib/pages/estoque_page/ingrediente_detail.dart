import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/dark_theme_widget/dark_theme_provider.dart';
import '../../models/foods/ingredient.dart';
import '../../services/theme_service.dart';

class IngredienteDetailPage extends StatefulWidget {
  final Ingredient ingredient;
  const IngredienteDetailPage({
    Key? key,
    required this.ingredient,
  }) : super(key: key);

  @override
  State<IngredienteDetailPage> createState() => _IngredienteDetailPageState();
}

class _IngredienteDetailPageState extends State<IngredienteDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late final bool userChangeFavorite;

  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                            'Deseja Excluir ' '"' + widget.ingredient.name + '"?'),
                        content: Text(''),
                        actions: <Widget>[
                          MaterialButton(
                              child: Text('Sim'),
                              onPressed: () async {
                                final docUser = FirebaseFirestore.instance
                                    .collection('ingrediente')
                                    .doc(widget.ingredient.name);
                                docUser.delete();
                                Navigator.pushNamed(
                                  context,
                                  'estoque',
                                );
                              }),
                          MaterialButton(
                              child: Text('Não'),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ],
                      );
                    });
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ],
          title: Text(
            widget.ingredient.name,
            style: Theme.of(context).textTheme.headline3,
          ),
        ),
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
                        child:  (widget.ingredient.icon.toString() == '')
                                  ? Center(child: Text('Sem Imagem',
                                  style: TextStyle(fontSize: 16),),) 
                                  :  Image.network(
                                   widget.ingredient.icon.toString(),
                                   height: 70)
                      ),
                    ),

                    Text(widget.ingredient.name.toString(),
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
                                          children: <Widget> [
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
                                              arguments: widget.ingredient);
                                        },
                                      ),
                                    ))),
                          ]),
                    ),
                  ]),
            )));
  }
}
