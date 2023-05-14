import 'package:clashify/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsInputDialog<T> extends HookConsumerWidget with PresLogger {
  const SettingsInputDialog({
    super.key,
    required this.title,
    required this.onConfirm,
    this.initialValue,
    this.icon,
  });

  final String title;
  final ValueChanged<String> onConfirm;
  final T? initialValue;
  final IconData? icon;

  Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = MaterialLocalizations.of(context);

    final textController = useTextEditingController(
      text: initialValue?.toString(),
    );

    return AlertDialog(
      title: Text(title),
      icon: Icon(icon),
      content: TextFormField(
        controller: textController,
        inputFormatters: [
          FilteringTextInputFormatter.singleLineFormatter,
        ],
        autovalidateMode: AutovalidateMode.always,
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Navigator.of(context).maybePop();
          },
          child: Text(localizations.cancelButtonLabel.toUpperCase()),
        ),
        TextButton(
          onPressed: () async {
            onConfirm(textController.value.text);
            await Navigator.of(context).maybePop();
          },
          child: Text(localizations.okButtonLabel.toUpperCase()),
        ),
      ],
    );
  }
}
