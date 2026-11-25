import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Project Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (project.projectImageUrl.trim().isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    project.projectImageUrl,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(
                          height: 120,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.broken_image_outlined, size: 40),
                                SizedBox(height: 8),
                                Text('Project image could not be loaded.'),
                              ],
                            ),
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(project.title, style: textTheme.headlineSmall),
              const SizedBox(height: 24),
              Text('Description', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(project.description),
              const SizedBox(height: 24),
              Text('Tech Stack', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(project.techStack),
              const SizedBox(height: 24),
              Text('Project URL', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              SelectableText(project.projectUrl),
            ],
          ),
        ),
      ),
    );
  }
}
