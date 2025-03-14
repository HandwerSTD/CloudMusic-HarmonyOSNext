import { CustomColors, CustomTheme, ThemeControl } from '@kit.ArkUI'

export class AppColors implements CustomColors {
}

export class AppTheme implements CustomTheme {
  public colors: AppColors = new AppColors()
  constructor(colorConfig: CustomColors) {
    this.colors = colorConfig
  }
}

export let gAppTheme: CustomTheme = new AppTheme({
  brand: '#FF6A6A'
})

export const themeColors = ['#ff0a59f7', '#ff6a6a']

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
  }
}