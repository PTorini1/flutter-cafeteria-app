import 'package:flutter/material.dart';
import 'package:lanchonet/models/enums.dart';
import 'package:lanchonet/models/fiado.dart';
import 'package:lanchonet/models/foods/ingredient.dart';
import 'package:lanchonet/pages/cadastro_page/cadastro_fiado.dart';
import 'package:lanchonet/pages/cadastro_page/cadastro_ingredientes.dart';
import 'package:lanchonet/pages/cadastro_page/cadastro_page.dart';
import 'package:lanchonet/pages/cadastro_page/cadastro_produtos.dart';
import 'package:lanchonet/pages/edita_page/editar_ingredientes.dart';
import 'package:lanchonet/pages/edita_page/editar_produtos.dart';
import 'package:lanchonet/pages/estoque_page/Ingredientes.dart';
import 'package:lanchonet/pages/estoque_page/estoque_detail.dart';
import 'package:lanchonet/pages/estoque_page/estoque_produtos_page.dart';
import 'package:lanchonet/pages/estoque_page/ingrediente_detail.dart';
import 'package:lanchonet/pages/favorite_page.dart';
import 'package:lanchonet/pages/fiados_page/fiados_detail_page.dart';
import 'package:lanchonet/pages/food_detail_page/food_detail_page.dart';
import 'package:lanchonet/pages/notify_page.dart';
import 'package:lanchonet/pages/pagamento_page/card_page.dart';
import 'package:lanchonet/pages/edita_page/editar_perfil.dart';
import 'package:lanchonet/pages/perfil_page/login_page.dart';
import 'package:lanchonet/pages/main_page.dart';
import 'package:lanchonet/pages/menu_page/menu_page.dart';
import 'package:lanchonet/pages/perfil_page/login_widget.dart';
import 'package:lanchonet/pages/popular_food_page.dart';
import 'package:lanchonet/pages/fiados_page/caderneta_page.dart';
import 'models/food.dart';

class FoodDeliveryRouter {

  static const detailIngrediente = "detailIngrediente";
  static const estoqueIngrediente = "ingredienteEstoque";
  static const editarIngrediente = "editarIngrediente";
  static const cadastroPerfil = "cadastroPerfil";
  static const cadastroProdutos = "cadastroProdutos";
  static const cadastroIngredientes = "cadastroIngredientes";
  static const cadastroFiado = "cadastroFiado";
  static const pagamento = "pagamento";
  static const estoqueProdutos = 'estoqueProdutos';
  static const cart = 'cart';
  static const detailPage = 'detail';
  static const favoritePage = 'favoritePage';
  static const login = "login";
  static const mainPage = 'mainPage';
  static const popularPage = "pop";
  static const menu = "menu";
  static const estoqueDetail = 'estoqueDetail';
  static const editarPerfil = 'editarPerfil';
  static const editarProdutos = 'editarProdutos';
  static const cadernetaPage = 'cadernetaPage';
  static const fiadosDetail = 'fiadosDetail';
  static const pedidos = 'pedidos';
  static Route onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case mainPage:
        return MaterialPageRoute<void>(builder: (_) => const MainPage());
      case cart:
        return MaterialPageRoute<void>(
          builder: (_) => const MainPage(
            initialIndex: 3,
          ),
        );
      case pedidos:
        return MaterialPageRoute<void>(
          builder: (_) => const ExpansionPage(),
        );
      case popularPage:
        return MaterialPageRoute<void>(
          builder: (_) => PopularFoodPage(
            currentFoodType: routeSettings.arguments as FoodType,
          ),
        );
      case pagamento:
        return MaterialPageRoute<void>(
          builder: (_) => CreditCard(),
        );
      case detailPage:
        return MaterialPageRoute<void>(
          builder: (_) => FoodDetailPage(
            food: routeSettings.arguments as Food,
          ),
        );
       case detailIngrediente:
        return MaterialPageRoute<void>(
          builder: (_) => IngredienteDetailPage(
            ingredient: routeSettings.arguments as Ingredient,
          ),
        );  
      case cadastroPerfil:
        return MaterialPageRoute<void>(
          builder: (_) => CadastroPage(),
        );
      case fiadosDetail:
        return MaterialPageRoute<void>(
            builder: (_) => FiadosDetailPage(
                  user: routeSettings.arguments as Fiado,
                ));
      case estoqueDetail:
        return MaterialPageRoute<void>(
            builder: (_) => EstoqueDetailPage(
                  food: routeSettings.arguments as Food,
                ));
      case menu:
        return MaterialPageRoute<void>(
          builder: (_) => const MenuPage(),
        );
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginWidget(),
        );
      case estoqueIngrediente:
        return MaterialPageRoute(
          builder: (_) => const IngredientesPage(),
        );
      case cadastroProdutos:
        return MaterialPageRoute(
          builder: (_) => CadastroProdutos(),
        );
      case cadastroFiado:
        return MaterialPageRoute(
          builder: (_) => CadastroFiado(),
        );
      case cadastroIngredientes:
        return MaterialPageRoute(
          builder: (_) => CadastroIngrediente());
      case favoritePage:
        return MaterialPageRoute(
          builder: (_) => const FavoritePage());
      case editarProdutos:
        return MaterialPageRoute(
            builder: (_) => EditarProdutos(
                  food: routeSettings.arguments as Food,
                ));
      case editarIngrediente:
        return MaterialPageRoute(
            builder: (_) => EditarIngrediente(
                  ingredient: routeSettings.arguments as Ingredient,
                ));
      case cadernetaPage:
        return MaterialPageRoute<void>(
          builder: (_) => CadernetaPage(),
        );
      case editarPerfil:
        return MaterialPageRoute(
          builder: (_) => PerfilPage(),
        );
      case estoqueProdutos:
        return MaterialPageRoute(
          builder: (_) => EstoqueProdutosPage(),
        );
      default: //per ora entra su login
        return MaterialPageRoute<void>(
          builder: (_) => LoginPage(),
        );
    }
  }
}
class Routes{
  static Map<String, Widget Function(BuildContext)> list = <String, WidgetBuilder>{
    '/home': (_) => const MainPage(),
    '/notificacao': (_) => const ExpansionPage(),
  };
  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}
