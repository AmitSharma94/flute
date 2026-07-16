import 'package:flutter/material.dart';


class QuickAccessSection extends StatelessWidget {

  const QuickAccessSection({
    super.key,
  });



  @override
  Widget build(BuildContext context) {


    final items = [

      (
        Icons.music_note,
        "Songs"
      ),

      (
        Icons.album,
        "Albums"
      ),

      (
        Icons.person,
        "Artists"
      ),

      (
        Icons.favorite,
        "Favorites"
      ),

    ];



    return SizedBox(

      height: 90,


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


          return Container(

            width:
                90,


            margin:
                const EdgeInsets.only(
                  right: 12,
                ),



            decoration:
                BoxDecoration(

              color:
                  Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,

              borderRadius:
                  BorderRadius.circular(
                    18,
                  ),

            ),



            child:
                Column(

              mainAxisAlignment:
                  MainAxisAlignment.center,


              children: [


                Icon(

                  items[index].$1,

                  size:
                      28,

                ),



                const SizedBox(
                  height: 6,
                ),



                Text(

                  items[index].$2,


                  style:
                      const TextStyle(

                    fontSize:
                        12,

                    fontWeight:
                        FontWeight.w600,

                  ),

                ),


              ],

            ),

          );


        },

      ),

    );

  }

}