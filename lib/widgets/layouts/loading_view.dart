import 'package:fluffychat/pages/chat_blank/chat_blank.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:matrix/matrix.dart';
import 'package:fluffychat/utils/update_checker_no_store.dart';
import 'package:fluffychat/widgets/matrix.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await UpdateCheckerNoStore(context).checkUpdate();
        context.go(
          Matrix.of(context).widget.clients.any(
                    (client) =>
                        client.onLoginStateChanged.value == LoginState.loggedIn,
                  )
              ? '/rooms'
              : '/home',
          extra: GoRouterState.of(context).pathParameters,
        );
      },
    );
    return const ChatBlank(loading: true);
  }
}
