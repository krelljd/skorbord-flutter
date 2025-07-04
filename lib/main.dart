import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'api/api_service.dart';
import 'api/socket_service.dart';
import 'api/app_state.dart';
import 'api/offline_manager.dart';
import 'widgets/game_board.dart';
import 'widgets/connection_status.dart';

void main() {
  runApp(const SkorbordApp());
}

class SkorbordApp extends StatelessWidget {
  const SkorbordApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine base URLs for REST and WebSocket
    const String restBaseUrl = String.fromEnvironment(
                'FLUTTER_WEB_USE_SKORBORD_PROD',
                defaultValue: 'false') ==
            'true'
        ? 'https://cards.skorbord.app/api/'
        : 'http://localhost:2424/api/';
    const String wsUrl = String.fromEnvironment('FLUTTER_WEB_USE_SKORBORD_PROD',
                defaultValue: 'false') ==
            'true'
        ? 'https://cards.skorbord.app/'
        : 'http://localhost:2424/';

    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/:sqid/game',
          builder: (context, state) {
            // final sqid = state.pathParameters['sqid']!;
            return const GameBoard();
          },
        ),
      ],
    );

    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService(baseUrl: restBaseUrl)),
        ChangeNotifierProvider(create: (_) {
          final socketService = SocketService(wsUrl);
          socketService.connect();
          return socketService;
        }),
        Provider<OfflineManager>(create: (_) => OfflineManager()),
        ChangeNotifierProvider(
          create: (context) => AppState(
            socketService: Provider.of<SocketService>(context, listen: false),
            apiService: Provider.of<ApiService>(context, listen: false),
            offlineManager: Provider.of<OfflineManager>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Skorbord',
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey, brightness: Brightness.dark),
          useMaterial3: true,
          textTheme: Typography.whiteCupertino.apply(
            fontSizeFactor: 1.0,
            fontFamily: 'Roboto',
          ),
          scaffoldBackgroundColor: Colors.black,
        ),
        routerConfig: router,
        builder: (context, child) => SafeArea(
          child: Stack(
            children: [
              child!,
              // Overlay connection status at the top using Provider
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Consumer<SocketService>(
                  builder: (context, socketService, _) => ConnectionStatus(
                    connected: socketService.connected,
                  ),
                ),
              ),
            ],
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skorbord'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to GameBoard with a mock sqid
            context.go('/mock-game-1/game');
          },
          child: const Text('Start New Game'),
        ),
      ),
    );
  }
}
