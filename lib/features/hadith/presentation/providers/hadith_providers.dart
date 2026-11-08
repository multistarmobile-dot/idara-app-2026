import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/file_cache.dart';
import '../../data/hadith_repository.dart';
import '../../domain/hadith_models.dart';

final hadithRepositoryProvider = Provider<HadithRepository>((ref) {
  return HadithRepository(FileCache());
});

typedef HadithSectionRequest = ({String collection, int section, HadithLang lang});

final hadithSectionProvider =
    FutureProvider.autoDispose.family<HadithSection, HadithSectionRequest>((ref, req) {
  return ref.watch(hadithRepositoryProvider).getSection(req.collection, req.section, req.lang);
});

final dailyHadithProvider = FutureProvider.autoDispose<DailyHadith>((ref) {
  return ref.watch(hadithRepositoryProvider).getDaily(DateTime.now());
});
