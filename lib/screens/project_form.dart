import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _techStack = '';
  String _projectUrl = '';
  String _projectImageUrl = '';
  bool _isSubmitting = false;

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Enter $label.';
    return null;
  }

  String? _validateUrl(String? value, {bool optional = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return optional ? null : 'Enter a project URL.';

    final uri = Uri.tryParse(text);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme.toLowerCase()) ||
        uri.host.isEmpty ||
        RegExp(r'\s').hasMatch(text) ||
        !_isValidHost(uri.host) ||
        (uri.hasPort && (uri.port < 1 || uri.port > 65535))) {
      return 'Enter a valid HTTP or HTTPS URL.';
    }
    return null;
  }

  bool _isValidHost(String host) {
    if (host == 'localhost' || host.contains(':')) return true;
    if (RegExp(r'^\d+(\.\d+){3}$').hasMatch(host)) {
      return host.split('.').every((part) => int.parse(part) <= 255);
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final newProject = Project(
      title: _title,
      description: _description,
      techStack: _techStack,
      projectUrl: _projectUrl,
      projectImageUrl: _projectImageUrl,
    );
    final authState = context.read<AuthState>();
    setState(() => _isSubmitting = true);

    try {
      if (!await ensureLoggedIn(context)) return;
      if (!mounted) return;
      final token = authState.token;
      if (token == null) {
        _showMessage('Please log in before saving your project.');
        return;
      }

      final created = await context.read<ApiClient>().createProject(
        newProject,
        token: token,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Project added successfully!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${created.title}'),
                Text('Description: ${created.description}'),
                Text('Tech Stack: ${created.techStack}'),
                Text('Project URL: ${created.projectUrl}'),
                Text(
                  'Project Image URL: ${created.projectImageUrl.isEmpty ? 'Not provided' : created.projectImageUrl}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        try {
          await authState.logout();
        } on Exception {
          // AuthState clears the local token even if remote logout fails.
        }
        if (!mounted) return;
        _showMessage('Session expired. Please log in again, then press Save.');
        await ensureLoggedIn(context);
      } else {
        if (!mounted) return;
        _showMessage(
          'Failed to save project (${error.statusCode}): ${error.message}',
        );
      }
    } on Exception {
      if (!mounted) return;
      _showMessage('Could not save the project. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _field({
    required String name,
    required String label,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: ValueKey('project-$name'),
        enabled: !_isSubmitting,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          errorMaxLines: 3,
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Form'),
        backgroundColor: const Color(0xFF93A9D1),
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                name: 'title',
                label: 'Title',
                onSaved: (value) => _title = value!.trim(),
                validator: (value) => _validateRequired(value, 'a title'),
              ),
              _field(
                name: 'description',
                label: 'Description',
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                onSaved: (value) => _description = value!.trim(),
                validator: (value) => _validateRequired(value, 'a description'),
              ),
              _field(
                name: 'tech-stack',
                label: 'Tech Stack',
                hint: 'Flutter, Django, PostgreSQL',
                onSaved: (value) => _techStack = value!.trim(),
                validator: (value) => _validateRequired(value, 'a tech stack'),
              ),
              _field(
                name: 'url',
                label: 'Project URL',
                hint: 'https://example.com/project',
                keyboardType: TextInputType.url,
                onSaved: (value) => _projectUrl = value!.trim(),
                validator: _validateUrl,
              ),
              _field(
                name: 'image-url',
                label: 'Project Image URL (Optional)',
                hint: 'https://example.com/project.png',
                keyboardType: TextInputType.url,
                onSaved: (value) => _projectImageUrl = value?.trim() ?? '',
                validator: (value) => _validateUrl(value, optional: true),
              ),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
