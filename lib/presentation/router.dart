
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noti/domain/entities/epreuve.dart';
import 'pages/home_page.dart';
import 'pages/filiere_detail_page.dart';
import 'pages/add_epreuve_page.dart';
import 'pages/epreuves_page.dart';
import 'pages/epreuve_detail_page.dart';
import 'pages/filieres_page.dart';
import 'pages/settings_page.dart';
import 'widgets/scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorEpreuvesKey = GlobalKey<NavigatorState>(debugLabel: 'shellEpreuves');
final _shellNavigatorFilieresKey = GlobalKey<NavigatorState>(debugLabel: 'shellFilieres');
final _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Home Branch
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        // Epreuves Branch
        StatefulShellBranch(
          navigatorKey: _shellNavigatorEpreuvesKey,
          routes: [
            GoRoute(
              path: '/epreuves',
              builder: (context, state) => const EpreuvesPage(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return EpreuveDetailPage(epreuveId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        // Filieres Branch
        StatefulShellBranch(
          navigatorKey: _shellNavigatorFilieresKey,
          routes: [
            GoRoute(
              path: '/filieres',
              builder: (context, state) => const FilieresPage(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  parentNavigatorKey: _rootNavigatorKey, // Hide bottom nav
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return FiliereDetailPage(filiereId: id);
                  },
                  routes: [
                    GoRoute(
                      path: 'add-epreuve',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                         final id = state.pathParameters['id']!;
                         final epreuve = state.extra as Epreuve?;
                         return AddEpreuvePage(filiereId: id, epreuve: epreuve);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Settings Branch
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSettingsKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
