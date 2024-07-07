import 'package:fluffychat/presentation/model/chat/downloading_state_presentation_model.dart';
import 'package:fluffychat/utils/extension/mime_type_extension.dart';
import 'package:fluffychat/widgets/file_widget/base_file_tile_widget.dart';
import 'package:fluffychat/widgets/file_widget/circular_loading_download_widget.dart';
import 'package:fluffychat/widgets/file_widget/file_tile_widget.dart';
import 'package:fluffychat/widgets/file_widget/message_file_tile_style.dart';
import 'package:flutter/material.dart';

class DownloadFileTileWidget extends StatelessWidget {
  const DownloadFileTileWidget({
    super.key,
    this.style = const MessageFileTileStyle(),
    required this.mimeType,
    required this.filename,
    this.highlightText,
    this.fileType,
    this.sizeString,
    required this.downloadFileStateNotifier,
    this.onCancelDownload,
    this.hasError = false,
  });

  final TwakeMimeType mimeType;
  final String filename;
  final MessageFileTileStyle style;
  final String? highlightText;
  final String? sizeString;
  final String? fileType;
  final ValueNotifier<DownloadPresentationState> downloadFileStateNotifier;
  final VoidCallback? onCancelDownload;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: style.paddingFileTileAll,
      decoration: ShapeDecoration(
        color: style.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: style.borderRadius,
        ),
      ),
      child: Row(
        crossAxisAlignment: style.crossAxisAlignment,
        children: [
          ValueListenableBuilder(
            valueListenable: downloadFileStateNotifier,
            builder: (context, downloadFileState, child) {
              double? downloadProgress;
              if (downloadFileState is DownloadingPresentationState) {
                if (downloadFileState.total == null ||
                    downloadFileState.receive == null) {
                  downloadProgress = null;
                } else {
                  downloadProgress =
                      downloadFileState.receive! / downloadFileState.total!;
                }
              } else if (downloadFileState is NotDownloadPresentationState) {
                downloadProgress = 0;
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    margin: style.marginDownloadIcon,
                    width: style.iconSize,
                    height: style.iconSize,
                    decoration: BoxDecoration(
                      color: style.iconBackgroundColor(
                        hasError: hasError,
                        context: context,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (downloadProgress != 0 && !hasError)
                    SizedBox(
                      width: style.circularProgressLoadingSize,
                      height: style.circularProgressLoadingSize,
                      child: CircularLoadingDownloadWidget(
                        style: style,
                        downloadProgress: downloadProgress,
                      ),
                    ),
                  Container(
                    width: style.downloadIconSize,
                    decoration: BoxDecoration(
                      color: style.iconBackgroundColor(
                        hasError: hasError,
                        context: context,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasError
                          ? Icons.error_outline
                          : downloadProgress == 0
                              ? Icons.arrow_downward
                              : Icons.close,
                      key: ValueKey(downloadProgress),
                      color: Theme.of(context).colorScheme.surface,
                      size: style.downloadIconSize,
                    ),
                  ),
                  InkWell(
                    onTap: onCancelDownload,
                    mouseCursor: SystemMouseCursors.click,
                    child: SizedBox(
                      width: style.downloadIconSize * 1.5,
                      height: style.downloadIconSize * 1.5,
                    ),
                  ),
                ],
              );
            },
          ),
          style.paddingRightIcon,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 4.0),
                FileNameText(
                  filename: filename,
                  highlightText: highlightText,
                  style: style,
                ),
                Row(
                  children: [
                    if (sizeString != null)
                      TextInformationOfFile(
                        value: sizeString!,
                        style: style.textInformationStyle(context),
                        downloadFileStateNotifier: downloadFileStateNotifier,
                      ),
                    TextInformationOfFile(
                      value: " · ",
                      style: style.textInformationStyle(context),
                    ),
                    Flexible(
                      child: TextInformationOfFile(
                        value: mimeType.getFileType(
                          context,
                          fileType: fileType,
                        ),
                        style: style.textInformationStyle(context),
                      ),
                    ),
                  ],
                ),
                style.paddingBottomText,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
