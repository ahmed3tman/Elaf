import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jalees/core/share/widgets/custom_search_bar.dart';
import 'package:jalees/core/share/widgets/gradient_background.dart';
import 'dart:math';
import 'package:jalees/features/bukhari/view/widgets/hadeeth_card.dart';
import 'package:jalees/features/bukhari/model/hadeeth_mode.dart';
import '../../cubit/bukhari_cubit.dart';

class BukhariScreen extends StatefulWidget {
  const BukhariScreen({super.key});

  @override
  State<BukhariScreen> createState() => _BukhariScreenState();
}

class _BukhariScreenState extends State<BukhariScreen> {
  String search = '';
  int? selectedChapterId; // null means 'الكل'

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BukhariCubit()..loadBukhari(),
      child: GradientScaffold(
        appBar: AppBar(title: const Text('أحاديث'), centerTitle: true),
        body: Column(
          children: [
            CustomSearchBar(
              hintText: 'ابحث في كل الأحاديث... (النص، الراوي، أو الفصل)',
              onChanged: (val) => setState(() => search = val),
            ),
            Expanded(
              child: BlocBuilder<BukhariCubit, BukhariState>(
                builder: (context, state) {
                  if (state is BukhariLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BukhariLoaded) {
                    final List<Chapter> chapters = state.book.chapters;
                    final List<Hadith> hadiths = state.book.hadiths;

                    // Build category chips: 'الكل' + chapters
                    final query = search.trim();
                    final isSearching = query.isNotEmpty;

                    // Filter hadiths: if searching, search across ALL hadiths; else filter by selected chapter
                    List<Hadith> filteredHadiths = hadiths.where((h) {
                      final matchesCategory = isSearching
                          ? true
                          : (selectedChapterId == null
                                ? true
                                : h.chapterId == selectedChapterId);
                      if (!matchesCategory) return false;

                      if (!isSearching) return true;

                      final Chapter chapterObj = chapters.firstWhere(
                        (c) => c.id == h.chapterId,
                        orElse: () => Chapter(
                          id: -1,
                          bookId: -1,
                          arabic: '',
                          english: '',
                        ),
                      );
                      final chapterTitle = chapterObj.arabic;

                      final englishText = (h.english is Map)
                          ? ((h.english['text']?.toString() ?? '') +
                                ' ' +
                                (h.english['narrator']?.toString() ?? ''))
                          : h.english?.toString() ?? '';

                      return h.arabic.contains(query) ||
                          englishText.toLowerCase().contains(
                            query.toLowerCase(),
                          ) ||
                          chapterTitle.contains(query);
                    }).toList();

                    // Recommended hadiths: pick up to 3 random items from the full list
                    final rnd = Random();
                    final allForRecommend = hadiths;
                    final int recommendCount = allForRecommend.isEmpty
                        ? 0
                        : (allForRecommend.length >= 3
                              ? 3
                              : allForRecommend.length);
                    final Set<int> pickedIdx = {};
                    final List<Hadith> recommended = <Hadith>[];
                    while (recommended.length < recommendCount) {
                      final idx = rnd.nextInt(allForRecommend.length);
                      if (pickedIdx.add(idx)) {
                        recommended.add(allForRecommend[idx]);
                      }
                    }

                    if (filteredHadiths.isEmpty) {
                      return const Center(child: Text('لا يوجد نتائج'));
                    }

                    return Column(
                      children: [
                        // Categories horizontal chips
                        SizedBox(
                          height: 45,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              // vertical: 1,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: chapters.length + 1, // + 'الكل'
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                final isSelected = selectedChapterId == null;
                                return ChoiceChip(
                                  label: const Text('الكل'),
                                  selected: isSelected,
                                  onSelected: (_) =>
                                      setState(() => selectedChapterId = null),
                                  selectedColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.15),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color: isSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withOpacity(0.4),
                                    ),
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                );
                              } else {
                                final chapter = chapters[index - 1];
                                final isSelected =
                                    selectedChapterId == chapter.id &&
                                    !isSearching;
                                return ChoiceChip(
                                  label: Text(chapter.arabic),
                                  selected: isSelected,
                                  onSelected: (_) => setState(
                                    () => selectedChapterId = chapter.id,
                                  ),
                                  selectedColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.15),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color: isSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withOpacity(0.4),
                                    ),
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        // List of hadiths with a top recommended card
                        Expanded(
                          child: ListView.builder(
                            itemCount:
                                filteredHadiths.length +
                                1, // + recommended card
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                // Recommended card
                                if (recommended.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.auto_awesome,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'أحاديث مقترحة',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ...recommended.map((Hadith h) {
                                          final String snippet =
                                              h.arabic.length > 120
                                              ? h.arabic.substring(0, 120) +
                                                    '...'
                                              : h.arabic;
                                          return ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                  vertical: 2,
                                                ),
                                            leading: Icon(
                                              Icons.star_border,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                            ),
                                            title: Text(
                                              snippet,
                                              textDirection: TextDirection.rtl,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                    ),
                                                builder: (ctx) =>
                                                    DraggableScrollableSheet(
                                                      expand: false,
                                                      initialChildSize: 0.8,
                                                      minChildSize: 0.5,
                                                      maxChildSize: 0.95,
                                                      builder: (_, controller) =>
                                                          SingleChildScrollView(
                                                            controller:
                                                                controller,
                                                            child: HadeethCard(
                                                              hadith: h,
                                                            ),
                                                          ),
                                                    ),
                                              );
                                            },
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              final item = filteredHadiths[index - 1];
                              return KeyedSubtree(
                                key: ValueKey(
                                  'hadith-${item.id}-${item.chapterId}',
                                ),
                                child: HadeethCard(hadith: item),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (state is BukhariError) {
                    return Center(child: Text('خطأ: ${state.message}'));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
