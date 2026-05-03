import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_app/features/system_control/bloc/system_control_bloc.dart';
import 'package:ai_app/features/system_control/models/models.dart';
import 'package:ai_app/features/system_control/repositories/network_control_repository.dart';
import 'package:ai_app/features/system_control/repositories/power_control_repository.dart';
import 'package:ai_app/features/system_control/repositories/system_control_repository.dart';

class MockSystemControlRepository extends Mock
    implements SystemControlRepository {}

class MockNetworkControlRepository extends Mock
    implements NetworkControlRepository {}

class MockPowerControlRepository extends Mock
    implements PowerControlRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSystemControlRepository mockSystemControlRepo;
  late MockNetworkControlRepository mockNetworkRepo;
  late MockPowerControlRepository mockPowerRepo;

  setUp(() {
    mockSystemControlRepo = MockSystemControlRepository();
    mockNetworkRepo = MockNetworkControlRepository();
    mockPowerRepo = MockPowerControlRepository();
  });

  setUpAll(() {
    registerFallbackValue(PowerAction.shutdown);
  });

  group('SystemControlBloc', () {
    test('initial state has correct default values', () {
      final bloc = SystemControlBloc(
        systemControlRepo: mockSystemControlRepo,
        networkRepo: mockNetworkRepo,
        powerRepo: mockPowerRepo,
      );
      expect(bloc.state.isSyncing, false);
      expect(bloc.state.isToggling, false);
      expect(bloc.state.isPowerActionExecuting, false);
      expect(bloc.state.wifiEnabled, true);
      expect(bloc.state.bluetoothEnabled, true);
      expect(bloc.state.ethernetEnabled, true);
      expect(bloc.state.error, isNull);
      expect(bloc.state.syncResults, isEmpty);
      expect(bloc.state.devices, isEmpty);
    });

    blocTest<SystemControlBloc, SystemControlState>(
      'SystemControlTimeSyncRequested syncs time successfully',
      build: () {
        when(() => mockSystemControlRepo.syncTime(any())).thenAnswer(
          (_) async => const TimeSyncResult(
            serverName: 'ntp.aliyun.com',
            localTime: '2024-01-01 00:00:00',
            serverTime: '2024-01-01 00:00:01',
            offset: Duration(seconds: 1),
            success: true,
          ),
        );

        return SystemControlBloc(
          systemControlRepo: mockSystemControlRepo,
          networkRepo: mockNetworkRepo,
          powerRepo: mockPowerRepo,
        );
      },
      act: (bloc) => bloc.add(
        const SystemControlTimeSyncRequested('ntp.aliyun.com'),
      ),
      verify: (bloc) {
        verify(() => mockSystemControlRepo.syncTime('ntp.aliyun.com'))
            .called(1);
        expect(bloc.state.isSyncing, false);
        expect(bloc.state.syncResults.length, 1);
        expect(bloc.state.syncResults.first.success, true);
      },
    );

    blocTest<SystemControlBloc, SystemControlState>(
      'SystemControlTimeSyncRequested handles failure',
      build: () {
        when(() => mockSystemControlRepo.syncTime(any())).thenAnswer(
          (_) async => const TimeSyncResult(
            serverName: 'ntp.aliyun.com',
            localTime: '2024-01-01 00:00:00',
            serverTime: '2024-01-01 00:00:00',
            offset: Duration.zero,
            success: false,
            error: 'sync failed',
          ),
        );

        return SystemControlBloc(
          systemControlRepo: mockSystemControlRepo,
          networkRepo: mockNetworkRepo,
          powerRepo: mockPowerRepo,
        );
      },
      act: (bloc) => bloc.add(
        const SystemControlTimeSyncRequested('ntp.aliyun.com'),
      ),
      verify: (bloc) {
        expect(bloc.state.isSyncing, false);
        expect(bloc.state.syncResults.first.success, false);
      },
    );

    blocTest<SystemControlBloc, SystemControlState>(
      'SystemControlTimeSyncRequested handles exception',
      build: () {
        when(() => mockSystemControlRepo.syncTime(any()))
            .thenThrow(Exception('network error'));

        return SystemControlBloc(
          systemControlRepo: mockSystemControlRepo,
          networkRepo: mockNetworkRepo,
          powerRepo: mockPowerRepo,
        );
      },
      act: (bloc) => bloc.add(
        const SystemControlTimeSyncRequested('ntp.aliyun.com'),
      ),
      verify: (bloc) {
        expect(bloc.state.isSyncing, false);
        expect(bloc.state.error, isNotNull);
      },
    );

    blocTest<SystemControlBloc, SystemControlState>(
      'SystemControlWifiToggled enables wifi successfully',
      build: () {
        when(() => mockNetworkRepo.toggleWifi(any()))
            .thenAnswer((_) async => true);

        return SystemControlBloc(
          systemControlRepo: mockSystemControlRepo,
          networkRepo: mockNetworkRepo,
          powerRepo: mockPowerRepo,
        );
      },
      act: (bloc) => bloc.add(const SystemControlWifiToggled(true)),
      verify: (bloc) {
        verify(() => mockNetworkRepo.toggleWifi(true)).called(1);
        expect(bloc.state.wifiEnabled, true);
        expect(bloc.state.isToggling, false);
      },
    );

    blocTest<SystemControlBloc, SystemControlState>(
      'SystemControlWifiToggled disables wifi successfully',
      build: () {
        when(() => mockNetworkRepo.toggleWifi(any()))
            .thenAnswer((_) async => true);

        return SystemControlBloc(
          systemControlRepo: mockSystemControlRepo,
          networkRepo: mockNetworkRepo,
          powerRepo: mockPowerRepo,
        );
      },
      act: (bloc) => bloc.add(const SystemControlWifiToggled(false)),
      verify: (bloc) {
        verify(() => mockNetworkRepo.toggleWifi(false)).called(1);
        expect(bloc.state.wifiEnabled, false);
        expect(bloc.state.isToggling, false);
      },
    );

    blocTest<SystemControlBloc, SystemControlState>(
      'SystemControlWifiToggled handles failure',
      build: () {
        when(() => mockNetworkRepo.toggleWifi(any()))
            .thenAnswer((_) async => false);

        return SystemControlBloc(
          systemControlRepo: mockSystemControlRepo,
          networkRepo: mockNetworkRepo,
          powerRepo: mockPowerRepo,
        );
      },
      act: (bloc) => bloc.add(const SystemControlWifiToggled(true)),
      verify: (bloc) {
        expect(bloc.state.isToggling, false);
        expect(bloc.state.error, isNotNull);
      },
    );

    blocTest<SystemControlBloc, SystemControlState>(
      'SystemControlPowerAction executes power action successfully',
      build: () {
        when(() => mockPowerRepo.executePowerAction(any()))
            .thenAnswer((_) async => true);

        return SystemControlBloc(
          systemControlRepo: mockSystemControlRepo,
          networkRepo: mockNetworkRepo,
          powerRepo: mockPowerRepo,
        );
      },
      act: (bloc) => bloc.add(
        const SystemControlPowerAction(PowerAction.shutdown),
      ),
      verify: (bloc) {
        verify(() => mockPowerRepo.executePowerAction(PowerAction.shutdown))
            .called(1);
        expect(bloc.state.isPowerActionExecuting, false);
      },
    );

    blocTest<SystemControlBloc, SystemControlState>(
      'SystemControlPowerAction handles failure',
      build: () {
        when(() => mockPowerRepo.executePowerAction(any()))
            .thenAnswer((_) async => false);

        return SystemControlBloc(
          systemControlRepo: mockSystemControlRepo,
          networkRepo: mockNetworkRepo,
          powerRepo: mockPowerRepo,
        );
      },
      act: (bloc) => bloc.add(
        const SystemControlPowerAction(PowerAction.restart),
      ),
      verify: (bloc) {
        expect(bloc.state.isPowerActionExecuting, false);
        expect(bloc.state.error, isNotNull);
      },
    );

    blocTest<SystemControlBloc, SystemControlState>(
      'SystemControlPowerAction handles exception',
      build: () {
        when(() => mockPowerRepo.executePowerAction(any()))
            .thenThrow(Exception('power error'));

        return SystemControlBloc(
          systemControlRepo: mockSystemControlRepo,
          networkRepo: mockNetworkRepo,
          powerRepo: mockPowerRepo,
        );
      },
      act: (bloc) => bloc.add(
        const SystemControlPowerAction(PowerAction.lock),
      ),
      verify: (bloc) {
        expect(bloc.state.isPowerActionExecuting, false);
        expect(bloc.state.error, isNotNull);
      },
    );

    blocTest<SystemControlBloc, SystemControlState>(
      'SystemControlBluetoothToggled enables bluetooth successfully',
      build: () {
        when(() => mockNetworkRepo.toggleBluetooth(any()))
            .thenAnswer((_) async => true);

        return SystemControlBloc(
          systemControlRepo: mockSystemControlRepo,
          networkRepo: mockNetworkRepo,
          powerRepo: mockPowerRepo,
        );
      },
      act: (bloc) => bloc.add(const SystemControlBluetoothToggled(true)),
      verify: (bloc) {
        verify(() => mockNetworkRepo.toggleBluetooth(true)).called(1);
        expect(bloc.state.bluetoothEnabled, true);
        expect(bloc.state.isToggling, false);
      },
    );

    blocTest<SystemControlBloc, SystemControlState>(
      'SystemControlNtpServersRefreshed refreshes server list',
      build: () {
        when(() => mockSystemControlRepo.getNtpServers()).thenAnswer(
          (_) async => TimeServer.commonServers,
        );

        return SystemControlBloc(
          systemControlRepo: mockSystemControlRepo,
          networkRepo: mockNetworkRepo,
          powerRepo: mockPowerRepo,
        );
      },
      act: (bloc) => bloc.add(const SystemControlNtpServersRefreshed()),
      verify: (bloc) {
        verify(() => mockSystemControlRepo.getNtpServers()).called(1);
        expect(bloc.state.ntpServers, isNotEmpty);
        expect(bloc.state.isSyncing, false);
      },
    );
  });
}
