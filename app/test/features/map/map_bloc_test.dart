import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kapok_app/features/map/bloc/map_bloc.dart';
import 'package:kapok_app/features/map/bloc/map_event.dart';
import 'package:kapok_app/features/map/bloc/map_state.dart';
import 'package:kapok_app/data/models/offline_map_region_model.dart';
import 'package:kapok_app/data/repositories/map_repository.dart';
import 'package:kapok_app/data/repositories/task_repository.dart';

class _MockMapRepository extends Mock implements MapRepository {}

class _MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MapBloc bloc;
  late _MockMapRepository repository;
  late _MockTaskRepository taskRepository;
  late OfflineMapRegion region;
  late StreamController<double> progressController;

  setUp(() {
    repository = _MockMapRepository();
    taskRepository = _MockTaskRepository();
    bloc = MapBloc(mapRepository: repository, taskRepository: taskRepository);
    region = OfflineMapRegion(
      id: 'region_1',
      centerLat: 10,
      centerLon: 20,
      zoomMin: 13,
      zoomMax: 18,
      northEastLat: 10.05,
      northEastLon: 20.05,
      southWestLat: 9.95,
      southWestLon: 19.95,
      name: 'Test Bubble',
      lastSyncedAt: DateTime(2024, 1, 1),
      totalTiles: 100,
      downloadedTiles: 0,
      status: 'pending',
    );
    progressController = StreamController<double>();
  });

  tearDown(() async {
    await bloc.close();
    await progressController.close();
  });

  blocTest<MapBloc, MapState>(
    'emits MapReady when cache already has a region',
    build: () {
      when(
        () => repository.getDownloadedRegions(),
      ).thenAnswer((_) async => [region]);
      when(() => repository.isOfflineMode()).thenAnswer((_) async => false);
      return bloc;
    },
    act: (bloc) => bloc.add(const MapStarted()),
    expect: () => [
      const MapLoading(),
      MapReady(region: region, isOfflineMode: false, lastCamera: null),
    ],
  );

  blocTest<MapBloc, MapState>(
    'refreshes offline bubble when forced',
    build: () {
      when(() => repository.getDownloadedRegions()).thenAnswer((_) async => []);
      when(() => repository.isOfflineMode()).thenAnswer((_) async => false);
      when(
        () => repository.loadRegionForCurrentLocation(
          radiusKm: any(named: 'radiusKm'),
          zoomMin: any(named: 'zoomMin'),
          zoomMax: any(named: 'zoomMax'),
        ),
      ).thenAnswer((_) async => (region: region, primedTiles: 9));
      when(
        () => repository.streamRegionStatus(region.id),
      ).thenAnswer((_) => progressController.stream);
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const MapStarted());
      await Future.microtask(() {});
      progressController.add(0.4);
      await Future.microtask(() {});
      progressController.add(1.0);
    },
    expect: () => [
      const MapLoading(),
      MapReady(region: region, isOfflineMode: false, lastCamera: null),
      OfflineRegionUpdating(
        region: region,
        progress: 0.4,
        isOfflineMode: false,
      ),
      MapReady(region: region, isOfflineMode: false, lastCamera: null),
    ],
  );
}
