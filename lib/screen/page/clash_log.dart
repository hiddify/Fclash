import 'dart:async';
import 'dart:convert';

import 'package:clashify/service/clash_service.dart';
import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';

class ClashLog extends StatefulWidget {
  const ClashLog({Key? key}) : super(key: key);

  @override
  State<ClashLog> createState() => _ClashLogState();
}

class _ClashLogState extends State<ClashLog> {
  final logs = RxList<String>();
  final buffer = List<String>.empty(growable: true);
  late Timer? _timer;
  final connected = false.obs;
  static const logMaxLen = 100;
  StreamSubscription<dynamic>? streamSubscription;

  @override
  void initState() {
    super.initState();
    tryConnect();
  }

  void tryConnect() {
    Get.find<ClashService>().startLogging();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (buffer.isNotEmpty) {
        logs.insertAll(0, buffer.reversed);
        buffer.clear();
        if (logs.length > logMaxLen) {
          logs.value = logs.sublist(0, logMaxLen);
        }
      }
    });
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (streamSubscription == null) {
        if (Get.find<ClashService>().logStream == null) {
          printInfo(info: 'clash log stream not opened');
        }
        streamSubscription =
            Get.find<ClashService>().logStream?.listen((event) {
          String logStr = event;
          buffer.add(logStr);
          Get.printInfo(info: 'Log widget: $logStr');
        });
        if (streamSubscription == null) {
          printInfo(info: 'log service retry');
        } else {
          printInfo(info: 'log service connected'.tr);
          connected.value = true;
        }
      } else {
        connected.value = true;
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    Get.printInfo(info: 'log dispose');
    Get.find<ClashService>().stopLog();
    streamSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Obx(
        //   () => BrnNoticeBar(
        //     content: connected.value
        //         ? 'Log is running. Any logs will show below.'.tr
        //         : "No Logs currently / Connecting to clash log daemon...".tr,
        //     showLeftIcon: true,
        //     showRightIcon: true,
        //     noticeStyle: connected.value
        //         ? NoticeStyles.succeedWithArrow
        //         : NoticeStyles.runningWithArrow,
        //   ),
        // ),
        Expanded(
          child: Obx(() => ListView.builder(
                itemBuilder: (cxt, index) {
                  return Padding(
                    key: ValueKey(logs[index]),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: buildLogItem(logs[index]),
                  );
                },
                itemCount: logs.length,
              )),
        ),
      ],
    );
  }

  Widget buildLogItem(String log) {
    final json = jsonDecode(log) ?? {};
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      margin: EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.grey.shade200),
      child: Stack(
        children: [
          Text(
            json['Payload'] ?? "",
            style: const TextStyle(fontFamily: 'nssc'),
          ),
          Align(
            alignment: Alignment.topRight,
            child: BrnStateTag(tagText: '${json['LogLevel']}'),
          )
        ],
      ),
    );
  }
}
