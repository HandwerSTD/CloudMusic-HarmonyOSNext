import { CircleImageButton } from '../buttons/CircleButton'
import { SetApiSheet } from '../sheets/CustomApiUrlSheet'
import Constants from '../../common/constants/Constants'

/**
 * 自定义API地址
 */
@Component
export struct SetApiUrl {
  @State isShowSheet: boolean = false
  build() {
    Column({ space: 5 }) {
      Row() {
        Row({ space: 5 }) {
          Text('API服务器与Cookie设置').LeftText()
        }
        CircleImageButton({ imgUrl: $r('app.media.ic_public_arrow_right'), })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .bindSheet(this.isShowSheet, this.Sheet(), {
        backgroundColor: $r('sys.color.background_secondary'),
        preferType: SheetType.CENTER,
        detents: [SheetSize.MEDIUM, SheetSize.LARGE],
        dragBar: true,
        onDisappear: () => {
          this.isShowSheet = false
        }
      })
      .onClick(() => {
        this.isShowSheet = !this.isShowSheet
      })
    }
    .width('100%')
  }

  @Builder
  Sheet() {
    SetApiSheet({ isShowSheet: this.isShowSheet })
  }
}

@Extend(Text) function LeftText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
}