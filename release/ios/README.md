# 🍎 iOS Release Info / iOS 發布說明

##  English

### Why is there no `.ipa` file?
Due to Apple's strict ecosystem restrictions, we cannot provide a direct `.ipa` installation file for public download. Unlike Android, iOS requires apps to be signed with a specific developer certificate, and "sideloading" apps is not directly supported without a computer.

### How to Install
To run **Mood Diary** on your iPhone or iPad, you must compile the source code yourself using a **Mac**.

#### Prerequisites
1.  **Hardware**: A Mac computer (MacBook, iMac, or Mac mini).
2.  **Software**: 
    * Xcode (Download from Mac App Store).
    * Flutter SDK installed.
    * CocoaPods installed.

#### Installation Steps
1.  **Prepare the Code**:
    Navigate to the project directory:
    ```bash
    cd flutter_app1
    flutter pub get
    cd ios && pod install && cd ..
    ```

2.  **Configure Signing (Important)**:
    * Open `ios/Runner.xcworkspace` with Xcode.
    * Select the **Runner** project in the left navigator.
    * Go to the **Signing & Capabilities** tab.
    * Under **Team**, select your personal Apple ID.
    * Change the **Bundle Identifier** to something unique (e.g., `com.yourname.mooddiary`).

3.  **Run on Device**:
    * Connect your iPhone to your Mac via USB.
    * Select your device in Xcode's top bar.
    * Click the **Play (▶️)** button to build and install.
    * *Note: On your iPhone, go to **Settings > General > VPN & Device Management** to trust your developer certificate.*

---

## 🇹🇼 繁體中文

### 為什麼這裡沒有 `.ipa` 檔案？
受限於 Apple 的生態系統限制，我們無法像 Android 一樣直接提供安裝檔供下載。iOS App 必須經過開發者憑證簽章才能安裝，且無法直接將檔案放入手機執行。

### 如何安裝
若您希望在 iPhone 或 iPad 上使用 **Mood Diary**，您必須擁有一台 **Mac 電腦** 並自行編譯原始碼。

#### 準備工作
1.  **硬體**: Mac 電腦 (MacBook, iMac, Mac mini)。
2.  **軟體**: 
    * Xcode (請至 Mac App Store 免費下載)。
    * 已安裝 Flutter SDK。
    * 已安裝 CocoaPods。

#### 安裝步驟
1.  **準備環境**:
    進入專案資料夾並安裝依賴：
    ```bash
    cd flutter_app1
    flutter pub get
    cd ios
    pod install
    cd ..
    ```

2.  **Xcode 簽章設定 (必要)**:
    * 使用 Xcode 開啟 `ios/Runner.xcworkspace` 檔案。
    * 點擊左側導覽列最上方的 **Runner** (藍色圖示)。
    * 切換到 **Signing & Capabilities** 分頁。
    * 在 **Team** 下拉選單中，登入並選擇您的 Apple ID。
    * 修改 **Bundle Identifier** 為一個唯一的名稱 (例如 `com.yourname.mooddiary`)。

3.  **安裝至實機**:
    * 使用傳輸線將 iPhone 連接至 Mac。
    * 在 Xcode 頂部選擇您的手機裝置。
    * 點擊 **Play (▶️)** 按鈕開始編譯與安裝。
    * *注意：首次安裝後，請在 iPhone 上前往 **設定 > 一般 > VPN 與裝置管理**，信任您的開發者憑證即可開啟 App。*
