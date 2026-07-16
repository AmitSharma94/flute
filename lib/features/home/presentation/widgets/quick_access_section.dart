import 'package:flutter/material.dart';


class QuickAccessSection extends StatelessWidget {

  const QuickAccessSection({
    super.key,
  });



  @override
  Widget build(BuildContext context) {


    final items = [

      (
        icon: Icons.favorite,
        title: "Favorites",
      ),

      (
        icon: Icons.history,
        title: "Recently Played",
      ),

      (
        icon: Icons.album,
        title: "Albums",
      ),

      (
        icon: Icons.person,
        title: "Artists",
      ),

    ];



    return SizedBox(

      height: 100,


      child: ListView.builder(

        scrollDirection:
            Axis.horizontal,


        padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),



        itemCount:
            items.length,



        itemBuilder:
            (context, index) {


          final item =
              items[index];



          return Container(

            width:
                150,


            margin:
                const EdgeInsets.only(
                  right: 12,
                ),



            child:
                Card(

              elevation:
                  0,


              color:
                  Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,



              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(
                      20,
                    ),

              ),



              child:
                  Padding(

                padding:
                    const EdgeInsets.all(
                      16,
                    ),



                child:
                    Row(

                  children: [


                    Icon(

                      item.icon,

                      size:
                          28,


                      color:
                          Theme.of(context)
                              .colorScheme
                              .primary,

                    ),



                    const SizedBox(
                      width: 10,
                    ),



                    Expanded(

                      child:
                          Text(

                        item.title,


                        maxLines:
                            2,


                        overflow:
                            TextOverflow.ellipsis,


                        style:
                            const TextStyle(

                          fontWeight:
                              FontWeight.w600,

                        ),

                      ),

                    ),



                  ],

                ),

              ),

            ),

          );

        },

      ),

    );

  }

}