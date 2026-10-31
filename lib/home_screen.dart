import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'strings.dart';
import 'subscription.dart';
import 'settings_controller.dart';
import 'storage_service.dart';
import 'app_theme.dart';
import 'settings_sheet.dart';
import 'subscription_tile.dart';
import 'summary_card.dart';
import 'subscription_form_screen.dart';

class HomeScreen extends StatefulWidget {
  final SettingsController settings;
  final AppUser user;
  final VoidCallback onLogout;

  const HomeScreen({
    super.key,
    required this.settings,
    required this.user,
    required this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final StorageService _storage = StorageService(widget.user.id);
  List<Subscription> _items = [];
  bool _loading = true;
  String _filter = 'all';
  List<String> _groups = [...kGroups];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _storage.load();
    final groups = await _storage.loadGroups();
    if (!mounted) return;
    setState(() {
      _items = items;
      _groups = groups;
      _loading = false;
    });
  }

  Future<void> _persist() => _storage.save(_items);

  // ---------- derived values ----------
  List<Subscription> get _visible => _filter == 'all'
      ? _items
      : _items.where((s) => s.group == _filter).toList();

  List<Subscription> get _active => _visible.where((s) => s.active).toList();

  double get _monthlyTotal =>
      _active.fold(0.0, (sum, s) => sum + s.monthlyCost);

  double get _yearlyTotal => _active.fold(0.0, (sum, s) => sum + s.yearlyCost);

  /// Active subscriptions first, sorted by the nearest renewal date.
  List<Subscription> get _sorted {
    final list = [..._visible];
    list.sort((a, b) {
      if (a.active != b.active) return a.active ? -1 : 1;
      if (!a.active) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return a.nextRenewal.compareTo(b.nextRenewal);
    });
    return list;
  }

  // ---------- actions ----------
  Future<void> _openForm([Subscription? existing]) async {
    final result = await Navigator.of(context).push<Subscription>(
      PageRouteBuilder<Subscription>(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) => SubscriptionFormScreen(existing: existing, groups: _groups),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
    if (result == null) return;
    setState(() {
      final index = _items.indexWhere((s) => s.id == result.id);
      if (index >= 0) {
        _items[index] = result;
      } else {
        _items.add(result);
      }
    });
    await _persist();
  }

  Future<void> _addGroup() async {
    final p = AppPalette.of(context);
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(ctx.tr('grpAdd'), style: TextStyle(color: p.text)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 20,
          style: TextStyle(color: p.text),
          decoration: InputDecoration(hintText: ctx.tr('grpName')),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    if (_groups.any((g) => g.toLowerCase() == name.toLowerCase())) {
      setState(() => _filter = _groups.firstWhere(
          (g) => g.toLowerCase() == name.toLowerCase()));
      return;
    }
    setState(() {
      _groups = [..._groups, name];
      _filter = name;
    });
    await _storage.saveGroups(_groups);
  }

  Future<void> _deleteGroup(String g) async {
    if (g == kGroups.first) return; // "Personal" always stays
    final p = AppPalette.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(ctx.tr('grpDeleteTitle'), style: TextStyle(color: p.text)),
        content: Text(ctx.tr('grpDeleteBody'),
            style: TextStyle(color: p.subtext)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: p.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.tr('delete')),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() {
      _groups = _groups.where((x) => x != g).toList();
      _items = [
        for (final s in _items)
          s.group == g
              ? Subscription(
                  id: s.id,
                  name: s.name,
                  price: s.price,
                  cycle: s.cycle,
                  category: s.category,
                  startDate: s.startDate,
                  renewalDate: s.renewalDate,
                  active: s.active,
                  group: kGroups.first,
                  colorValue: s.colorValue,
                  iconKey: s.iconKey,
                )
              : s,
      ];
      if (_filter == g) _filter = 'all';
    });
    await _storage.saveGroups(_groups);
    await _persist();
  }

  Future<bool> _confirmDelete(Subscription s) async {
    final p = AppPalette.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(ctx.tr('deleteTitle'), style: TextStyle(color: p.text)),
        content: Text(ctx.deleteBody(s.name),
            style: TextStyle(color: p.subtext)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: p.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.tr('delete')),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _delete(Subscription s) async {
    final index = _items.indexWhere((e) => e.id == s.id);
    if (index < 0) return;
    setState(() => _items.removeAt(index));
    await _persist();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.deletedMsg(s.name)),
          action: SnackBarAction(
            label: context.tr('undo'),
            onPressed: () async {
              setState(() => _items.insert(index.clamp(0, _items.length).toInt(), s));
              await _persist();
            },
          ),
        ),
      );
  }

  Future<void> _confirmLogout() async {
    final p = AppPalette.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(ctx.tr('logout'), style: TextStyle(color: p.text)),
        content: Text(ctx.tr('logoutConfirm'),
            style: TextStyle(color: p.subtext)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: p.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.tr('logout')),
          ),
        ],
      ),
    );
    if (ok == true) widget.onLogout();
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('appTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('logout'),
            icon: const Icon(Icons.logout_rounded),
            onPressed: _confirmLogout,
          ),
          IconButton(
            tooltip: context.tr('settings'),
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => showSettingsSheet(context, widget.settings),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: p.accent))
          : AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _items.isEmpty
            ? _emptyState(context)
            : _list(context),
      ),
    );
  }

  Widget _list(BuildContext context) {
    final p = AppPalette.of(context);
    final sorted = _sorted;
    return ListView(
      key: const ValueKey('list'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
          child: Text(
            '${context.tr('hello')}${context.isAr ? '،' : ','} ${widget.user.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: p.subtext, fontSize: 15),
          ),
        ),
        SummaryCard(monthly: _monthlyTotal, yearly: _yearlyTotal),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              for (final g in ['all', ..._groups])
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: GestureDetector(
                    onLongPress: g == 'all' ? null : () => _deleteGroup(g),
                    child: ChoiceChip(
                      label: Text(g == 'all'
                          ? context.tr('grp.all')
                          : groupLabel(g, context.tr)),
                      selected: _filter == g,
                      onSelected: (_) => setState(() => _filter = g),
                    ),
                  ),
                ),
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: Text(context.tr('grpAdd')),
                onPressed: _addGroup,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < sorted.length; i++)
          _FadeSlide(
            key: ValueKey(sorted[i].id),
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Dismissible(
                key: ValueKey('dismiss-${sorted[i].id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(sorted[i]),
                onDismissed: (_) => _delete(sorted[i]),
                background: Container(
                  padding: const EdgeInsetsDirectional.only(end: 28),
                  decoration: BoxDecoration(
                    color: p.danger,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: AlignmentDirectional.centerEnd,
                  child: const Icon(Icons.delete_rounded,
                      color: Colors.white, size: 28),
                ),
                child: SubscriptionTile(
                  subscription: sorted[i],
                  onTap: () => _openForm(sorted[i]),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    final p = AppPalette.of(context);
    return Center(
      key: const ValueKey('empty'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: p.gradient),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.subscriptions_rounded,
                  size: 52, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('emptyTitle'),
              style: TextStyle(
                color: p.text,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('emptyBody'),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.subtext, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Makes each list item fade and slide up when it first appears.
class _FadeSlide extends StatelessWidget {
  final int index;
  final Widget child;

  const _FadeSlide({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final delay = math.min(index, 8) * 60;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + delay),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, v, child) {
        return Opacity(
          opacity: v.clamp(0.0, 1.0).toDouble(),
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - v)),
            child: child,
          ),
        );
      },
    );
  }
}