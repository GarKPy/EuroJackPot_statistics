import 'package:eurojackpot/providers/utils_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key, required this.onSelectScreen});

  final void Function(String identifier) onSelectScreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //print('----- MainDrawer');
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_border_purple500,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 18,
                  ),
                  Text(
                    'Euro JackPot',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.circle_outlined,
                size: 40,
                //color: Colors.yellow,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              title: Text(
                'General',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 24,
                    ),
              ),
              onTap: () {
                ref.read(activePageProvider.notifier).state = 'general';
                ref.read(isGeneralProvider.notifier).state = true;
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.star_border_outlined,
                size: 40,
                //color: Colors.yellow,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              title: Text(
                'Additional',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 24,
                    ),
              ),
              onTap: () {
                ref.read(activePageProvider.notifier).state = 'additional';
                ref.read(isGeneralProvider.notifier).state = false;
                ref.read(pageIndexProvider.notifier).state = 1;
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.sync,
                size: 40,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              title: Text(
                'Update Data',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 24,
                    ),
              ),
              onTap: () {
                onSelectScreen('update');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.sync,
                size: 40,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              title: Text(
                'Read Data',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 24,
                    ),
              ),
              onTap: () {
                onSelectScreen('read');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.sync,
                size: 40,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              title: Text(
                'Delete Last',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 24,
                    ),
              ),
              onTap: () {
                onSelectScreen('delete');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.account_circle_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              title: Text(
                'About',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 24,
                    ),
              ),
              onTap: () {
                onSelectScreen('filters');
              },
            ),
          ],
        ),
      ),
    );
  }
}
