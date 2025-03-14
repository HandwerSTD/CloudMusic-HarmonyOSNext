import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import PreferencesUtils from '../common/utils/data/PreferencesUtils';
import { LogUtil } from '@pura/harmony-utils';
import { appInit } from '../common/functions/app/appInit';
import { StorageConstants } from '../common/constants/StorageConstants';
import { ThemeManager } from '../common/utils/theme/ThemeUtils';


export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    // 初始化 Log
    LogUtil.init(0x1010, 'Cloud Music', true)

    // 初始化用户首选项
    await PreferencesUtils.loadPreference(this.context, StorageConstants.USER_PREF)
    await PreferencesUtils.loadPreference(this.context, StorageConstants.SET_PERF)
    await PreferencesUtils.loadPreference(this.context, StorageConstants.QUEUE_PREF)

    // 初始化应用信息
    appInit()
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', async (err, data) => {
      if (err.code) {
        return
      }
      let windowClass: window.Window = windowStage.getMainWindowSync() // 获取应用主窗口
      let lastPrefTheme = await PreferencesUtils.getPreferenceValue(StorageConstants.USER_PREF, StorageConstants.SELECTED_THEME, 0)
      ThemeManager.setTheme(lastPrefTheme)
      // 设置窗口全屏
      // let isLayoutFullScreen = true;
      // windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
      //   console.info('Succeeded in setting the window layout to full-screen mode.');
      // }).catch((err: BusinessError) => {
      //   console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
      // });

      // 获取布局避让遮挡的区域
      let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR
      let avoidArea = windowClass.getWindowAvoidArea(type)
      let bottomRectHeight = avoidArea.bottomRect.height
      AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight)
      type = window.AvoidAreaType.TYPE_SYSTEM
      avoidArea = windowClass.getWindowAvoidArea(type)
      let topRectHeight = avoidArea.topRect.height
      AppStorage.setOrCreate('topRectHeight', topRectHeight)

      // 注册监听函数，动态获取避让区域数据
      windowClass.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          let topRectHeight = data.area.topRect.height
          AppStorage.setOrCreate('topRectHeight', topRectHeight)
        } else if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          let bottomRectHeight = data.area.bottomRect.height
          AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight)
        }
      })
    })
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
