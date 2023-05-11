enum RouterMode {
  rule,
  global,
  direct,
  script;
}

enum LogLevel { info, warning, error, debug, silent }

enum ProxyType {
  direct,
  reject,
  shadowSocks,
  shadowSocksR,
  snell,
  socks5,
  http,
  vmess,
  trojan,
  relay,
  selector,
  fallback,
  urlTest,
  loadBalance,
  unknown,
}
