import 'package:clashify/screen/controller/theme_controller.dart';
import 'package:clashify/service/clash_service.dart';
import 'package:flutter/material.dart';
import 'package:kommon/kommon.dart';

class Proxy extends StatefulWidget {
  const Proxy({Key? key}) : super(key: key);

  @override
  State<Proxy> createState() => _ProxyState();
}

class _ProxyState extends State<Proxy> {
  ClashService get service => Get.find<ClashService>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Opacity(
              opacity: 0.4,
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    "assets/images/network.png",
                    width: 300,
                  ))),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [Expanded(child: buildTiles())],
          ),
        ],
      ),
    );
  }

  Widget buildTiles() {
    final c = Get.find<ClashService>().proxies;

    if (c.value == null) {
      return BrnAbnormalStateWidget(
        title: 'No Proxies'.tr,
        content: 'Select a profile to show proxies.',
      );
    }
    Map<String, dynamic> maps = c.value['proxies'] ?? {};
    printInfo(info: 'proxies: ${maps.toString()}');

    return Obx(
      () {
        var selectors = maps.keys.where((proxy) {
          return maps[proxy]['type'] == 'Selector';
        }).toList(growable: false);
        final mode =
            Get.find<ClashService>().configEntity.value?.mode ?? "direct";
        if (mode == "direct") {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/rocket.png",
                  width: 100.0,
                  fit: BoxFit.cover,
                ),
                Text(
                  "direct".tr,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        } else if (mode == "global") {
// global
          selectors = selectors
              .where((sel) => maps[sel]['name'].toLowerCase() == 'global')
              .toList();
        }
        return ListView.builder(
          itemBuilder: (context, index) {
            final selectorName = selectors[index];
            return buildSelector(maps[selectorName]);
          },
          itemCount: selectors.length,
        );
      },
    );
  }

  Widget buildSelector(Map<String, dynamic> selector) {
    final proxyName = selector['name'];
    final isExpanded = false.obs;
    const headStyle = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);
    final body = Column(
      children: [
        Row(
          children: [
            Expanded(child: buildSelectItem(selector)),
          ],
        ).paddingSymmetric(horizontal: 4.0),
        // for debug
        // kDebugMode ? BrnExpandableText(text: selector.toString(),maxLines: 1,textStyle: TextStyle(fontSize: 20,
        // color: Colors.black),) : Offstage(),
      ],
    );
    return Stack(
      children: [
        Obx(
          () => Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0), color: Colors.blue),
            child: ExpansionPanelList(
              elevation: 0,
              key: ValueKey(proxyName),
              expansionCallback: (index, expand) {
                isExpanded.value = !expand;
              },
              children: [
                ExpansionPanel(
                  // title: proxyName ?? "",
                  // subtitle: selector['now'],
                  canTapOnHeader: true,
                  isExpanded: isExpanded.value,
                  headerBuilder: (context, isExpanded) => Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    proxyName ?? "",
                                    style: headStyle,
                                  ).marginOnly(bottom: 4.0),
                                ),
                              ],
                            ),
                            Text(selector['now'])
                          ],
                        ),
                      ),
                    ],
                  ).paddingAll(8.0),
                  // backgroundColor: Get.find<ThemeController>().isDarkMode.value
                  //     ? Colors.black12
                  //     : Colors.white,
                  body: body,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
              onPressed: () async {
                List<dynamic> allItem = selector['all'];
                Future.delayed(Duration.zero, () {
                  BrnToast.show('Start test, please wait.'.tr, context);
                });
                await Get.find<ClashService>().testAllProxies(allItem);
                Future.delayed(Duration.zero, () {
                  BrnToast.show('Test complete.'.tr, context);
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Test Delay".tr,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )),
        ).paddingAll(4.0)
      ],
    );
  }

  Widget buildSelectItem(Map<String, dynamic> selector) {
    final selectName = selector['name'];
    final now = selector['now'];
    List<dynamic> allItems = selector['all'];
    return Obx(
      () {
        var index = 0;
        return Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: allItems.map((itemName) {
            final delayInMs = service.proxyStatus[itemName.toString()] ?? 0;
            return SizedBox(
              width: 250,
              height: 75,
              child: Card(
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Container(
                          width: 12,
                          height: 75,
                          decoration: BoxDecoration(
                              color: delayInMs < 0
                                  ? Colors.red
                                  : delayInMs == 0
                                      ? Colors.grey
                                      : delayInMs <= 100
                                          ? Colors.green
                                          : delayInMs <= 500
                                              ? Colors.lightBlue
                                              : delayInMs <= 1000
                                                  ? Colors.blue
                                                  : Colors.orange,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  bottomLeft: Radius.circular(5)))),
                      Expanded(
                        child: BrnRadioButton(
                            radioIndex: index++,
                            behavior: HitTestBehavior.opaque,
                            mainAxisSize: MainAxisSize.max,
                            onValueChangedAtIndex: (newIndex, value) {
                              final res = Get.find<ClashService>()
                                  .changeProxy(selectName, allItems[newIndex]);
                              if (res) {
                                BrnToast.show(
                                    'switch to name success.'.trParams(
                                        {"name": "${allItems[newIndex]}"}),
                                    context);
                              } else {
                                BrnToast.show(
                                    'switch to name failed.'.trParams(
                                        {"name": "${allItems[newIndex]}"}),
                                    context);
                              }
                              Future.delayed(Duration.zero, () {
                                setState(() {});
                              });
                            },
                            isSelected: itemName == now,
                            child: Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Tooltip(
                                      message: itemName.toString(),
                                      child: Text(
                                        itemName,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w400),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ).marginOnly(left: 4.0),
                                  ),
                                  // ping
                                  Text(
                                    delayInMs == 0 ? '' : '${delayInMs}ms',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ).marginOnly(right: 4.0)
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}
