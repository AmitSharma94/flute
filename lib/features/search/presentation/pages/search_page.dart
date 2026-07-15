import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../music/providers/music_provider.dart';
import '../../providers/search_provider.dart';


class SearchPage extends ConsumerWidget {

  const SearchPage({
    super.key,
  });


  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final songs =
        ref.watch(songsProvider);


    final query =
        ref.watch(searchQueryProvider);



    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Search',
        ),

      ),



      body: songs.when(

        data: (list) {


          final results =
              ref.watch(
                filteredSongsProvider(list),
              );


          return Column(

            children: [


              Padding(

                padding:
                    const EdgeInsets.all(12),


                child: TextField(

                  decoration:
                      const InputDecoration(

                    hintText:
                        'Search songs or artists',

                    prefixIcon:
                        Icon(Icons.search),

                    border:
                        OutlineInputBorder(),

                  ),



                  onChanged: (value) {

                    ref
                        .read(
                          searchQueryProvider
                              .notifier,
                        )
                        .updateQuery(value);

                  },



                  controller:
                      TextEditingController(
                        text: query,
                      ),

                ),

              ),



              Expanded(

                child: ListView.builder(

                  itemCount:
                      results.length,


                  itemBuilder:
                      (context, index) {


                    final song =
                        results[index];


                    return ListTile(

                      leading:
                          const Icon(
                            Icons.music_note,
                          ),


                      title:
                          Text(song.title),


                      subtitle:
                          Text(song.artist),


                    );

                  },

                ),

              ),

            ],

          );

        },


        error: (error, stack) {

          return Center(
            child:
                Text(error.toString()),
          );

        },


        loading: () {

          return const Center(
            child:
                CircularProgressIndicator(),
          );

        },

      ),

    );
  }
}