import 'package:excise/data/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BodyMeasurementInputDialog extends StatefulWidget {
  final BodyMeasurement? existing;
  const BodyMeasurementInputDialog({super.key, this.existing});

  @override
  State<BodyMeasurementInputDialog> createState() => _BodyMeasurementInputDialogState();
}

class _BodyMeasurementInputDialogState extends State<BodyMeasurementInputDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightCtrl;
  late TextEditingController _bodyFatCtrl;
  late TextEditingController _chestCtrl;
  late TextEditingController _waistCtrl;
  late TextEditingController _hipCtrl;
  late TextEditingController _armCtrl;
  late TextEditingController _thighCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _weightCtrl = TextEditingController(text: (e != null && e.weight > 0) ? e.weight.toStringAsFixed(1) : '');
    _bodyFatCtrl = TextEditingController(text: (e != null && e.bodyFatPercent > 0) ? e.bodyFatPercent.toStringAsFixed(1) : '');
    _chestCtrl = TextEditingController(text: (e != null && e.chest > 0) ? e.chest.toStringAsFixed(1) : '');
    _waistCtrl = TextEditingController(text: (e != null && e.waist > 0) ? e.waist.toStringAsFixed(1) : '');
    _hipCtrl = TextEditingController(text: (e != null && e.hip > 0) ? e.hip.toStringAsFixed(1) : '');
    _armCtrl = TextEditingController(text: (e != null && e.arm > 0) ? e.arm.toStringAsFixed(1) : '');
    _thighCtrl = TextEditingController(text: (e != null && e.thigh > 0) ? e.thigh.toStringAsFixed(1) : '');
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _bodyFatCtrl.dispose();
    _chestCtrl.dispose();
    _waistCtrl.dispose();
    _hipCtrl.dispose();
    _armCtrl.dispose();
    _thighCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.existing == null ? '记录身体数据' : '编辑身体数据'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _buildTextField(_weightCtrl, '体重 (kg)', 'weight', theme),
            _buildTextField(_bodyFatCtrl, '体脂率 (%)', 'bodyFat', theme),
            const SizedBox(height: 12),
            Text('围度测量（cm）', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildTextField(_chestCtrl, '胸围', 'chest', theme)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_waistCtrl, '腰围', 'waist', theme)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildTextField(_hipCtrl, '臀围', 'hip', theme)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_armCtrl, '臂围', 'arm', theme)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildTextField(_thighCtrl, '腿围', 'thigh', theme)),
            ]),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, BodyMeasurement(
                id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                date: widget.existing?.date ?? DateTime.now(),
                weight: double.tryParse(_weightCtrl.text) ?? 0,
                bodyFatPercent: double.tryParse(_bodyFatCtrl.text) ?? 0,
                chest: double.tryParse(_chestCtrl.text) ?? 0,
                waist: double.tryParse(_waistCtrl.text) ?? 0,
                hip: double.tryParse(_hipCtrl.text) ?? 0,
                arm: double.tryParse(_armCtrl.text) ?? 0,
                thigh: double.tryParse(_thighCtrl.text) ?? 0,
              ));
            }
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, String key, ThemeData theme) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d+)?$'))],
      decoration: InputDecoration(
        labelText: label,
        suffixText: key == 'weight' ? 'kg' : 'cm',
        border: const OutlineInputBorder(),
      ),
      validator: (v) => (v == null || v.isEmpty) ? null : (double.tryParse(v) == null ? '请输入有效数字' : null),
    );
  }
}