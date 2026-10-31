import 'package:flutter/material.dart';

import 'strings.dart';
import 'settings_controller.dart';
import 'subscription.dart';
import 'app_theme.dart';
import 'date_utils.dart';
import 'subscription_tile.dart';

/// Used for both adding a new subscription and editing an existing one.
class SubscriptionFormScreen extends StatefulWidget {
  final Subscription? existing;
  final List<String> groups;

  const SubscriptionFormScreen(
      {super.key, this.existing, this.groups = kGroups});

  @override
  State<SubscriptionFormScreen> createState() => _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState extends State<SubscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final String _initialPrice;
  late BillingCycle _cycle;
  late String _category;
  late String _group;
  late DateTime _start;
  late DateTime _renewal;
  late bool _active;
  late int _color;
  late String _icon;
  bool _renewalPickedManually = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _initialPrice =
        e == null ? '' : SettingsController.fromSar(e.price).toStringAsFixed(2);
    _priceCtrl = TextEditingController(text: _initialPrice);
    _cycle = e?.cycle ?? BillingCycle.monthly;
    _category = e?.category ?? kCategories.first;
    _start = e?.startDate ?? dateOnly(DateTime.now());
    _renewal = e?.renewalDate ?? addMonths(_start, _cycle.months);
    _active = e?.active ?? true;
    _group = e?.group ?? kGroups.first;
    _color = e?.colorValue ?? kDefaultSubColor;
    _icon = e?.iconKey ?? 'auto';
    _renewalPickedManually = e != null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _suggestRenewal() {
    if (!_renewalPickedManually) {
      _renewal = addMonths(_start, _cycle.months);
    }
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  String _cycleLabel(BillingCycle c) {
    switch (c) {
      case BillingCycle.monthly:
        return context.tr('monthly');
      case BillingCycle.quarterly:
        return context.tr('quarterly');
      case BillingCycle.yearly:
        return context.tr('yearly');
    }
  }

  InputDecoration _dec(String label, IconData icon, {String? suffix}) {
    final p = AppPalette.of(context);
    OutlineInputBorder border(Color c, [double w = 0]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: w == 0 ? BorderSide.none : BorderSide(color: c, width: w),
    );
    return InputDecoration(
      labelText: label,
      suffixText: suffix,
      labelStyle: TextStyle(color: p.subtext),
      floatingLabelStyle: TextStyle(color: p.accent),
      prefixIcon: Icon(icon, color: p.accent),
      filled: true,
      fillColor: p.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: border(p.surface),
      enabledBorder: border(p.surface),
      focusedBorder: border(p.accent, 1.6),
      errorBorder: border(p.danger, 1.2),
      focusedErrorBorder: border(p.danger, 1.6),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    // Prices are stored in SAR. Keep the old value if the text was not changed.
    final price = (widget.existing != null &&
            _priceCtrl.text.trim() == _initialPrice)
        ? widget.existing!.price
        : SettingsController.toSar(
            double.parse(_priceCtrl.text.trim().replaceAll(',', '.')));
    final id = widget.existing?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();
    Navigator.of(context).pop(
      Subscription(
        id: id,
        name: _nameCtrl.text.trim(),
        price: price,
        cycle: _cycle,
        category: _category,
        startDate: _start,
        renewalDate: _renewal,
        active: _active,
        group: _group,
        colorValue: _color,
        iconKey: _icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final ar = context.isAr;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(_isEdit ? 'editTitle' : 'addTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('saveChanges'),
            icon: const Icon(Icons.check_rounded, size: 28),
            onPressed: _save,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(color: p.text),
                decoration: _dec(context.tr('name'), Icons.label_rounded),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.tr('nameReq')
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: p.text),
                decoration: _dec(
                  context.tr('price'),
                  Icons.payments_rounded,
                  suffix: context.currencyLabel,
                ),
                validator: (v) {
                  final value =
                  double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                  if (value == null) return context.tr('priceInvalid');
                  if (value <= 0) return context.tr('pricePositive');
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BillingCycle>(
                initialValue: _cycle,
                dropdownColor: p.surface,
                borderRadius: BorderRadius.circular(18),
                style: TextStyle(color: p.text, fontSize: 16),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: p.subtext),
                decoration: _dec(context.tr('cycle'), Icons.repeat_rounded),
                items: [
                  for (final c in BillingCycle.values)
                    DropdownMenuItem(value: c, child: Text(_cycleLabel(c))),
                ],
                onChanged: (c) {
                  if (c == null) return;
                  setState(() {
                    _cycle = c;
                    _suggestRenewal();
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _group,
                dropdownColor: p.surface,
                borderRadius: BorderRadius.circular(18),
                style: TextStyle(color: p.text, fontSize: 16),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: p.subtext),
                decoration: _dec(context.tr('group'), Icons.folder_rounded),
                items: [
                  for (final g in {...widget.groups, _group})
                    DropdownMenuItem(
                        value: g, child: Text(groupLabel(g, context.tr))),
                ],
                onChanged: (g) {
                  if (g != null) setState(() => _group = g);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                dropdownColor: p.surface,
                borderRadius: BorderRadius.circular(18),
                style: TextStyle(color: p.text, fontSize: 16),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: p.subtext),
                decoration: _dec(context.tr('category'), Icons.category_rounded),
                items: [
                  for (final c in kCategories)
                    DropdownMenuItem(value: c, child: Text(context.category(c))),
                ],
                onChanged: (c) {
                  if (c != null) setState(() => _category = c);
                },
              ),
              const SizedBox(height: 16),
              _DateField(
                decoration: _dec(context.tr('startDate'), Icons.event_available_rounded),
                text: formatDate(_start, ar: ar),
                onTap: () async {
                  final picked = await _pickDate(_start);
                  if (picked == null) return;
                  setState(() {
                    _start = picked;
                    _suggestRenewal();
                  });
                },
              ),
              const SizedBox(height: 16),
              _DateField(
                decoration: _dec(context.tr('renewalDate'), Icons.event_repeat_rounded),
                text: formatDate(_renewal, ar: ar),
                onTap: () async {
                  final picked = await _pickDate(_renewal);
                  if (picked == null) return;
                  setState(() {
                    _renewal = picked;
                    _renewalPickedManually = true;
                  });
                },
              ),
              const SizedBox(height: 16),
              _AppearancePicker(
                color: _color,
                icon: _icon,
                category: _category,
                onColor: (c) => setState(() => _color = c),
                onIcon: (i) => setState(() => _icon = i),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: SwitchListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  activeThumbColor: Colors.white,
                  activeTrackColor: p.accent,
                  title: Text(context.tr('active'),
                      style: TextStyle(
                          color: p.text, fontWeight: FontWeight.w600)),
                  subtitle: Text(context.tr('activeHint'),
                      style: TextStyle(color: p.subtext, fontSize: 12.5)),
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: p.gradient,
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: p.gradient.first.withAlpha(70),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: _save,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            context.tr(_isEdit ? 'saveChanges' : 'addSub'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final InputDecoration decoration;
  final String text;
  final VoidCallback onTap;

  const _DateField({
    required this.decoration,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: InputDecorator(
        decoration: decoration,
        child: Text(text, style: TextStyle(color: p.text, fontSize: 16)),
      ),
    );
  }
}

/// Lets the user choose the circle color and icon of a subscription.
class _AppearancePicker extends StatelessWidget {
  final int color;
  final String icon;
  final String category;
  final ValueChanged<int> onColor;
  final ValueChanged<String> onIcon;

  const _AppearancePicker({
    required this.color,
    required this.icon,
    required this.category,
    required this.onColor,
    required this.onIcon,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final shownIcon = kSubIcons[icon] ?? categoryIcon(category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Color(color),
                shape: BoxShape.circle,
              ),
              child: Icon(shownIcon, color: Colors.white, size: 34),
            ),
          ),
          const SizedBox(height: 18),
          Text(context.tr('color'), style: TextStyle(color: p.subtext)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in kSubColors)
                GestureDetector(
                  onTap: () => onColor(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == c ? p.text : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: color == c
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(context.tr('icon'), style: TextStyle(color: p.subtext)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final entry in kSubIcons.entries)
                GestureDetector(
                  onTap: () => onIcon(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: icon == entry.key ? Color(color) : p.bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      entry.value,
                      size: 24,
                      color: icon == entry.key ? Colors.white : p.subtext,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
