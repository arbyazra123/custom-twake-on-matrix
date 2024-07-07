import 'package:fluffychat/utils/dialog/twake_dialog.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';

import 'settings_ignore_list_view.dart';

class SettingsIgnoreList extends StatefulWidget {
  final String? initialUserId;

  const SettingsIgnoreList({super.key, this.initialUserId});

  @override
  SettingsIgnoreListController createState() => SettingsIgnoreListController();
}

class SettingsIgnoreListController extends State<SettingsIgnoreList> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialUserId != null) {
      controller.text = widget.initialUserId!.replaceAll('@', '');
    }
  }

  void ignoreUser(BuildContext context) {
    if (controller.text.isEmpty) return;
    final userId = '@${controller.text}';

    TwakeDialog.showFutureLoadingDialogFullScreen(
      future: () => Matrix.of(context).client.ignoreUser(userId),
    );
    controller.clear();
  }

  @override
  Widget build(BuildContext context) => SettingsIgnoreListView(this);
}
