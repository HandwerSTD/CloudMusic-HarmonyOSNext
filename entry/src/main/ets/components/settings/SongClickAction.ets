import { CircleImageButton } from '../buttons/CircleButton'
import Constants from '../../common/constants/Constants'
import { SongClickActionSheet } from '../sheets/SongClickActionSheet'

/**
 * 歌曲卡片单击操作
 */
@Component
export struct SongClickAction {
  @State isShowSheet: boolean = false
  build() {
    Column({ space: 5 }) {
      Row() {
        Row({ space: 5 }) {
          Text('歌曲卡片点击模式').LeftText()
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
    SongClickActionSheet({ isShowSheet: this.isShowSheet })
  }
}

@Extend(Text) function LeftText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
}