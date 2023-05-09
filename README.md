#```````  ]\\]]];
FClash

<p align="center"><img src="assets/images/logo.png" style="border-radius: 50%" width="150px"/></p>


<p align="center" style="font-size: 20px">A Clash Proxy Fronted based on Clash</p>
<p align="center" style="font-size: 16px">Windows / macOS / Linux(amd64/arm64) / Android(Beta) Supported!</p>
<p align="center" style="font-size: 16px">This app mainly focused on all Linux distros, which brings a better experience for linux users/developers.</p>

<p align="center" style="font-size: 8px;">The purpose of the app is to give a learning case how to build an app with Flutter and Golang for full-stack developers. It's STRICTLY Prohibited for any illegal usages, and it's only built for the learning purpose! </p>

[![flutter awesome](https://img.shields.io/badge/Flutter-Awesome-orange)](https://flutterawesome.com/clash-fronted-client-by-flutter-linux-supported/)
[![fclash](https://snapcraft.io/fclash/badge.svg)](https://snapcraft.io/fclash)
[![release](https://img.shields.io/github/v/release/kingtous/fclash)](https://github.com/Kingtous/Fclash/releases)
[![aur](https://img.shields.io/aur/version/fclash)](https://aur.archlinux.org/packages/fclash)
![downloads](https://img.shields.io/github/downloads/kingtous/fclash/total)
![](https://img.shields.io/github/workflow/status/kingtous/fclash/Build%20Debian%20Package)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/1d9c16d3c94f45fc9b4ee95d9c2e6f8c)](https://www.codacy.com/gh/Kingtous/Fclash/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=Kingtous/Fclash&amp;utm_campaign=Badge_Grade)
![commit](https://img.shields.io/github/commit-activity/y/kingtous/fclash)
[![stars](https://img.shields.io/github/stars/kingtous/fclash?style=social)]()
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FKingtous%2FFclash.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2FKingtous%2FFclash?ref=badge_shield)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=kingtous/fclash&type=Date)](https://star-history.com/#kingtous/fclash&Date)

## Install

### Linux

- For Arch/Manjaro users, using AUR
  - `yay -S fclash`
- For Ubuntu/Debian users, download deb files directly
  - [https://github.com/Kingtous/Fclash/releases](https://github.com/Kingtous/Fclash/releases)
- For Redhat/Fedora/OpenSuse users, download rpm files directly.
  - [https://github.com/Kingtous/Fclash/releases](https://github.com/Kingtous/Fclash/releases)
- For other distro users, please to use the snap app.
  - [![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/fclash)

### Windows

Please download .exe setup directly. [https://github.com/Kingtous/Fclash/releases](https://github.com/Kingtous/Fclash/releases)

### MacOS

Please download .dmg setup directly. [https://github.com/Kingtous/Fclash/releases](https://github.com/Kingtous/Fclash/releases)

Note that macOS will treat the `FClash` as an untrusted app, so please go to settings and trust it manually.

### Android

Please download .apk directly. [https://github.com/Kingtous/Fclash/releases](https://github.com/Kingtous/Fclash/releases)

Note: the Android version is looking for contributors.

## Feature

- More features: FClash is based on the full open source [Clash.Meta](https://github.com/MetaCubeX/Clash.Meta).
- Stable: Restart and restore clash status when clash kernel crashs automatically.
- Stable: Monitor Realtime runtime status.
- UI: Beautiful UI built by Flutter.
- UI: Chinese/English localizations supported.
- UI: Light/Dark mode supported.
- Functions: Easy to set/unset as system proxy.
- Functions: Full customized setting, proxy mode, ports, LAN connection, ipv6, etc.
- Functions: Switch yaml configs in realtime.
- Functions: Test delay with each proxy.
- Functions: prebuilt clash kernel and country mmdb.
- Info: Show status on status menu bar.
- Info: Show logs on About page.
- Info: Show download/upload rates on both system app menu bar and in-app menu bar.

## Preview

- Proxy Page
  ![image](https://user-images.githubusercontent.com/39793325/215257245-f712eb8d-3740-4e08-82ac-d14f357f6c48.png)

- Profile Page
  ![image](https://user-images.githubusercontent.com/39793325/215257268-3a3a2859-17be-44d8-8a52-e08d87b52b2a.png)

- Setting Page
  ![image](https://user-images.githubusercontent.com/39793325/215257279-d8b17f26-df46-4c59-80c0-c6e971d343d3.png)

- Logs Page
  ![image](https://user-images.githubusercontent.com/39793325/215257305-b6d52b8e-e94e-4020-b847-1352b3faa029.png)

- Add a subscription page
  ![](docs/images/深度截图_选择区域_20220414110622.png)
  
  - support `RULE-SET` convert (a feature of Clash Premium).
  ![image](https://user-images.githubusercontent.com/39793325/215257349-2e55d8ec-3d73-4244-8ea1-f652a0627086.png)


- About Page
  ![image](https://user-images.githubusercontent.com/39793325/215257313-eb1e3a5b-8c28-41c3-8c6d-038f452d7913.png)

- App system menu bar
  ![](docs/images/Screenshot_20220414_112025.png)

## Install

- Snap Store(comming soon)
  - `sudo snap install fclash --classic`

- Download DEB files, go to [Github Action page](https://github.com/Kingtous/Fclash/actions).

## Build from source

FClash depends `libappindicator3-dev` when compiling.

## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FKingtous%2FFclash.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FKingtous%2FFclash?ref=badge_large)

