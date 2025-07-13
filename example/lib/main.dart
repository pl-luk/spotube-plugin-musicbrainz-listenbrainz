import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:example/form.dart';
import 'package:example/localstorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hetu_script/hetu_script.dart';
import 'package:hetu_spotube_plugin/hetu_spotube_plugin.dart';
import 'package:hetu_std/hetu_std.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (runWebViewTitleBarWidget(args)) {
    return;
  }

  final hetu = Hetu();
  getIt.registerSingleton<Hetu>(hetu);
  getIt.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );

  hetu.init();
  HetuStdLoader.loadBindings(hetu);

  await HetuStdLoader.loadBytecodeFlutter(hetu);
  await HetuSpotubePluginLoader.loadBytecodeFlutter(hetu);
  final byteCode = await rootBundle.load("assets/bytecode/plugin.out");
  await hetu.loadBytecode(
    bytes: byteCode.buffer.asUint8List(),
    moduleName: "plugin",
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: MyHome()));
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  void initState() {
    super.initState();
    final hetu = getIt<Hetu>();
    BuildContext? pageContext;
    HetuSpotubePluginLoader.loadBindings(
      hetu,
      localStorageImpl: SharedPreferencesLocalStorage(
        getIt<SharedPreferences>(),
      ),
      onNavigatorPush: (route) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              pageContext = context;
              return Scaffold(
                appBar: AppBar(title: const Text('WebView')),
                body: route,
              );
            },
          ),
        );
      },
      onNavigatorPop: () {
        if (pageContext == null) {
          return;
        }
        Navigator.pop(pageContext!);
      },
      onShowForm: (title, fields) {
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return FormPage(title: title, fields: fields);
            },
          ),
        );
      },
    );

    hetu.eval(r"""
    import "module:plugin" as plugin;

    var BrainzMetadataProviderPlugin = plugin.BrainzMetadataProviderPlugin;
    var metadata = BrainzMetadataProviderPlugin()
    """);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                await getIt<Hetu>().eval("metadata.auth.authenticate()");
              } catch (e, stackTrace) {
                debugPrint("Error during authentication: $e");
                debugPrintStack(stackTrace: stackTrace);
              }
            },
            child: Text("Login"),
          ),
          Text("User"),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval("metadata.user.me()");
                  debugPrint(result.toString());
                },
                child: Text("Get Me"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.user.savedTracks()",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Get User Saved Tracks"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.user.savedPlaylists()",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Get User Saved Playlists"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.user.savedAlbums()",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Get User Saved Albums"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.user.savedArtists()",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Get User Saved Artists"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    """
                    metadata.user.isSavedTracks([
                      'd2555d82-571d-406c-8e96-21562753cebc',
                      'a16e6dab-38d7-4ec6-b751-c1ebb5e62c22'
                    ])
                    """,
                  );
                  debugPrint(result.toString());
                },
                child: Text("Is track saved?"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.user.isSavedPlaylist('dc2ad3e2-af4d-492f-a814-8179df4cee70')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Is playlist saved?"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.user.isSavedAlbums(['2fddd479-26b1-457c-a8e2-09d2c71436bf'])",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Is album saved?"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.user.isSavedArtists(['80609a00-b394-4a49-975b-2db6b543fa97'])",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Is artist saved?"),
              ),
            ],
          ),
          Text("Tracks"),
          Row(
            spacing: 12,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.track.getTrack('11dFghVXANMlKmJXsNCbNl')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Get Track"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.track.save(['11dFghVXANMlKmJXsNCbNl'])",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Save Track"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.track.unsave(['11dFghVXANMlKmJXsNCbNl'])",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Unsave Track"),
              ),
            ],
          ),
          Text("Playlists"),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.playlist.getPlaylist('dc2ad3e2-af4d-492f-a814-8179df4cee70')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Get Playlist"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.playlist.tracks('dc2ad3e2-af4d-492f-a814-8179df4cee70')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Get Playlist Tracks"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval("""
                    var myPlaylist
                    metadata.user.me().then((me) {
                      return metadata.playlist.create(
                        me["id"],
                        name: "Hetu Playlist",
                        description: "This is a playlist created by Hetu"
                      ).then((playlist){
                        myPlaylist = playlist
                        return playlist
                      })
                    })
                    """);
                  debugPrint(result.toString());
                },
                child: Text("Create Playlist"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Create playlist must be called first
                  final result = await getIt<Hetu>().eval("""
                    metadata.playlist.update(
                      myPlaylist["id"],
                      name: "Hetu Update Playlist",
                      description: "This playlist is updated by Hetu"
                    ).then((data)=> metadata.playlist.getPlaylist(myPlaylist["id"]))
                    """);
                  debugPrint(result.toString());
                },
                child: Text("Update Playlist"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Create playlist must be called first
                  final result = await getIt<Hetu>().eval(
                    'metadata.playlist.deletePlaylist(myPlaylist["id"])',
                  );
                  debugPrint(result.toString());
                },
                child: Text("Delete Playlist"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    'metadata.playlist.save("37i9dQZF1E4oJSdHZrVjxD")',
                  );
                  debugPrint(result.toString());
                },
                child: Text("Save Playlist"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    'metadata.playlist.unsave("37i9dQZF1E4oJSdHZrVjxD")',
                  );
                  debugPrint(result.toString());
                },
                child: Text("Unsave Playlist"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Create playlist must be called first
                  final result = await getIt<Hetu>().eval(
                    'metadata.playlist.addTracks(myPlaylist["id"], trackIds: ["a817f622-2f84-428a-86e0-c50378d886bc"])',
                  );
                  debugPrint(result.toString());
                },
                child: Text("Add Tracks"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Create playlist must be called first
                  final result = await getIt<Hetu>().eval(
                    'metadata.playlist.removeTracks(myPlaylist["id"], trackIds: ["a817f622-2f84-428a-86e0-c50378d886bc"])',
                  );
                  debugPrint(result.toString());
                },
                child: Text("Remove Tracks"),
              ),
            ],
          ),
          Text("Albums"),
          Row(
            spacing: 12,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.album.getAlbum('9c5a6a5f-ec6e-4ab3-a183-a332bc9e6a01')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Get Album"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.album.tracks('9c5a6a5f-ec6e-4ab3-a183-a332bc9e6a01')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Get Album Tracks"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.album.releases()",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Releases"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    'metadata.album.save(["9edb549d-b9cd-47b8-8b33-523b0bf8e301"])',
                  );
                  debugPrint(result.toString());
                },
                child: Text("Save Album"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    'metadata.album.unsave(["9edb549d-b9cd-47b8-8b33-523b0bf8e301"])',
                  );
                  debugPrint(result.toString());
                },
                child: Text("Unsave Album"),
              ),
            ],
          ),
          Text("Artists"),
          Row(
            spacing: 12,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.artist.getArtist('a6c6897a-7415-4f8d-b5a5-3a5e05f3be67')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Get Artist"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.artist.topTracks('a6c6897a-7415-4f8d-b5a5-3a5e05f3be67')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Artist Top Tracks"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.artist.albums('a6c6897a-7415-4f8d-b5a5-3a5e05f3be67')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Artist albums"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.artist.save(['c75b226d-d643-41dc-a2b7-00c0ff8c8e7b'])",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Save Artist"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.artist.unsave(['c75b226d-d643-41dc-a2b7-00c0ff8c8e7b'])",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Unsave Artists"),
              ),
            ],
          ),
          Text("Search"),
          TextField(
            decoration: InputDecoration(
              labelText: "Search Query",
              hintText: "Enter search query",
            ),
            onSubmitted: (query) async {
              final result = await getIt<Hetu>().eval(
                "metadata.search.all('$query')",
              );
              debugPrint(result.toString());
            },
          ),
          Row(
            spacing: 12,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.search.all('Twenty One Pilots')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Search Twenty One Pilots"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.search.tracks('Twenty One Pilots')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Only Tracks"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.search.albums('Twenty One Pilots')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Only albums"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.search.artists('Twenty One Pilots')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Only artists"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.search.playlists('Twenty One Pilots')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Only playlists"),
              ),
            ],
          ),
          Text("Browse"),
          Row(
            spacing: 12,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.browse.sections()",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Browse sections"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.browse.sectionItems('0JQ5DAnM3wGh0gz1MXnu3B')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Popular singles and albums"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.browse.sectionItems('0JQ5DAuChZYPe9iDhh2mJz')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Today in Music"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await getIt<Hetu>().eval(
                    "metadata.browse.sectionItems('0JQ5DAnM3wGh0gz1MXnu3C')",
                  );
                  debugPrint(result.toString());
                },
                child: Text("Popular Artists"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
