// screens/location_bin_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/utils/constants/colors.dart';
import '../riverpod/location_bin_provider.dart';
import '../widgets/bin_card.dart';
import '../widgets/location_card.dart';
import 'add_bin_page.dart';
import 'add_location_page.dart';


class LocationBinScreen extends ConsumerWidget {
  const LocationBinScreen({
    super.key,
  });

  Future<String?> getCompanyId() async {
    var box = await Hive.openBox('auth_data');
    return box.get('companyId')?.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
      future: getCompanyId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Company ID not found'));
        }

        final companyId = snapshot.data!;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Locations & Bins'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
              bottom: const PreferredSize(
  preferredSize: Size.fromHeight(48),
  child: Align(
    alignment: Alignment.center,
    child: TabBar(
      labelColor: tPrimary,
      unselectedLabelColor: Colors.grey,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: tPrimary,
            width: 3,
          ),
        ),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: [
        SizedBox(
          width: double.infinity,
          child: Tab(text: 'Locations'),
        ),
        SizedBox(
          width: double.infinity,
          child: Tab(text: 'Bins'),
        ),
      ],
    ),
  ),
),
            ),
            body: TabBarView(
              children: [
                LocationsTab(companyId: companyId),
                BinsTab(companyId: companyId),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LocationsTab extends ConsumerStatefulWidget {
  final String companyId;

  const LocationsTab({
    super.key,
    required this.companyId,
  });

  @override
  ConsumerState<LocationsTab> createState() => _LocationsTabState();
}

class _LocationsTabState extends ConsumerState<LocationsTab> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh from API every 30 seconds silently
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        ref.read(locationsProvider(widget.companyId).notifier).loadLocations(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(locationsProvider(widget.companyId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(locationsProvider(widget.companyId).notifier).loadLocations(silent: true);
        },
        child: locationsAsync.when(
          data: (locations) {
            if (locations.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height - 200,
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No locations found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the + button to add a location',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];
                return LocationCard(location: location, companyId: widget.companyId);
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height - 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading locations',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(locationsProvider(widget.companyId).notifier).loadLocations();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddLocationScreen(companyId: widget.companyId),
            ),
          );
          ref.read(locationsProvider(widget.companyId).notifier).loadLocations(silent: true);
        },
        backgroundColor: tPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BinsTab extends ConsumerStatefulWidget {
  final String companyId;

  const BinsTab({
    super.key,
    required this.companyId,
  });

  @override
  ConsumerState<BinsTab> createState() => _BinsTabState();
}

class _BinsTabState extends ConsumerState<BinsTab> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh from API every 30 seconds silently
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        ref.read(binsProvider(widget.companyId).notifier).loadBins(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final binsAsync = ref.watch(binsProvider(widget.companyId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(binsProvider(widget.companyId).notifier).loadBins(silent: true);
        },
        child: binsAsync.when(
          data: (bins) {
            if (bins.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height - 200,
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No bins found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the + button to add a bin',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bins.length,
              itemBuilder: (context, index) {
                final bin = bins[index];
                return BinCard(bin: bin, companyId: widget.companyId);
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height - 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading bins',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(binsProvider(widget.companyId).notifier).loadBins();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddBinScreen(companyId: widget.companyId),
            ),
          );
          ref.read(binsProvider(widget.companyId).notifier).loadBins(silent: true);
        },
        backgroundColor: tPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
