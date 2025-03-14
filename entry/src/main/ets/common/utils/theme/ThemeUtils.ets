import { CustomColors, CustomTheme } from '@kit.ArkUI'

export class AppColors implements CustomColors {
  //自定义主题色
  brand: ResourceColor = '#FF6A6A';
}

export class AppTheme implements CustomTheme {
  public colors: AppColors = new AppColors()
}

export let gAppTheme: CustomTheme = new AppTheme()