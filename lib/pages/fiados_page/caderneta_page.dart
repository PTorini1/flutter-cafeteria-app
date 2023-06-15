import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanchonet/models/fiado.dart';
import 'package:provider/provider.dart';

import '../../dark_theme_widget/dark_theme_provider.dart';
import '../../models/user.dart';
import '../../services/theme_service.dart';

class CadernetaPage extends StatefulWidget {
  const CadernetaPage({super.key});

  @override
  State<CadernetaPage> createState() => _CadernetaPageState();
}

class _CadernetaPageState extends State<CadernetaPage> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Stream<List<Fiado>> readFiados() => FirebaseFirestore.instance
        .collection('fiados')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Fiado.fromMap(doc.data())).toList());
    final themeState = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Caderneta de fiados',
            style: Theme.of(context).textTheme.headline3,
          ),
          leading: BackButton(
            color: AppColor.primaryColor,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: StreamBuilder(
          stream: readFiados(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              final fiados = snapshot.data;
              return ListView.builder(
                itemCount: fiados!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () => Navigator.pushNamed(context, 'fiadosDetail',
                          arguments: fiados[index]),
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
                                  ? Color.fromARGB(255, 0, 0, 0)
                                      .withOpacity(0.5)
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
                              child: GestureDetector(
                                onTap:() {
                                   showDialog(context: context, builder: (context) {
                                    return AlertDialog(
                                      content: Image.network(fiados[index].caloteiro.getImageUrl),
                                    );
                                });
                              },
                                child: CircleAvatar(
                                radius: 35,
                                backgroundImage: NetworkImage(
                                fiados[index].caloteiro.getImageUrl),
                              ),) 
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fiados[index].caloteiro.getNome,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3
                                      ?.copyWith(
                                        fontSize: 18.0,
                                      ),
                                ),
                                Text(
                                  'Email.: ${fiados[index].caloteiro.getEmail}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3
                                      ?.copyWith(
                                        fontSize: 15.0,
                                      ),
                                ),
                                Text(
                                  'Valor: R\$${fiados[index].divida.toString()}',
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
                  // Text(
                  //   fiados[index].getname,
                  //   style: TextStyle(
                  //       fontSize: 18.0,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.black87),
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // Text(
                  //   'E.: ${fiados[index].getEmail}',
                  //   style: TextStyle(
                  //       fontSize: 15.0,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.black54),
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // Text(
                  //   'Valor: R\$${fiados[index].getdivida}',
                  //   style: TextStyle(
                  //       fontSize: 18.0,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.black54),
                  // ),
                },

                // @override
                // Widget build(BuildContext context) {
                //   return Scaffold(
                //     appBar: AppBar(
                //       title: Text(
                //         'Caderneta de viados',
                //         style: Theme.of(context).textTheme.headline3,
                //       ),
                //       backgroundColor: Colors.white,
                //       leading: BackButton(
                //         color: AppColor.primaryColor,
                //         onPressed: () {
                //           Navigator.of(context).pop();
                //         },
                //       ),
                //     ),
                //       body: SingleChildScrollView(
                //         child: Container(
                //           padding: EdgeInsets.all(10),
                //           child: Column(
                //             children: persons.map((personone) {
                //               return Card(
                //                 child: Container(
                //                   decoration: BoxDecoration(
                //                       shape: BoxShape.circle,
                //                       image: DecorationImage(
                //                           fit: BoxFit.cover,
                //                           image: NetworkImage(
                //                               'https://aaronturatv.ig.com.br/wp-content/uploads/2022/07/faustao-22-07.jpg'))),
                //                   child: ListTile(
                //                     title: Text(personone.nome),
                //                     subtitle: Text('R\$ ${personone.valorDevendo}'),
                //                     trailing: SizedBox(
                //                         width: 100,
                //                         height: 100,
                //                         child: Row(
                //                           children: <Widget>[
                //                             IconButton(
                //                               onPressed: () {},
                //                               icon: const Icon(Icons.edit),
                //                             ),
                //                             IconButton(
                //                               onPressed: () {},
                //                               icon: const Icon(Icons.delete),
                //                             )
                //                           ],
                //                         )),
                //                   ),
                //                 ),
                //               );
                //             }).toList(),
                //           ),
                //         ),
                //       ));
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}

// trailing: IconButton(
//   icon: const Icon(
//     Icons.edit,
//     color: AppColor.primaryColor,
//   ),
//   //remove element from the cart
//   onPressed: () {
//     //CartHandler.removeItem(food);
//     showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Alterar valor'),
//             content: TextField(
//               onChanged: (value) {},
//               decoration:
//                   InputDecoration(hintText: "Text Field in Dialog"),
//             ),
//           );
//         });
//   },
// ),

class Person {
  //modal class for Person object
  int id;
  String nome, telefone, img;
  double valorDevendo;
  Person(
      {required this.id,
      required this.img,
      required this.nome,
      required this.telefone,
      required this.valorDevendo});
}

// trailing: ElevatedButton(
//                         style:
//                             ElevatedButton.styleFrom(primary: Colors.redAccent),
//                         child: Icon(Icons.delete),
//                         onPressed: () {
//                           //delete action for this button
//                           persons.removeWhere((element) {
//                             return element.id == personone.id;
//                           }); //go through the loop and match content to delete from list
//                           setState(() {
//                             //refresh UI after deleting element from list
//                           });
//                         },
