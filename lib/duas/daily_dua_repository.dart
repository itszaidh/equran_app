import 'dart:math';

import 'package:equran/duas/hisn_al_muslim_models.dart';
import 'package:equran/duas/hisn_al_muslim_repository.dart';

class DailyDuaPayload {
  const DailyDuaPayload({required this.dua, required this.categoryIndex});

  final DuaEntry dua;
  final DuaCategoryIndex categoryIndex;
}

class DailyDuaRepository {
  DailyDuaRepository({HisnAlMuslimRepository? repository})
    : _repository = repository ?? HisnAlMuslimRepository();

  final HisnAlMuslimRepository _repository;

  Future<DailyDuaPayload> getDailyDua(DateTime date) async {
    final List<DuaCategoryIndex> index = await _repository.loadCategoryIndex();
    final int totalDuas = index.fold<int>(
      0,
      (int sum, DuaCategoryIndex cat) => sum + cat.duaCount,
    );
    if (totalDuas == 0) {
      throw StateError('No Duas available in the index');
    }

    final int seed = date.year + date.month + date.day;
    final Random random = Random(seed);
    final int randomIndex = random.nextInt(totalDuas);

    int currentSum = 0;
    DuaCategoryIndex? targetCategory;
    int targetDuaIndex = -1;
    for (final DuaCategoryIndex category in index) {
      if (randomIndex < currentSum + category.duaCount) {
        targetCategory = category;
        targetDuaIndex = randomIndex - currentSum;
        break;
      }
      currentSum += category.duaCount;
    }

    if (targetCategory == null) {
      targetCategory = index.first;
      targetDuaIndex = 0;
    }

    final DuaCategory category = await _repository.loadCategoryById(
      targetCategory.id,
    );
    final DuaEntry dua = category.duas[targetDuaIndex];
    return DailyDuaPayload(dua: dua, categoryIndex: targetCategory);
  }
}
