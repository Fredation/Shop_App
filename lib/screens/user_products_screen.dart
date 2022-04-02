import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './edit_product_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/products_providers.dart';
import '../widgets/user_products_item.dart';

class UserProductScreen extends StatelessWidget {
  //const UserProductScreen({Key? key}) : super(key: key);
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products_Providers>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    //final dataProduct = Provider.of<Products_Providers>(context);
    print('...rebuilding');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products_Providers>(
                      builder: (ctx, dataProduct, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemBuilder: (ctx, index) => Column(
                            children: [
                              UserProductsItem(
                                dataProduct.items[index].id.toString(),
                                dataProduct.items[index].title,
                                dataProduct.items[index].imageUrl,
                              ),
                              const Divider(),
                            ],
                          ),
                          itemCount: dataProduct.items.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
