import 'package:flutter/material.dart';

import '../../../../core/widgets/ornamented_card.dart';
import 'test_intro_card_row.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class TestIntroCard extends StatelessWidget {
  const TestIntroCard({required this.rows, super.key});

  final List<TestIntroRow> rows;

  @override
  Widget build(BuildContext context) {
    return OrnamentedCard(
      leading: null,
      trailing: null,
      padding: EdgeInsets.symmetric(horizontal: (12).w(context), vertical: (4).h(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int index = 0; index < rows.length; index++) ...<Widget>[
            if (index > 0)
              Divider(
                height: (1).h(context),
                thickness: 1,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.08),
              ),

            TestIntroCardRow(row: rows[index]),
          ],
        ],
      ),
    );
  }
}

class TestIntroRow {
  const TestIntroRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
