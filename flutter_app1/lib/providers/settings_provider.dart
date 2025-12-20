import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 定義設定的資料結構
class AppSettings {
  final bool isRemoteMode;
  final String serverUrl;

  AppSettings({
    this.isRemoteMode = false,
    this.serverUrl = "http://192.168.1.100:8000",
  });

  AppSettings copyWith({bool? isRemoteMode, String? serverUrl}) {
    return AppSettings(
      isRemoteMode: isRemoteMode ?? this.isRemoteMode,
      serverUrl: serverUrl ?? this.serverUrl,
    );
  }
}

// StateNotifier 用來管理讀寫邏輯
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings()) {
    _loadSettings();
  }

  // 載入設定
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isRemote = prefs.getBool('isRemoteMode') ?? false;
    final url = prefs.getString('serverUrl') ?? "http://192.168.1.100:8000";
    state = AppSettings(isRemoteMode: isRemote, serverUrl: url);
  }

  // 切換模式
  Future<void> setRemoteMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemoteMode', value);
    state = state.copyWith(isRemoteMode: value);
  }

  // 更新網址
  Future<void> setServerUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverUrl', value);
    state = state.copyWith(serverUrl: value);
  }
}

// 建立 Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});
