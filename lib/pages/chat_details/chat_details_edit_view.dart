import 'package:dartz/dartz.dart';
import 'package:fluffychat/app_state/failure.dart';
import 'package:fluffychat/app_state/success.dart';
import 'package:fluffychat/pages/chat_details/chat_details_edit.dart';
import 'package:fluffychat/pages/chat_details/chat_details_edit_option.dart';
import 'package:fluffychat/pages/chat_details/chat_details_edit_ui_state/upload_avatar_ui_state.dart';
import 'package:fluffychat/pages/chat_details/chat_details_edit_view_style.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/avatar/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:linagora_design_flutter/colors/linagora_sys_colors.dart';
import 'package:matrix/matrix.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class ChatDetailsEditView extends StatelessWidget {
  final ChatDetailsEditController controller;

  const ChatDetailsEditView(
    this.controller, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.room == null) {
      return Scaffold(
        backgroundColor: LinagoraSysColors.material().onPrimary,
        appBar: AppBar(
          backgroundColor: LinagoraSysColors.material().onPrimary,
          title: Text(L10n.of(context)!.oopsSomethingWentWrong),
        ),
        body: Center(
          child: Text(L10n.of(context)!.youAreNoLongerParticipatingInThisChat),
        ),
      );
    }

    return Scaffold(
      backgroundColor: LinagoraSysColors.material().onPrimary,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: LinagoraSysColors.material().onPrimary,
        title: Row(
          children: [
            Padding(
              padding: ChatDetailEditViewStyle.backIconPadding,
              child: IconButton(
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                onPressed: controller.onBack,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            Text(
              L10n.of(context)!.edit,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            ValueListenableBuilder(
              valueListenable: controller.isEditedGroupInfoNotifier,
              builder: (context, value, child) {
                if (!value) {
                  return const SizedBox.shrink();
                }
                return child!;
              },
              child: Padding(
                padding: ChatDetailEditViewStyle.doneIconPadding,
                child: IconButton(
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onPressed: () => controller.handleSaveAction(context),
                  icon: const Icon(Icons.done),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: ChatDetailEditViewStyle.editAvatarPadding,
              child: Center(
                child: Stack(
                  children: [
                    Padding(
                      padding: ChatDetailEditViewStyle.avatarPadding,
                      child: SizedBox(
                        width: ChatDetailEditViewStyle.avatarSize(context),
                        height: ChatDetailEditViewStyle.avatarSize(context),
                        child: Hero(
                          tag: 'content_banner',
                          child: _AvatarBuilder(
                            updateGroupAvatarNotifier:
                                controller.updateGroupAvatarNotifier,
                            room: controller.room!,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: ValueListenableBuilder(
                        valueListenable: controller.isEditedGroupInfoNotifier,
                        builder: (context, _, __) {
                          return MenuAnchor(
                            controller: controller.menuController,
                            alignmentOffset: ChatDetailEditViewStyle
                                .contextMenuAlignmentOffset(context),
                            builder: (
                              BuildContext context,
                              MenuController menuController,
                              Widget? child,
                            ) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                padding:
                                    ChatDetailEditViewStyle.editIconPadding,
                                child: ElevatedButton(
                                  onPressed: () => {
                                    menuController.isOpen
                                        ? menuController.close()
                                        : menuController.open(),
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      const CircleBorder(),
                                    ),
                                    padding: MaterialStateProperty.all(
                                      ChatDetailEditViewStyle
                                          .editIconMaterialPadding,
                                    ),
                                    iconColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.onPrimary,
                                    ),
                                    backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    size: ChatDetailEditViewStyle.editIconSize,
                                  ),
                                ),
                              );
                            },
                            menuChildren:
                                controller.listContextMenuBuilder(context),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: ChatDetailEditViewStyle.avatarAndTextFieldsGap,
            ),
            Padding(
              padding: ChatDetailEditViewStyle.editAvatarPadding,
              child: Column(
                children: [
                  _GroupNameField(controller: controller),
                  const SizedBox(
                    height: ChatDetailEditViewStyle.textFieldsGap,
                  ),
                  _DescriptionField(controller: controller),
                ],
              ),
            ),
            Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                L10n.of(context)!.dangerZone,
                style: ChatDetailEditViewStyle.textChatDetailsEditCategoryStyle(
                  context,
                ),
              ),
            ),
            ChatDetailsEditOption(
              title: L10n.of(context)!.commandHint_leave,
              subtitle: L10n.of(context)!.leaveGroupSubtitle,
              leading: Icons.logout_outlined,
              titleColor: Theme.of(context).colorScheme.error,
              leadingIconColor: Theme.of(context).colorScheme.error,
              onTap: () => controller.leaveChat(context, controller.room),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarBuilder extends StatelessWidget {
  final ValueNotifier<Either<Failure, Success>> updateGroupAvatarNotifier;
  final Room room;

  const _AvatarBuilder({
    required this.updateGroupAvatarNotifier,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: updateGroupAvatarNotifier,
      builder: (context, value, child) => value.fold(
        (failure) => const SizedBox(),
        (success) {
          if (PlatformInfos.isMobile &&
              success is ChatDetailsGetAvatarInStreamSuccess) {
            return ClipOval(
              child: SizedBox.fromSize(
                size: const Size.fromRadius(
                  ChatDetailEditViewStyle.avatarRadiusForMobile,
                ),
                child: AssetEntityImage(
                  success.assetEntity,
                  thumbnailSize: const ThumbnailSize(
                    ChatDetailEditViewStyle.thumbnailSizeWidth,
                    ChatDetailEditViewStyle.thumbnailSizeHeight,
                  ),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress != null &&
                        loadingProgress.cumulativeBytesLoaded !=
                            loadingProgress.expectedTotalBytes) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }
                    return child;
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error_outline),
                    );
                  },
                ),
              ),
            );
          }

          if (PlatformInfos.isWeb &&
              success is ChatDetailsGetAvatarInByteSuccess) {
            return ClipOval(
              child: SizedBox.fromSize(
                size: const Size.fromRadius(
                  ChatDetailEditViewStyle.avatarRadiusForWeb,
                ),
                child: Image.memory(
                  success.filePickerResult.files.single.bytes!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error_outline),
                    );
                  },
                ),
              ),
            );
          }

          if (success is ChatDetailsDeleteAvatarSuccess) {
            return Avatar(
              fontSize: ChatDetailEditViewStyle.avatarFontSize,
              name: room.getLocalizedDisplayname(
                MatrixLocals(L10n.of(context)!),
              ),
              size: ChatDetailEditViewStyle.avatarSize(context),
            );
          }

          return child!;
        },
      ),
      child: Avatar(
        fontSize: ChatDetailEditViewStyle.avatarFontSize,
        mxContent: room.avatar,
        name: room.getLocalizedDisplayname(
          MatrixLocals(L10n.of(context)!),
        ),
        size: ChatDetailEditViewStyle.avatarSize(context),
      ),
    );
  }
}

class _GroupNameField extends StatelessWidget {
  const _GroupNameField({
    required this.controller,
  });

  final ChatDetailsEditController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ChatDetailEditViewStyle.textFieldPadding,
      child: TextField(
        style: ChatDetailEditViewStyle.textFieldStyle(context),
        controller: controller.groupNameTextEditingController,
        focusNode: controller.groupNameFocusNode,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.shadow),
          ),
          labelText: L10n.of(context)!.widgetName,
          labelStyle: ChatDetailEditViewStyle.textFieldLabelStyle(context),
          hintText: L10n.of(context)!.enterGroupName,
          hintStyle: ChatDetailEditViewStyle.textFieldHintStyle(context),
          contentPadding: ChatDetailEditViewStyle.contentPadding,
          suffixIcon: ValueListenableBuilder<bool>(
            valueListenable: controller.groupNameEmptyNotifier,
            builder: (context, isGroupNameEmpty, child) {
              if (isGroupNameEmpty) {
                return child!;
              }

              return IconButton(
                onPressed: () =>
                    controller.groupNameTextEditingController.clear(),
                icon: Icon(
                  Icons.cancel_outlined,
                  size: ChatDetailEditViewStyle.clearIconSize,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            },
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({
    required this.controller,
  });

  final ChatDetailsEditController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ChatDetailEditViewStyle.textFieldPadding,
      child: Column(
        children: [
          TextField(
            style: ChatDetailEditViewStyle.textFieldStyle(context),
            controller: controller.descriptionTextEditingController,
            focusNode: controller.descriptionFocusNode,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.shadow),
              ),
              labelText: L10n.of(context)!.description,
              labelStyle: ChatDetailEditViewStyle.textFieldLabelStyle(context),
              hintText: L10n.of(context)!.description,
              hintStyle: ChatDetailEditViewStyle.textFieldHintStyle(context),
              contentPadding: ChatDetailEditViewStyle.contentPadding,
              suffixIcon: ValueListenableBuilder<bool>(
                valueListenable: controller.descriptionEmptyNotifier,
                builder: (context, isDescriptionEmpty, child) {
                  if (isDescriptionEmpty) {
                    return child!;
                  }

                  return IconButton(
                    onPressed: () =>
                        controller.descriptionTextEditingController.clear(),
                    icon: Icon(
                      Icons.cancel_outlined,
                      size: ChatDetailEditViewStyle.clearIconSize,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                },
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(
            height: 2.0,
          ),
          Text(
            L10n.of(context)!.descriptionHelper,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
