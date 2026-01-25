
import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
import 'pages/filiere_detail_page.dart';
import 'pages/add_epreuve_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'filiere/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return FiliereDetailPage(filiereId: id);
          },
          routes: [
            GoRoute(
              path: 'add-epreuve',
              builder: (context, state) {
                 final id = state.pathParameters['id']!;
                 return AddEpreuvePage(filiereId: id);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
