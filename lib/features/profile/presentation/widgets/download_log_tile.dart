import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/models/download_log_item.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class DownloadLogTile extends StatelessWidget {
  const DownloadLogTile({
    required this.item,
    required this.isDeleting,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final DownloadLogItem item;

  final bool isDeleting;

  final VoidCallback onTap;

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Opacity(
      opacity: isDeleting ? 0.5 : 1,
      child: Material(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular((12).r(context)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          enabled: !isDeleting,
          leading: Icon(
            Icons.picture_as_pdf,
            color: colors.primary,
            size: (26).r(context),
          ),
          title: Text(
            item.fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            item.formattedSize,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: _DeleteAction(
            isDeleting: isDeleting,
            onDelete: onDelete,
            color: colors.error,
          ),
          onTap: isDeleting ? null : onTap,
        ),
      ),
    );
  }
}

class _DeleteAction extends StatelessWidget {
  const _DeleteAction({
    required this.isDeleting,
    required this.onDelete,
    required this.color,
  });

  final bool isDeleting;
  final VoidCallback onDelete;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (isDeleting) {
      return SizedBox(
        width: (22).w(context),
        height: (22).h(context),
        child: CircularProgressIndicator(strokeWidth: (2).r(context), color: color),
      );
    }

    return IconButton(
      onPressed: onDelete,
      visualDensity: VisualDensity.compact,
      tooltip: 'delete_download'.tr(),
      icon: Icon(Icons.delete_outline, size: (22).r(context), color: color),
    );
  }
}
