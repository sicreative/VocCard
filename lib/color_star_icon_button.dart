import 'package:flutter/material.dart';
import 'db.dart';
import 'common_helper.dart';

class ColorStarIconButton extends StatelessWidget{

  final VocCard card;
  final State state;
  final bool isUpdateDB;


  const ColorStarIconButton({
    required this.card,
    required this.state,
    this.isUpdateDB=true,

  });
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        card.colorlabel==0?Icons.star_outline_rounded:Icons.star_rounded,
        color: card.colorlabel==0?Colors.grey:colorlabel_colors[card.colorlabel!],
        size: 24,
      ),
      onPressed: () {

        state.setState(() {
          card.colorlabel = card.colorlabel!+1;
          if (card.colorlabel!>=colorlabel_colors.length)
            card.colorlabel=0;

          if(isUpdateDB)
            Db.updateCard(card);


        });
      },
    );
  }

}

