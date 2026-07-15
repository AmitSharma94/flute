import 'package:flutter/material.dart';

import '../../../history/presentation/widgets/recently_played.dart';


class HomePage extends StatelessWidget {

  const HomePage({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Flute',
        ),

        centerTitle: true,

      ),


      body: ListView(

        children: const [

          SizedBox(
            height: 20,
          ),


          RecentlyPlayed(),


          SizedBox(
            height: 20,
          ),


          Padding(

            padding:
                EdgeInsets.all(16),

            child: Text(

              'Welcome to Flute',

              style: TextStyle(

                fontSize: 28,

                fontWeight:
                    FontWeight.bold,

              ),

            ),

          ),

        ],

      ),

    );
  }
}