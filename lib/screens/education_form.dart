import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _institution = TextEditingController();
  final _major = TextEditingController();
  final _description = TextEditingController();
  final _thumbnail = TextEditingController();
  final _startYear = TextEditingController();
  final _endYear = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _title,
      _institution,
      _major,
      _description,
      _thumbnail,
      _startYear,
      _endYear,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateRequiredText(String? value, String label, {int? maxLength}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Enter $label.';
    }
    if (maxLength != null && text.runes.length > maxLength) {
      return 'Use at most $maxLength characters.';
    }
    return null;
  }

  String? _validateYear(String? value, {bool optional = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return optional ? null : 'Enter a start year.';
    }
    final year = int.tryParse(text);
    // Education uses Django PositiveSmallIntegerField (0 through 32767).
    if (!RegExp(r'^\d+$').hasMatch(text) ||
        year == null ||
        year < 0 ||
        year > 32767) {
      return 'Enter a whole year from 0 to 32767.';
    }
    return null;
  }

  String? _validateEndYear(String? value) {
    final error = _validateYear(value, optional: true);
    if (error != null) return error;
    final end = int.tryParse(value?.trim() ?? '');
    final start = int.tryParse(_startYear.text.trim());
    if (end != null && start != null && end < start) {
      return 'End year must not be before start year.';
    }
    return null;
  }

  String? _validateThumbnail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.runes.length > 500) {
      return 'Use at most 500 characters.';
    }
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme.toLowerCase()) ||
        uri.host.isEmpty ||
        RegExp(r'\s').hasMatch(text) ||
        !_isValidHost(uri.host) ||
        (uri.hasPort && uri.port > 65535)) {
      return 'Enter a valid HTTP or HTTPS URL.';
    }
    return null;
  }

  bool _isValidHost(String host) {
    if (host == 'localhost' || host.contains(':')) return true;
    if (RegExp(r'^\d+(\.\d+){3}$').hasMatch(host)) {
      return host.split('.').every((part) {
        final number = int.tryParse(part);
        return number != null && number <= 255;
      });
    }
    final domain = host.endsWith('.')
        ? host.substring(0, host.length - 1)
        : host;
    final labels = domain.split('.');
    final labelPattern = RegExp(
      r'^[a-zA-Z0-9\u00a1-\uffff](?:[a-zA-Z0-9\u00a1-\uffff-]{0,61}[a-zA-Z0-9\u00a1-\uffff])?$',
    );
    return domain.length <= 253 &&
        labels.length >= 2 &&
        labels.every(labelPattern.hasMatch) &&
        labels.last.length >= 2 &&
        !RegExp(r'^\d+$').hasMatch(labels.last);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final thumbnail = _thumbnail.text.trim();
    final endYear = _endYear.text.trim();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Education added successfully!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Education Title: ${_title.text.trim()}'),
              Text('Institution: ${_institution.text.trim()}'),
              Text('Major: ${_major.text.trim()}'),
              Text('Description: ${_description.text.trim()}'),
              Text(
                'Thumbnail URL: ${thumbnail.isEmpty ? 'Not provided' : thumbnail}',
              ),
              Text('Start Year: ${_startYear.text.trim()}'),
              Text('End Year: ${endYear.isEmpty ? 'Ongoing' : endYear}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String name,
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: ValueKey('education-$name'),
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          errorMaxLines: 3,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Education',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _field(
                  name: 'title',
                  label: 'Education Title',
                  hint: 'Bachelor of Information Systems',
                  controller: _title,
                  validator: (value) => _validateRequiredText(
                    value,
                    'an education title',
                    maxLength: 255,
                  ),
                ),
                _field(
                  name: 'institution',
                  label: 'Institution',
                  hint: 'Universitas Indonesia',
                  controller: _institution,
                  validator: (value) => _validateRequiredText(
                    value,
                    'an institution',
                    maxLength: 255,
                  ),
                ),
                _field(
                  name: 'major',
                  label: 'Major',
                  hint: 'Information Systems',
                  controller: _major,
                  validator: (value) =>
                      _validateRequiredText(value, 'a major', maxLength: 255),
                ),
                _field(
                  name: 'description',
                  label: 'Description',
                  hint: 'Describe your education and activities',
                  controller: _description,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  validator: (value) =>
                      _validateRequiredText(value, 'a description'),
                ),
                _field(
                  name: 'thumbnail',
                  label: 'Thumbnail URL (optional)',
                  hint: 'https://example.com/institution.png',
                  controller: _thumbnail,
                  keyboardType: TextInputType.url,
                  validator: _validateThumbnail,
                ),
                _field(
                  name: 'start-year',
                  label: 'Start Year',
                  hint: '2025',
                  controller: _startYear,
                  keyboardType: TextInputType.number,
                  validator: _validateYear,
                ),
                _field(
                  name: 'end-year',
                  label: 'End Year (optional)',
                  hint: 'Leave blank if ongoing',
                  controller: _endYear,
                  keyboardType: TextInputType.number,
                  validator: _validateEndYear,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
