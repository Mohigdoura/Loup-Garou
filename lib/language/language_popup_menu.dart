import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/language/language.dart';
import 'package:loup_garou/language/language_provider.dart';

class LanguagePopupMenu extends ConsumerWidget {
  const LanguagePopupMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    return PopupMenuButton(
      onSelected: (value) =>
          ref.read(languageProvider.notifier).setLanguage(value),
      itemBuilder: (context) => [
        for (final language in Language.values)
          PopupMenuItem(
            value: language,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [Text(language.name), Text(language.flag)],
            ),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [Text(language.name), Text(language.flag)],
      ),
    );
  }
}
