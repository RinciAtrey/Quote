import 'package:flutter/material.dart';

class Explorepage extends StatefulWidget {
  const Explorepage({super.key});

  @override
  _ExplorePage createState() => _ExplorePage();
}

class _ExplorePage extends State<Explorepage> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);
   return Scaffold(
        body: GridView.builder(
          itemCount: 7,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                 crossAxisSpacing: 12,
                 mainAxisSpacing: 12),

            itemBuilder: (context, index) {
              return Material(
                borderRadius: BorderRadius.circular(20),
                elevation: 5,
              );
            },),
   );

  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;



}

