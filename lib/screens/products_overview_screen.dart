import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//import '../providers/products_providers.dart';
//import '../providers/product.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/products_providers.dart';
import '../providers/auth.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/products-overview';
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  //static const routeName = '/products-overview';
  //const ProductsOverviewScreen({ Key? key }) : super(key: key);
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    //Provider.of<Products_Providers>(context, listen: false).fetchAndSetProducts(); WONT WORK BECAUSE YOU CANT CALL PROVDER IN initState(), but setting listen to false and calling .then will make it work
    /*Future.delayed(Duration.zero).then((value) {
      Provider.of<Products_Providers>(context).fetchAndSetProducts();
    }); NB: Future.delayed also works as well as didChangeDependencies()*/
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products_Providers>(context)
          .fetchAndSetProducts()
          .then((value) {
        // setState(() {
        _isLoading = false;
        // });
      });
    }
    _isInit = false;
    // Provider.of<Auth>(context, listen: false).autoLogOut().then((value) {
    //   Navigator.popUntil(context, ModalRoute.withName('/'));
    //});
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final productsContainer = Provider.of<Products_Providers>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (FilterOptions selectedValue) {
              setState(
                () {
                  if (selectedValue == FilterOptions.favorites) {
                    _showOnlyFavorites = true;
                    //   productsContainer.showFavoritesOnly();
                  } else {
                    _showOnlyFavorites = false;
                    //  productsContainer.showAll();
                  }
                },
              );
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.favorites,
              ),
              const PopupMenuItem(
                child: Text('Show all Items'),
                value: FilterOptions.all,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (ctx, cartData, child) => Badge(
              // Colour: Color(Colors.black),
              Child: child as Widget,
              value: cartData.itemCount.toString(),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
