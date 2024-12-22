import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_manager_app/models/media.dart';
import 'package:media_manager_app/services/rakuten_api.dart';

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

late final Future<Database> database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // データベースを開く
  database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'media_manager_database.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE media(id INTEGER PRIMARY KEY, type TEXT, title TEXT, released_at DATE, added_at DATE)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  runApp(const MyApp());
}

// media テーブルに insert する
Future<void> insertMedia(Media media) async {
  // Get a reference to the database.
  final db = await database;

  // Conflict が発生した場合、置き換える
  await db.insert(
    'media',
    media.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// media テーブルから全データを取得する
Future<List<Media>> listMedia() async {
  // Get a reference to the database.
  final db = await database;

  // media からrefetchMyMediazぜんけ取得するクエリ.
  final List<Map<String, Object?>> maps = await db.query('media');

  // 取得したデータをMediaに変換する
  return maps
      .map((v) => Media(
            id: v['id'] as int,
            type: MediaType.from(v['type'] as String),
            title: v['title'] as String,
            releasedAt: DateTime.parse(v['released_at'] as String),
            addedAt: DateTime.parse(v['added_at'] as String),
          ))
      .toList();
}

Future<void> updateMedia(Media media) async {
  // Get a reference to the database.
  final db = await database;

  // 引数のmediaで更新する
  await db.update(
    'media',
    media.toMap(),
    // IDで更新対象を特定する
    where: 'id = ?',
    whereArgs: [media.id],
  );
}

Future<void> deleteMedia(int id) async {
  // Get a reference to the database.
  final db = await database;

  // 引数idのmediaを削除する
  await db.delete(
    'media',
    // IDで削除対象を特定する
    where: 'id = ?',
    whereArgs: [id],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Media Manager App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var mediaList = <Media>[];

  void refetchMyMedia() async {
    listMedia().then((v) => mediaList = v);
    notifyListeners();
  }

  void clearMediaList() {
    mediaList.clear();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const MyMediaPage();
        break;
      case 2:
        page = const SearchPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('My Media'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.search),
                    label: Text('Search'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // media テーブルへ insert するデータ
                  var media = Media(
                    id: 0,
                    type: MediaType.dvd,
                    title: 'Flutterの冒険',
                    releasedAt: DateTime(1999, 3, 6),
                    addedAt: DateTime.now(),
                  );

                  insertMedia(media);
                  appState.refetchMyMedia();
                },
                child: const Text('Insert Flutterの冒険'),
              ),
              IconButton(
                onPressed: () {
                  // 0 のデータを削除
                  deleteMedia(0);
                  appState.refetchMyMedia();
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  var media = Media(
                    id: 1,
                    type: MediaType.dvd,
                    title: 'Flutterの冒険2',
                    releasedAt: DateTime(2000, 5, 9),
                    addedAt: DateTime.now(),
                  );

                  insertMedia(media);
                  appState.refetchMyMedia();
                },
                child: const Text('Insert Flutterの冒険2'),
              ),
              IconButton(
                onPressed: () {
                  // 1 のデータを削除
                  deleteMedia(1);
                  appState.refetchMyMedia();
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // updateするデータ
              var media = Media(
                id: 1,
                type: MediaType.bluray,
                title: 'Flutterの冒険3',
                releasedAt: DateTime(2012, 2, 6),
                addedAt: DateTime.now(),
              );

              updateMedia(media);
              appState.refetchMyMedia();
            },
            child: const Text('Update Flutterの冒険2 title'),
          ),
        ],
      ),
    );
  }
}

class MyMediaPage extends StatelessWidget {
  const MyMediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.mediaList.isEmpty) {
      return const Center(
        child: Text('No MyMedia yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.mediaList.length} mediaList:'),
        ),
        ...appState.mediaList.map((v) => ListTile(
              leading: const Icon(Icons.favorite),
              title: Text(v.title),
              subtitle: Text('''
ID: ${v.id}
MediaType: ${v.type.displayName}
ReleaseDate: ${v.releasedAt.toLocal().toIso8601String()}
AddedDate: ${v.addedAt.toLocal().toIso8601String()}
'''),
            ))
      ],
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // 検索入力フィールドのコントローラー
  final _searchController = TextEditingController();

  List<dynamic> _searchResults = [];
  bool _searchError = false;

  bool _isLoading = false;

  /// 楽天APIを使って検索を実行する関数.
  /// 検索中は _isLoading に true を設定する
  /// 検索結果を _searchResults に格納する
  void _performSearch() async {
    // 検索開始時にローディング状態をtrueに設定
    setState(() {
      _isLoading = true;
    });

    _searchError = false;

    try {
      // 楽天APIを呼び出して検索結果を取得
      final results = await RakutenAPI.searchItems(_searchController.text);
      // 検索結果を状態に反映
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      // エラーが発生した場合にエラーメッセージを出力
      _searchResults = [];
      _searchError = true;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search DVDs/Blu-rays'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 検索入力フィールド
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
              ),
            ),
            // ローディング中はプログレスインジケーターを表示
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_searchError)
              const Text("エラーが発生しました")
            else
              // ローディング中以外は検索結果を表示
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return ListTile(
                      title: Text(item['title']), //< 作品タイトル
                      subtitle: Text(item['salesDate']), //< 販売日
                      leading: Image.network(item['mediumImageUrl']), //< 商品画像
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
