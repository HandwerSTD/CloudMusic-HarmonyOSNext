import Constants from '../../common/constants/Constants';

/**
 * 登录页面
 */

@Component
export struct LoginPage {
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    NavDestination() {
      Stack() {
        Column({ space: 30 }) {
          Text('登录账号')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.reverse'))
            .padding({ bottom: 10 })

          Row() {
            // 网页登录
            LoginTypeButton({
              icon: $r('app.media.ic_celiakeyboard_default'),
              bgColor: Color.Orange,
              text: '网页登录',
              ClickOp: () => {
                this.pageInfos.replacePathByName('WebLogin', null)
              }
            })

            // 二维码登录
            LoginTypeButton({
              icon: $r('app.media.ic_public_input_code'),
              bgColor: Color.Red,
              text: '二维码登录',
              ClickOp: () => {
                this.pageInfos.replacePathByName('QrCodeLogin', null)
              }
            })
          }
          .width('80%')
          .justifyContent(FlexAlign.SpaceEvenly)
        }
        .height('100%')
        .width('100%')
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .width('100%')
      .height('100%')
      .padding({ top: Constants.PADDING_EDGE_TEXT })
    }
    .title('登录')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

@Component struct LoginTypeButton {
  @State icon: string | ResourceStr = ''
  @State bgColor: string | Color | ResourceStr = Color.Transparent
  @State text: string = ''
  ClickOp: () => void = () => {}

  build() {
    Column({ space: 15 }) {
      Button() {
        Image(this.icon)
          .fillColor(Color.White)
          .height('60%')
      }
      .backgroundColor(this.bgColor)
      .aspectRatio(1)
      .width('70%')
      .onClick(() => {
        this.ClickOp()
      })

      Text(this.text)
        .fontColor($r('app.color.reverse'))
        .fontSize(14)
    }
    .aspectRatio(1)
    .width(100)
    .backgroundColor(Color.Transparent)
  }
}
