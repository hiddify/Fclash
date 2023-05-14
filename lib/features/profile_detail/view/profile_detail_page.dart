import 'package:clashify/core/core_providers.dart';
import 'package:clashify/features/profile_detail/notifier/notifier.dart';
import 'package:clashify/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class ProfileDetailPage extends HookConsumerWidget with PresLogger {
  const ProfileDetailPage(
    this.id, {
    super.key,
    this.url,
  });

  final String id;
  final String? url;

  Tuple2<String, String> get _providerId => Tuple2(id, url ?? '');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(Core.translations);
    final asyncState = ref.watch(ProfileDetailNotifier.provider(_providerId));
    final notifier =
        ref.watch(ProfileDetailNotifier.provider(_providerId).notifier);

    ref.listen(
      ProfileDetailNotifier.provider(_providerId)
          .select((data) => data.whenData((value) => value.save)),
      (_, next) {
        next.whenOrNull(
          data: (saveState) {
            saveState.whenOrNull(
              success: () {
                loggy.debug('save successful, popping screen');
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );

    return asyncState.maybeWhen(
      data: (state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(t.profileDetail.pageTitle.titleCase),
            actions: [
              IconButton(
                onPressed: notifier.save,
                icon: const Icon(Icons.save),
              ),
            ],
          ),
          body: Form(
            autovalidateMode: state.showErrorMessages
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: state.profile.name,
                  onChanged: (value) => notifier.setField(name: value),
                  validator: (value) => (value?.isEmpty ?? true)
                      ? 'name should not be empty'
                      : null,
                  decoration: InputDecoration(
                    label: Text(t.profileDetail.name.titleCase),
                  ),
                ),
                TextFormField(
                  initialValue: state.profile.url,
                  onChanged: (value) => notifier.setField(url: value),
                  validator: (value) =>
                      (value != null && !isUrl(value)) ? 'invalid url' : null,
                  decoration: InputDecoration(
                    label: Text(t.profileDetail.url.toUpperCase()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const Scaffold(),
    );
  }
}
