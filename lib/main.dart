import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_route.dart';
import '../providers/auth.dart';
import '../screens/auth_screen.dart';
import '../screens/cart_screen.dart';
import '../providers/cart.dart';
//import '../providers/product.dart';
import '../providers/products_providers.dart';
import '../screens/products_overview_screen.dart';
import '../screens/product_detail_screen.dart';
import '../providers/orders.dart';
import '../screens/order_screen.dart';
import '../screens/user_products_screen.dart';
import '../screens/edit_product_screen.dart';
import '../screens/waiting_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          //create: (context) => Auth(_token, _expiryDate, _userId),
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products_Providers>(
          update: (context, auth, previousProducts) => Products_Providers(
              auth.token, auth.userId,
              prodItems:
                  previousProducts == null ? [] : previousProducts.prodItems),
          create: (context) => Products_Providers('', ''),
          // create: (context) => Products_Providers(
          //     Provider.of<Auth>(context, listen: false).toString()),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders(
            [],
            '',
            '',
          ),
          // create: (_) =>
          //     Orders([], Provider.of<Auth>(context, listen: false).toString()),
          update: (context, auth, previousOrders) => Orders(
            previousOrders == null ? [] : previousOrders.orders,
            auth.token ?? '',
            auth.userId ?? '',
          ),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'My Shop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato-Regular.ttf',
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomRoutePageTransitionBuilder(),
              TargetPlatform.iOS: CustomRoutePageTransitionBuilder(),
            }),
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const WaitingScreen()
                          : AuthScreen(),
                ),
          routes: {
            AuthScreen.routeName: (ctx) => AuthScreen(),
            ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrderScreen.routeName: (ctx) => OrderScreen(),
            UserProductScreen.routeName: (ctx) => UserProductScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
