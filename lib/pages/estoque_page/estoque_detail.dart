import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/dark_theme_widget/dark_theme_provider.dart';
import 'package:lanchonet/models/enums.dart';
import 'package:lanchonet/models/food.dart';
import '../../services/theme_service.dart';

class EstoqueDetailPage extends StatefulWidget {
  final Food food;
  const EstoqueDetailPage({
    Key? key,
    required this.food,
  }) : super(key: key);

  @override
  State<EstoqueDetailPage> createState() => _EstoqueDetailPageState();
}

class _EstoqueDetailPageState extends State<EstoqueDetailPage>
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
                            'Deseja Excluir ' '"' + widget.food.name + '"?'),
                        content: Text(''),
                        actions: <Widget>[
                          MaterialButton(
                              child: Text('Sim'),
                              onPressed: () async {
                                final docUser = FirebaseFirestore.instance
                                    .collection('produtos')
                                    .doc(widget.food.id);
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
                // final docUser = FirebaseFirestore.instance
                //     .collection('produtos')
                //     .doc(widget.food.id);
                // docUser.delete();
                // Navigator.pop(context);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ],
          title: Text(
            widget.food.name,
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
                        child: (widget.food.image.toString() == '')
                            ? Center(
                                child: Text(
                                  'Sem Imagem',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : Image.network(widget.food.image.toString(),
                                height: 70),
                      ),
                    ),

                    Text(widget.food.name.toString(),
                        style: Theme.of(context).textTheme.headline3),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                        'Categoria: ' +
                            '"' +
                            widget.food.foodType
                                .toString()
                                .substring(9)
                                .capitalize(widget.food.foodType.toString()) +
                            '"',
                        style: Theme.of(context).textTheme.headline3),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Preço: ' + widget.food.price.toString(),
                        style: Theme.of(context).textTheme.headline3),
                    Text('Quantidade: ' + widget.food.quantity.toString(),
                        style: Theme.of(context).textTheme.headline3),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    // Text(widget.food.ingredients.toString(),
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
                                              context, 'editarProdutos',
                                              arguments: widget.food);
                                        },
                                      ),
                                    ))),
                          ]),
                    ),
                  ]),
            )));
  }
}
