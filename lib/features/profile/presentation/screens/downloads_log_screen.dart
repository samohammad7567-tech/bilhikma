import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/prd_services.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../textbooks/presentation/screens/book_preview_screen.dart';

class DownloadsLogScreen extends StatefulWidget {
  const DownloadsLogScreen({super.key});

  @override
  State<DownloadsLogScreen> createState() => _DownloadsLogScreenState();
}

class _DownloadsLogScreenState extends State<DownloadsLogScreen> {
  late Future<List<File>> _files = _load();

  Future<List<File>> _load() async {
    final Directory directory = await PdfService.libraryDirectory();
    if (!directory.existsSync()) return const <File>[];

    final List<File> files = directory
        .listSync()
        .whereType<File>()
        .where((File file) => file.path.toLowerCase().endsWith('.pdf'))
        .toList();

    files.sort(
      (File a, File b) =>
          b.statSync().modified.compareTo(a.statSync().modified),
    );

    return files;
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionScaffold(
      title: context.tr('downloads_log'),
      child: FutureBuilder<List<File>>(
        future: _files,
        builder: (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<File> files = snapshot.data ?? const <File>[];

          if (files.isEmpty) {
            return const AppEmptyView(
              icon: Icons.download_outlined,
              messageKey: 'no_downloads',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() => _files = _load()),
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              itemCount: files.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (BuildContext context, int index) =>
                  _DownloadRow(file: files[index]),
            ),
          );
        },
      ),
    );
  }
}

class _DownloadRow extends StatelessWidget {
  const _DownloadRow({required this.file});

  final File file;

  String get _name => file.uri.pathSegments.last;

  String get _size {
    final int bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.tertiaryContainer,
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(Icons.picture_as_pdf, color: colors.primary, size: 26.w),
        title: Text(
          _name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Text(_size, style: Theme.of(context).textTheme.bodySmall),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.bookPreview,
          arguments: BookPreviewArgs(
            filePath: file.path,
            title: _name.replaceAll('.pdf', ''),
          ),
        ),
      ),
    );
  }
}
