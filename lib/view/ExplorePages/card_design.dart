import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/quotes_model.dart';
class CardDesign extends StatefulWidget {
  final List<Container> cards;
  final List<QuotesModel> quoteList;
  const CardDesign({
    super.key,
    required this.cards,
    required this.quoteList,
  });

  @override
  State<CardDesign> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<CardDesign> {
  final CardSwiperController controller = CardSwiperController();


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CardSwiper(
          controller: controller,
          cardsCount: widget.cards.length,
          duration: Durations.extralong1,
          maxAngle: 0,
          numberOfCardsDisplayed:1,
          onSwipe: _onSwipe,
          onUndo:  _onUndo,
          padding: const EdgeInsets.all(8.0),
          cardBuilder: (ctx, index, _, __) => Stack(
            children: [
              widget.cards[index],
              Positioned(
                top: 8, right: 8,
                child: IconButton(
                  icon: Icon(
                    widget.quoteList[index].isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.quoteList[index].isFavorite =
                      !widget.quoteList[index].isFavorite;
                    });
                  },
                ),
              ),
              Positioned(
                top: 8, left: 8,
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.blue),
                  onPressed: () {
                    final q = widget.quoteList[index];
                    Share.share(
                      '"${q.q}" — ${q.a}',
                      subject: 'Quote to share',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  bool _onSwipe(int prev, int? curr, CardSwiperDirection dir) {
    final quote = widget.quoteList[prev];

    if (dir == CardSwiperDirection.left) {
      Share.share(
        '"${quote.q}" — ${quote.a}',
        subject: 'Sharing a quote',
      );
    } else if (dir == CardSwiperDirection.right) {
      setState(() {
        quote.isFavorite = !quote.isFavorite;
      });
    }
    else if (dir == CardSwiperDirection.bottom) {
      setState(() {
        controller.undo();
      });
    }
    return true;
  }

  bool _onUndo(
      int? previousIndex,
      int currentIndex,
      CardSwiperDirection direction,
      ) {
    debugPrint(
      'The card $currentIndex was undod from the ${direction.name}',
    );
    return true;
  }
}
