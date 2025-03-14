import { CustomColors, CustomTheme, ThemeControl } from '@kit.ArkUI'
import { StorageConstants } from '../../constants/StorageConstants'
import PreferencesUtils from '../data/PreferencesUtils';

export class AppColors implements CustomColors {
}

export class AppTheme implements CustomTheme {
  public colors: AppColors = new AppColors()
  constructor(colorConfig: CustomColors) {
    this.colors = colorConfig
  }
}

export let gAppTheme: CustomTheme = new AppTheme({
  brand: $r('app.color.app_red')
})

export const themeColors = [$r('app.color.app_red'),
   $r('app.color.CosmicBlue') ,
   $r('app.color.NavyBlue') ,
   $r('app.color.SkyBlue') ,
   $r('app.color.CyanGreen') ,
   $r('app.color.GrassGreen') ,
   $r('app.color.LilacPurple') ,
   $r('app.color.StrawberryPink') ,
   $r('app.color.CrimsonRed') ,
   $r('app.color.Orange') ]

PersistentStorage.persistProp(StorageConstants.SELECTED_THEME, 0)

@ObservedV2
export class ThemeManager {
  static singleton_: ThemeManager;
  @Trace appTheme: CustomTheme = gAppTheme
  nowUsedThemeIndex: number = 0
  static getSingleton() {
    if(!ThemeManager.singleton_) {
      ThemeManager.singleton_ = new ThemeManager();
    };
    return ThemeManager.singleton_
  }
  static getTheme() {
    if(!ThemeManager.singleton_) {
      ThemeManager.singleton_ = new ThemeManager();
    };
    return ThemeManager.singleton_.appTheme;
  }
  static setTheme(index: number) {
    let st = ThemeManager.getSingleton()
    st.appTheme = new AppTheme({
      brand: themeColors[index]
    })
    ThemeControl.setDefaultTheme(st.appTheme)
    st.nowUsedThemeIndex = index
    PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.SELECTED_THEME, index)
  }
}