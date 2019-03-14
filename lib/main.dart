import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());

final API_KEY = "Ldb1PHYH3ainOG3s5DdxgtxEX1O8hxkk";

Future<Response> fetchPost(String query, int offset) async {
  final response =
  await http.get('http://api.giphy.com/v1/gifs/search?api_key='
      + API_KEY +
      '&q=' + Uri.encodeFull(query) +
      '&offset=' + offset.toString());

  print (response.body);

  if (response.statusCode == 200) {
    return Response.fromJson(json.decode(response.body));
  } else {
    throw Exception('Request failed');
  }
}

class Response {
  final Pagination pagination;
  final Meta meta;
  final List<GifModel> models;

  Response({this.pagination, this.meta, this.models});

  factory Response.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<GifModel> models = list.map((i) => GifModel.fromJson(i)).toList();
    return Response(
      pagination: Pagination.fromJson(json['pagination']),
      meta: Meta.fromJson(json['meta']),
      models: models,
    );
  }

}

class Pagination {
  final int totalCount;
  final int count;
  final int offset;
  Pagination({this.totalCount, this.count, this.offset});
  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalCount: json['total_count'],
      offset: json['offset'],
      count: json['count'],
    );
  }
}

class Meta {
  final int status;
  final String msg;
  final String responseId;
  Meta({this.status, this.msg, this.responseId});
  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      status: json['status'],
      msg: json['msg'],
      responseId: json['response_id'],
    );
  }
}

class GifModel {
  final String type;
  final String id;
  GifModel({this.type, this.id});
  factory GifModel.fromJson(Map<String, dynamic> json) {
    return GifModel(
        type: json['type'],
        id: json['id'],
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget appBarTitle = new Text("Giphy searcher", style: new TextStyle(color: Colors.white),);
  Icon actionIcon = new Icon(Icons.search, color: Colors.white,);
  final TextEditingController _searchQuery = new TextEditingController();

  Future<Response> response;
  List<GifModel> models = new List();

  bool _searching = false;
  String playingId = null;

  _MyHomePageState() {

  }
  @override
  void dispose() {
    _searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
      future: response,
      builder: (context, snapshot) {
        Widget descriptionContainer = null;
        // snapshot holds data from previous request, so check both connection state and data.
        // currently it handles only 2 main states. Request state and "we have data state".

        String message = "";
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            message = snapshot.error;
          } else if (snapshot.data.models == null
          || snapshot.data.models.length < 1) {
            message = "There are no images to show";
          } else {
            if (snapshot.data.pagination.offset == 0) models.clear();

            if (snapshot.data.pagination.offset + snapshot.data.pagination.count != models.length)
              models.addAll(snapshot.data.models);
          }
        } else if (snapshot.connectionState == ConnectionState.none) {
          message = "Try to search something";
        }
        // we have to say something to our user
        if (snapshot.connectionState == ConnectionState.waiting) {
          // we should show spinner
          descriptionContainer = CircularProgressIndicator();
        } else {
          descriptionContainer = Text(
            "$message",
            textAlign: TextAlign.center,
            style: new TextStyle(
              fontSize: 16.0,
              decoration: TextDecoration.none,
              color: Colors.black,
            ),
          );
        }

        final gridContainer = Container (
          color: Colors.white,
          child: buildGrid(context, this.models),
        );
        return Stack(
          alignment: Alignment(0.0, 0.0),
          children: <Widget>[
            gridContainer,
            descriptionContainer,
          ],
        );
      },
    );
  }

  Widget buildGrid(BuildContext context, List<GifModel> models) {
    List<Widget> slivers = new List();
    slivers.add(buildBar(context));
    slivers.add(SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          // I've just used hardcore url construction not to parse all data I receive from giphy
          return GestureDetector(
            onTap: (){
              setState(() {
                playingId = models[index].id;
              });
            },
            child: Container(
              alignment: Alignment.center,
              child: Image.network( playingId == models[index].id ?
              "https://media.giphy.com/media/${models[index].id}/200w.gif" :
              "https://media.giphy.com/media/${models[index].id}/200w_s.gif",
              ),
            ),
          );
        },
        childCount: models != null ? models.length : 0,
      ),
    ));
    if (models.length > 0) {
      slivers.add(new SliverToBoxAdapter(
          child: new Container(
            height: 100.0,
            child:RaisedButton(
              onPressed: () {
                setState(() {
                  this.response = fetchPost(_searchQuery.text, this.models.length);
                });
              },
              child: const Text('Load more'),
            ),
          )));
    }
    return CustomScrollView(
      slivers: slivers,
    );
  }

  Widget buildBar(BuildContext context) {
    return new SliverAppBar(
        pinned: false,
        floating: true,
        snap: false,
        centerTitle: true,
        title: appBarTitle,
        actions: <Widget>[
          new IconButton(icon: actionIcon, onPressed: () {
            setState(() {
              if (_searching) {
                _handleSearchEnd();
              }
              else {
                _handleSearchStart();
              }
            });
          },),
        ]
    );
  }
  void _handleSearchStart() {
    setState(() {
      this.actionIcon = new Icon(Icons.close, color: Colors.white,);
      this.appBarTitle = new TextField(
        controller: _searchQuery,
        autofocus: true,
        onSubmitted: (String text){
          _handleSearchQuery();
        },
        style: new TextStyle(
          color: Colors.white,
        ),

        decoration: new InputDecoration(
          prefixIcon: new Icon(Icons.search, color: Colors.white),
          hintText: "Search...",
          hintStyle: new TextStyle(color: Colors.white),

        ),
      );
      _searching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(Icons.search, color: Colors.white,);
      this.appBarTitle = new Text("Giphy searcher", style: new TextStyle(color: Colors.white),);
      _searching = false;
    });
  }

  void _handleSearchQuery() {
    if (_searchQuery.text.isNotEmpty)
      setState(() {
        this.playingId = null;
        this.response = fetchPost(_searchQuery.text, 0);
      });
    _handleSearchEnd();
  }
}

