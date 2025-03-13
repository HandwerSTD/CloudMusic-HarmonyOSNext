import { PlayQueue } from "../../../common/entities/PlayQueue"
import { PlayQueueSheet } from "../../sheets/PlayQueueSheet"

@Component
export struct PlayQueueButton {
  @StorageProp('PlayQueue') queue: Array<PlayQueue> = []
  @StorageProp('currentQueueIndex') currentQueueIndex: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @State isShow: boolean = false
  @State imgWidth: number = 30
  @State imgColor: Color | ResourceStr = $r('app.color.reverse')

  build() {
    Button(){
      Image($r('app.media.ic_public_view_list_filled'))
        .width(this.imgWidth)
        .fillColor(this.imgColor)
        .draggable(false)
    }
    .stateEffect(false)
    .backgroundColor(Color.Transparent)
    .onClick(() => { this.isShow = !this.isShow })
    .bindSheet(this.isShow, this.QueueComponent(), {
      preferType: SheetType.BOTTOM,
      detents: ['70%', '100%'],
      dragBar: false,
      showClose: false,
      backgroundColor: $r('sys.color.background_secondary'),
      onDisappear: () => { this.isShow = false }
    })
  }

  @Builder
  QueueComponent() {
    PlayQueueSheet({ isShow: this.isShow })
  }
}